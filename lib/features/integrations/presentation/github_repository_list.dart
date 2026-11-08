import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../github/presentation/github_controller.dart';

/// Ignoring deletes a repository's GitHub history, so it asks first.
Future<void> toggleRepositoryIgnored(
  BuildContext context,
  WidgetRef ref,
  TrackedRepository repository, {
  bool confirm = true,
}) async {
  if (confirm && !repository.ignored) {
    final accepted = await showAppSheet<bool>(
      context,
      (sheet) => SheetBody(
        title: 'Ignore ${repository.fullName}?',
        body:
            'Its GitHub activity will be deleted from this phone and won’t '
            'be synced any more.',
        actions: [
          DestructiveButton(
            label: 'Ignore and delete',
            onPressed: () => Navigator.pop(sheet, true),
          ),
          TextButton(
            onPressed: () => Navigator.pop(sheet),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
  }
  await ref
      .read(githubRepositoryProvider)
      .setRepositoryIgnored(repository, ignored: !repository.ignored);
}

class GitHubRepositoryList extends ConsumerStatefulWidget {
  const GitHubRepositoryList({this.confirmIgnore = true, super.key});

  /// Off before the first sync, when there's nothing to delete yet.
  final bool confirmIgnore;

  @override
  ConsumerState<GitHubRepositoryList> createState() =>
      _GitHubRepositoryListState();
}

class _GitHubRepositoryListState extends ConsumerState<GitHubRepositoryList> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repositories = ref.watch(githubRepositoriesProvider).value ?? [];
    final query = _search.text.trim();
    final lowered = query.toLowerCase();
    final shown = repositories
        .where((r) => r.fullName.toLowerCase().contains(lowered))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _search,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Search repositories',
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.muted,
            ),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: _search.clear,
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        if (query.isNotEmpty && shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No repositories match “$query”.',
              style: AppText.caption.copyWith(fontSize: 13),
            ),
          ),
        for (final repository in shown)
          InkWell(
            onTap: () =>
                context.push('/integrations/github/repo/${repository.id}'),
            child: Container(
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
                      onTap: () => toggleRepositoryIgnored(
                        context,
                        ref,
                        repository,
                        confirm: widget.confirmIgnore,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
