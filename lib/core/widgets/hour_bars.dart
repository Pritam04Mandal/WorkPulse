import 'package:flutter/material.dart';

import '../format/durations.dart';
import '../theme/tokens.dart';

class BarSeries {
  const BarSeries(this.name, this.color, this.hours);

  final String name;
  final Color color;
  final List<double> hours;
}

/// Grouped vertical bars on one hours scale. Tapping a group shows its values.
class HourBars extends StatefulWidget {
  const HourBars({
    required this.labels,
    required this.series,
    this.height = 140,
    this.barWidth = 12,
    super.key,
  });

  final List<String> labels;
  final List<BarSeries> series;
  final double height;
  final double barWidth;

  @override
  State<HourBars> createState() => _HourBarsState();
}

class _HourBarsState extends State<HourBars> {
  int? _selected;

  @override
  void didUpdateWidget(HourBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels != widget.labels) _selected = null;
  }

  String _value(BarSeries series, int index) =>
      formatDuration(Duration(minutes: (series.hours[index] * 60).round()));

  String _describe(int index) => [
    widget.labels[index],
    for (final series in widget.series)
      '${series.name} ${_value(series, index)}',
  ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final maxHours = widget.series
        .expand((s) => s.hours)
        .fold<double>(0.01, (max, h) => h > max ? h : max);
    final selected = _selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: [for (var i = 0; i < widget.labels.length; i++) _describe(i)]
              .join(', '),
          child: SizedBox(
            height: widget.height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < widget.labels.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          setState(() => _selected = _selected == i ? null : i),
                      child: Opacity(
                        opacity: selected == null || selected == i ? 1 : 0.45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 2,
                          children: [
                            for (final series in widget.series)
                              Container(
                                width: widget.barWidth,
                                height: series.hours[i] <= 0
                                    ? 0
                                    : (series.hours[i] /
                                              maxHours *
                                              widget.height)
                                          .clamp(3, widget.height),
                                decoration: BoxDecoration(
                                  color: series.color,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final label in widget.labels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.mono(size: 11, color: AppColors.muted),
                ),
              ),
          ],
        ),
        if (selected != null) ...[
          const SizedBox(height: 8),
          Text(
            _describe(selected),
            textAlign: TextAlign.center,
            style: AppText.mono(size: 12, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
