import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

import '../models/contribution_data.dart';

/// GitHub katkı verilerini getiren servis sınıfı
class GitHubService {
  /// Belirli bir kullanıcının katkı verilerini getirir
  ///
  /// [username] GitHub kullanıcı adı
  /// [year] Veri getirilecek yıl (son zamanlarda seçiliyse yok sayılır)
  /// [showRecent] Son zamanlardaki katkıları göster
  /// [urlPrefix] URL ön eki (isteğe bağlı, genellikle CORS sorunlarını aşmak için kullanılır)
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
        // API hata verdi
        return ContributionData.empty();
      }
    } catch (e) {
      // İstek sırasında bir hata oluştu
      return ContributionData.empty();
    }
  }

  /// HTML yanıtını ayrıştırarak katkı verisini oluşturur
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

    // "Son zamanlarda" görünümü için tarih aralığını bul
    DateTime? earliestDate;
    DateTime? latestDate;

    // İlk geçiş: "Son zamanlarda" görünümü için tarih aralığını belirle
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

    // Hesaplama için temel tarih
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

    // GitHub'ın hafta başlangıcı için ayarlama (Pazar = 0)
    final startWeekday = baseDate.weekday % 7;

    for (var square in squares) {
      final dateStr = square.attributes['data-date'];
      final count = int.tryParse(square.attributes['data-level'] ?? '0') ?? 0;

      if (dateStr != null) {
        final date = DateTime.parse(dateStr);
        // GitHub'a göre haftanın günü hesapla (Pazar = 0)
        final dayOfWeek = date.weekday % 7;

        // Başlangıç tarihinden beri geçen gün sayısı
        final daysSinceStart = date.difference(baseDate).inDays;

        // Hafta hesaplama (negatif indeksleri önle)
        final weekOfYear = ((daysSinceStart + startWeekday) / 7).floor();

        // Geçerli aralıktaki verileri ekle
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
