import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/domain/enums.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../domain/project.dart';
import 'project_providers.dart';

/// Creates a project, or edits one when [id] is set.
class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({this.id, super.key});

  final String? id;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _name = TextEditingController();
  final _repositories = <TextEditingController>[];
  var _colorHex = projectColors.first.$2;
  var _matchFolder = true;
  var _saving = false;
  Project? _existing;

  @override
  void initState() {
    super.initState();
    for (final project in ref.read(projectsProvider).value ?? <Project>[]) {
      if (project.id == widget.id) {
        _existing = project;
        _name.text = project.name;
        _colorHex = project.colorHex;
        _repositories.addAll(
          project.repositories.map((r) => TextEditingController(text: r)),
        );
      }
    }
    if (_repositories.isEmpty) _repositories.add(TextEditingController());
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    for (final controller in _repositories) {
      controller.dispose();
    }
    super.dispose();
  }

  void _removeRepository(int index) => setState(() {
    final removed = _repositories.removeAt(index);
    // It may still be attached until the rebuild finishes.
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
    if (_repositories.isEmpty) _repositories.add(TextEditingController());
  });

  List<ProjectRuleItem> _repositoryRules() => [
    for (final value in {
      for (final controller in _repositories)
        if (controller.text.trim().isNotEmpty) controller.text.trim(),
    })
      ProjectRuleItem(RuleKind.repo, value),
  ];

  Future<void> _save() async {
    setState(() => _saving = true);
    final name = _name.text.trim();
    final store = ref.read(projectRepositoryProvider);
    final existing = _existing;
    if (existing != null) {
      await store.save(
        Project(
          id: existing.id,
          name: name,
          colorHex: _colorHex,
          rules: [
            ...existing.rules.where((r) => r.kind != RuleKind.repo),
            ..._repositoryRules(),
          ],
        ),
      );
      if (mounted) context.pop();
      return;
    }
    final id = const Uuid().v4();
    await store.save(
      Project(
        id: id,
        name: name,
        colorHex: _colorHex,
        rules: [
          if (_matchFolder) ProjectRuleItem(RuleKind.path, name),
          ..._repositoryRules(),
        ],
      ),
    );
    if (mounted) context.pushReplacement('/projects/$id');
  }

  @override
  Widget build(BuildContext context) {
    final editing = _existing != null;
    final name = _name.text.trim();
    return DetailPage(
      title: editing ? 'Edit project' : 'New project',
      footer: [
        FilledButton(
          onPressed: name.isEmpty || _saving ? null : _save,
          child: Text(editing ? 'Save changes' : 'Create project'),
        ),
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
      ],
      children: [
        const _Label('Name'),
        TextField(
          controller: _name,
          autofocus: !editing,
          maxLength: 120,
          decoration: const InputDecoration(
            hintText: 'mobile-release',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        const _Label('Colour'),
        Row(
          spacing: 12,
          children: [
            for (final (label, hex) in projectColors)
              Semantics(
                label: label,
                selected: hex == _colorHex,
                button: true,
                child: GestureDetector(
                  onTap: () => setState(() => _colorHex = hex),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorFromHex(hex),
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 3,
                        color: hex == _colorHex
                            ? AppColors.text
                            : AppColors.background,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const _Label('Repositories (optional)'),
        for (final (index, controller) in _repositories.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: ObjectKey(controller),
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'github.com/owner/repo',
                    ),
                  ),
                ),
                if (_repositories.length > 1)
                  IconButton(
                    tooltip: 'Remove repository',
                    onPressed: () => _removeRepository(index),
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 40),
              foregroundColor: AppColors.accent,
            ),
            onPressed: () =>
                setState(() => _repositories.add(TextEditingController())),
            child: const Text('Add another repository'),
          ),
        ),
        if (!editing && name.isNotEmpty) ...[
          const SizedBox(height: 12),
          const _Label('Auto-assign activity that matches'),
          InkWell(
            onTap: () => setState(() => _matchFolder = !_matchFolder),
            child: Row(
              children: [
                Checkbox(
                  value: _matchFolder,
                  activeColor: AppColors.accent,
                  checkColor: AppColors.onAccent,
                  onChanged: (v) => setState(() => _matchFolder = v ?? false),
                ),
                Expanded(
                  child: Text(
                    'Coding sessions in a folder named “$name”',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  'PATH',
                  style: AppText.mono(size: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppText.caption.copyWith(fontSize: 13)),
  );
}
