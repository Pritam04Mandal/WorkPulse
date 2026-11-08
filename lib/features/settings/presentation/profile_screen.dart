import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/domain/enums.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../auth/presentation/session_controller.dart';

/// Shortens an ID for display, keeping both ends.
String shortId(String id, {int head = 8, int tail = 4}) =>
    id.length <= head + tail
    ? id
    : '${id.substring(0, head)}…${id.substring(id.length - tail)}';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppSheet<bool>(
      context,
      (sheet) => SheetBody(
        title: 'Sign out?',
        body:
            'Your activity stays on this phone. GitHub stays connected; '
            'disconnect it separately.',
        actions: [
          DestructiveButton(
            label: 'Sign out',
            onPressed: () => Navigator.pop(sheet, true),
          ),
          TextButton(
            onPressed: () => Navigator.pop(sheet),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirmed == true) await ref.read(sessionProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider.select((s) => s.user));
    final isLocal = user == null || user.isLocal;
    final text = Theme.of(context).textTheme;
    final date = DateFormat('d MMM yyyy');
    final name = isLocal
        ? 'Local profile'
        : user.name ?? user.email ?? 'Account';
    final providerName = user?.provider == AuthProvider.microsoft
        ? 'Microsoft'
        : 'Google';
    final subtitle = isLocal
        ? 'No account connected'
        : [user.email, providerName].nonNulls.join(' · ');

    return DetailPage(
      footer: isLocal
          ? [
              OutlinedButton(
                onPressed: () => context.push('/sign-in/google'),
                child: const Text('Sign in with Google'),
              ),
            ]
          : [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.destructiveText,
                ),
                onPressed: () => _confirmSignOut(context, ref),
                child: const Text('Sign out'),
              ),
            ],
      children: [
        Row(
          spacing: 16,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Text(
                name.characters.first.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.headlineSmall),
                  Text(subtitle, style: AppText.caption.copyWith(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        KeyValueList(
          rows: [
            if (!isLocal) ...[
              ('Provider', providerName, false),
              if (user.subjectId != null)
                (
                  'Subject ID',
                  shortId(user.subjectId!, head: 4, tail: 4),
                  true,
                ),
            ],
            if (user != null) ...[
              ('Local ID', shortId(user.id), true),
              ('Created', date.format(user.createdAt), false),
            ],
            if (isLocal)
              ('Storage', 'This phone only', false)
            else
              (
                'Last sign-in',
                DateFormat('d MMM, HH:mm').format(user.lastLoginAt),
                false,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          isLocal
              ? 'Signing in links a name and email to this profile. Your data '
                    'stays on this phone either way.'
              : 'There is no WorkPulse server, so signing in on another phone '
                    'does not bring this data with it. Use Export in Settings '
                    'to move it.',
          style: AppText.caption,
        ),
      ],
    );
  }
}
