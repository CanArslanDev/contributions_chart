import 'package:flutter/material.dart';

import 'models/contribution_data.dart';
import 'painters/contributions_painter.dart';
import 'utils/github_service.dart';
import 'utils/layout_utils.dart';

part 'github_contributions_widget_state.dart';

/// A widget that displays GitHub contribution graph
class GitHubContributionsWidget extends StatefulWidget {
  /// GitHub username or profile URL
  final String username;

  /// Year to display contributions for (ignored if [showRecent] is true)
  final int? year;

  /// Show recent contributions instead of a specific year
  final bool showRecent;

  /// Width of the widget (if both width and height are specified, one will be chosen based on aspect ratio)
  final double? width;

  /// Height of the widget (if both width and height are specified, one will be chosen based on aspect ratio)
  final double? height;

  /// Background color of the widget
  final Color backgroundColor;

  /// Color array for different contribution levels (0-4)
  final List<Color>? contributionColors;

  /// Single color option for all contribution levels (overrides contributionColors if set)
  /// Opacity is applied according to contribution level
  final Color? singleContributionColor;

  /// Opacity values for single color mode (0.0 - 1.0)
  /// Must contain 5 values for contribution levels 0-4
  final List<double>? singleColorOpacities;

  /// Spacing between contribution cells
  final double cellSpacing;

  /// Corner radius of contribution squares
  final double squareBorderRadius;

  /// Show calendar labels (month names at top, day names on left)
  final bool showCalendar;

  /// Text style for month names
  final TextStyle? monthLabelStyle;

  /// Text style for day names
  final TextStyle? dayLabelStyle;

  /// Custom month names (requires 12 names if specified)
  final List<String>? customMonthLabels;

  /// Custom day names (should contain 3 names for Mon/Wed/Fri if specified)
  final List<String>? customDayLabels;

  /// Border for each contribution cell
  final Border? contributionBorder;

  /// Color for cells with no contributions
  final Color? emptyColor;

  /// Custom loading indicator
  final Widget? loadingWidget;

  /// Custom tooltip text format
  /// Use {{count}} placeholder for contribution count
  /// Use {{date}} placeholder for date
  final String? tooltipTextFormat;

  /// Callback when a contribution cell is tapped
  final Function(DateTime date, int count)? onCellTap;

  /// URL prefix (optional, typically used to bypass CORS issues)
  final String? urlPrefix;

  /// Creates a GitHub contribution graph widget
  ///
  /// [githubUrl] can be a GitHub username or a complete GitHub profile URL
  /// If [showRecent] is true, [year] is ignored
  /// At least one of [width] or [height] values must be provided
  GitHubContributionsWidget({
    super.key,
    required String githubUrl,
    this.year,
    this.showRecent = false,
    this.width,
    this.height,
    this.backgroundColor = const Color(0xFF0d1117),
    this.contributionColors,
    this.singleContributionColor,
    this.singleColorOpacities,
    this.cellSpacing = 4.0,
    this.squareBorderRadius = 2.0,
    this.showCalendar = false,
    this.monthLabelStyle,
    this.dayLabelStyle,
    this.customMonthLabels,
    this.customDayLabels,
    this.contributionBorder,
    this.emptyColor,
    this.loadingWidget,
    this.tooltipTextFormat,
    this.onCellTap,
    this.urlPrefix,
  }) : assert(
         width != null || height != null,
         "At least one of width or height must be specified",
       ),
       assert(
         customMonthLabels == null || customMonthLabels.length == 12,
         "customMonthLabels must contain exactly 12 month names",
       ),
       assert(
         customDayLabels == null || customDayLabels.length == 3,
         "customDayLabels must contain exactly 3 day names",
       ),
       assert(
         singleColorOpacities == null || singleColorOpacities.length == 5,
         "singleColorOpacities must contain exactly 5 values (0.0-1.0)",
       ),
       username = _extractUsername(githubUrl);

  /// Extracts username from GitHub URL or returns the same string if it's just a username
  static String _extractUsername(String githubUrl) {
    if (githubUrl.contains('github.com/')) {
      return githubUrl.split('/').last;
    }
    return githubUrl;
  }

  @override
  State<GitHubContributionsWidget> createState() =>
      _GitHubContributionsWidgetState();
}
