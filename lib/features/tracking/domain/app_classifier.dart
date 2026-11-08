import '../../../core/domain/enums.dart';

const _categories = <String, ActivityCategory>{
  // AI assistants
  'com.openai.chatgpt': ActivityCategory.ai,
  'com.anthropic.claude': ActivityCategory.ai,
  'com.google.android.apps.bard': ActivityCategory.ai,
  'com.microsoft.copilot': ActivityCategory.ai,
  'ai.perplexity.app.android': ActivityCategory.ai,
  // Calls. Teams and Slack are left out: most time there is chat, not meetings.
  'us.zoom.videomeetings': ActivityCategory.meetings,
  'com.google.android.apps.tachyon': ActivityCategory.meetings,
  'com.cisco.webex.meetings': ActivityCategory.meetings,
  // Coding
  'com.termux': ActivityCategory.coding,
  'com.github.android': ActivityCategory.coding,
  'com.foxdebug.acode': ActivityCategory.coding,
  'com.foxdebug.acodefree': ActivityCategory.coding,
};

ActivityCategory categoryForPackage(String package) =>
    _categories[package] ?? ActivityCategory.other;
