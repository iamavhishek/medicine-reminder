import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_remainder_app/blocs/medicine/medicine_bloc.dart';
import 'package:medicine_remainder_app/blocs/medicine/medicine_state.dart';
import 'package:medicine_remainder_app/models/medicine.dart';
import 'package:medicine_remainder_app/utils/medicine_utils.dart';
import 'package:medicine_remainder_app/widgets/insights/insights_widgets.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          if (state is MedicineLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          final medicines = state.medicines;
          final activeCount = medicines.where((m) => m.isActive).length;
          final totalDoses = _calculateTotalDailyDoses(medicines);
          final adherence = medicines.isNotEmpty
              ? (activeCount / medicines.length * 100).toInt()
              : 0;

          return CustomScrollView(
            slivers: [
              _buildSliverHeader(context, isDesktop),
              _buildStatsRow(context, isDesktop, activeCount, totalDoses),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildComplianceCard(context, isDesktop, adherence),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildTypeDistributionSection(context, isDesktop, medicines),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 48 : 24,
          isDesktop ? 64 : 48,
          isDesktop ? 48 : 24,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OVERVIEW',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: FontWeight.w800,
                fontSize: isDesktop ? 12 : 10,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'INSIGHTS',
              style: TextStyle(
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    bool isDesktop,
    int activeCount,
    int totalDoses,
  ) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'ACTIVE MEDS',
                value: activeCount.toString(),
                icon: Icons.medication_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: 'DAILY DOSES',
                value: totalDoses.toString(),
                icon: Icons.fact_check_outlined,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceCard(
    BuildContext context,
    bool isDesktop,
    int adherence,
  ) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24),
      sliver: SliverToBoxAdapter(
        child: InsightCard(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COMPLIANCE RATE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'THIS MONTH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$adherence%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                    height: 1,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'of scheduled medicines\nare currently active.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDistributionSection(
    BuildContext context,
    bool isDesktop,
    List<Medicine> medicines,
  ) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                'DISTRIBUTION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ),
            InsightCard(
              children: _buildTypeDistributionList(context, medicines),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  int _calculateTotalDailyDoses(List<Medicine> medicines) {
    int count = 0;
    for (var m in medicines) {
      if (!m.isActive) continue;
      if (m.schedules.isNotEmpty) {
        count += m.schedules.first.times.length;
      } else {
        count += m.times.length;
      }
    }
    return count;
  }

  List<Widget> _buildTypeDistributionList(
    BuildContext context,
    List<Medicine> medicines,
  ) {
    final theme = Theme.of(context);
    if (medicines.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No data available',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ),
      ];
    }

    final types = <String, int>{};
    for (var m in medicines) {
      types[m.type] = (types[m.type] ?? 0) + 1;
    }

    final sortedKeys = types.keys.toList()
      ..sort((a, b) => types[b]!.compareTo(types[a]!));

    return sortedKeys.asMap().entries.map((entry) {
      final index = entry.key;
      final type = entry.value;
      final count = types[type]!;
      final isLast = index == sortedKeys.length - 1;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    MedicineUtils.getMedicineIcon(type),
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.87),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  MedicineUtils.getMedicineTypeLabel(type),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '$count',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              indent: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
        ],
      );
    }).toList();
  }
}
