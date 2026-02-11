import 'package:ausadhi_khau/blocs/medicine/medicine_bloc.dart';
import 'package:ausadhi_khau/blocs/medicine/medicine_event.dart';
import 'package:ausadhi_khau/blocs/medicine/medicine_state.dart';
import 'package:ausadhi_khau/models/medicine.dart';
import 'package:ausadhi_khau/utils/medicine_utils.dart';
import 'package:ausadhi_khau/widgets/medicine_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DoseDetailsScreen extends StatelessWidget {
  final DateTime scheduledTime;

  const DoseDetailsScreen({super.key, required this.scheduledTime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm').format(scheduledTime);
    final displayTime = MedicineUtils.formatTimeOfDayString(timeStr);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          final medicines = state.medicines;
          final dateOnly = DateTime(
            scheduledTime.year,
            scheduledTime.month,
            scheduledTime.day,
          );
          final todayMedicines = MedicineUtils.getMedicinesForDate(
            medicines,
            dateOnly,
          );

          // Filter medicines that are scheduled at THIS exact time
          final medicinesAtTime = todayMedicines.where((m) {
            final current = m.schedules.isNotEmpty
                ? m.schedules.firstWhere(
                    (s) => MedicineUtils.isScheduleActive(s, scheduledTime),
                    orElse: () => m.schedules.first,
                  )
                : null;
            final times = current?.times ?? m.times;
            return times.contains(timeStr);
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: theme.colorScheme.surface,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.1,
                    ),
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.2,
                  centerTitle: false,
                  titlePadding: const EdgeInsets.all(24),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DOSE AT $displayTime',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'EEEE, MMM d',
                        ).format(scheduledTime).toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (medicinesAtTime.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.done_all_rounded,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('No medicines found for this time.'),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildMedicineCard(
                          context,
                          medicinesAtTime[index],
                          scheduledTime,
                        );
                      },
                      childCount: medicinesAtTime.length,
                    ),
                  ),
                ),
            ],
          );
        },
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

    return MedicineCard(
      medicine: medicine,
      selectedDate: selectedDate,
      dosage: dosage,
      times: times,
      formattedSchedule: MedicineUtils.formatSchedule(medicine),
      isBaseActive: isEffectivelyActive,
      isEffectivelyActive: isEffectivelyActive && !areAllTimesDeactivated,
      isSkipped: isSkipped,
      isManuallyEnabled: isManuallyEnabled,
      showToggles: false,
      showEdit: false,
      showTimes: false,
      onEdit: () => context.push('/edit', extra: medicine),
      onToggleParent: (value) {
        final bloc = context.read<MedicineBloc>();
        if (value == false) {
          if (isManuallyEnabled) {
            bloc.add(RemoveManualEnableForDateEvent(medicine.id, selectedDate));
          } else if (medicine.isActive) {
            bloc.add(SkipMedicineForDateEvent(medicine.id, selectedDate));
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
            bloc.add(ManualEnableForDateEvent(medicine.id, selectedDate));
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
    );
  }
}
