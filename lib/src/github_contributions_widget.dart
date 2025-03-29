import 'package:flutter/material.dart';

import 'models/contribution_data.dart';
import 'painters/contributions_painter.dart';
import 'utils/github_service.dart';
import 'utils/layout_utils.dart';

part 'github_contributions_widget_state.dart';

/// GitHub katkı grafiğini gösteren bir widget
class GitHubContributionsWidget extends StatefulWidget {
  /// GitHub kullanıcı adı veya profil URL'si
  final String username;

  /// Katkıları gösterilecek yıl ([showRecent] true ise yok sayılır)
  final int? year;

  /// Belirli bir yıl yerine son katkıları göster
  final bool showRecent;

  /// Widget'ın genişliği (genişlik ve yükseklik belirtilirse, en-boy oranına göre biri seçilir)
  final double? width;

  /// Widget'ın yüksekliği (genişlik ve yükseklik belirtilirse, en-boy oranına göre biri seçilir)
  final double? height;

  /// Widget'ın arka plan rengi
  final Color backgroundColor;

  /// Farklı katkı seviyeleri için renk dizisi (0-4)
  final List<Color>? contributionColors;

  /// Tüm katkı seviyeleri için tek renk seçeneği (ayarlanırsa, contributionColors'ı geçersiz kılar)
  /// Katkı seviyesine göre opaklık uygulanır
  final Color? singleContributionColor;

  /// Tek renk modu için opaklık değerleri (0.0 - 1.0)
  /// Katkı seviyeleri 0-4 için 5 değer içermelidir
  final List<double>? singleColorOpacities;

  /// Katkı hücreleri arasındaki boşluk
  final double cellSpacing;

  /// Katkı karelerinin köşe yarıçapı
  final double squareBorderRadius;

  /// Takvim etiketlerini göster (üstte ay adları, solda gün adları)
  final bool showCalendar;

  /// Ay adları için metin stili
  final TextStyle? monthLabelStyle;

  /// Gün adları için metin stili
  final TextStyle? dayLabelStyle;

  /// Özel ay adları (belirtilirse 12 ad gereklidir)
  final List<String>? customMonthLabels;

  /// Özel gün adları (belirtilirse Pzt/Çrş/Cum için 3 ad içermelidir)
  final List<String>? customDayLabels;

  /// Her katkı hücresi için kenarlık
  final Border? contributionBorder;

  /// Katkısız hücreler için renk
  final Color? emptyColor;

  /// Özel yükleme göstergesi
  final Widget? loadingWidget;

  /// Özel tooltip metin formatı
  /// Katkı sayısı için {{count}} yer tutucusu kullanın
  /// Tarih için {{date}} yer tutucusu kullanın
  final String? tooltipTextFormat;

  /// Bir katkı hücresine dokunulduğunda çağrılacak callback
  final Function(DateTime date, int count)? onCellTap;

  /// URL ön eki (isteğe bağlı, genellikle CORS sorunlarını aşmak için kullanılır)
  final String? urlPrefix;

  /// GitHub katkı grafiği widget'ı oluşturur
  ///
  /// [githubUrl] bir GitHub kullanıcı adı veya tam bir GitHub profil URL'si olabilir
  /// [showRecent] true ise, [year] dikkate alınmaz
  /// [width] veya [height] değerlerinden en az biri sağlanmalıdır
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
         "Genişlik veya yükseklikten en az biri belirtilmelidir",
       ),
       assert(
         customMonthLabels == null || customMonthLabels.length == 12,
         "customMonthLabels tam olarak 12 ay adı içermelidir",
       ),
       assert(
         customDayLabels == null || customDayLabels.length == 3,
         "customDayLabels tam olarak 3 gün adı içermelidir",
       ),
       assert(
         singleColorOpacities == null || singleColorOpacities.length == 5,
         "singleColorOpacities tam olarak 5 değer içermelidir (0.0-1.0)",
       ),
       username = _extractUsername(githubUrl);

  /// GitHub URL'sinden kullanıcı adını çıkarır veya sadece bir kullanıcı adıysa aynı string'i döndürür
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
