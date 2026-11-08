import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../tracking/domain/usage_models.dart';
import '../../tracking/presentation/tracking_controller.dart';

class ExclusionsScreen extends ConsumerWidget {
  const ExclusionsScreen({super.key});

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    InstalledApp app, {
    required bool excluded,
  }) async {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final excluded = ref.watch(excludedAppsProvider).value ?? const <String>{};
    final apps = ref.watch(installedAppsProvider).value ?? const [];

    return DetailPage(
      title: 'Excluded apps',
      children: [
        Text(
          'Time in excluded apps is never recorded. Existing events from '
          'them are deleted.',
          style: AppText.caption.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        for (final app in apps)
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
                        app.label,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        app.package,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.mono(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: PillButton(
                    label: excluded.contains(app.package)
                        ? 'Excluded'
                        : 'Exclude',
                    selected: excluded.contains(app.package),
                    selectedColor: AppColors.amberBorder,
                    selectedFill: AppColors.amberTint,
                    selectedText: AppColors.amber,
                    onTap: () => _toggle(
                      context,
                      ref,
                      app,
                      excluded: excluded.contains(app.package),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text('${excluded.length} excluded', style: AppText.caption),
      ],
    );
  }
}
