import 'package:flutter/material.dart';

import '../models/contribution_data.dart';

/// GitHub katkı grafiğini çizen CustomPainter sınıfı
class ContributionsPainter extends CustomPainter {
  /// Katkı verileri
  final ContributionData data;

  /// Hücreler arası boşluk
  final double cellSpacing;

  /// Katkı seviyelerine göre renkler (0-4)
  final List<Color>? customColors;

  /// Tek renk modu için temel renk (belirtilirse customColors yerine kullanılır)
  final Color? singleContributionColor;

  /// Tek renk modu için opaklık değerleri (0.0 - 1.0)
  final List<double>? singleColorOpacities;

  /// Arka plan rengi
  final Color backgroundColor;

  /// Katkı karelerinin köşe yarıçapı
  final double squareBorderRadius;

  /// Takvim etiketlerini göster
  final bool showCalendar;

  /// Ay etiketleri için metin stili
  final TextStyle? monthLabelStyle;

  /// Gün etiketleri için metin stili
  final TextStyle? dayLabelStyle;

  /// Özel ay etiketleri (belirtilirse 12 ad gereklidir)
  final List<String>? customMonthLabels;

  /// Özel gün etiketleri (belirtilirse 3 ad gereklidir)
  final List<String>? customDayLabels;

  /// Her katkı hücresi için kenarlık
  final Border? contributionBorder;

  /// Katkısız hücreler için renk
  final Color? emptyColor;

  /// Özel tooltip metin formatı
  final String? tooltipTextFormat;

  /// Bir hücreye tıklandığında çağrılacak callback
  final Function(DateTime date, int count)? onCellTap;

