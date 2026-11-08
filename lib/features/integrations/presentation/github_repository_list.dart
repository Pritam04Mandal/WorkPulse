import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../github/presentation/github_controller.dart';

class GitHubRepositoryList extends ConsumerWidget {
  const GitHubRepositoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositories = ref.watch(githubRepositoriesProvider).value ?? [];
    return Column(
      children: [
        for (final repository in repositories)
          Container(
            constraints: const BoxConstraints(minHeight: 52),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Text(
                    repository.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.mono(size: 13),
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: PillButton(
                    label: repository.ignored ? 'Ignored' : 'Tracked',
                    selected: repository.ignored,
                    selectedColor: AppColors.amberBorder,
                    selectedFill: AppColors.amberTint,
                    selectedText: AppColors.amber,
                    onTap: () => ref
                        .read(githubRepositoryProvider)
                        .setRepositoryIgnored(
                          repository,
                          ignored: !repository.ignored,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
