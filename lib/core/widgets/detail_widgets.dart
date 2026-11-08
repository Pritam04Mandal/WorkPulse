import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import 'app_widgets.dart';

/// Shown by controls whose real behaviour arrives with the integrations.
const notAvailableYet = 'Not available yet. This arrives with real data.';

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> copyToClipboard(
  BuildContext context,
  String text,
  String confirmation,
) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) showToast(context, confirmation);
}

/// A pushed screen: back button, optional title, scrolling body, pinned footer.
class DetailPage extends StatelessWidget {
  const DetailPage({
    required this.children,
    this.title,
    this.actions = const [],
    this.footer = const [],
    this.sample = false,
    this.showBack = true,
    super.key,
  });

  final String? title;
  final List<Widget> actions;
  final List<Widget> children;
  final List<Widget> footer;
  final bool sample;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: showBack,
      title: title == null ? null : Text(title!),
      actions: [
        ...actions,
        if (sample) const Center(child: SampleDataChip()),
        const SizedBox(width: 16),
      ],
    ),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: children,
            ),
          ),
          if (footer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: footer,
              ),
            ),
        ],
      ),
    ),
  );
}

/// Top of a main tab: title on the left, trailing widgets on the right.
class TabHeader extends StatelessWidget {
  const TabHeader({required this.title, this.trailing = const [], super.key});

  final String title;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      spacing: 8,
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ...trailing,
      ],
    ),
  );
}

/// A segmented control, such as Day / Week / Month.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        for (final (option, label) in options)
          Expanded(
            child: Semantics(
              selected: option == value,
              button: true,
              child: Material(
                color: option == value
                    ? AppColors.borderStrong
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                child: InkWell(
                  borderRadius: BorderRadius.circular(7),
                  onTap: () => onChanged(option),
                  child: SizedBox(
                    height: 36,
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: option == value
                              ? AppColors.text
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// A rounded on/off choice.
class PillButton extends StatelessWidget {
  const PillButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = AppColors.accent,
    this.selectedFill = AppColors.accentTint,
    this.selectedText = AppColors.text,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedFill;
  final Color selectedText;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? selectedFill : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? selectedColor : AppColors.borderStrong,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? selectedText : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

/// Label/value rows in a bordered card.
class KeyValueList extends StatelessWidget {
  const KeyValueList({required this.rows, super.key});

  /// Label, value, and whether the value is an identifier set in mono.
  final List<(String, String, bool)> rows;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        for (final (index, (key, value, mono)) in rows.indexed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: index == 0
                  ? null
                  : const Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text(key, style: AppText.caption.copyWith(fontSize: 13)),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: mono
                        ? AppText.mono(size: 13)
                        : const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

/// A tappable settings-style row with an optional trailing value.
class NavRow extends StatelessWidget {
  const NavRow({
    required this.title,
    required this.onTap,
    this.value,
    this.color,
    super.key,
  });

  final String title;
  final String? value;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color ?? AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (value != null)
            Text(value!, style: AppText.caption.copyWith(fontSize: 13)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: color ?? AppColors.muted),
        ],
      ),
    ),
  );
}

/// An OAuth scope and the reason it is requested.
class ScopeRow extends StatelessWidget {
  const ScopeRow({required this.scope, required this.reason, super.key});

  final String scope;
  final String reason;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(scope, style: AppText.mono(size: 13, color: AppColors.accent)),
        Text(reason, style: AppText.caption),
      ],
    ),
  );
}

/// Status line with an activity spinner, such as "Waiting for approval".
class WaitingRow extends StatelessWidget {
  const WaitingRow(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 12,
    children: [
      const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.accent,
          backgroundColor: AppColors.border,
        ),
      ),
      Expanded(child: Text(label, style: AppText.caption)),
    ],
  );
}

/// A teal-outlined confirmation block.
class SuccessCard extends StatelessWidget {
  const SuccessCard({required this.title, this.body, super.key});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.accentTint.withValues(alpha: 0.35),
      border: Border.all(color: AppColors.accentTint),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (body != null) Text(body!, style: AppText.caption),
      ],
    ),
  );
}

/// A red, irreversible action.
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.destructive,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.border,
      disabledForegroundColor: AppColors.muted,
    ),
    onPressed: onPressed,
    child: Text(label),
  );
}

Future<T?> showAppSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            16 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: builder(sheetContext),
        ),
      ),
    );

/// Standard sheet content: heading, explanation, stacked actions.
class SheetBody extends StatelessWidget {
  const SheetBody({
    required this.title,
    required this.actions,
    this.body,
    super.key,
  });

  final String title;
  final String? body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
      ),
      if (body != null) ...[
        const SizedBox(height: 8),
        Text(
          body!,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
      const SizedBox(height: 16),
      ...actions.expand((a) => [a, const SizedBox(height: 10)]).toList()
        ..removeLast(),
    ],
  );
}
