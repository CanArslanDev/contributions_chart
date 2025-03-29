import 'package:flutter/material.dart';

/// Utility class containing layout calculations for the contribution graph
class LayoutUtils {
  /// Width/height ratio of the GitHub contribution graph
  /// GitHub calendar contains 53 weeks (columns) and 7 days (rows)
  static const double aspectRatio = 53 / 7;

  /// Calculates widget dimensions (width and height)
  ///
  /// [width] Widget width
  /// [height] Widget height
  static Size calculateWidgetSize({double? width, double? height}) {
    assert(
      width != null || height != null,
      "At least width or height must be specified",
    );

    if (width != null && height != null) {
      // Both dimensions specified, select based on aspect ratio
      final providedRatio = width / height;

      if (providedRatio > aspectRatio) {
        // Width is too large for height, use height as constraint
        final calculatedWidth = height * aspectRatio;
        return Size(calculatedWidth, height);
      } else {
        // Height is too large for width, use width as constraint
        final calculatedHeight = width / aspectRatio;
        return Size(width, calculatedHeight);
      }
    } else if (width != null) {
      // Only width specified
      final calculatedHeight = width / aspectRatio;
      return Size(width, calculatedHeight);
    } else {
      // Only height specified (width must be null)
      final calculatedWidth = height! * aspectRatio;
      return Size(calculatedWidth, height);
    }
  }

  /// Calculates cell size and cell spacing
  ///
  /// [availableWidth] Available width
  /// [availableHeight] Available height
  /// [cellSpacing] Space between cells
  /// [squareBorderRadius] Border radius for squares
  static Map<String, double> calculateCellMetrics({
    required double availableWidth,
    required double availableHeight,
    required double cellSpacing,
    required double squareBorderRadius,
  }) {
    // Calculate cell dimensions
    final cellWidth = availableWidth / 53;
    final cellHeight = availableHeight / 7;
    final baseCellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

    // Scale padding and border radius values based on widget size
    final scaleFactor = baseCellSize / 15.0; // 15.0 is the reference value
    final scaledCellSpacing = cellSpacing * scaleFactor;
    final scaledBorderRadius = squareBorderRadius * scaleFactor;

    final cellSize = baseCellSize - (scaledCellSpacing / 2);

    // Calculate total area
    final totalWidth = 53 * cellSize + 52 * scaledCellSpacing;
    final totalHeight = 7 * cellSize + 6 * scaledCellSpacing;

    // Reduce cell size if exceeding widget dimensions
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

  /// Calculates day and week coordinates from touch position
  ///
  /// [tapPosition] Touch position
  /// [horizontalOffset] Horizontal offset
  /// [verticalOffset] Vertical offset
  /// [adjustedCellSize] Adjusted cell size
  /// [adjustedCellSpacing] Adjusted cell spacing
  static Map<String, int>? calculateTapCoordinates({
    required Offset tapPosition,
    required double horizontalOffset,
    required double verticalOffset,
    required double adjustedCellSize,
    required double adjustedCellSpacing,
  }) {
    // Calculate which week and day the tapped cell corresponds to
    final weekIndex =
        ((tapPosition.dx - horizontalOffset) /
                (adjustedCellSize + adjustedCellSpacing))
            .floor();
    final dayIndex =
        ((tapPosition.dy - verticalOffset) /
                (adjustedCellSize + adjustedCellSpacing))
            .floor();

    // Check if a valid cell was tapped
    if (weekIndex >= 0 && weekIndex < 53 && dayIndex >= 0 && dayIndex < 7) {
      return {'weekIndex': weekIndex, 'dayIndex': dayIndex};
    }

    return null;
  }
}
