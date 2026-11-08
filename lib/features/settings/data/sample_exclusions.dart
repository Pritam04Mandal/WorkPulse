import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Websites can only be enforced by the browser extension, which doesn't
/// exist yet, so this list is still an example.
const sampleExcludableSites = [
  ('Reddit', 'reddit.com'),
  ('YouTube', 'youtube.com'),
  ('Banking site', 'yourbank.example'),
  ('Hacker News', 'news.ycombinator.com'),
];

class SampleSiteExclusions extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {'reddit.com', 'youtube.com'};

  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

final sampleSiteExclusionsProvider =
    NotifierProvider<SampleSiteExclusions, Set<String>>(
      SampleSiteExclusions.new,
    );
