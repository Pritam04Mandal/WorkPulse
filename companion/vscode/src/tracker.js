'use strict';

// Coming back to the editor after this long starts a new stretch of work.
const IDLE_GAP_MS = 5 * 60 * 1000;
// The phone refuses anything longer than a day, so split well before that.
const MAX_SEGMENT_MS = 12 * 60 * 60 * 1000;
const MAX_BATCH = 200;

/** Turns editor activity into segments of continuous work on one project. */
class Tracker {
  constructor(sessionId) {
    this.sessionId = sessionId;
    this.current = null;
    this.count = 0;
    this.pending = new Map();
  }

  heartbeat(project, repo, now) {
    const previous = this.current;
    const isNew =
      !previous ||
      previous.project !== project.slice(0, 100) ||
      now - previous.end > IDLE_GAP_MS ||
      now - previous.start > MAX_SEGMENT_MS;

    if (isNew) {
      this.count += 1;
      this.current = {
        id: `vscode.${this.sessionId}.${this.count}`,
        kind: 'vscode',
        project: project.slice(0, 100),
        repo: repo ? repo.slice(0, 140) : null,
        start: now,
        end: now,
      };
    } else {
      previous.end = now;
      if (repo) previous.repo = repo.slice(0, 140);
    }
    this.pending.set(this.current.id, { ...this.current });
  }

  adopt(segments) {
    for (const segment of segments) {
      if (!this.pending.has(segment.id)) this.pending.set(segment.id, segment);
    }
  }

  /** Segments worth sending. A single moment has no duration yet. */
  batch() {
    return [...this.pending.values()]
      .filter((segment) => segment.end > segment.start)
      .slice(0, MAX_BATCH);
  }

  /** Forgets what was delivered, unless it has grown since. */
  acknowledge(batch) {
    for (const sent of batch) {
      const pending = this.pending.get(sent.id);
      if (pending && pending.end === sent.end) this.pending.delete(sent.id);
    }
  }

  snapshot() {
    return [...this.pending.values()];
  }
}

function parseRepository(remoteUrl) {
  const match = /[:/]([^/:]+\/[^/]+?)(?:\.git)?\/?$/.exec(remoteUrl.trim());
  return match ? match[1] : null;
}

module.exports = { Tracker, parseRepository, IDLE_GAP_MS, MAX_SEGMENT_MS };
