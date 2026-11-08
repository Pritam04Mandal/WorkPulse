'use strict';

const { execFile } = require('child_process');
const crypto = require('crypto');
const os = require('os');
const vscode = require('vscode');

const protocol = require('./protocol');
const queue = require('./queue');
const { Tracker, parseRepository } = require('./tracker');

const FLUSH_EVERY_MS = 30 * 1000;
const TRACKED_SCHEMES = new Set(['file', 'vscode-remote', 'vscode-vfs']);

let tracker;
let sessionId;
let statusItem;
let flushing = false;
let lastFolder = null;
const repositories = new Map();

function repositoryFor(folder) {
  const key = folder.uri.toString();
  if (!repositories.has(key)) {
    repositories.set(key, null);
    if (folder.uri.scheme === 'file') {
      execFile(
        'git',
        ['config', '--get', 'remote.origin.url'],
        { cwd: folder.uri.fsPath, timeout: 2000 },
        (error, stdout) => {
          if (!error) repositories.set(key, parseRepository(stdout));
        },
      );
    }
  }
  return repositories.get(key);
}

/** Only ever looks at which workspace folder is in use, never at content. */
function recordActivity(document) {
  if (!vscode.window.state.focused) return;
  if (!document || !TRACKED_SCHEMES.has(document.uri.scheme)) return;
  const folder = vscode.workspace.getWorkspaceFolder(document.uri);
  if (!folder) return;
  lastFolder = folder;
  tracker.heartbeat(folder.name, repositoryFor(folder), Date.now());
}

function recordTerminalActivity() {
  if (vscode.window.state.focused && lastFolder) {
    tracker.heartbeat(lastFolder.name, repositoryFor(lastFolder), Date.now());
  }
}

function showStatus(text, tooltip) {
  statusItem.text = `$(pulse) ${text}`;
  statusItem.tooltip = tooltip;
}

async function flush() {
  if (flushing) return;
  flushing = true;
  try {
    const config = protocol.readConfig();
    if (!config) {
      showStatus('Pair', 'WorkPulse: click to pair with your phone');
      queue.save(sessionId, tracker.snapshot());
      return;
    }
    const batch = tracker.batch();
    if (batch.length > 0) {
      const result = await protocol.sendSegments(config, batch);
      if (result === 'sent') {
        tracker.acknowledge(batch);
        showStatus('WorkPulse', 'Sending coding time to your phone');
      } else if (result === 'unpaired') {
        showStatus('Pair', 'Your phone no longer recognises this computer');
      } else {
        showStatus(
          `WorkPulse (${tracker.snapshot().length})`,
          'Waiting for the WorkPulse app to be open on your phone',
        );
      }
    }
    queue.save(sessionId, tracker.snapshot());
  } catch {
    // Tracking must never get in the way of the editor.
  } finally {
    flushing = false;
  }
}

async function pairCommand() {
  const address = await vscode.window.showInputBox({
    title: 'WorkPulse: Pair with phone',
    prompt: 'Address shown in the WorkPulse app',
    placeHolder: '192.168.1.20:47831',
    ignoreFocusOut: true,
    validateInput: (value) =>
      /^[^\s:]+:\d+$/.test(value.trim()) ? null : 'Use the form address:port',
  });
  if (!address) return;
  const code = await vscode.window.showInputBox({
    title: 'WorkPulse: Pair with phone',
    prompt: 'Pairing code shown in the WorkPulse app',
    ignoreFocusOut: true,
  });
  if (!code) return;
  try {
    await protocol.pair(address.trim(), code.trim(), os.hostname());
    vscode.window.showInformationMessage('WorkPulse: paired with your phone.');
    await flush();
  } catch (error) {
    vscode.window.showErrorMessage(
      error instanceof protocol.PairingError
        ? `WorkPulse: ${error.message}`
        : 'WorkPulse: couldn’t reach the phone. Keep the app open on the ' +
            'pairing screen, on the same Wi-Fi as this computer.',
    );
  }
}

function statusCommand() {
  const config = protocol.readConfig();
  if (!config) {
    pairCommand();
    return;
  }
  vscode.window.showInformationMessage(
    `WorkPulse: paired with ${config.address}. ` +
      `${tracker.snapshot().length} update(s) waiting to send.`,
  );
}

function activate(context) {
  sessionId = crypto.randomUUID().replace(/-/g, '');
  tracker = new Tracker(sessionId);
  tracker.adopt(queue.adoptOrphans(sessionId, Date.now()));

  statusItem = vscode.window.createStatusBarItem(
    vscode.StatusBarAlignment.Right,
    0,
  );
  statusItem.command = 'workpulse.status';
  showStatus('WorkPulse', 'WorkPulse');
  statusItem.show();

  const { window, workspace, commands } = vscode;
  const timer = setInterval(flush, FLUSH_EVERY_MS);
  context.subscriptions.push(
    statusItem,
    { dispose: () => clearInterval(timer) },
    commands.registerCommand('workpulse.pair', pairCommand),
    commands.registerCommand('workpulse.status', statusCommand),
    workspace.onDidChangeTextDocument((event) => {
      if (event.contentChanges.length > 0) recordActivity(event.document);
    }),
    workspace.onDidSaveTextDocument(recordActivity),
    window.onDidChangeActiveTextEditor((editor) => {
      if (editor) recordActivity(editor.document);
    }),
    window.onDidChangeTextEditorSelection((event) =>
      recordActivity(event.textEditor.document),
    ),
    window.onDidChangeWindowState((state) => {
      if (state.focused && window.activeTextEditor) {
        recordActivity(window.activeTextEditor.document);
      }
    }),
  );
  // Newer editors only.
  if (window.onDidStartTerminalShellExecution) {
    context.subscriptions.push(
      window.onDidStartTerminalShellExecution(recordTerminalActivity),
    );
  }

  if (window.activeTextEditor) recordActivity(window.activeTextEditor.document);
  flush();
}

async function deactivate() {
  await flush();
}

module.exports = { activate, deactivate };
