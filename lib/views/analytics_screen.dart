import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../widgets/analytics_widgets.dart';
import '../widgets/gradient_background.dart';
import '../models/analytics_model.dart';
import '../utils/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsViewModel>(context, listen: false).loadAnalytics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Analytics'),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
          elevation: 0,        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.waterBlue,
          labelColor: Theme.of(context).textTheme.titleLarge?.color,
          unselectedLabelColor: Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.6),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Insights'),
            Tab(text: 'Progress'),
          ],
        ),
        actions: [
          Consumer<AnalyticsViewModel>(
            builder: (context, analyticsVM, child) {
              return PopupMenuButton<String>(
                icon: Icon(Icons.date_range, color: Theme.of(context).textTheme.titleLarge?.color),
                onSelected: (value) {
                  if (value == 'custom') {
                    _showDateRangePicker(context, analyticsVM);
                  } else {
                    analyticsVM.setAnalysisPeriod(value);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: '7days',
                    child: Text(
                      'Last 7 Days',
                      style: TextStyle(
                        fontWeight: analyticsVM.selectedPeriod == '7days'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: '30days',
                    child: Text(
                      'Last 30 Days',
                      style: TextStyle(
                        fontWeight: analyticsVM.selectedPeriod == '30days'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: '90days',
                    child: Text(
                      'Last 90 Days',
                      style: TextStyle(
                        fontWeight: analyticsVM.selectedPeriod == '90days'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'custom',
                    child: Text('Custom Range...'),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).textTheme.titleLarge?.color),
            onPressed: () {
              Provider.of<AnalyticsViewModel>(context, listen: false)
                  .refreshAnalytics();
            },
          ),
        ],
      ),
      body: Consumer<AnalyticsViewModel>(
        builder: (context, analyticsVM, child) {
          if (analyticsVM.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your hydration data...'),
                ],
              ),
            );
          }

          if (analyticsVM.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading analytics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analyticsVM.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => analyticsVM.refreshAnalytics(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!analyticsVM.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start tracking your water intake to see analytics',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(analyticsVM),
              _buildTrendsTab(analyticsVM),
              _buildInsightsTab(analyticsVM),
              _buildProgressTab(analyticsVM),
            ],          );
        },
      )
      ), // Close GradientBackground
    );
  }
  Widget _buildOverviewTab(AnalyticsViewModel analyticsVM) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding for nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Row
          Row(
            children: [
              Expanded(
                child: AnalyticsCard(
                  title: 'Daily Average',
                  value: analyticsVM.getFormattedAverage(),
                  subtitle: 'Past ${analyticsVM.analysisDays} days',
                  icon: Icons.water_drop,
                  color: AppColors.waterBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnalyticsCard(
                  title: 'Goal Rate',
                  value: analyticsVM.getFormattedGoalRate(),
                  subtitle: 'Goals completed',
                  icon: Icons.flag,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Streak and Total Row
          Row(
            children: [
              Expanded(
                child: AnalyticsCard(
                  title: 'Current Streak',
                  value: analyticsVM.getFormattedStreak(),
                  subtitle: 'Keep it up!',
                  icon: Icons.local_fire_department,
                  color: analyticsVM.getStreakColor(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnalyticsCard(
                  title: 'Total Intake',
                  value: analyticsVM.getFormattedTotalIntake(),
                  subtitle: 'Past ${analyticsVM.analysisDays} days',
                  icon: Icons.waves,
                  color: AppColors.waterBlueLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly Pattern
          _buildWeeklyPatternCard(analyticsVM),
          const SizedBox(height: 16),

          // Recent Performance
          _buildRecentPerformanceCard(analyticsVM),
        ],
      ),
    );
  }
  Widget _buildTrendsTab(AnalyticsViewModel analyticsVM) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding for nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trend Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        analyticsVM.getTrendIcon(),
                        color: analyticsVM.getTrendColor(),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hydration Trend',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              analyticsVM.trendDescription,
                              style: TextStyle(
                                color: analyticsVM.getTrendColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (analyticsVM.improvementPercentage != 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: analyticsVM.improvementPercentage > 0
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            analyticsVM.improvementPercentage > 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: analyticsVM.improvementPercentage > 0
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${analyticsVM.improvementPercentage.abs().toStringAsFixed(1)}% vs last week',
                            style: TextStyle(
                              color: analyticsVM.improvementPercentage > 0
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Comparison Cards
          if (analyticsVM.comparisons.isNotEmpty) ...[
            Text(
              'Performance Comparisons',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...analyticsVM.comparisons.map((comparison) =>
                _buildComparisonCard(comparison)),
            const SizedBox(height: 16),
          ],

          // Daily Performance Chart would go here
          // This would require a charting library like fl_chart
          _buildDailyPerformanceChart(analyticsVM),
        ],
      ),
    );
  }
  Widget _buildInsightsTab(AnalyticsViewModel analyticsVM) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding for nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized Insights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'AI-powered insights based on your hydration patterns',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          if (analyticsVM.priorityInsights.isNotEmpty) ...[
            ...analyticsVM.priorityInsights.map((insight) =>
                _buildInsightCard(insight)),
          ] else if (analyticsVM.insights.isNotEmpty) ...[
            ...analyticsVM.insights.map((insight) =>
                _buildInsightCard(insight)),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No insights available yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep tracking your water intake for a few more days to get personalized insights.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildProgressTab(AnalyticsViewModel analyticsVM) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding for nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildProgressIndicator(
                    'Daily Goal Achievement',
                    analyticsVM.analyticsData?.goalCompletionRate ?? 0.0,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),                  _buildProgressIndicator(
                    'Consistency Score',
                    analyticsVM.analyticsData?.goalCompletionRate ?? 0.0,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildProgressIndicator(
                    'Improvement Rate',
                    (analyticsVM.improvementPercentage / 100).clamp(0.0, 1.0),
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Best and Worst Days
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.green[700],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Best Day',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          analyticsVM.getBestDay(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.trending_down,
                          color: Colors.orange[700],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Focus Day',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          analyticsVM.getWorstDay(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPatternCard(AnalyticsViewModel analyticsVM) {
    final data = analyticsVM.analyticsData;
    if (data == null || data.weekdayPatterns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Pattern',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...data.weekdayPatterns.entries.map((entry) {
              final performance = analyticsVM.getWeekdayPerformance(entry.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        entry.key.substring(0, 3),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: performance,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.waterBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value.toInt()}ml',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPerformanceCard(AnalyticsViewModel analyticsVM) {
    final recentDays = analyticsVM.getRecentDays(7);
    if (recentDays.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Performance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recentDays.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = recentDays[index];
                  final goalMet = day.totalIntake >= day.goalAmount;
                  
                  return Container(
                    width: 40,
                    decoration: BoxDecoration(
                      color: goalMet ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: goalMet ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          goalMet ? Icons.check : Icons.close,
                          color: goalMet ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.date.day}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: goalMet ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(ComparisonData comparison) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'vs ${comparison.period == 'week' ? 'Last Week' : comparison.period == 'month' ? 'Last Month' : 'Previous Period'}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${comparison.currentPeriodAverage.toInt()}ml avg → ${comparison.previousPeriodAverage.toInt()}ml avg',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: comparison.isImprovement ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${comparison.isImprovement ? '+' : ''}${comparison.percentageChange.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: comparison.isImprovement ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(GoalInsight insight) {
    IconData iconData;
    Color iconColor;
    
    switch (insight.insightType) {
      case 'achievement':
        iconData = Icons.star;
        iconColor = Colors.amber;
        break;
      case 'warning':
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'suggestion':
        iconData = Icons.lightbulb;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconData, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (insight.relevanceScore > 0.8) ...[
                    const SizedBox(height: 8),
                    Text(
                      '💡 ${insight.recommendation}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(insight.relevanceScore * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildDailyPerformanceChart(AnalyticsViewModel analyticsVM) {
    // Placeholder for daily performance chart
    // This would require a charting library like fl_chart
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Performance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Chart will be displayed here',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '(Requires chart library)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    AnalyticsViewModel analyticsVM,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: analyticsVM.customStartDate != null &&
              analyticsVM.customEndDate != null
          ? DateTimeRange(
              start: analyticsVM.customStartDate!,
              end: analyticsVM.customEndDate!,
            )
          : null,
    );

    if (picked != null) {
      analyticsVM.setCustomDateRange(picked.start, picked.end);
    }
  }
}
