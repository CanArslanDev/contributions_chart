import 'package:flutter/material.dart';

/// Katkı grafiği için düzen hesaplamaları içeren yardımcı sınıf
class LayoutUtils {
  /// GitHub katkı grafiğinin genişlik/yükseklik oranı
  /// GitHub takvimi 53 hafta (sütun) ve 7 gün (satır) içerir
  static const double aspectRatio = 53 / 7;

  /// Widget boyutlarını (genişlik ve yükseklik) hesaplar
  ///
  /// [width] Widget genişliği
  /// [height] Widget yüksekliği
  static Size calculateWidgetSize({double? width, double? height}) {
    assert(
      width != null || height != null,
      "En az genişlik veya yükseklik belirtilmelidir",
    );

    if (width != null && height != null) {
      // Her iki boyut da belirtilmiş, en-boy oranına göre seç
      final providedRatio = width / height;

      if (providedRatio > aspectRatio) {
        // Genişlik, yükseklik için çok büyük, yüksekliği kısıtlama olarak kullan
        final calculatedWidth = height * aspectRatio;
        return Size(calculatedWidth, height);
      } else {
        // Yükseklik, genişlik için çok büyük, genişliği kısıtlama olarak kullan
        final calculatedHeight = width / aspectRatio;
        return Size(width, calculatedHeight);
      }
    } else if (width != null) {
      // Sadece genişlik belirtilmiş
      final calculatedHeight = width / aspectRatio;
      return Size(width, calculatedHeight);
    } else {
      // Sadece yükseklik belirtilmiş (genişlik null olmalı)
      final calculatedWidth = height! * aspectRatio;
      return Size(calculatedWidth, height);
    }
  }

  /// Hücre boyutu ve hücre aralığı hesaplar
  ///
  /// [availableWidth] Kullanılabilir genişlik
  /// [availableHeight] Kullanılabilir yükseklik
  /// [cellSpacing] Hücreler arası boşluk
  static Map<String, double> calculateCellMetrics({
    required double availableWidth,
    required double availableHeight,
    required double cellSpacing,
    required double squareBorderRadius,
  }) {
    // Hücre boyutlarını hesapla
    final cellWidth = availableWidth / 53;
    final cellHeight = availableHeight / 7;
    final baseCellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

    // Widget boyutuna göre ölçeklenebilir padding ve border radius değerleri
    final scaleFactor = baseCellSize / 15.0; // 15.0 referans değer
    final scaledCellSpacing = cellSpacing * scaleFactor;
    final scaledBorderRadius = squareBorderRadius * scaleFactor;

    final cellSize = baseCellSize - (scaledCellSpacing / 2);

    // Toplam alanı hesapla
    final totalWidth = 53 * cellSize + 52 * scaledCellSpacing;
    final totalHeight = 7 * cellSize + 6 * scaledCellSpacing;

    // Widget boyutunu aşarsa hücre boyutunu küçült
    final widgetScaleFactor =
        (totalWidth > availableWidth || totalHeight > availableHeight)
            ? (availableWidth / totalWidth < availableHeight / totalHeight
                ? availableWidth / totalWidth
                : availableHeight / totalHeight)
            : 1.0;

    final adjustedCellSize = cellSize * widgetScaleFactor;
    final adjustedCellSpacing = scaledCellSpacing * widgetScaleFactor;

    return {
      'baseCellSize': baseCellSize,
      'cellSize': cellSize,
      'scaledCellSpacing': scaledCellSpacing,
      'scaledBorderRadius': scaledBorderRadius,
      'adjustedCellSize': adjustedCellSize,
      'adjustedCellSpacing': adjustedCellSpacing,
      'widgetScaleFactor': widgetScaleFactor,
    };
  }

  /// Dokununan pozisyondan gün ve hafta koordinatlarını hesaplar
  ///
  /// [tapPosition] Dokunma konumu
  /// [horizontalOffset] Yatay offset
  /// [verticalOffset] Dikey offset
  /// [adjustedCellSize] Ayarlanmış hücre boyutu
  /// [adjustedCellSpacing] Ayarlanmış hücre aralığı
  static Map<String, int>? calculateTapCoordinates({
    required Offset tapPosition,
    required double horizontalOffset,
    required double verticalOffset,
    required double adjustedCellSize,
    required double adjustedCellSpacing,
  }) {
    // Tıklanan hücrenin hangi hafta ve gün olduğunu hesapla
    final weekIndex =
        ((tapPosition.dx - horizontalOffset) /
                (adjustedCellSize + adjustedCellSpacing))
            .floor();
    final dayIndex =
        ((tapPosition.dy - verticalOffset) /
                (adjustedCellSize + adjustedCellSpacing))
            .floor();

    // Geçerli bir hücreye tıklanıp tıklanmadığını kontrol et
    if (weekIndex >= 0 && weekIndex < 53 && dayIndex >= 0 && dayIndex < 7) {
      return {'weekIndex': weekIndex, 'dayIndex': dayIndex};
    }

    return null;
  }
}
