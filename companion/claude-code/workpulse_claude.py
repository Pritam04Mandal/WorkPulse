#!/usr/bin/env python3
"""Reports Claude Code session times to the WorkPulse app on your phone.

Sends only: when you worked, the project folder name and the git repository
name. It never reads your prompts, Claude's responses or any file contents.

Usage:
  workpulse_claude.py pair ADDRESS CODE   Pair with the phone (shown in the app)
  workpulse_claude.py install             Add the Claude Code hooks
  workpulse_claude.py uninstall           Remove the Claude Code hooks
  workpulse_claude.py status              Show the pairing and queued sessions

Needs Python 3.8+ and nothing else.
"""

import hashlib
import hmac
import json
import os
import re
import secrets
import shlex
import shutil
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.request
from contextlib import contextmanager
from pathlib import Path

try:
    import fcntl
except ImportError:  # Windows
    fcntl = None

# RFC 3526 group 14, matching lib/features/companion/domain/pairing_crypto.dart.
PRIME = int(
    "FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74"
    "020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F1437"
    "4FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED"
    "EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF05"
    "98DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB"
    "9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3B"
    "E39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF695581718"
    "3995497CEA956AE515D2261898FA051015728E5A8AACAA68FFFFFFFFFFFFFFFF",
    16,
)

# Coming back after this long starts a new stretch of work.
IDLE_GAP_MS = 15 * 60 * 1000
MAX_BATCH = 200
KEEP_PENDING_MS = 7 * 24 * 60 * 60 * 1000
HOOK_EVENTS = ("UserPromptSubmit", "PreToolUse", "PostToolUse", "Stop", "SessionEnd")
# These fire for every tool call, so they must never hold Claude up.
BACKGROUND_EVENTS = ("PreToolUse", "PostToolUse")
# While Claude works, send a heartbeat this often.
TICK_SECONDS = float(os.environ.get("WORKPULSE_TICK_S") or 10)
# Claude counts as working if its transcript file changed this recently.
TRANSCRIPT_FRESH_MS = 2 * 60 * 1000
# Stops a tool that never reported finishing from looking busy forever.
TOOL_LIMIT_MS = 10 * 60 * 1000
HOOK_MARKER = "workpulse_claude.py"

STATE_DIR = Path(os.environ.get("WORKPULSE_HOME") or Path.home() / ".workpulse")
CONFIG_FILE = STATE_DIR / "config.json"
STATE_FILE = STATE_DIR / "state.json"


def now_ms():
    return int(os.environ.get("WORKPULSE_NOW_MS") or time.time() * 1000)


def claude_settings_path():
    root = os.environ.get("CLAUDE_CONFIG_DIR")
    return (Path(root) if root else Path.home() / ".claude") / "settings.json"


def read_json(path, default):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return default


def write_private(path, data):
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(".tmp")
    descriptor = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
        json.dump(data, handle)
    os.replace(temporary, path)


@contextmanager
def locked():
    """Hooks from several Claude Code windows can run at the same moment."""
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    with open(STATE_DIR / "state.lock", "w", encoding="utf-8") as lock:
        if fcntl:
            fcntl.flock(lock, fcntl.LOCK_EX)
        yield


def post(address, path, body, headers=None, timeout=5):
    request = urllib.request.Request(
        f"http://{address}{path}",
        data=body,
        headers={"Content-Type": "application/json", **(headers or {})},
        method="POST",
    )
    # Always direct: the phone is on the local network, never behind a proxy.
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    with opener.open(request, timeout=timeout) as response:
        return json.loads(response.read().decode("utf-8"))


def mac(key, message):
    return hmac.new(key, message.encode("utf-8"), hashlib.sha256).hexdigest()


# Pairing ---------------------------------------------------------------------


def pair(address, code):
    private = secrets.randbits(320)
    client_public = format(pow(2, private, PRIME), "x")
    name = socket.gethostname()[:60] or "Computer"

    def call(path, payload):
        return post(address, path, json.dumps(payload).encode("utf-8"))

    server_public = call(
        "/v1/pair/start", {"name": name, "client_public": client_public}
    )["server_public"]
    server_value = int(server_public, 16)
    if not 1 < server_value < PRIME - 1:
        raise ValueError("The phone sent an invalid key.")

    shared = pow(server_value, private, PRIME)
    key = hashlib.sha256(format(shared, "x").encode("utf-8")).digest()
    transcript = f"{code}|{client_public}|{server_public}"
    reply = call("/v1/pair/finish", {"mac": mac(key, f"client|{transcript}")})
    if not hmac.compare_digest(reply["mac"], mac(key, f"server|{transcript}")):
        raise ValueError("The phone could not prove it knows the code.")

    write_private(
        CONFIG_FILE,
        {
            "address": address,
            "device_id": reply["device_id"],
            "secret": mac(key, f"secret|{code}"),
        },
    )


