# Hydrify Advanced Analytics

## Overview
The Advanced Analytics feature provides comprehensive insights into your hydration patterns and helps you optimize your water intake habits.

## Features Added

### 1. Analytics Models (`lib/models/analytics_model.dart`)
- **AnalyticsData**: Comprehensive analytics data structure
- **DailyStats**: Daily hydration statistics
- **MonthlyStats**: Monthly aggregated data
- **HourlyPattern**: Hourly drinking patterns
- **StreakInfo**: Streak tracking with history
- **ComparisonData**: Period-over-period comparisons
- **TrendData**: Trend analysis with insights
- **GoalInsight**: AI-powered personalized insights

### 2. Analytics Service (`lib/services/analytics_service.dart`)
- **Data Analysis**: Processes raw water intake data into meaningful insights
- **Trend Calculation**: Linear regression for trend analysis
- **Pattern Recognition**: Identifies weekly and hourly patterns
- **Streak Calculation**: Tracks current and historical streaks
- **Comparison Engine**: Compares performance across different periods
- **Insight Generation**: Creates personalized recommendations

### 3. Analytics ViewModel (`lib/viewmodels/analytics_viewmodel.dart`)
- **State Management**: Manages analytics data and loading states
- **Period Selection**: 7 days, 30 days, 90 days, or custom range
- **Reactive Updates**: Automatically refreshes when data changes
- **Helper Methods**: Formatted strings and colors for UI
- **Error Handling**: Graceful error management

### 4. Analytics Widgets (`lib/widgets/analytics_widgets.dart`)
- **AnalyticsCard**: Reusable metric display cards
- **WeeklyChart**: Visual representation of weekly progress
- **HourlyPatternChart**: Shows drinking patterns throughout the day
- **InsightCard**: Displays personalized insights with recommendations
- **ComparisonWidget**: Shows period-over-period comparisons

### 5. Analytics Screen (`lib/views/analytics_screen.dart`)
Four main tabs providing different perspectives:

#### Overview Tab
- Key metrics dashboard (daily average, goal rate, streak, total intake)
- Weekly pattern visualization
- Recent performance indicators

#### Trends Tab
- Trend analysis with visual indicators
- Performance comparisons (week-over-week, month-over-month)
- Daily performance charts

#### Insights Tab
- AI-powered personalized insights
- Actionable recommendations
- Relevance scoring for prioritization

#### Progress Tab
- Progress indicators for various metrics
- Best and worst performing days
- Consistency scoring

## Key Analytics Metrics

### 1. Basic Metrics
- **Daily Average**: Average water intake over selected period
- **Goal Completion Rate**: Percentage of days goals were met
- **Current Streak**: Consecutive days of meeting goals
- **Total Intake**: Sum of water consumed in period

### 2. Pattern Analysis
- **Weekly Patterns**: Performance by day of week
- **Hourly Patterns**: Drinking frequency by hour
- **Consistency Score**: Measure of intake regularity

### 3. Trend Analysis
- **Linear Trend**: Mathematical trend calculation
- **Percentage Changes**: Period-over-period comparisons
- **Improvement Rate**: Rate of progress over time

### 4. Streak Analysis
- **Current Streak**: Active consecutive goal days
- **Longest Streak**: Historical best performance
- **Streak History**: Complete streak timeline

## Personalized Insights

The system generates insights based on:
- **Goal Achievement Patterns**
- **Timing Optimization**
- **Performance Consistency**
- **Streak Opportunities**
- **Weekly Pattern Analysis**

Each insight includes:
- Clear description of the pattern
- Actionable recommendation
- Relevance score (0-100%)

## Usage

### Navigation
1. Use the bottom navigation to access the Analytics tab
2. Or use the Debug Panel button to open analytics directly

### Period Selection
- Tap the date range icon in the app bar
- Choose from preset periods (7, 30, 90 days)
- Or select a custom date range

### Tab Navigation
- **Overview**: Quick metrics and recent performance
- **Trends**: Historical analysis and comparisons
- **Insights**: Personalized recommendations
- **Progress**: Detailed performance breakdowns

## Technical Architecture

### Data Flow
1. Raw water intake data from database
2. Processing through AnalyticsService
3. State management via AnalyticsViewModel
4. UI rendering with specialized widgets

### Performance Optimizations
- Efficient data grouping and aggregation
- Lazy loading of complex calculations
- Cached results for repeated queries
- Responsive UI with loading states

### Error Handling
- Graceful degradation when data is unavailable
- User-friendly error messages
- Retry mechanisms for failed operations

## Future Enhancements

Potential additions for the analytics system:
- Export analytics to PDF/CSV
- Social sharing of achievements
- Advanced chart visualizations (using fl_chart)
- Predictive analytics
- Integration with health platforms
- Customizable dashboard layouts
- Voice insights and summaries

## Getting Started

1. Ensure you have water intake data in your app
2. Navigate to the Analytics tab
3. Explore different time periods and tabs
4. Review personalized insights for optimization tips

The analytics system becomes more accurate and insightful as you continue to track your water intake consistently over time.
