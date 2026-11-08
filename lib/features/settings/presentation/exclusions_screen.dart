import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../tracking/domain/usage_models.dart';
import '../../tracking/presentation/tracking_controller.dart';
import '../data/sample_exclusions.dart';

class ExclusionsScreen extends ConsumerStatefulWidget {
  const ExclusionsScreen({this.showSites = false, super.key});

  final bool showSites;

  @override
  ConsumerState<ExclusionsScreen> createState() => _ExclusionsScreenState();
}

class _ExclusionsScreenState extends ConsumerState<ExclusionsScreen> {
  late var _sites = widget.showSites;

  Widget _row({
    required String name,
    required String id,
    required bool excluded,
    required VoidCallback onToggle,
  }) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.divider)),
    ),
    child: Row(
      spacing: 12,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                id,
                overflow: TextOverflow.ellipsis,
                style: AppText.mono(color: AppColors.muted),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 96,
          child: PillButton(
            label: excluded ? 'Excluded' : 'Exclude',
            selected: excluded,
            selectedColor: AppColors.amberBorder,
            selectedFill: AppColors.amberTint,
            selectedText: AppColors.amber,
            onTap: onToggle,
          ),
        ),
      ],
    ),
  );

  Future<void> _toggleApp(InstalledApp app, bool excluded) async {
    if (!excluded) {
      final confirmed = await showAppSheet<bool>(
        context,
        (sheet) => SheetBody(
          title: 'Exclude ${app.label}?',
          body: 'Everything already recorded from it will be deleted.',
          actions: [
            DestructiveButton(
              label: 'Exclude and delete',
              onPressed: () => Navigator.pop(sheet, true),
            ),
            TextButton(
              onPressed: () => Navigator.pop(sheet),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await ref
        .read(trackingRepositoryProvider)
        .setAppExcluded(app, excluded: !excluded);
  }

  List<Widget> _apps() {
    final excluded = ref.watch(excludedAppsProvider).value ?? const {};
    final apps = ref.watch(installedAppsProvider).value ?? const [];
    return [
      for (final app in apps)
        _row(
          name: app.label,
          id: app.package,
          excluded: excluded.contains(app.package),
          onToggle: () => _toggleApp(app, excluded.contains(app.package)),
        ),
      const SizedBox(height: 12),
      Text('${excluded.length} excluded', style: AppText.caption),
    ];
  }

  List<Widget> _websites() {
    final excluded = ref.watch(sampleSiteExclusionsProvider);
    return [
      for (final (name, id) in sampleExcludableSites)
        _row(
          name: name,
          id: id,
          excluded: excluded.contains(id),
          onToggle: () =>
              ref.read(sampleSiteExclusionsProvider.notifier).toggle(id),
        ),
      const SizedBox(height: 12),
      const Text('Sample list', style: AppText.caption),
    ];
  }

  @override
  Widget build(BuildContext context) => DetailPage(
    title: 'Exclusions',
    sample: _sites,
    children: [
      SegmentedTabs(
        options: const [(false, 'Apps'), (true, 'Websites')],
        value: _sites,
        onChanged: (sites) => setState(() => _sites = sites),
      ),
      const SizedBox(height: 12),
      Text(
        _sites
            ? 'The browser extension ignores these domains completely, '
                  'including AI sites you add here.'
            : 'Time in excluded apps is never recorded. Existing events from '
                  'them are deleted.',
        style: AppText.caption.copyWith(fontSize: 13),
      ),
      const SizedBox(height: 8),
      ...(_sites ? _websites() : _apps()),
    ],
  );
}
