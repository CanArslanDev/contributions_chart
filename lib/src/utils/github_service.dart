import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

import '../models/contribution_data.dart';

/// Service class for fetching GitHub contribution data
class GitHubService {
  /// Fetches contribution data for a specific user
  ///
  /// [username] GitHub username
  /// [year] Year to fetch data for (ignored if recent view is selected)
  /// [showRecent] Show recent contributions
  /// [urlPrefix] URL prefix (optional, typically used to bypass CORS issues)
  static Future<ContributionData> fetchContributions({
    required String username,
    required int year,
    bool showRecent = false,
    String? urlPrefix,
  }) async {
    final prefix = urlPrefix?.isNotEmpty == true ? urlPrefix! : '';
    String url;

    if (showRecent) {
      url = '${prefix}https://github.com/users/$username/contributions';
    } else {
      final String fromDate = "$year-01-01";
      final String toDate = "$year-12-31";
      url =
          '${prefix}https://github.com/users/$username/contributions?from=$fromDate&to=$toDate';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return _parseContributionHtml(response.body, year, showRecent);
      } else {
        // API returned an error
        return ContributionData.empty();
      }
    } catch (e) {
      // An error occurred during the request
      return ContributionData.empty();
    }
  }

  /// Parses HTML response to create contribution data
  static ContributionData _parseContributionHtml(
    String htmlBody,
    int year,
    bool isRecently,
  ) {
    final document = parser.parse(htmlBody);
    final squares = document.getElementsByClassName('ContributionCalendar-day');

    final contributionsList = List.generate(
      7,
      (i) => List.generate(53, (j) => 0),
    );

    // Find date range for "Recently" view
    DateTime? earliestDate;
    DateTime? latestDate;

    // First pass: Determine date range for "Recently" view
    if (isRecently) {
      for (var square in squares) {
        final dateStr = square.attributes['data-date'];
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          if (earliestDate == null || date.isBefore(earliestDate)) {
            earliestDate = date;
          }
          if (latestDate == null || date.isAfter(latestDate)) {
            latestDate = date;
          }
        }
      }
    }

    // Base date for calculations
    DateTime baseDate;
    if (isRecently && earliestDate != null) {
      baseDate = DateTime(
        earliestDate.year,
        earliestDate.month,
        earliestDate.day,
      );
    } else {
      baseDate = DateTime(year, 1, 1);
    }

    // Adjustment for GitHub's week start (Sunday = 0)
    final startWeekday = baseDate.weekday % 7;

    for (var square in squares) {
      final dateStr = square.attributes['data-date'];
      final count = int.tryParse(square.attributes['data-level'] ?? '0') ?? 0;

      if (dateStr != null) {
        final date = DateTime.parse(dateStr);
        // Calculate day of week according to GitHub (Sunday = 0)
        final dayOfWeek = date.weekday % 7;

        // Days since start date
        final daysSinceStart = date.difference(baseDate).inDays;

        // Week calculation (prevent negative indexes)
        final weekOfYear = ((daysSinceStart + startWeekday) / 7).floor();

        // Add data within valid range
        if (weekOfYear >= 0 && weekOfYear < 53 && dayOfWeek < 7) {
          contributionsList[dayOfWeek][weekOfYear] = count;
        }
      }
    }

    return ContributionData(
      matrix: contributionsList,
      baseDate: baseDate,
      startWeekday: baseDate.weekday,
      year: year,
      isRecentlyView: isRecently,
      isLoaded: true,
    );
  }
}
