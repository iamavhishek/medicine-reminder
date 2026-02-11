import 'package:ausadhi_khau/blocs/medicine/medicine_bloc.dart';
import 'package:ausadhi_khau/blocs/medicine/medicine_state.dart';
import 'package:ausadhi_khau/models/medicine.dart';
import 'package:ausadhi_khau/utils/medicine_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicineCard extends StatefulWidget {
  final Medicine medicine;
  final DateTime selectedDate;
  final String dosage;
  final List<String> times;
  final String formattedSchedule;
  final bool isBaseActive;
  final bool isEffectivelyActive;
  final bool isSkipped;
  final bool isManuallyEnabled;
  final VoidCallback onEdit;
  final Function(bool) onToggleParent;
  final Function(String, bool) onToggleTime;
  final bool showToggles;
  final bool showEdit;
  final bool showTimes;
  final bool isExpandedInitial;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.selectedDate,
    required this.dosage,
    required this.times,
    required this.formattedSchedule,
    required this.isBaseActive,
    required this.isEffectivelyActive,
    required this.isSkipped,
    required this.isManuallyEnabled,
    required this.onEdit,
    required this.onToggleParent,
    required this.onToggleTime,
    this.showToggles = true,
    this.showEdit = true,
    this.showTimes = true,
    this.isExpandedInitial = false,
  });

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpandedInitial;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isEffectivelyActive
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: widget.isEffectivelyActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.showTimes || widget.showEdit
            ? () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          MedicineUtils.getMedicineIcon(widget.medicine.type),
                          size: 20,
                          color: widget.isEffectivelyActive
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.38,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.medicine.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: widget.isEffectivelyActive
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.38,
                                    ),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.showToggles)
                    BlocBuilder<MedicineBloc, MedicineState>(
                      builder: (context, state) {
                        final isLoading = state is MedicineLoading;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: Switch.adaptive(
                                value: widget.isEffectivelyActive,
                                activeThumbColor: theme.colorScheme.primary,
                                activeTrackColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.38),
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        widget.onToggleParent(value);
                                      },
                              ),
                            ),
                            if (isLoading)
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.54,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.dosage} • ${widget.formattedSchedule}'.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.isEffectivelyActive
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.54)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.26),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              if (widget.showTimes && !_isExpanded)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.times.map((t) {
                    final isTimeDeactivated = widget.medicine.deactivatedTimes
                        .contains(t);
                    return _buildTimeBadge(
                      context,
                      t,
                      widget.isEffectivelyActive && !isTimeDeactivated,
                    );
                  }).toList(),
                )
              else if (_isExpanded) ...[
                if (widget.showTimes)
                  ...widget.times.map((t) {
                    final isTimeDeactivated = widget.medicine.deactivatedTimes
                        .contains(t);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.54,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                MedicineUtils.formatTimeOfDayString(t),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: !isTimeDeactivated
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.26,
                                        ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.showToggles)
                            BlocBuilder<MedicineBloc, MedicineState>(
                              builder: (context, state) {
                                final isLoading = state is MedicineLoading;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 0.7,
                                      child: Switch.adaptive(
                                        value:
                                            widget.isEffectivelyActive &&
                                            !isTimeDeactivated,
                                        activeThumbColor:
                                            theme.colorScheme.primary,
                                        activeTrackColor: theme
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.38),
                                        onChanged:
                                            isLoading || !widget.isBaseActive
                                            ? null
                                            : (value) {
                                                widget.onToggleTime(t, value);
                                              },
                                      ),
                                    ),
                                    if (isLoading)
                                      SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.54),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                if (widget.showEdit) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text(
                        'EDIT DETAILS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ],
              if (widget.medicine.takeWithFood) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 12,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.54,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'TAKE AFTER MEAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: widget.isEffectivelyActive
                            ? theme.colorScheme.onSurface.withValues(
                                alpha: 0.54,
                              )
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.26,
                              ),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBadge(BuildContext context, String time, bool isActive) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.onSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        MedicineUtils.formatTimeOfDayString(time),
        style: TextStyle(
          fontSize: 12,
          color: isActive
              ? theme.colorScheme.surface
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
