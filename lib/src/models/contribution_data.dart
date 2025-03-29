import 'package:flutter/foundation.dart';

/// Data model for GitHub contribution graph.
class ContributionData {
  /// Data structure for contribution matrix
  /// Outer list represents days (0-6), inner list represents weeks (0-52).
  final List<List<int>> matrix;

  /// Base date for the contribution graph
  final DateTime baseDate;

  /// Day of the week for the first day of the year in the graph
  final int startWeekday;

  /// Year being displayed
  final int year;

  /// Is this the "Recently" view?
  final bool isRecentlyView;

  /// Has the data been successfully loaded?
  final bool isLoaded;

  /// Creates a new contribution data object
  const ContributionData({
    required this.matrix,
    required this.baseDate,
    required this.startWeekday,
    required this.year,
    this.isRecentlyView = false,
    this.isLoaded = false,
  });

  /// Creates an empty contribution data object
  factory ContributionData.empty() {
    final emptyMatrix = List.generate(7, (i) => List.generate(53, (j) => 0));
    final now = DateTime.now();

    return ContributionData(
      matrix: emptyMatrix,
      baseDate: DateTime(now.year, 1, 1),
      startWeekday: DateTime(now.year, 1, 1).weekday,
      year: now.year,
      isLoaded: false,
    );
  }

  /// Creates a copy with new data loading status
  ContributionData copyWith({
    List<List<int>>? matrix,
    DateTime? baseDate,
    int? startWeekday,
    int? year,
    bool? isRecentlyView,
    bool? isLoaded,
  }) {
    return ContributionData(
      matrix: matrix ?? this.matrix,
      baseDate: baseDate ?? this.baseDate,
      startWeekday: startWeekday ?? this.startWeekday,
      year: year ?? this.year,
      isRecentlyView: isRecentlyView ?? this.isRecentlyView,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContributionData &&
        listEquals(
          other.matrix.expand((i) => i).toList(),
          matrix.expand((i) => i).toList(),
        ) &&
        other.baseDate == baseDate &&
        other.startWeekday == startWeekday &&
        other.year == year &&
        other.isRecentlyView == isRecentlyView &&
        other.isLoaded == isLoaded;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(matrix.expand((i) => i).toList()),
      baseDate,
      startWeekday,
      year,
      isRecentlyView,
      isLoaded,
    );
  }
}
