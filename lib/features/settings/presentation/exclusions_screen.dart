import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../data/sample_exclusions.dart';

class ExclusionsScreen extends ConsumerStatefulWidget {
  const ExclusionsScreen({this.showSites = false, super.key});

  final bool showSites;

  @override
  ConsumerState<ExclusionsScreen> createState() => _ExclusionsScreenState();
}

class _ExclusionsScreenState extends ConsumerState<ExclusionsScreen> {
  late var _sites = widget.showSites;

  @override
  Widget build(BuildContext context) {
    final excluded = ref.watch(sampleExclusionsProvider);
    final items = _sites ? sampleExcludableSites : sampleExcludableApps;

    return DetailPage(
      title: 'Exclusions',
      sample: true,
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
              : 'Time in excluded apps is never recorded. Existing events '
                    'from them are deleted.',
          style: AppText.caption.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        for (final (name, id) in items)
          Container(
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
                      Text(id, style: AppText.mono(color: AppColors.muted)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: PillButton(
                    label: excluded.contains(id) ? 'Excluded' : 'Exclude',
                    selected: excluded.contains(id),
                    selectedColor: AppColors.amberBorder,
                    selectedFill: AppColors.amberTint,
                    selectedText: AppColors.amber,
                    onTap: () =>
                        ref.read(sampleExclusionsProvider.notifier).toggle(id),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          '${countExcluded(excluded, items)} excluded · sample list',
          style: AppText.caption,
        ),
      ],
    );
  }
}
