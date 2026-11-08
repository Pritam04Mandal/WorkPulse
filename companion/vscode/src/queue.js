'use strict';

const fs = require('fs');
const path = require('path');
const { stateDir, writePrivate } = require('./protocol');

const KEEP_MS = 7 * 24 * 60 * 60 * 1000;
// A window that has been quiet this long has probably closed.
const ORPHAN_AFTER_MS = 2 * 60 * 1000;

function directory() {
  return path.join(stateDir(), 'vscode');
}

/** Each window keeps its own file, so windows never overwrite each other. */
function save(sessionId, segments) {
  const file = path.join(directory(), `${sessionId}.json`);
  if (segments.length === 0) {
    fs.rmSync(file, { force: true });
    return;
  }
  writePrivate(file, JSON.stringify(segments));
}

/**
 * Takes over what closed windows left unsent. If a window turns out to be
 * alive it just sends the same segments again, which the phone treats as one.
 */
function adoptOrphans(sessionId, now) {
  const adopted = [];
  let names;
  try {
    names = fs.readdirSync(directory());
  } catch {
    return adopted;
  }
  for (const name of names) {
    if (!name.endsWith('.json') || name === `${sessionId}.json`) continue;
    const file = path.join(directory(), name);
    try {
      if (now - fs.statSync(file).mtimeMs < ORPHAN_AFTER_MS) continue;
      const segments = JSON.parse(fs.readFileSync(file, 'utf8'));
      adopted.push(...segments.filter((s) => now - s.end <= KEEP_MS));
      fs.rmSync(file, { force: true });
    } catch {
      // Unreadable leftovers aren't worth interrupting anyone over.
    }
  }
  return adopted;
}

module.exports = { adoptOrphans, save };
