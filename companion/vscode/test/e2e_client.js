'use strict';

// Driven by test/features/companion/companion_e2e_test.dart, so the Node
// protocol code is checked against the phone's real receiver.

const protocol = require('../src/protocol');

async function main() {
  const [command, ...args] = process.argv.slice(2);
  if (command === 'pair') {
    await protocol.pair(args[0], args[1], 'e2e-computer');
    return 0;
  }
  if (command === 'send') {
    const [project, start, end] = args;
    const result = await protocol.sendSegments(protocol.readConfig(), [
      {
        id: 'vscode.e2e.1',
        kind: 'vscode',
        project,
        repo: 'me/app',
        start: Number(start),
        end: Number(end),
      },
    ]);
    process.stdout.write(result);
    return 0;
  }
  return 2;
}

main().then(
  (code) => process.exit(code),
  (error) => {
    process.stderr.write(String(error.message));
    process.exit(1);
  },
);
