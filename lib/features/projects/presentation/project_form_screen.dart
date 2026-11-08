import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../data/sample_projects.dart';
import '../domain/project.dart';

/// Creates a project, or edits one when [id] is set.
class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({this.id, super.key});

  final String? id;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _name = TextEditingController();
  final _repository = TextEditingController();
  var _color = projectColors.first.$2;
  var _matchFolder = true;
  var _matchTitles = true;
  Project? _existing;

  @override
  void initState() {
    super.initState();
    for (final project in ref.read(sampleProjectsProvider)) {
      if (project.id == widget.id) {
        _existing = project;
        _name.text = project.name;
        _repository.text = project.repository ?? '';
        _color = project.color;
      }
    }
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _repository.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final repository = _repository.text.trim();
    final store = ref.read(sampleProjectsProvider.notifier);
    final existing = _existing;
    if (existing != null) {
      store.upsert(
        existing.copyWith(
          name: name,
          color: _color,
          repository: repository.isEmpty ? null : repository,
        ),
      );
      context.pop();
      return;
    }
    final id = const Uuid().v4();
    store.upsert(
      Project(
        id: id,
        name: name,
        color: _color,
        repository: repository.isEmpty ? null : repository,
        rules: [
          if (_matchFolder) ProjectRuleItem('Path', '~/code/$name'),
          if (_matchTitles) ProjectRuleItem('Title', name),
        ],
      ),
    );
    context.pushReplacement('/projects/$id');
  }

  @override
  Widget build(BuildContext context) {
    final editing = _existing != null;
    final name = _name.text.trim();
    return DetailPage(
      title: editing ? 'Edit project' : 'New project',
      sample: true,
      footer: [
        FilledButton(
          onPressed: name.isEmpty ? null : _save,
          child: Text(editing ? 'Save changes' : 'Create project'),
        ),
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
      ],
      children: [
        const _Label('Name'),
        TextField(
          controller: _name,
          autofocus: !editing,
          decoration: const InputDecoration(hintText: 'mobile-release'),
        ),
        const SizedBox(height: 20),
        const _Label('Colour'),
        Row(
          spacing: 12,
          children: [
            for (final (label, color) in projectColors)
              Semantics(
                label: label,
                selected: color == _color,
                button: true,
                child: GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 3,
                        color: color == _color
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
        const _Label('Repository (optional)'),
        TextField(
          controller: _repository,
          decoration: const InputDecoration(hintText: 'github.com/owner/repo'),
        ),
        if (!editing && name.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _Label('Auto-assign activity that matches'),
          _RuleToggle(
            label: 'Folder ~/code/$name',
            kind: 'PATH',
            value: _matchFolder,
            onChanged: (v) => setState(() => _matchFolder = v),
          ),
          _RuleToggle(
            label: 'Window titles with “$name”',
            kind: 'TITLE',
            value: _matchTitles,
            onChanged: (v) => setState(() => _matchTitles = v),
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

class _RuleToggle extends StatelessWidget {
  const _RuleToggle({
    required this.label,
    required this.kind,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String kind;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!value),
    child: Row(
      children: [
        Checkbox(
          value: value,
          activeColor: AppColors.accent,
          checkColor: AppColors.onAccent,
          onChanged: (v) => onChanged(v ?? false),
        ),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(kind, style: AppText.mono(size: 11, color: AppColors.muted)),
      ],
    ),
  );
}
