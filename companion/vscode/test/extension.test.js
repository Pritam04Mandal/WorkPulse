'use strict';

// Exercises the extension against a stand-in for the VS Code API.

const assert = require('node:assert');
const fs = require('node:fs');
const Module = require('node:module');
const os = require('node:os');
const path = require('node:path');
const { beforeEach, test } = require('node:test');

const handlers = {};
const on = (name) => (handler) => {
  handlers[name] = handler;
  return { dispose() {} };
};
const folder = { name: 'my-project', uri: { scheme: 'other', toString: () => 'f' } };
const stub = {
  StatusBarAlignment: { Right: 2 },
  commands: { registerCommand: () => ({ dispose() {} }) },
  window: {
    state: { focused: true },
    activeTextEditor: undefined,
    createStatusBarItem: () => ({ show() {}, dispose() {} }),
    onDidChangeActiveTextEditor: on('active'),
    onDidChangeTextEditorSelection: on('selection'),
    onDidChangeWindowState: on('state'),
  },
  workspace: {
    getWorkspaceFolder: (uri) => (uri.scheme === 'file' ? folder : undefined),
    onDidChangeTextDocument: on('change'),
    onDidSaveTextDocument: on('save'),
  },
};

const originalLoad = Module._load;
Module._load = function load(request, ...rest) {
  return request === 'vscode' ? stub : originalLoad.call(this, request, ...rest);
};

process.env.WORKPULSE_HOME = fs.mkdtempSync(path.join(os.tmpdir(), 'wp-ext-'));
const extension = require('../src/extension');
const queueDir = path.join(process.env.WORKPULSE_HOME, 'vscode');

const secretContent = 'const password = "hunter2"';
const document = {
  uri: { scheme: 'file', fsPath: '/home/me/secret-folder/private.txt' },
  getText: () => {
    throw new Error('the extension must never read document text');
  },
  fileName: '/home/me/secret-folder/private.txt',
};

function savedSegments() {
  if (!fs.existsSync(queueDir)) return [];
  return fs
    .readdirSync(queueDir)
    .flatMap((f) => JSON.parse(fs.readFileSync(path.join(queueDir, f), 'utf8')));
}

const edit = () => ({
  document,
  contentChanges: [{ text: secretContent }],
});

async function pause() {
  await new Promise((resolve) => setTimeout(resolve, 15));
}

beforeEach(() => fs.rmSync(queueDir, { recursive: true, force: true }));

test('records edits without touching their content', async () => {
  const context = { subscriptions: [] };
  extension.activate(context);

  handlers.change(edit());
  await pause();
  handlers.change(edit());
  await extension.deactivate();

  const saved = savedSegments();
  assert.strictEqual(saved.length, 1);
  assert.strictEqual(saved[0].project, 'my-project');
  assert.ok(saved[0].end > saved[0].start);

  const onDisk = JSON.stringify(saved);
  assert.ok(!onDisk.includes('hunter2'));
  assert.ok(!onDisk.includes('private.txt'));
  assert.ok(!onDisk.includes('secret-folder'));
  context.subscriptions.forEach((s) => s.dispose());
});

test('ignores activity while another window has focus', async () => {
  const context = { subscriptions: [] };
  extension.activate(context);

  stub.window.state.focused = false;
  handlers.change(edit());
  await pause();
  handlers.change(edit());
  await extension.deactivate();

  assert.deepStrictEqual(savedSegments(), []);
  stub.window.state.focused = true;
  context.subscriptions.forEach((s) => s.dispose());
});

test('ignores panels that are not files in the workspace', async () => {
  const context = { subscriptions: [] };
  extension.activate(context);
  const output = { uri: { scheme: 'output' } };

  handlers.change({ document: output, contentChanges: [{ text: 'x' }] });
  await pause();
  handlers.change({ document: output, contentChanges: [{ text: 'x' }] });
  await extension.deactivate();

  assert.deepStrictEqual(savedSegments(), []);
  context.subscriptions.forEach((s) => s.dispose());
});
