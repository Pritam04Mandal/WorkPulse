'use strict';

const assert = require('node:assert');
const { test } = require('node:test');
const {
  Tracker,
  parseRepository,
  IDLE_GAP_MS,
  MAX_SEGMENT_MS,
} = require('../src/tracker');

test('continuous work is one segment that grows', () => {
  const tracker = new Tracker('s');
  tracker.heartbeat('app', 'me/app', 1000);
  tracker.heartbeat('app', 'me/app', 61000);

  const [segment] = tracker.batch();
  assert.strictEqual(tracker.batch().length, 1);
  assert.strictEqual(segment.start, 1000);
  assert.strictEqual(segment.end, 61000);
  assert.strictEqual(segment.kind, 'vscode');
});

test('a single moment is not sent', () => {
  const tracker = new Tracker('s');
  tracker.heartbeat('app', null, 1000);
  assert.deepStrictEqual(tracker.batch(), []);
});

test('coming back after the idle gap starts a new segment', () => {
  const tracker = new Tracker('s');
  tracker.heartbeat('app', null, 0);
  tracker.heartbeat('app', null, 1000);
  tracker.heartbeat('app', null, 1000 + IDLE_GAP_MS + 1);
  tracker.heartbeat('app', null, 2000 + IDLE_GAP_MS + 1);
  assert.strictEqual(tracker.batch().length, 2);
});

test('switching project starts a new segment', () => {
  const tracker = new Tracker('s');
  tracker.heartbeat('a', null, 0);
  tracker.heartbeat('a', null, 1000);
  tracker.heartbeat('b', null, 2000);
  tracker.heartbeat('b', null, 3000);
  assert.deepStrictEqual(
    tracker.batch().map((s) => s.project),
    ['a', 'b'],
  );
});

test('very long stretches are split before the phone would refuse them', () => {
  const tracker = new Tracker('s');
  const step = IDLE_GAP_MS - 1;
  for (let at = 0; at <= MAX_SEGMENT_MS + step * 2; at += step) {
    tracker.heartbeat('a', null, at);
  }
  for (const segment of tracker.batch()) {
    assert.ok(segment.end - segment.start <= MAX_SEGMENT_MS + step);
  }
  assert.ok(tracker.batch().length >= 2);
});

test('a segment that grew during sending stays queued', () => {
  const tracker = new Tracker('s');
  tracker.heartbeat('a', null, 0);
  tracker.heartbeat('a', null, 1000);
  const batch = tracker.batch();
  tracker.heartbeat('a', null, 2000);

  tracker.acknowledge(batch);
  assert.strictEqual(tracker.batch()[0].end, 2000);

  tracker.acknowledge(tracker.batch());
  assert.deepStrictEqual(tracker.snapshot(), []);
});

test('repository names come from common remote formats', () => {
  assert.strictEqual(parseRepository('git@github.com:me/app.git\n'), 'me/app');
  assert.strictEqual(parseRepository('https://github.com/me/app'), 'me/app');
  assert.strictEqual(parseRepository('nonsense'), null);
});
