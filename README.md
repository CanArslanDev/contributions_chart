# Contributions Chart

A Flutter widget that displays a GitHub-style contributions graph in your Flutter application.
![contributions_chart_radius](https://github.com/user-attachments/assets/cc15458c-5e23-4229-932e-952de6e3aefb)


## Features

- Visual representation similar to GitHub profile contribution graphs
- Display contributions for an entire year or recent contributions
- Highly customizable colors and styling
- Support for tap/click interactions on contribution cells
- Calendar labels (month names on top, day names on left)
- Automatic scaling based on widget dimensions
- Responsive design that works on all screen sizes
- Light and dark theme support through color customization

## Installation

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  contributions_chart: ^1.0.0+2
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:contributions_chart/contributions_chart.dart';

// ...

GitHubContributionsWidget(
  githubUrl: 'https://github.com/username',
  width: 300,
  height: 100,
),
```

### Advanced Usage with Customization

```dart
GitHubContributionsWidget(
  githubUrl: 'username', // GitHub username or full profile URL
  year: 2023, // Specific year to display (default: current year)
  showRecent: false, // Show recent contributions instead
  width: 350, // Width (at least one of width or height is required)
  height: 120, // Height
  backgroundColor: Colors.black, // Background color
  contributionColors: [ // Colors for contribution levels (0-4)
    Colors.grey.shade900, // 0 contributions
    Colors.blue.shade900, // 1 contribution
    Colors.blue.shade700, // 2 contributions
    Colors.blue.shade500, // 3 contributions
    Colors.blue.shade300, // 4+ contributions
  ],
  // Alternatively, use a single color with different opacities:
  singleContributionColor: Colors.blue,
  singleColorOpacities: [0.1, 0.3, 0.5, 0.7, 0.9],
  
  cellSpacing: 2.0, // Spacing between cells
  squareBorderRadius: 2.0, // Border radius for contribution squares
  showCalendar: true, // Show month and day labels
  
  // Calendar label styling
  monthLabelStyle: TextStyle(color: Colors.white, fontSize: 10),
  dayLabelStyle: TextStyle(color: Colors.white, fontSize: 10),
  customMonthLabels: ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
  customDayLabels: ['M', 'W', 'F'],
  
  // Cell border
  contributionBorder: Border.all(color: Colors.white10, width: 0.5),
  emptyColor: Colors.grey.shade800, // Color for cells with no contributions
  
  // Custom loading indicator
  loadingWidget: Center(child: CircularProgressIndicator()),
  
  // Tap/click handler for cells
  onCellTap: (DateTime date, int contributionCount) {
    print('On $date: $contributionCount contributions');
  },
);
```

## Widget Properties

| Property | Type | Description |
|----------|------|-------------|
| `githubUrl` | `String` | GitHub username or full profile URL (required) |
| `year` | `int?` | Year to display contributions for (default: current year) |
| `showRecent` | `bool` | Show recent contributions instead of a specific year |
| `width` | `double?` | Width of the widget (one of width or height required) |
| `height` | `double?` | Height of the widget (one of width or height required) |
| `backgroundColor` | `Color` | Background color of the widget |
| `contributionColors` | `List<Color>?` | Array of colors for different contribution levels (0-4) |
| `singleContributionColor` | `Color?` | Single color option (if set, will override contributionColors) |
| `singleColorOpacities` | `List<double>?` | Opacity values for single color mode (0.0 to 1.0) |
| `cellSpacing` | `double` | Spacing between contribution cells |
| `squareBorderRadius` | `double` | Border radius for contribution squares |
| `showCalendar` | `bool` | Show calendar labels (month names on top, day names on left) |
| `monthLabelStyle` | `TextStyle?` | Text style for month names |
| `dayLabelStyle` | `TextStyle?` | Text style for day names |
| `customMonthLabels` | `List<String>?` | Custom month names (12 names required if provided) |
| `customDayLabels` | `List<String>?` | Custom day names (3 names required for Mon/Wed/Fri) |
| `contributionBorder` | `Border?` | Border for each contribution cell |
| `emptyColor` | `Color?` | Color for cells with no contributions |
| `loadingWidget` | `Widget?` | Custom loading widget |
| `tooltipTextFormat` | `String?` | Custom tooltip text format |
| `onCellTap` | `Function(DateTime, int)?` | Callback when a contribution cell is tapped |
| `urlPrefix` | `String?` | URL prefix (optional, typically used to bypass CORS issues) |

## How It Works

The `GitHubContributionsWidget` fetches contribution data from GitHub for the specified user and year. It works by:

1. Parsing GitHub's contribution calendar HTML
2. Extracting contribution data from the DOM
3. Organizing data into a matrix representation
4. Rendering a visual representation using Flutter's `CustomPainter`

The widget is responsive and will adapt to whatever size you provide, maintaining the proper aspect ratio of the GitHub contribution graph.

## Architecture

The package follows a clean architecture with several components:

- `GitHubContributionsWidget`: Main widget class with the public API
- `ContributionData`: Data model for contribution matrix
- `GitHubService`: Service for fetching and parsing GitHub contribution data
- `ContributionsPainter`: CustomPainter for rendering the contribution graph
- `LayoutUtils`: Helper functions for layout calculations

## Examples

### Default Dark Theme (GitHub Style)

```dart
GitHubContributionsWidget(
  githubUrl: 'username',
  width: 400,
  height: 150,
),
```

### Custom Colors

```dart
GitHubContributionsWidget(
  githubUrl: 'username',
  width: 400,
  height: 150,
  backgroundColor: Colors.white,
  contributionColors: [
    Colors.grey.shade200,
    Colors.green.shade100,
    Colors.green.shade300,
    Colors.green.shade500,
    Colors.green.shade700,
  ],
),
```

### Single Color with Opacity Levels

```dart
GitHubContributionsWidget(
  githubUrl: 'username',
  width: 400,
  height: 150,
  singleContributionColor: Colors.purple,
  singleColorOpacities: [0.1, 0.25, 0.5, 0.75, 1.0],
),
```

### With Calendar Labels

```dart
GitHubContributionsWidget(
  githubUrl: 'username',
  width: 400,
  height: 150,
  showCalendar: true,
),
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open issues for bugs, feature requests, or enhancements.

## License

This package is distributed under the MIT License.
