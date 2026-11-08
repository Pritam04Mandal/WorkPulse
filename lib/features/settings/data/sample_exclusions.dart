import 'package:flutter_riverpod/flutter_riverpod.dart';

const sampleExcludableApps = [
  ('WhatsApp', 'com.whatsapp'),
  ('Instagram', 'com.instagram.android'),
  ('YouTube', 'com.google.android.youtube'),
  ('Netflix', 'com.netflix.mediaclient'),
  ('Slack', 'com.Slack'),
  ('Chrome', 'com.android.chrome'),
  ('Microsoft Teams', 'com.microsoft.teams'),
];

const sampleExcludableSites = [
  ('Reddit', 'reddit.com'),
  ('YouTube', 'youtube.com'),
  ('Banking site', 'yourbank.example'),
  ('Hacker News', 'news.ycombinator.com'),
];

/// IDs currently excluded in the sample list, until the app restarts.
class SampleExclusions extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {
    'com.whatsapp',
    'com.instagram.android',
    'com.google.android.youtube',
    'com.netflix.mediaclient',
    'reddit.com',
    'youtube.com',
  };

  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

final sampleExclusionsProvider =
    NotifierProvider<SampleExclusions, Set<String>>(SampleExclusions.new);

int countExcluded(Set<String> excluded, List<(String, String)> items) =>
    items.where((item) => excluded.contains(item.$2)).length;
