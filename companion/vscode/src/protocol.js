'use strict';

const crypto = require('crypto');
const fs = require('fs');
const http = require('http');
const os = require('os');
const path = require('path');

function stateDir() {
  return process.env.WORKPULSE_HOME || path.join(os.homedir(), '.workpulse');
}

function configFile() {
  return path.join(stateDir(), 'config.json');
}

/** Shared with the Claude Code script, so a computer only pairs once. */
function readConfig() {
  try {
    const config = JSON.parse(fs.readFileSync(configFile(), 'utf8'));
    return config.address && config.device_id && config.secret ? config : null;
  } catch {
    return null;
  }
}

function writePrivate(file, contents) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const temporary = `${file}.${process.pid}.tmp`;
  fs.writeFileSync(temporary, contents, { mode: 0o600 });
  fs.renameSync(temporary, file);
}

function post(address, route, body, headers, timeoutMs) {
  const separator = address.lastIndexOf(':');
  return new Promise((resolve, reject) => {
    const request = http.request(
      {
        host: address.slice(0, separator),
        port: Number(address.slice(separator + 1)),
        path: route,
        method: 'POST',
        timeout: timeoutMs,
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(body),
          ...headers,
        },
      },
      (response) => {
        const chunks = [];
        response.on('data', (chunk) => chunks.push(chunk));
        response.on('end', () => {
          let json = null;
          try {
            json = JSON.parse(Buffer.concat(chunks).toString('utf8'));
          } catch {
            // Status alone decides what happens next.
          }
          resolve({ status: response.statusCode, json });
        });
      },
    );
    request.on('timeout', () => request.destroy(new Error('timed out')));
    request.on('error', reject);
    request.end(body);
  });
}

function hmacHex(key, message) {
  return crypto.createHmac('sha256', key).update(message, 'utf8').digest('hex');
}

// The phone hashes and signs big numbers as bare lowercase hex.
function bareHex(hex) {
  return BigInt(`0x${hex}`).toString(16);
}

function hexBuffer(hex) {
  return Buffer.from(hex.length % 2 ? `0${hex}` : hex, 'hex');
}

class PairingError extends Error {}

/** Same exchange as the phone's pairing_crypto.dart. */
async function pair(address, code, name) {
  const exchange = crypto.getDiffieHellman('modp14');
  exchange.generateKeys();
  const clientPublic = bareHex(exchange.getPublicKey('hex'));

  const call = async (route, payload) => {
    const reply = await post(address, route, JSON.stringify(payload), {}, 8000);
    if (reply.status === 403) {
      throw new PairingError('The code was wrong or has expired.');
    }
    if (reply.status !== 200 || !reply.json) {
      throw new PairingError(`The phone refused the request (${reply.status}).`);
    }
    return reply.json;
  };

  const { server_public: serverPublic } = await call('/v1/pair/start', {
    name: name.slice(0, 60) || 'Computer',
    client_public: clientPublic,
  });
  const shared = bareHex(
    exchange.computeSecret(hexBuffer(serverPublic)).toString('hex'),
  );
  const key = crypto.createHash('sha256').update(shared, 'utf8').digest();
  const transcript = `${code}|${clientPublic}|${serverPublic}`;

  const finished = await call('/v1/pair/finish', {
    mac: hmacHex(key, `client|${transcript}`),
  });
  const expected = Buffer.from(hmacHex(key, `server|${transcript}`));
  const received = Buffer.from(String(finished.mac));
  if (
    expected.length !== received.length ||
    !crypto.timingSafeEqual(expected, received)
  ) {
    throw new PairingError('The phone could not prove it knows the code.');
  }

  writePrivate(
    configFile(),
    JSON.stringify({
      address,
      device_id: finished.device_id,
      secret: hmacHex(key, `secret|${code}`),
    }),
  );
}

/** Returns 'sent', 'unpaired' (the phone refused this computer) or 'away'. */
async function sendSegments(config, segments) {
  const body = JSON.stringify({ segments });
  const timestamp = String(Date.now());
  try {
    const reply = await post(
      config.address,
      '/v1/events',
      body,
      {
        'X-WorkPulse-Device': config.device_id,
        'X-WorkPulse-Timestamp': timestamp,
        'X-WorkPulse-Signature': hmacHex(
          config.secret,
          `${timestamp}.${body}`,
        ),
      },
      3000,
    );
    if (reply.status === 200) return 'sent';
    return reply.status === 401 ? 'unpaired' : 'away';
  } catch {
    return 'away';
  }
}

module.exports = {
  PairingError,
  pair,
  readConfig,
  sendSegments,
  stateDir,
  writePrivate,
};
