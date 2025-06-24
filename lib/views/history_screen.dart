import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/history_viewmodel.dart';
import '../widgets/common_widgets.dart';
import '../widgets/gradient_background.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryViewModel>(context, listen: false).initialize();
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
        backgroundColor: Colors.transparent,        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + kTextTabBarHeight),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AppBar(
                title: const Text('History & Stats'),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                scrolledUnderElevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Chart', icon: Icon(Icons.bar_chart)),
              Tab(text: 'History', icon: Icon(Icons.list)),
            ],
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<HistoryViewModel>(context, listen: false).refreshHistory();
            },
          ),        ],
              ),
            ),
          ),
        ),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildChartTab(viewModel),
              _buildHistoryTab(viewModel),
            ],
          );
        },
      ),
    ),
    );
  }
  Widget _buildChartTab(HistoryViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding for nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(viewModel),
          const SizedBox(height: 20),
          _buildWeeklyChart(viewModel),
          const SizedBox(height: 20),
          _buildInsights(viewModel),
        ],
      ),
    );
  }

  Widget _buildStatsCards(HistoryViewModel viewModel) {
    final averageWeekly = viewModel.getAverageIntake(7);
    final averageMonthly = viewModel.getAverageIntake(30);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Weekly Average',
            WaterCalculator.formatAmount(averageWeekly.round()),
            Icons.calendar_view_week,
            AppColors.waterBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Monthly Average',
            WaterCalculator.formatAmount(averageMonthly.round()),
            Icons.calendar_month,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(HistoryViewModel viewModel) {
    final weeklyTotals = viewModel.getWeeklyTotals();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Intake',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: weeklyTotals.isEmpty                  ? Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: AppColors.getTextLight(context)),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: weeklyTotals.values.isNotEmpty 
                            ? weeklyTotals.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2
                            : 3000,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: AppColors.waterBlue,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final date = weeklyTotals.keys.elementAt(groupIndex);
                              final amount = rod.toY.round();                              return BarTooltipItem(
                                '${DateTimeUtils.formatDateShort(DateTime.parse(date))}\n${WaterCalculator.formatAmount(amount)}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < weeklyTotals.length) {
                                  final date = weeklyTotals.keys.elementAt(value.toInt());
                                  final parsedDate = DateTime.parse(date);                                  return Text(
                                    DateTimeUtils.formatDateShort(parsedDate),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${(value / 1000).toStringAsFixed(1)}L',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: weeklyTotals.entries.map((entry) {
                          final index = weeklyTotals.keys.toList().indexOf(entry.key);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: AppColors.waterBlue,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(HistoryViewModel viewModel) {
    final weeklyAverage = viewModel.getAverageIntake(7);
    final monthlyAverage = viewModel.getAverageIntake(30);
    
    List<Widget> insights = [];
    
    if (weeklyAverage > monthlyAverage) {
      insights.add(_buildInsightCard(
        'Great Progress!',
        'Your weekly average is higher than your monthly average. Keep it up!',
        Icons.trending_up,
        AppColors.success,
      ));
    } else if (weeklyAverage < monthlyAverage * 0.8) {
      insights.add(_buildInsightCard(
        'Room for Improvement',
        'Your weekly average is lower than usual. Try to drink more water!',
        Icons.trending_down,
        AppColors.warning,
      ));
    }
    
    if (weeklyAverage >= 2000) {
      insights.add(_buildInsightCard(
        'Excellent Hydration!',
        'You\'re meeting the recommended daily water intake. Well done!',
        Icons.star,
        AppColors.success,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        Text(
          'Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        if (insights.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [                  Icon(Icons.lightbulb, color: AppColors.getTextLight(context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Keep tracking your water intake to get personalized insights!',
                      style: TextStyle(color: AppColors.getTextSecondary(context)),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...insights,
      ],
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(HistoryViewModel viewModel) {
    final groupedHistory = viewModel.getGroupedHistory();

    if (groupedHistory.isEmpty) {
      return const EmptyStateWidget(
        title: 'No History Yet',
        subtitle: 'Start tracking your water intake to see your history here.',
        icon: Icons.history,
      );
    }    return RefreshIndicator(
      onRefresh: viewModel.refreshHistory,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding for nav
        itemCount: groupedHistory.length,
        itemBuilder: (context, index) {
          final dayData = groupedHistory[index];
          final date = DateTime.parse(dayData['date']);
          final totalAmount = dayData['totalAmount'] as int;
          final intakes = dayData['intakes'] as List;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                DateTimeUtils.getRelativeDate(date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),              subtitle: Text(
                '${WaterCalculator.formatAmount(totalAmount)} • ${intakes.length} entries',
                style: TextStyle(color: AppColors.getTextSecondary(context)),
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.waterBlueLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppColors.waterBlue,
                ),
              ),
              children: intakes.map<Widget>((intake) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                  leading: const Icon(
                    Icons.water_drop,
                    color: AppColors.waterBlueLight,
                    size: 20,
                  ),
                  title: Text(WaterCalculator.formatAmount(intake.amount)),
                  subtitle: Text(DateTimeUtils.formatTime(intake.timestamp)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                    onPressed: () => _showDeleteConfirmation(context, viewModel, intake),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, HistoryViewModel viewModel, intake) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: Text('Are you sure you want to delete this ${WaterCalculator.formatAmount(intake.amount)} entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.deleteIntake(intake);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
