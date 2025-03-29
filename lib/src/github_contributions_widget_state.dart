part of 'github_contributions_widget.dart';

class _GitHubContributionsWidgetState extends State<GitHubContributionsWidget> {
  /// Contribution data
  ContributionData _contributionData = ContributionData.empty();

  /// Loading state
  bool _isLoading = true;

  /// Selected year
  late int _selectedYear;

  /// Is it in recent contributions mode?
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

    // Check if relevant properties have changed
    if (oldWidget.year != widget.year ||
        oldWidget.showRecent != widget.showRecent ||
        oldWidget.username != widget.username) {
      _selectedYear = widget.year ?? DateTime.now().year;
      _isRecentlyView = widget.showRecent;

      _fetchContributions();
    }
  }

  /// Fetch contribution data from GitHub
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

  /// Handle tap event
  void _handleTap(TapUpDetails details) {
    if (_isLoading || widget.onCellTap == null) return;

    // Margins for calendar labels
    double leftPadding = 0;
    double topPadding = 0;

    if (widget.showCalendar) {
      // Fixed values for available width/height ratio
      final widgetSize = LayoutUtils.calculateWidgetSize(
        width: widget.width,
        height: widget.height,
      );
      leftPadding = widgetSize.width * 0.06; // 6% left margin
      topPadding = widgetSize.height * 0.1; // 10% top margin
    }

    // Get tap position
    final tapPosition = details.localPosition;

    // Calculate widget dimensions
    final widgetSize = LayoutUtils.calculateWidgetSize(
      width: widget.width,
      height: widget.height,
    );

    // Available area
    final availableWidth = widgetSize.width - leftPadding;
    final availableHeight = widgetSize.height - topPadding;

    // Calculate cell metrics
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

    // Calculate the coordinates of the tapped cell
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

      // Get contribution value in the cell
      final contribution = _contributionData.matrix[dayIndex][weekIndex];

      // Calculate the date of the cell
      DateTime firstDayOfYear = DateTime(_selectedYear, 1, 1);
      int daysToAdd = (weekIndex * 7) + dayIndex;
      DateTime cellDate = firstDayOfYear.add(Duration(days: daysToAdd));

      // Call the callback
      widget.onCellTap!(cellDate, contribution);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate size based on aspect ratio
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
