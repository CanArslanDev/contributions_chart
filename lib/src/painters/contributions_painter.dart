import 'package:flutter/material.dart';

import '../models/contribution_data.dart';

/// CustomPainter class that draws the GitHub contribution graph
class ContributionsPainter extends CustomPainter {
  /// Contribution data
  final ContributionData data;

  /// Spacing between cells
  final double cellSpacing;

  /// Colors based on contribution levels (0-4)
  final List<Color>? customColors;

  /// Base color for single color mode (used instead of customColors if specified)
  final Color? singleContributionColor;

  /// Opacity values for single color mode (0.0 - 1.0)
  final List<double>? singleColorOpacities;

  /// Background color
  final Color backgroundColor;

  /// Corner radius of contribution squares
  final double squareBorderRadius;

  /// Show calendar labels
  final bool showCalendar;

  /// Text style for month labels
  final TextStyle? monthLabelStyle;

  /// Text style for day labels
  final TextStyle? dayLabelStyle;

  /// Custom month labels (requires 12 names if specified)
  final List<String>? customMonthLabels;

  /// Custom day labels (requires 3 names if specified)
  final List<String>? customDayLabels;

  /// Border for each contribution cell
  final Border? contributionBorder;

  /// Color for cells with no contributions
  final Color? emptyColor;

  /// Custom tooltip text format
  final String? tooltipTextFormat;

  /// Callback when a cell is tapped
  final Function(DateTime date, int count)? onCellTap;

  /// Creates a CustomPainter that draws GitHub contribution graph
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
    // First draw the background color - ensure it covers the entire area
    final backgroundPaint = Paint()..color = backgroundColor;
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(backgroundRect, backgroundPaint);

    // Margins for calendar labels
    double leftPadding = 0;
    double topPadding = 0;

    if (showCalendar) {
      // Add left and top margins when in calendar view
      leftPadding = size.width * 0.06; // 6% left margin
      topPadding = size.height * 0.1; // 10% top margin
    }

    // Available area for contribution graph
    final availableWidth = size.width - leftPadding;
    final availableHeight = size.height - topPadding;

    // Calculate cell dimensions
    final cellWidth = availableWidth / 53;
    final cellHeight = availableHeight / 7;
    final baseCellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

    // Scale cell spacing (padding) and border radius values based on widget size
    final scaleFactor =
        baseCellSize / 15.0; // 15.0 is reference value (for 120 height)
    final scaledCellSpacing = cellSpacing * scaleFactor;
    final scaledBorderRadius = squareBorderRadius * scaleFactor;

    final cellSize = baseCellSize - (scaledCellSpacing / 2);

    // Default contribution colors
    final defaultColors = [
      emptyColor ?? Color(0xFF161b22),
      Color(0xFF0E4429),
      Color(0xFF006D32),
      Color(0xFF26A641),
      Color(0xFF39D353),
    ];

    // Single color mode
    List<Color> colors;
    if (singleContributionColor != null) {
      final defaultOpacities = [0.1, 0.3, 0.5, 0.7, 0.9];
      final opacities = singleColorOpacities ?? defaultOpacities;

      colors = List.generate(5, (index) {
        if (index == 0 && emptyColor != null) {
          return emptyColor!;
        }

        // Use withAlpha instead of withOpacity for more precise values
        final alpha = (opacities[index] * 255).round();
        return singleContributionColor!.withAlpha(alpha);
      });
    } else {
      colors = customColors ?? defaultColors;
    }

    final radius = BorderRadius.circular(scaledBorderRadius);

    // Calculate total area and offsets
    final totalWidth = 53 * cellSize + 52 * scaledCellSpacing;
    final totalHeight = 7 * cellSize + 6 * scaledCellSpacing;

    // Reduce cell size if it exceeds widget dimensions
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

    // Calculate start and end dates of the year
    final firstDayOfYear = DateTime(data.year, 1, 1);
    final lastDayOfYear = DateTime(data.year, 12, 31);

    // First day of the year's week (Sunday = 0)
    final firstDayWeekday = firstDayOfYear.weekday % 7;

    // Last day of the year's week (Sunday = 0)
    final lastDayWeekday = lastDayOfYear.weekday % 7;

    // Check if showing recently view
    bool showingRecentlyView = data.isRecentlyView;

    // Calendar labels
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

    // Draw contribution squares
    for (var weekIndex = 0; weekIndex < 53; weekIndex++) {
      for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
        // Skip days before start day in first week - unless in recently mode
        if (weekIndex == 0 &&
            dayIndex < firstDayWeekday &&
            !showingRecentlyView) {
          continue;
        }

        // Skip days after last day in last week
        if (weekIndex == 52 && dayIndex > lastDayWeekday) {
          continue;
        }

        final contribution = data.matrix[dayIndex][weekIndex];

        // Ensure contribution level is within bounds of colors array
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

        // Draw border (if specified)
        if (contributionBorder != null) {
          // Border drawing for RRect
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

  /// Draws calendar labels
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
    // Default or customized text styles
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

    // Default or customized labels
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

    // Show all months
    // Determine approximate starting week for each month
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

      // Position text with its center at the middle of the week instead of at the beginning
      final xPos =
          horizontalOffset +
          weekIndex * (adjustedCellSize + adjustedCellSpacing) -
          (textPainter.width / 2);
      final yPos = topPadding / 2 - textPainter.height / 2;

      textPainter.paint(canvas, Offset(xPos, yPos));
    }

    // Draw day names (on left) - Show only 3 days
    final dayIndices = [0, 2, 4]; // 0=Monday, 2=Wednesday, 4=Friday

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
