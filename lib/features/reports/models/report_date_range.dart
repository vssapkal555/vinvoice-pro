enum ReportDatePreset {
  today,
  thisWeek,
  thisMonth,
  thisFinancialYear,
  last30Days,
  last90Days,
  allTime,
  custom,
}

class ReportDateRange {
  const ReportDateRange({
    required this.start,
    required this.end,
    required this.preset,
  });

  final DateTime? start;
  final DateTime? end;
  final ReportDatePreset preset;

  bool contains(DateTime value) {
    final date = DateTime(value.year, value.month, value.day);

    if (start != null) {
      final from = DateTime(start!.year, start!.month, start!.day);
      if (date.isBefore(from)) return false;
    }

    if (end != null) {
      final to = DateTime(end!.year, end!.month, end!.day);
      if (date.isAfter(to)) return false;
    }

    return true;
  }

  static ReportDateRange fromPreset(ReportDatePreset preset, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);

    switch (preset) {
      case ReportDatePreset.today:
        return ReportDateRange(start: today, end: today, preset: preset);

      case ReportDatePreset.thisWeek:
        final monday = today.subtract(
          Duration(days: today.weekday - DateTime.monday),
        );

        return ReportDateRange(start: monday, end: today, preset: preset);

      case ReportDatePreset.thisMonth:
        return ReportDateRange(
          start: DateTime(today.year, today.month, 1),
          end: today,
          preset: preset,
        );

      case ReportDatePreset.thisFinancialYear:
        final fyStartYear = today.month >= 4 ? today.year : today.year - 1;

        return ReportDateRange(
          start: DateTime(fyStartYear, 4, 1),
          end: today,
          preset: preset,
        );

      case ReportDatePreset.last30Days:
        return ReportDateRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
          preset: preset,
        );

      case ReportDatePreset.last90Days:
        return ReportDateRange(
          start: today.subtract(const Duration(days: 89)),
          end: today,
          preset: preset,
        );

      case ReportDatePreset.allTime:
        return ReportDateRange(start: null, end: null, preset: preset);

      case ReportDatePreset.custom:
        return ReportDateRange(start: today, end: today, preset: preset);
    }
  }

  ReportDateRange copyWith({
    DateTime? start,
    DateTime? end,
    ReportDatePreset? preset,
  }) {
    return ReportDateRange(
      start: start ?? this.start,
      end: end ?? this.end,
      preset: preset ?? this.preset,
    );
  }
}
