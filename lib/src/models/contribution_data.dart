import 'package:flutter/foundation.dart';

/// GitHub katkı grafiği için veri modeli.
class ContributionData {
  /// Katkı matrisinin veri yapısı
  /// Dış liste günleri (0-6), iç liste haftaları (0-52) temsil eder.
  final List<List<int>> matrix;

  /// Katkı grafiğinin temel tarihi
  final DateTime baseDate;

  /// Grafik yılının ilk gününün haftanın hangi günü olduğu
  final int startWeekday;

  /// Gösterilen yıl
  final int year;

  /// "Son zamanlarda" görünümü mü?
  final bool isRecentlyView;

  /// Veri başarıyla yüklendi mi?
  final bool isLoaded;

  /// Yeni bir katkı veri nesnesi oluşturur
  const ContributionData({
    required this.matrix,
    required this.baseDate,
    required this.startWeekday,
    required this.year,
    this.isRecentlyView = false,
    this.isLoaded = false,
  });

  /// Boş bir katkı veri nesnesi oluşturur
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

  /// Yeni bir veri yükleme durumu ile kopyalar
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
