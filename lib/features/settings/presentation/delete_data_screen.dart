import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../auth/presentation/session_controller.dart';

class DeleteDataScreen extends ConsumerStatefulWidget {
  const DeleteDataScreen({super.key});

  @override
  ConsumerState<DeleteDataScreen> createState() => _DeleteDataScreenState();
}

class _DeleteDataScreenState extends ConsumerState<DeleteDataScreen> {
  final _confirmation = TextEditingController();
  var _deleting = false;
  var _done = false;

  bool get _confirmed => _confirmation.text.trim().toUpperCase() == 'DELETE';

  @override
  void initState() {
    super.initState();
    _confirmation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    await ref.read(sessionProvider.notifier).deleteAllData();
    if (mounted) {
      setState(() {
        _deleting = false;
        _done = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final body = text.bodyMedium?.copyWith(color: AppColors.textSecondary);

    return PopScope(
      canPop: !_done && !_deleting,
      child: DetailPage(
        title: _done ? null : 'Delete all data',
        showBack: !_done && !_deleting,
        footer: [
          if (_done)
            FilledButton(
              onPressed: ref.read(sessionProvider.notifier).startOver,
              child: const Text('Start over'),
            )
          else
            DestructiveButton(
              label: _deleting ? 'Deleting…' : 'Delete everything',
              onPressed: _confirmed && !_deleting ? _delete : null,
            ),
        ],
        children: _done
            ? [
                const SizedBox(height: 40),
                const Icon(
                  Icons.check_circle_outline,
                  size: 40,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 16),
                Text('All local data deleted', style: text.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  'Also revoke WorkPulse in your Google and Microsoft account '
                  'settings if you won’t use it again.',
                  style: body,
                ),
              ]
            : [
                Text(
                  'This permanently removes everything WorkPulse stored on '
                  'this phone. It can’t be undone.',
                  style: body,
                ),
                const SizedBox(height: 16),
                for (final item in const [
                  'Activity events and work sessions',
                  'Projects, rules and daily reports',
                  'Saved sign-ins',
                  'Your local profile',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('—  $item', style: body),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Type DELETE to confirm',
                  style: AppText.caption.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmation,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
      ),
    );
  }
}
