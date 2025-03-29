## 1.0.0+1
- Updated pubspec.yaml in example folder
- Added Github address to pubspec.yaml file

## 1.0.0+1
- Updated various text elements throughout the package

## 1.0.0

- Created the GitHubContributionsWidget that displays GitHub-style contribution graphs
- Implemented HTML parsing of GitHub contribution data
- Added support for displaying contributions for a specific year or recent contributions
- Implemented responsive design with automatic scaling based on widget dimensions
- Added color customization options:
  - Custom color array for different contribution levels
  - Single color with opacity options
  - Custom background and empty cell colors
- Added styling options:
  - Cell spacing and border radius
  - Custom borders for contribution cells
- Added calendar label support with customization options:
  - Show/hide month and day labels
  - Custom month and day label text
  - Custom styles for labels
- Added tap/click handling for contribution cells with date and count information
- Created clean architecture with separation of concerns:
  - Model layer with ContributionData
  - Service layer for data fetching
  - Layout utilities for responsive design
  - Custom painter for rendering
- Added comprehensive documentation and examples
