import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/app_database.dart' hide Project;
import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../github/domain/github_models.dart';
import '../../github/presentation/github_controller.dart';
import '../../projects/domain/project.dart';
import '../../projects/domain/project_matcher.dart';
import '../../projects/presentation/project_providers.dart';
import '../../tracking/domain/usage_models.dart';
import '../../tracking/presentation/tracking_controller.dart';
import 'github_repository_list.dart';

const _recentLimit = 20;

class GitHubRepositoryScreen extends ConsumerWidget {
  const GitHubRepositoryScreen({required this.id, super.key});

  final String id;

  Future<void> _open(BuildContext context, String fullName) async {
    final opened = await launchUrl(
      Uri.https('github.com', '/$fullName'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      showToast(context, 'Couldn’t open GitHub.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositories = ref.watch(githubRepositoriesProvider);
    TrackedRepository? found;
    for (final candidate in repositories.value ?? <TrackedRepository>[]) {
      if (candidate.id == id) found = candidate;
    }
    if (found == null) {
      return DetailPage(
        children: [
          if (repositories.hasValue)
            const Text('This repository is no longer connected.'),
        ],
      );
    }
    final repository = found;

    final activity =
        (ref.watch(repositoryActivityProvider(repository.fullName)).value ??
                const <TrackedActivity>[])
            .where((a) => !a.isPrivate)
            .toList();
    final stats = RepositoryStats.from(activity);
    final slug = normalizeRepository(repository.fullName);
    final linked = (ref.watch(projectsProvider).value ?? const <Project>[])
        .where((p) => p.repositories.any((r) => normalizeRepository(r) == slug))
        .toList();
    final last = stats.lastActivity;
    final text = Theme.of(context).textTheme;

    return DetailPage(
      children: [
        Text(
          repository.fullName,
          style: AppText.mono(size: 18, weight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          repository.ignored
              ? 'Ignored · not synced'
              : last == null
              ? 'Tracked · no activity recorded yet'
              : 'Tracked · last activity '
                    '${DateFormat('d MMM, HH:mm').format(last)}',
          style: AppText.caption.copyWith(
            fontSize: 13,
            color: repository.ignored ? AppColors.amber : null,
          ),
        ),
        const SizedBox(height: 20),
        KeyValueList(
          rows: [
            ('Commits', '${stats.commits}', true),
            ('Pull requests', '${stats.pullRequests}', true),
            ('Reviews', '${stats.reviews}', true),
            ('Issues', '${stats.issues}', true),
            ('Coding time', formatDuration(stats.codingTime), true),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Recorded on this phone, not the repository’s full history.',
          style: AppText.caption,
        ),
        const SizedBox(height: 20),
        const SectionTitle('Projects'),
        if (linked.isEmpty)
          const Text('Not linked to a project.', style: AppText.caption),
        for (final project in linked)
          NavRow(
            title: project.name,
            onTap: () => context.push('/projects/${project.id}'),
          ),
        const SizedBox(height: 20),
        const SectionTitle('Recent activity'),
        if (activity.isEmpty)
          const Text('Nothing recorded yet.', style: AppText.caption),
        for (final item in activity.take(_recentLimit))
          InkWell(
            onTap: () => context.push('/activity/${item.id}'),
            child: Container(
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
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('d MMM, HH:mm').format(item.start),
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                  if (item.duration != null)
                    Text(
                      formatDuration(item.duration),
                      style: AppText.mono(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => _open(context, repository.fullName),
          child: const Text('Open on GitHub'),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: repository.ignored
              ? null
              : TextButton.styleFrom(
                  foregroundColor: AppColors.destructiveText,
                ),
          onPressed: () => toggleRepositoryIgnored(context, ref, repository),
          child: Text(
            repository.ignored ? 'Track this repository' : 'Ignore repository',
          ),
        ),
      ],
    );
  }
}
