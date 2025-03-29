import 'package:contributions_chart/contributions_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub Contributions Demo',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedYear = DateTime.now().year;
  bool _showRecent = false;
  bool _useSingleColor = false;
  bool _showBorder = false;
  bool _showCalendar = false;
  Color _singleColor = Colors.purple;
  Color _emptyColor = const Color(0xFF161b22);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    final String urlPrefix =
        kIsWeb ? 'https://api.codetabs.com/v1/proxy?quest=' : '';
    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161b22),
        title: Row(
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'contributions_chart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  TextSpan(
                    text: ' package',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'canarslan.me',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Controls
                Card(
                  color: const Color(0xFF161b22),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Display Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 24,
                          runSpacing: 16,
                          alignment: WrapAlignment.start,
                          children: [
                            // Year selection
                            DropdownButtonHideUnderline(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: DropdownButton<int>(
                                  value: _selectedYear,
                                  dropdownColor: const Color(0xFF161b22),
                                  style: const TextStyle(color: Colors.white),
                                  isDense: true,
                                  items: List.generate(
                                    5,
                                    (index) => DropdownMenuItem(
                                      value: DateTime.now().year - index,
                                      child: Text(
                                        '${DateTime.now().year - index}',
                                      ),
                                    ),
                                  ),
                                  onChanged:
                                      _showRecent
                                          ? null
                                          : (int? value) {
                                            if (value != null) {
                                              setState(() {
                                                _selectedYear = value;
                                              });
                                            }
                                          },
                                ),
                              ),
                            ),

                            // Show recent activities
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _showRecent,
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        _showRecent = value;
                                      });
                                    }
                                  },
                                ),
                                const Text('Show recent'),
                              ],
                            ),

                            // Use single color
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _useSingleColor,
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        _useSingleColor = value;
                                      });
                                    }
                                  },
                                ),
                                const Text('Use single color'),
                              ],
                            ),

                            // Show border
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _showBorder,
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        _showBorder = value;
                                      });
                                    }
                                  },
                                ),
                                const Text('Show border'),
                              ],
                            ),

                            // Show calendar
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _showCalendar,
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        _showCalendar = value;
                                      });
                                    }
                                  },
                                ),
                                const Text('Show calendar'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Example 1: Standard View
                DemoSection(
                  title: 'Standard View',
                  child: GitHubContributionsWidget(
                    githubUrl: 'https://github.com/CanArslanDev',
                    year: _showRecent ? null : _selectedYear,
                    showRecent: _showRecent,
                    showCalendar: _showCalendar,
                    width: screenWidth > 900 ? 900 : screenWidth - 48,
                    backgroundColor: const Color(0xFF0d1117),
                    urlPrefix: urlPrefix,
                    contributionColors:
                        _useSingleColor
                            ? null
                            : const [
                              Color(0xFF161b22),
                              Color(0xFF0E4429),
                              Color(0xFF006D32),
                              Color(0xFF26A641),
                              Color(0xFF39D353),
                            ],
                    singleContributionColor:
                        _useSingleColor ? _singleColor : null,
                    singleColorOpacities: const [0.1, 0.3, 0.5, 0.7, 0.9],
                    cellSpacing: 3.0,
                    contributionBorder:
                        _showBorder
                            ? Border.all(color: Colors.white30, width: 0.5)
                            : null,
                    emptyColor: _emptyColor,
                    tooltipTextFormat: "{{count}} contributions on {{date}}",
                    onCellTap: (date, count) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "$count contributions on ${date.day}/${date.month}/${date.year}",
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Example 2: Custom Text Styles and Labels
                DemoSection(
                  title: 'Custom Text Styles and Labels',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dark Mode
                      const Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GitHubContributionsWidget(
                        githubUrl: 'https://github.com/CanArslanDev',
                        year: 2023,
                        showRecent: false,
                        showCalendar: true,
                        width: screenWidth > 900 ? 900 : screenWidth - 48,
                        backgroundColor: const Color(0xFF121212),
                        urlPrefix: urlPrefix,
                        monthLabelStyle: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        dayLabelStyle: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                        customMonthLabels: [
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
                        ],
                        customDayLabels: ['Mon', 'Wed', 'Fri'],
                        contributionColors: const [
                          Color(0xFF1F1F1F),
                          Color(0xFF018786),
                          Color(0xFF03DAC5),
                          Color(0xFF00B3A6),
                          Color(0xFF01ECE4),
                        ],
                        squareBorderRadius: 4.0,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.white24, thickness: 1),
                      ),

                      // Light Mode
                      const Text(
                        'Light Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GitHubContributionsWidget(
                        githubUrl: 'https://github.com/CanArslanDev',
                        year: 2023,
                        showRecent: false,
                        showCalendar: true,
                        width: screenWidth > 900 ? 900 : screenWidth - 48,
                        backgroundColor: Colors.white,
                        urlPrefix: urlPrefix,
                        monthLabelStyle: const TextStyle(
                          color: Color(0xFF6200EE),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        dayLabelStyle: const TextStyle(
                          color: Color(0xFF3700B3),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                        customMonthLabels: [
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
                        ],
                        customDayLabels: ['Mon', 'Wed', 'Fri'],
                        contributionColors: const [
                          Color(0xFFF6F6F6),
                          Color(0xFFBBDEFB),
                          Color(0xFF90CAF9),
                          Color(0xFF64B5F6),
                          Color(0xFF42A5F5),
                        ],
                        squareBorderRadius: 4.0,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Example 3: Custom Loading Indicator
                DemoSection(
                  title: 'Custom Loading Indicator',
                  child: GitHubContributionsWidget(
                    githubUrl: 'https://github.com/CanArslanDev',
                    year: 2024,
                    width: screenWidth > 900 ? 900 : screenWidth - 48,
                    showCalendar: true,
                    loadingWidget: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.greenAccent),
                          SizedBox(width: 8),
                          Text('Loading GitHub contributions...'),
                        ],
                      ),
                    ),
                    urlPrefix: urlPrefix,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const DemoSection({Key? key, required this.title, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF161b22),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