def command_pair(arguments):
    if len(arguments) != 2:
        print("Usage: workpulse_claude.py pair ADDRESS CODE", file=sys.stderr)
        return 2
    address, code = arguments
    try:
        pair(address, code)
    except urllib.error.HTTPError as error:
        reason = (
            "The code was wrong or has expired. Check the app and try again."
            if error.code == 403
            else f"The phone refused the request ({error.code})."
        )
        print(reason, file=sys.stderr)
        return 1
    except (OSError, ValueError, KeyError) as error:
        print(
            f"Couldn't pair with {address}: {error}\n"
            "Keep WorkPulse open on the Claude Code screen and make sure both "
            "devices are on the same Wi-Fi.",
            file=sys.stderr,
        )
        return 1
    print("Paired. Now run: workpulse_claude.py install")
    return 0


# Claude Code hooks -----------------------------------------------------------


def hook_command():
    script = str(Path(__file__).resolve())
    return f"{shlex.quote(sys.executable)} {shlex.quote(script)} hook"


def is_ours(entry):
    return any(
        HOOK_MARKER in str(hook.get("command", "")) for hook in entry.get("hooks", [])
    )


def load_settings(path):
    if not path.exists():
        return {}
    settings = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(settings, dict):
        raise ValueError("settings.json is not a JSON object.")
    return settings


def save_settings(path, settings):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        shutil.copy2(path, path.with_name(path.name + ".workpulse-backup"))
    path.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")


def command_install():
    path = claude_settings_path()
    try:
        settings = load_settings(path)
    except ValueError as error:
        print(f"Left {path} alone because it isn't valid: {error}", file=sys.stderr)
        return 1
    hooks = settings.setdefault("hooks", {})
    for event in HOOK_EVENTS:
        kept = [entry for entry in hooks.get(event, []) if not is_ours(entry)]
        hook = {"type": "command", "command": hook_command(), "timeout": 5}
        if event in BACKGROUND_EVENTS:
            hook["async"] = True
        kept.append({"hooks": [hook]})
        hooks[event] = kept
    save_settings(path, settings)
    print(f"Hooks added to {path}. Restart any open Claude Code sessions.")
    return 0


def command_uninstall():
    path = claude_settings_path()
    try:
        settings = load_settings(path)
    except ValueError as error:
        print(f"Left {path} alone because it isn't valid: {error}", file=sys.stderr)
        return 1
    hooks = settings.get("hooks", {})
    for event in HOOK_EVENTS:
        kept = [entry for entry in hooks.get(event, []) if not is_ours(entry)]
        if kept:
            hooks[event] = kept
        else:
            hooks.pop(event, None)
    if not hooks:
        settings.pop("hooks", None)
    save_settings(path, settings)
    print(f"Hooks removed from {path}.")
    return 0


def command_status():
    config = read_json(CONFIG_FILE, None)
    state = read_json(STATE_FILE, {})
    print(f"Paired with: {config['address'] if config else 'nothing yet'}")
    print(f"Sessions waiting to send: {len(state.get('pending', {}))}")
    try:
        hooks = load_settings(claude_settings_path()).get("hooks", {})
    except ValueError:
        hooks = {}
    installed = all(any(is_ours(e) for e in hooks.get(ev, [])) for ev in HOOK_EVENTS)
    print(f"Hooks installed: {'yes' if installed else 'no'}")
    return 0


# Recording -------------------------------------------------------------------


