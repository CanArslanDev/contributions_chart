part of 'github_contributions_widget.dart';

class _GitHubContributionsWidgetState extends State<GitHubContributionsWidget> {
  /// Katkı verisi
  ContributionData _contributionData = ContributionData.empty();

  /// Yükleniyor durumu
  bool _isLoading = true;

  /// Seçili yıl
  late int _selectedYear;

  /// Son katkılar modu mu?
  late bool _isRecentlyView;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.year ?? DateTime.now().year;
    _isRecentlyView = widget.showRecent;

    _fetchContributions();
  }

  @override
  void didUpdateWidget(GitHubContributionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // İlgili özellikler değişti mi kontrol et
    if (oldWidget.year != widget.year ||
        oldWidget.showRecent != widget.showRecent ||
        oldWidget.username != widget.username) {
      _selectedYear = widget.year ?? DateTime.now().year;
      _isRecentlyView = widget.showRecent;

      _fetchContributions();
    }
  }

  /// GitHub'dan katkı verilerini getir
  Future<void> _fetchContributions() async {
    setState(() {
      _isLoading = true;
    });

    final contributionData = await GitHubService.fetchContributions(
      username: widget.username,
      year: _selectedYear,
      showRecent: _isRecentlyView,
      urlPrefix: widget.urlPrefix,
    );

    if (mounted) {
      setState(() {
        _contributionData = contributionData;
        _isLoading = false;
      });
    }
  }

  /// Dokunma olayını işle
  void _handleTap(TapUpDetails details) {
    if (_isLoading || widget.onCellTap == null) return;

    // Takvim etiketleri için kenar boşlukları
    double leftPadding = 0;
    double topPadding = 0;

    if (widget.showCalendar) {
      // Kullanılabilir genişlik/yükseklik oranı için sabit değerler
      final widgetSize = LayoutUtils.calculateWidgetSize(
        width: widget.width,
        height: widget.height,
      );
      leftPadding = widgetSize.width * 0.06; // %6 sol kenar boşluğu
      topPadding = widgetSize.height * 0.1; // %10 üst kenar boşluğu
    }

    // Tıklama konumunu al
    final tapPosition = details.localPosition;

    // Widget boyutlarını hesapla
    final widgetSize = LayoutUtils.calculateWidgetSize(
      width: widget.width,
      height: widget.height,
    );

    // Kullanılabilir alan
    final availableWidth = widgetSize.width - leftPadding;
    final availableHeight = widgetSize.height - topPadding;

    // Hücre ölçümlerini hesapla
    final metrics = LayoutUtils.calculateCellMetrics(
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      cellSpacing: widget.cellSpacing,
      squareBorderRadius: widget.squareBorderRadius,
    );

    final adjustedTotalWidth =
        53 * metrics['adjustedCellSize']! +
        52 * metrics['adjustedCellSpacing']!;
    final adjustedTotalHeight =
        7 * metrics['adjustedCellSize']! + 6 * metrics['adjustedCellSpacing']!;

    final horizontalOffset =
        leftPadding + (availableWidth - adjustedTotalWidth) / 2;
    final verticalOffset =
        topPadding + (availableHeight - adjustedTotalHeight) / 2;

    // Tıklanan hücrenin koordinatlarını hesapla
    final coordinates = LayoutUtils.calculateTapCoordinates(
      tapPosition: tapPosition,
      horizontalOffset: horizontalOffset,
      verticalOffset: verticalOffset,
      adjustedCellSize: metrics['adjustedCellSize']!,
      adjustedCellSpacing: metrics['adjustedCellSpacing']!,
    );

    if (coordinates != null) {
      final weekIndex = coordinates['weekIndex']!;
      final dayIndex = coordinates['dayIndex']!;

      // Hücredeki katkı değerini al
      final contribution = _contributionData.matrix[dayIndex][weekIndex];

      // Hücrenin tarihini hesapla
      DateTime firstDayOfYear = DateTime(_selectedYear, 1, 1);
      int daysToAdd = (weekIndex * 7) + dayIndex;
      DateTime cellDate = firstDayOfYear.add(Duration(days: daysToAdd));

      // Callback'i çağır
      widget.onCellTap!(cellDate, contribution);
    }
  }

  @override
  Widget build(BuildContext context) {
    // En-boy oranına göre boyut hesapla
    final widgetSize = LayoutUtils.calculateWidgetSize(
      width: widget.width,
      height: widget.height,
    );

    return SizedBox(
      width: widgetSize.width,
      height: widgetSize.height,
      child:
          _isLoading
              ? widget.loadingWidget ??
                  const Center(child: CircularProgressIndicator())
              : widget.onCellTap != null
              ? GestureDetector(
                onTapUp: _handleTap,
                child: CustomPaint(
                  painter: ContributionsPainter(
                    data: _contributionData,
                    cellSpacing: widget.cellSpacing,
                    customColors: widget.contributionColors,
                    singleContributionColor: widget.singleContributionColor,
                    singleColorOpacities: widget.singleColorOpacities,
                    backgroundColor: widget.backgroundColor,
                    squareBorderRadius: widget.squareBorderRadius,
                    showCalendar: widget.showCalendar,
                    monthLabelStyle: widget.monthLabelStyle,
                    dayLabelStyle: widget.dayLabelStyle,
                    customMonthLabels: widget.customMonthLabels,
                    customDayLabels: widget.customDayLabels,
                    contributionBorder: widget.contributionBorder,
                    emptyColor: widget.emptyColor,
                    tooltipTextFormat: widget.tooltipTextFormat,
                    onCellTap: widget.onCellTap,
                  ),
                  size: Size(widgetSize.width, widgetSize.height),
                ),
              )
              : CustomPaint(
                painter: ContributionsPainter(
                  data: _contributionData,
                  cellSpacing: widget.cellSpacing,
                  customColors: widget.contributionColors,
                  singleContributionColor: widget.singleContributionColor,
                  singleColorOpacities: widget.singleColorOpacities,
                  backgroundColor: widget.backgroundColor,
                  squareBorderRadius: widget.squareBorderRadius,
                  showCalendar: widget.showCalendar,
                  monthLabelStyle: widget.monthLabelStyle,
                  dayLabelStyle: widget.dayLabelStyle,
                  customMonthLabels: widget.customMonthLabels,
                  customDayLabels: widget.customDayLabels,
                  contributionBorder: widget.contributionBorder,
                  emptyColor: widget.emptyColor,
                  tooltipTextFormat: widget.tooltipTextFormat,
                  onCellTap: widget.onCellTap,
                ),
                size: Size(widgetSize.width, widgetSize.height),
              ),
    );
  }
}
