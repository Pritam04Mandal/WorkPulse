import '../../../core/domain/enums.dart';
import '../domain/dashboard_summary.dart';

/// Fixed example data until real collection exists.
const sampleDashboard = DashboardSummary(
  isSample: true,
  categories: [
    CategoryTime(ActivityCategory.coding, 'Coding', Duration(minutes: 171)),
    CategoryTime(ActivityCategory.ai, 'AI assistants', Duration(minutes: 66)),
    CategoryTime(ActivityCategory.meetings, 'Meetings', Duration(minutes: 65)),
    CategoryTime(ActivityCategory.other, 'Other apps', Duration(minutes: 40)),
  ],
  nowLabel: 'Claude · workpulse-app',
  nowDuration: Duration(minutes: 18),
  tiles: [
    StatTile(
      label: 'Observed events',
      value: '312',
      caption: 'from 3 sources',
      destination: DashboardDestination.timeline,
    ),
    StatTile(
      label: 'Active projects',
      value: '3',
      caption: '1h 12m unassigned',
      destination: DashboardDestination.projects,
    ),
    StatTile(
      label: 'GitHub',
      value: '7',
      caption: '4 commits · 2 PRs · 1 review',
      destination: DashboardDestination.integrations,
    ),
    StatTile(
      label: 'AI sessions',
      value: '5',
      caption: 'Claude 3 · ChatGPT 2',
      destination: DashboardDestination.insights,
    ),
  ],
  recent: [
    RecentActivity(
      time: '13:42',
      kind: RecentKind.ai,
      title: 'Claude session',
      subtitle: 'Browser extension · observed',
      duration: Duration(minutes: 18),
    ),
    RecentActivity(
      time: '12:58',
      kind: RecentKind.github,
      title: 'Opened PR #42 · Add drift migrations',
      subtitle: 'GitHub · observed',
    ),
    RecentActivity(
      time: '11:05',
      kind: RecentKind.coding,
      title: 'VS Code',
      subtitle: 'Desktop companion · project inferred 81%',
      duration: Duration(minutes: 73),
    ),
    RecentActivity(
      time: '10:00',
      kind: RecentKind.meeting,
      title: 'Sprint planning',
      subtitle: 'Teams calendar · observed',
      duration: Duration(minutes: 45),
    ),
  ],
  dailySummary:
      'Most time went to workpulse-app (3h 04m). 4 commits and 2 pull '
      'requests on GitHub. 1 meeting, Sprint planning (45m).',
  integrationsLabel: '5 connected · 1 planned',
);