def git_value(cwd, *arguments):
    try:
        result = subprocess.run(
            ["git", "-C", cwd, *arguments],
            capture_output=True,
            text=True,
            timeout=1,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    return result.stdout.strip() if result.returncode == 0 else None


def describe_project(cwd):
    """Folder name and `owner/name`. The full path never leaves the computer."""
    top_level = git_value(cwd, "rev-parse", "--show-toplevel") or cwd
    project = os.path.basename(top_level.rstrip("/\\")) or "Unknown project"
    remote = git_value(cwd, "config", "--get", "remote.origin.url") or ""
    match = re.search(r"[:/]([^/:]+/[^/]+?)(?:\.git)?/?$", remote)
    return project[:100], (match.group(1)[:140] if match else None)


def snapshot(session_id, session):
    segment_id = f"{session_id}.{session['segment']}"
    return segment_id, {
        "id": segment_id,
        "project": session["project"],
        "repo": session.get("repo"),
        "start": session["start"],
        "end": session["last"],
        "prompts": session.get("prompts", 0),
        "working": session.get("working", False),
    }


def record(event):
    """Returns the background jobs to start. The prompt text is never read:
    only the session ID, event name, folder and transcript path are used."""
    session_id = re.sub(r"[^A-Za-z0-9_-]", "", str(event.get("session_id", "")))[:80]
    name = event.get("hook_event_name")
    if not session_id or name not in HOOK_EVENTS:
        return []
    cwd = str(event.get("cwd") or os.getcwd())
    now = now_ms()

    with locked():
        state = read_json(STATE_FILE, {})
        sessions = state.setdefault("sessions", {})
        pending = state.setdefault("pending", {})
        session = sessions.get(session_id)

        if name == "UserPromptSubmit":
            if session is None or now - session["last"] > IDLE_GAP_MS:
                project, repo = (
                    (session["project"], session.get("repo"))
                    if session
                    else describe_project(cwd)
                )
                session = {
                    "segment": (session["segment"] + 1) if session else 1,
                    "start": now,
                    "last": now,
                    "project": project,
                    "repo": repo,
                    "prompts": 0,
                }
                sessions[session_id] = session
            session["prompts"] = session.get("prompts", 0) + 1
            session["transcript"] = str(event.get("transcript_path") or "")
        elif session is None:
            return []

        was_working = session.get("working", False)
        session["last"] = now
        if name == "UserPromptSubmit":
            session["working"] = True
            session["tool_started"] = None
        elif name == "PreToolUse":
            session["working"] = True
            session["tool_started"] = now
        elif name == "PostToolUse":
            session["working"] = True
            session["tool_started"] = None
        else:
            session["working"] = False
            session["tool_started"] = None

        segment_id, item = snapshot(session_id, session)
        pending[segment_id] = item
        if name == "SessionEnd":
            sessions.pop(session_id, None)
        write_private(STATE_FILE, state)

    if name in BACKGROUND_EVENTS:
        return ["ticker"] if not was_working else []
    return ["flush", "ticker"] if name == "UserPromptSubmit" else ["flush"]


def spawn(job):
    """Hooks must return at once, even when the phone can't be reached."""
    subprocess.Popen(
        [sys.executable, str(Path(__file__).resolve()), job],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )


def command_hook():
    # Anything printed here would be added to Claude's context, and a failure
    # must never disturb the session, so this stays silent and always exits 0.
    try:
        for job in record(json.loads(sys.stdin.read())):
            spawn(job)
    except Exception:  # pylint: disable=broad-except
        pass
    return 0


def still_working(session, now):
    """Whether Claude is busy, and when it last visibly did something. Looks
    only at the transcript's modified time, never at what's inside it."""
    started = session.get("tool_started")
    if started and now - started < TOOL_LIMIT_MS:
        return True, None
    try:
        modified = int(os.path.getmtime(session.get("transcript") or "") * 1000)
    except OSError:
        return False, None
    return (True, modified) if now - modified < TRANSCRIPT_FRESH_MS else (False, None)


def tick():
    now = now_ms()
    any_working = False
    with locked():
        state = read_json(STATE_FILE, {})
        pending = state.setdefault("pending", {})
        for session_id, session in state.get("sessions", {}).items():
            if not session.get("working"):
                continue
            working, seen = still_working(session, now)
            if seen:
                session["last"] = max(session["last"], seen)
            session["working"] = working
            any_working = any_working or working
            segment_id, item = snapshot(session_id, session)
            pending[segment_id] = item
        write_private(STATE_FILE, state)
    return any_working


def command_ticker():
    """Sends heartbeats while Claude works, then exits. One runs at a time."""
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    with open(STATE_DIR / "ticker.lock", "w", encoding="utf-8") as lock:
        if fcntl:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except OSError:
                return 0
        while True:
            time.sleep(TICK_SECONDS)
            working = tick()
            command_flush()
            if not working:
                return 0


def command_flush():
    config = read_json(CONFIG_FILE, None)
    if not config:
        return 0
    with locked():
        state = read_json(STATE_FILE, {})
        oldest = now_ms() - KEEP_PENDING_MS
        pending = {
            key: value
            for key, value in state.get("pending", {}).items()
            if value["end"] >= oldest
        }
    # A zero-length segment still matters: it starts or ends the live state.
    batch = [v for v in pending.values() if v["end"] > v["start"] or "working" in v]
    batch = batch[:MAX_BATCH]
    if not batch:
        return 0

    body = json.dumps({"segments": batch}, separators=(",", ":")).encode("utf-8")
    timestamp = str(int(time.time() * 1000))
    signature = mac(
        config["secret"].encode("utf-8"), f"{timestamp}.{body.decode('utf-8')}"
    )
    try:
        post(
            config["address"],
            "/v1/events",
            body,
            {
                "X-WorkPulse-Device": config["device_id"],
                "X-WorkPulse-Timestamp": timestamp,
                "X-WorkPulse-Signature": signature,
            },
            timeout=3,
        )
    except (OSError, ValueError):
        return 0  # Phone closed or away: these stay queued for the next hook.

    def fingerprint(item):
        return item["end"], item.get("working"), item.get("prompts")

    sent = {item["id"]: fingerprint(item) for item in batch}
    with locked():
        state = read_json(STATE_FILE, {})
        current = state.get("pending", {})
        state["pending"] = {
            key: value
            for key, value in current.items()
            if fingerprint(value) != sent.get(key)
        }
        write_private(STATE_FILE, state)
    return 0


def main(arguments):
    command = arguments[0] if arguments else ""
    if command == "pair":
        return command_pair(arguments[1:])
    if command == "install":
        return command_install()
    if command == "uninstall":
        return command_uninstall()
    if command == "status":
        return command_status()
    if command == "hook":
        return command_hook()
    if command == "flush":
        return command_flush()
    if command == "ticker":
        try:
            return command_ticker()
        except Exception:  # pylint: disable=broad-except
            return 0
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
