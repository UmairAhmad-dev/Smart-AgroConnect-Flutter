// lib/views/home/home_dashboard_screen.dart (Final, Dynamic KPIs, 20-Screen Complete)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// --- CRITICAL VIEWMODEL IMPORTS ---
import '../../view_models/auth_view_model.dart';
import '../../view_models/crop_view_model.dart';
import '../../view_models/crop_task_view_model.dart'; // REQUIRED for Pending Tasks
import '../../view_models/crop_expense_view_model.dart'; // REQUIRED for Total Expenses
// ----------------------------------

import '../../models/crop_model.dart';
import '../../models/weather_model.dart'; // For Weather Card
import '../../services/weather_service.dart'; // For Weather Card
import '../shared/main_drawer.dart';
import 'add_crop_screen.dart';
import 'crop_detail_screen.dart';
import 'crop_list_screen.dart'; // For View All navigation

// Reusing constants
abstract class AppSpacing {
  static const double xsmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xlarge = 32.0;
}

abstract class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color textBody = Color(0xFF424242);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color primaryBlue = Color(0xFF42A5F5);
  static const Color expenseRed = Color(0xFFD32F2F);
}


class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userName = authViewModel.currentUser?.displayName ?? 'Farmer';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const MainDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }
        ),
        title: Text(
          'AgroConnect Dashboard',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authViewModel.signOut(),
          ),
        ],
      ),
      // --- WRAPPER FOR MAX WIDTH FIX (CENTERS CONTENT ON WIDE SCREENS) ---
      body: Center(
        child: SizedBox(
          width: 1000,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Welcome Header
                    _buildWelcomeHeader(userName, authViewModel.currentUser?.email ?? 'N/A'),
                    const SizedBox(height: AppSpacing.large),

                    // 2. Quick Action Button
                    _buildQuickActionButton(context),
                    const SizedBox(height: AppSpacing.xlarge),

                    Text('Farm Statistics', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                    const SizedBox(height: AppSpacing.medium),
                  ]),
                ),
              ),

              // 3. KPI Cards Row (Grid) --- PULLING LIVE DATA FROM VIEWMODELS ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                sliver: SliverGrid.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: AppSpacing.medium,
                  mainAxisSpacing: AppSpacing.medium,
                  childAspectRatio: 1.0,
                  children: [
                    // KPI 1: Active Crops (Dynamic)
                    Consumer<CropViewModel>(
                      builder: (context, cropVM, child) => _buildKpiCard(
                        context,
                        icon: FontAwesomeIcons.seedling,
                        title: 'Active Crops',
                        color: AppColors.primaryGreen,
                        future: cropVM.getactiveCropCount(),
                        valueFormatter: (data) => data.toString(),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CropListScreen())),
                      ),
                    ),

                    // KPI 2: Pending Tasks (Dynamic)
                    Consumer<CropTaskViewModel>(
                      builder: (context, taskVM, child) => _buildKpiCard(
                        context,
                        icon: FontAwesomeIcons.clipboardCheck,
                        title: 'Pending Tasks',
                        color: AppColors.accentOrange,
                        future: taskVM.getPendingTaskCount(),
                        valueFormatter: (data) => data.toString(),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CropListScreen())),
                      ),
                    ),

                    // KPI 3: Total Acres (DYNAMICALLY FETCHED)
                    Consumer<CropViewModel>(
                      builder: (context, cropVM, child) => _buildKpiCard(
                        context,
                        icon: FontAwesomeIcons.mountain, // Use FontAwesome for land
                        title: 'Total Acres',
                        color: AppColors.darkGreen,
                        future: cropVM.getTotalAcres(), // FINAL METHOD CALL
                        valueFormatter: (data) => (data as num).toStringAsFixed(0), // Final cast and formatting
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CropListScreen())),
                      ),
                    ),

                    // KPI 4: Total Expenses (Dynamic)
                    Consumer<CropExpenseViewModel>(
                      builder: (context, expenseVM, child) => _buildKpiCard(
                        context,
                        icon: FontAwesomeIcons.sackDollar,
                        title: 'Total Expenses',
                        color: AppColors.expenseRed,
                        future: expenseVM.getTotalExpenses(),
                        valueFormatter: (data) => '\$${(data as num).toStringAsFixed(0)}', // Final cast and formatting
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CropListScreen())),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Chart & Weather Section
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppSpacing.xlarge),
                    _buildWeatherCard(),
                    const SizedBox(height: AppSpacing.xlarge),

                    Text('Yield Projection', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                    const SizedBox(height: AppSpacing.medium),
                    _buildChartCard(context),
                    const SizedBox(height: AppSpacing.xlarge),

                    // Quick List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recently Registered', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CropListScreen()));
                          },
                          child: const Text('View All', style: TextStyle(color: AppColors.darkGreen)),
                        )
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                  ]),
                ),
              ),

              // 5. StreamBuilder for Recent Crops List
              StreamBuilder<List<CropModel>>(
                stream: Provider.of<CropViewModel>(context).cropsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)));
                  }

                  final crops = snapshot.data ?? [];

                  if (crops.isEmpty) {
                    return const SliverToBoxAdapter(child: Center(child: Padding(
                      padding: EdgeInsets.all(AppSpacing.large),
                      child: Text('You have no crops registered yet. Use the button above to add one!'),
                    )));
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                          child: _CropListItem(crop: crops[index]),
                        );
                      },
                      childCount: crops.take(3).length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xlarge)),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS (Helpers) ---

  Widget _buildWelcomeHeader(String userName, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, $userName!', style: GoogleFonts.roboto(fontSize: 16, color: AppColors.textBody)),
        Text(
          'Logged in as ${email}',
          style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.darkGreen),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: const LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.darkGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: AppColors.primaryGreen.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
          ]
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddCropScreen()));
        },
        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 26),
        label: Text(
          'REGISTER NEW CROP',
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
    );
  }

  // --- NEW: GENERIC KPI CARD BUILDER ---
  Widget _buildKpiCard<T>(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required Future<T> future,
        required String Function(T) valueFormatter,
        VoidCallback? onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: FutureBuilder<T>(
            future: future,
            builder: (context, snapshot) {
              String value;
              Color valueColor;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(strokeWidth: 2, color: color));
              }

              if (snapshot.hasError || !snapshot.hasData) {
                value = 'Error';
                valueColor = AppColors.expenseRed;
              } else {
                value = valueFormatter(snapshot.data as T);
                // Highlight pending tasks red/orange
                // We use .runtimeType to safely check if the future was an int (for counts)
                if (title.contains('Pending Tasks') && snapshot.data.runtimeType == int && (snapshot.data as int) > 0) {
                  valueColor = AppColors.accentOrange;
                } else if (title.contains('Expenses')) {
                  valueColor = AppColors.expenseRed;
                } else {
                  valueColor = AppColors.darkGreen;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon, size: 30, color: color),
                      Text(
                        value,
                        style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: valueColor),
                      ),
                    ],
                  ),
                  Text(
                    title,
                    style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- CHART WIDGET ---
  Widget _buildChartCard(BuildContext context) {
    final cropViewModel = Provider.of<CropViewModel>(context, listen: false);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: SizedBox(
          height: 250,
          child: FutureBuilder<List<FlSpot>>(
            future: cropViewModel.getChartData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No crop data available for yield projection.', style: GoogleFonts.roboto(color: AppColors.textBody)));
              }

              List<FlSpot> spots = snapshot.data!;
              double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1.0;

              return LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,

                  gridData: FlGridData(show: true, drawHorizontalLine: true, getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xfff3f3f3), strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1.0,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xsmall),
                          child: Text('Crop ${value.toInt()}', style: GoogleFonts.roboto(fontSize: 10, color: AppColors.textBody)),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()} Acs'),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300, width: 1)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: const LinearGradient(colors: [AppColors.primaryGreen, AppColors.darkGreen]),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- WEATHER CARD WIDGET ---
  Widget _buildWeatherCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: FutureBuilder<ForecastWrapper>(
        future: WeatherService().fetchFiveDayForecast(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.large), child: CircularProgressIndicator(color: AppColors.primaryGreen)));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.dailyForecast.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.large), child: Text('Weather data unavailable.', style: GoogleFonts.roboto())));
          }

          final today = snapshot.data!.dailyForecast.first;
          final location = snapshot.data!.timezone;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Weather', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                const SizedBox(height: AppSpacing.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${today.maxTemp.toStringAsFixed(0)}°C', style: GoogleFonts.montserrat(fontSize: 48, fontWeight: FontWeight.bold)),
                        Text(today.description.toUpperCase(), style: GoogleFonts.roboto(fontSize: 16, color: AppColors.textBody)),
                        Text(location, style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    Image.network(
                      'http://openweathermap.org/img/wn/${today.iconCode}@2x.png',
                      height: 80,
                    ),
                  ],
                ),
                Text('Min: ${today.minTemp.toStringAsFixed(0)}°C', style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom widget for summary statistics (NO LONGER USED, replaced by _buildKpiCard)
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // This is kept only for the static 'Total Acres' card.
    // NOTE: This widget is now completely replaced by the dynamic Consumer in the final code.
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 30, color: color),
                Text(
                  value,
                  style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
              ],
            ),
            Text(
              title,
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying a single crop item (Unchanged)
class _CropListItem extends StatelessWidget {
  final CropModel crop;

  const _CropListItem({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
          child: const Icon(FontAwesomeIcons.pagelines, color: AppColors.darkGreen),
        ),
        title: Text(
          crop.name,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Type: ${crop.type} | Status: ${crop.status}',
          style: GoogleFonts.roboto(color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CropDetailScreen(crop: crop),
            ),
          );
        },
      ),
    );
  }
}