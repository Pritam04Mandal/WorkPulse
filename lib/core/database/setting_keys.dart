/// Usage events older than this time (epoch ms) are never imported. Survives
/// a data wipe, since Android still holds the log the wipe was meant to clear.
const importFloorSettingKey = 'usage_import_floor_ms';

/// When the live GitHub check last completed (epoch ms).
const githubPollCursorSettingKey = 'github_poll_cursor_ms';

const biometricLockSettingKey = 'biometric_lock';

const privateSessionSettingKey = 'private_session';
