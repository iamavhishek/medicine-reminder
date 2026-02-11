import 'package:ausadhi_khau/blocs/medicine/medicine_bloc.dart';
import 'package:ausadhi_khau/blocs/medicine/medicine_event.dart';
import 'package:ausadhi_khau/blocs/medicine/medicine_state.dart';
import 'package:ausadhi_khau/models/medicine.dart';
import 'package:ausadhi_khau/utils/medicine_utils.dart';
import 'package:ausadhi_khau/widgets/home/empty_state_widget.dart';
import 'package:ausadhi_khau/widgets/home/next_dose_hero.dart';
import 'package:ausadhi_khau/widgets/home/summary_header.dart';
import 'package:ausadhi_khau/widgets/home/timeline_widget.dart';
import 'package:ausadhi_khau/widgets/medicine_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _timelineController = ScrollController();
  double? _lastWidth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(DateTime.now());
    });
  }

  void _scrollToDate(DateTime date) {
    if (!_timelineController.hasClients) return;
    final firstDayOfYear = DateTime(date.year);
    final daysSinceStart = date.difference(firstDayOfYear).inDays;

    final offset = daysSinceStart * 62.0;
    _timelineController.jumpTo(
      offset.clamp(0.0, _timelineController.position.maxScrollExtent),
    );
  }

  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (_lastWidth != null && (width - _lastWidth!).abs() > 0.1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final selectedDate = context.read<MedicineBloc>().state.selectedDate;
          _scrollToDate(selectedDate);
        }
      });
    }
    _lastWidth = width;

    final isDesktop = width > 900;

    return BlocListener<MedicineBloc, MedicineState>(
      listener: (context, state) {
        final theme = Theme.of(context);
        if (state is MedicineOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.toUpperCase()),
              backgroundColor: theme.colorScheme.onSurface,
            ),
          );
        } else if (state is MedicineError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toUpperCase()),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          final selectedDate = state.selectedDate;
          final medicines = state.medicines;
          final todayMedicines = MedicineUtils.getMedicinesForDate(
            medicines,
            selectedDate,
          );
          final activeTodayCount = todayMedicines
              .where((m) => MedicineUtils.isEffectivelyActive(m, selectedDate))
              .length;
          final nextDose = MedicineUtils.findNextDose(
            todayMedicines,
            selectedDate,
          );

          if (isDesktop) {
            return _buildDesktopLayout(
              context,
              state,
              selectedDate,
              todayMedicines,
              activeTodayCount,
              nextDose,
            );
          }

          return _buildMobileLayout(
            context,
            state,
            selectedDate,
            todayMedicines,
            activeTodayCount,
            nextDose,
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    MedicineState state,
    DateTime selectedDate,
    List<Medicine> todayMedicines,
    int activeTodayCount,
    Medicine? nextDose,
  ) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(48, 64, 48, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          'EEEE, MMMM d',
                        ).format(selectedDate).toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.38,
                          ),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'YOUR SCHEDULE',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: theme.colorScheme.onSurface,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<MedicineBloc>().add(
                            UpdateSelectedDate(DateTime.now()),
                          );
                          _scrollToDate(DateTime.now());
                        },
                        icon: const Icon(Icons.today_rounded),
                        tooltip: 'Go to Today',
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurface,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/add'),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'ADD MEDICINE',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: TimelineWidget(
                controller: _timelineController,
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  context.read<MedicineBloc>().add(UpdateSelectedDate(date));
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(48),
            sliver: todayMedicines.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(),
                  )
                : SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: _buildMedicineWidgets(
                              context,
                              todayMedicines,
                              selectedDate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                        Expanded(
                          child: Column(
                            children: [
                              SummaryHeader(
                                selectedDate: selectedDate,
                                activeCount: activeTodayCount,
                              ),
                              const SizedBox(height: 24),
                              if (nextDose != null && _isToday(selectedDate))
                                NextDoseHero(
                                  medicine: nextDose,
                                  nextTimeStr: _getNextTimeStr(nextDose),
                                  medicineTypeLabel:
                                      MedicineUtils.getMedicineTypeLabel(
                                        nextDose.type,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    MedicineState state,
    DateTime selectedDate,
    List<Medicine> todayMedicines,
    int activeTodayCount,
    Medicine? nextDose,
  ) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'COMPANION',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 12,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, size: 20),
            onPressed: () {
              context.read<MedicineBloc>().add(
                UpdateSelectedDate(DateTime.now()),
              );
              _scrollToDate(DateTime.now());
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            color: theme.colorScheme.surface,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: TimelineWidget(
                    controller: _timelineController,
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      context.read<MedicineBloc>().add(
                        UpdateSelectedDate(date),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SummaryHeader(
                    selectedDate: selectedDate,
                    activeCount: activeTodayCount,
                  ),
                ),
                if (nextDose != null && _isToday(selectedDate))
                  SliverToBoxAdapter(
                    child: NextDoseHero(
                      medicine: nextDose,
                      nextTimeStr: _getNextTimeStr(nextDose),
                      medicineTypeLabel: MedicineUtils.getMedicineTypeLabel(
                        nextDose.type,
                      ),
                    ),
                  ),
                if (todayMedicines.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(),
                  )
                else
                  SliverList(
                    delegate: SliverChildListDelegate(
                      _buildMedicineWidgets(
                        context,
                        todayMedicines,
                        selectedDate,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: FloatingActionButton(
          heroTag: 'add_medicine_home',
          onPressed: () {
            context.push('/add');
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  String _getNextTimeStr(Medicine medicine) {
    final now = DateTime.now();
    final times = medicine.schedules.isNotEmpty
        ? medicine.schedules
              .firstWhere(
                (s) => MedicineUtils.isScheduleActive(s, now),
                orElse: () => medicine.schedules.first,
              )
              .times
        : medicine.times;

    final currentTime = now.hour * 60 + now.minute;
    String nextTimeStr = times.first;
    int minDiff = 24 * 60;
    for (var tS in times) {
      final p = tS.split(':');
      final t = int.parse(p[0]) * 60 + int.parse(p[1]);
      final d = t - currentTime;
      if (d > 0 && d < minDiff) {
        minDiff = d;
        nextTimeStr = tS;
      }
    }
    return nextTimeStr;
  }

  List<Widget> _buildMedicineWidgets(
    BuildContext context,
    List<Medicine> medicines,
    DateTime selectedDate,
  ) {
    final morning = <Medicine>[];
    final afternoon = <Medicine>[];
    final evening = <Medicine>[];

    for (var m in medicines) {
      final times = m.schedules.isNotEmpty
          ? m.schedules
                .firstWhere(
                  (s) => MedicineUtils.isScheduleActive(s, selectedDate),
                  orElse: () => m.schedules.first,
                )
                .times
          : m.times;

      if (times.isEmpty) continue;

      int earliestHour = 24;
      for (var tS in times) {
        final hour = int.parse(tS.split(':')[0]);
        if (hour < earliestHour) {
          earliestHour = hour;
        }
      }

      if (earliestHour < 12) {
        morning.add(m);
      } else if (earliestHour < 17) {
        afternoon.add(m);
      } else {
        evening.add(m);
      }
    }

    final widgets = <Widget>[];
    if (morning.isNotEmpty) {
      widgets.add(_buildGroupHeader(context, 'MORNING'));
      widgets.addAll(
        morning.map((m) => _buildMedicineCard(context, m, selectedDate)),
      );
    }
    if (afternoon.isNotEmpty) {
      widgets.add(_buildGroupHeader(context, 'AFTERNOON'));
      widgets.addAll(
        afternoon.map((m) => _buildMedicineCard(context, m, selectedDate)),
      );
    }
    if (evening.isNotEmpty) {
      widgets.add(_buildGroupHeader(context, 'EVENING'));
      widgets.addAll(
        evening.map((m) => _buildMedicineCard(context, m, selectedDate)),
      );
    }
    return widgets;
  }

  Widget _buildGroupHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(
    BuildContext context,
    Medicine medicine,
    DateTime selectedDate,
  ) {
    final isSkipped = MedicineUtils.isSkipped(medicine, selectedDate);
    final isManuallyEnabled = MedicineUtils.isManuallyEnabled(
      medicine,
      selectedDate,
    );
    final isEffectivelyActive = MedicineUtils.isEffectivelyActive(
      medicine,
      selectedDate,
    );

    final current = medicine.schedules.isNotEmpty
        ? medicine.schedules.firstWhere(
            (s) => MedicineUtils.isScheduleActive(s, selectedDate),
            orElse: () => medicine.schedules.first,
          )
        : null;

    final dosage = current?.dosage ?? medicine.dosage;
    final times = current?.times ?? medicine.times;

    final areAllTimesDeactivated =
        times.isNotEmpty &&
        times.every((t) => medicine.deactivatedTimes.contains(t));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: MedicineCard(
        medicine: medicine,
        selectedDate: selectedDate,
        dosage: dosage,
        times: times,
        formattedSchedule: MedicineUtils.formatSchedule(medicine),
        isBaseActive: isEffectivelyActive,
        isEffectivelyActive: isEffectivelyActive && !areAllTimesDeactivated,
        isSkipped: isSkipped,
        isManuallyEnabled: isManuallyEnabled,
        onEdit: () {
          context.push('/edit', extra: medicine);
        },
        onToggleParent: (value) async {
          final bloc = context.read<MedicineBloc>();
          if (!value) {
            if (isManuallyEnabled) {
              bloc.add(
                RemoveManualEnableForDateEvent(medicine.id, selectedDate),
              );
            } else if (medicine.isActive) {
              final choice = await _showToggleDialog(context);
              if (choice == 'today') {
                bloc.add(SkipMedicineForDateEvent(medicine.id, selectedDate));
              } else if (choice == 'all') {
                bloc.add(ToggleMedicineStatusEvent(medicine.id, false));
              }
            }
          } else {
            if (isSkipped) {
              bloc.add(UnskipMedicineForDateEvent(medicine.id, selectedDate));
            } else if (areAllTimesDeactivated) {
              for (var t in times) {
                bloc.add(
                  ToggleMedicineTimeEvent(
                    medicineId: medicine.id,
                    time: t,
                    isEnabled: true,
                  ),
                );
              }
            } else if (!medicine.isActive) {
              final choice = await _showResumeDialog(context);
              if (choice == 'today') {
                bloc.add(ManualEnableForDateEvent(medicine.id, selectedDate));
              } else if (choice == 'all') {
                bloc.add(ToggleMedicineStatusEvent(medicine.id, true));
              }
            }
          }
        },
        onToggleTime: (time, isEnabled) {
          context.read<MedicineBloc>().add(
            ToggleMedicineTimeEvent(
              medicineId: medicine.id,
              time: time,
              isEnabled: isEnabled,
            ),
          );
        },
      ),
    );
  }

  Future<String?> _showToggleDialog(BuildContext context) async {
    final theme = Theme.of(context);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'STOP REMINDERS?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Would you like to skip today\'s doses only, or stop all future reminders?',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'today'),
            child: Text(
              'TODAY ONLY',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'all'),
            child: const Text(
              'STOP ALL FUTURE',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showResumeDialog(BuildContext context) async {
    final theme = Theme.of(context);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'RESUME REMINDERS?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Would you like to resume all future reminders, or just re-enable medical tracking for today?',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'today'),
            child: Text(
              'TODAY ONLY',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'all'),
            child: Text(
              'RESUME ALL',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