  /// GitHub katkı grafiğini çizen CustomPainter oluşturur
  ContributionsPainter({
    required this.data,
    this.cellSpacing = 4.0,
    this.customColors,
    this.singleContributionColor,
    this.singleColorOpacities,
    required this.backgroundColor,
    required this.squareBorderRadius,
    this.showCalendar = false,
    this.monthLabelStyle,
    this.dayLabelStyle,
    this.customMonthLabels,
    this.customDayLabels,
    this.contributionBorder,
    this.emptyColor,
    this.tooltipTextFormat,
    this.onCellTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // İlk olarak arka plan rengini çiziyoruz - tüm alanı kapladığından emin olalım
    final backgroundPaint = Paint()..color = backgroundColor;
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(backgroundRect, backgroundPaint);

    // Takvim etiketleri için kenar boşlukları
    double leftPadding = 0;
    double topPadding = 0;

    if (showCalendar) {
      // Takvim görünümündeyken sol ve üst kenar boşlukları ekleyelim
      leftPadding = size.width * 0.06; // %6 sol kenar boşluğu
      topPadding = size.height * 0.1; // %10 üst kenar boşluğu
    }

    // Katkı grafiği için kullanılabilir alan
    final availableWidth = size.width - leftPadding;
    final availableHeight = size.height - topPadding;

    // Hücre boyutlarını hesapla
    final cellWidth = availableWidth / 53;
    final cellHeight = availableHeight / 7;
    final baseCellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

    // Widget boyutuna göre ölçeklenebilir cell spacing (padding) ve border radius değerleri
    final scaleFactor =
        baseCellSize / 15.0; // 15.0 referans değer (120 height için)
    final scaledCellSpacing = cellSpacing * scaleFactor;
    final scaledBorderRadius = squareBorderRadius * scaleFactor;

    final cellSize = baseCellSize - (scaledCellSpacing / 2);

    // Varsayılan katkı renkleri
    final defaultColors = [
      emptyColor ?? Color(0xFF161b22),
      Color(0xFF0E4429),
      Color(0xFF006D32),
      Color(0xFF26A641),
      Color(0xFF39D353),
    ];

    // Tek renk modu
    List<Color> colors;
    if (singleContributionColor != null) {
      final defaultOpacities = [0.1, 0.3, 0.5, 0.7, 0.9];
      final opacities = singleColorOpacities ?? defaultOpacities;

      colors = List.generate(5, (index) {
        if (index == 0 && emptyColor != null) {
          return emptyColor!;
        }

        // withOpacity yerine withAlpha kullanarak daha kesin değerler elde edelim
        final alpha = (opacities[index] * 255).round();
        return singleContributionColor!.withAlpha(alpha);
      });
    } else {
      colors = customColors ?? defaultColors;
    }

    final radius = BorderRadius.circular(scaledBorderRadius);

    // Toplam alanı ve offset'leri hesapla
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

    final adjustedTotalWidth = 53 * adjustedCellSize + 52 * adjustedCellSpacing;
    final adjustedTotalHeight = 7 * adjustedCellSize + 6 * adjustedCellSpacing;

    final horizontalOffset =
        leftPadding + (availableWidth - adjustedTotalWidth) / 2;
    final verticalOffset =
        topPadding + (availableHeight - adjustedTotalHeight) / 2;

    // Yılın başlangıç ve bitiş tarihlerini hesapla
    final firstDayOfYear = DateTime(data.year, 1, 1);
    final lastDayOfYear = DateTime(data.year, 12, 31);

    // Yılın ilk haftasının günü (Pazar = 0)
    final firstDayWeekday = firstDayOfYear.weekday % 7;

    // Yılın son haftasının günü (Pazar = 0)
    final lastDayWeekday = lastDayOfYear.weekday % 7;

    // Son zamanlarda görünümü mü kontrol et
    bool showingRecentlyView = data.isRecentlyView;

    // Takvim etiketleri
    if (showCalendar) {
      _drawCalendarLabels(
        canvas,
        baseCellSize,
        horizontalOffset,
        verticalOffset,
        topPadding,
        leftPadding,
        adjustedCellSize,
        adjustedCellSpacing,
      );
    }

    // Katkı karelerini çiz
    for (var weekIndex = 0; weekIndex < 53; weekIndex++) {
      for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
        // İlk haftada başlangıç gününden önceki günleri atla - son zamanlarda modunda değilse
        if (weekIndex == 0 &&
            dayIndex < firstDayWeekday &&
            !showingRecentlyView) {
          continue;
        }

        // Son haftada yılın son gününden sonraki günleri atla
        if (weekIndex == 52 && dayIndex > lastDayWeekday) {
          continue;
        }

        final contribution = data.matrix[dayIndex][weekIndex];

        // Katkı seviyesinin renkler dizisinin sınırları içinde olduğundan emin ol
        final colorIndex = contribution.clamp(0, colors.length - 1);

        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(
            horizontalOffset +
                weekIndex * (adjustedCellSize + adjustedCellSpacing),
            verticalOffset +
                dayIndex * (adjustedCellSize + adjustedCellSpacing),
            adjustedCellSize,
            adjustedCellSize,
          ),
          topLeft: radius.topLeft,
          topRight: radius.topRight,
          bottomLeft: radius.bottomLeft,
          bottomRight: radius.bottomRight,
        );

        final paint = Paint()..color = colors[colorIndex];
        canvas.drawRRect(rect, paint);

        // Kenarlık çiz (varsa)
        if (contributionBorder != null) {
          // RRect için kenarlık çizme
          final borderPaint =
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = contributionBorder!.top.width;

          if (contributionBorder!.top.color != Colors.transparent) {
            borderPaint.color = contributionBorder!.top.color;
            canvas.drawRRect(rect, borderPaint);
          }
        }
      }
    }
  }

  /// Takvim etiketlerini çizer
  void _drawCalendarLabels(
    Canvas canvas,
    double baseCellSize,
    double horizontalOffset,
    double verticalOffset,
    double topPadding,
    double leftPadding,
    double adjustedCellSize,
    double adjustedCellSpacing,
  ) {
    // Varsayılan veya özelleştirilmiş metin stilleri
    final baseMonthLabelStyle = TextStyle(
      color: Colors.white70,
      fontSize: baseCellSize * 0.7,
      fontWeight: FontWeight.w500,
    );

    final effectiveMonthLabelStyle =
        monthLabelStyle?.copyWith(
          fontSize: monthLabelStyle?.fontSize ?? baseCellSize * 0.7,
        ) ??
        baseMonthLabelStyle;

    final baseDayLabelStyle = TextStyle(
      color: Colors.white70,
      fontSize: baseCellSize * 0.7,
      fontWeight: FontWeight.w500,
    );

    final effectiveDayLabelStyle =
        dayLabelStyle?.copyWith(
          fontSize: dayLabelStyle?.fontSize ?? baseCellSize * 0.7,
        ) ??
        baseDayLabelStyle;

    // Varsayılan veya özelleştirilmiş etiketler
    final monthNames =
        customMonthLabels ??
        [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];

    final dayNames = customDayLabels ?? ['Mon', 'Wed', 'Fri'];

    // Tüm ayları göster
    // Her ay için yaklaşık başlangıç haftasını belirle
    final weeksPerMonth = [2, 6, 11, 15, 19, 23, 28, 32, 36, 41, 45, 50];

    for (int i = 0; i < 12; i++) {
      final weekIndex = weeksPerMonth[i];
      final textSpan = TextSpan(
        text: monthNames[i],
        style: effectiveMonthLabelStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Aydaki metni hafta başlangıcına konumlandırmak yerine, metnin merkezi hafta ortasında olacak şekilde konumlandıralım
      final xPos =
          horizontalOffset +
          weekIndex * (adjustedCellSize + adjustedCellSpacing) -
          (textPainter.width / 2);
      final yPos = topPadding / 2 - textPainter.height / 2;

      textPainter.paint(canvas, Offset(xPos, yPos));
    }

    // Gün isimlerini çiz (solda) - Sadece 3 gün göster
    final dayIndices = [0, 2, 4]; // 0=Pazartesi, 2=Çarşamba, 4=Cuma

    for (int i = 0; i < 3; i++) {
      final textSpan = TextSpan(
        text: dayNames[i],
        style: effectiveDayLabelStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final xPos = leftPadding / 2 - textPainter.width / 2;
      final yPos =
          verticalOffset +
          dayIndices[i] * (adjustedCellSize + adjustedCellSpacing) +
          adjustedCellSize / 2 -
          textPainter.height / 2;

      textPainter.paint(canvas, Offset(xPos, yPos));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
