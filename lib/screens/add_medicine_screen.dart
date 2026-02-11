import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicine_remainder_app/blocs/medicine/medicine_bloc.dart';
import 'package:medicine_remainder_app/blocs/medicine/medicine_event.dart';
import 'package:medicine_remainder_app/blocs/medicine/medicine_state.dart';
import 'package:medicine_remainder_app/models/medicine.dart';
import 'package:medicine_remainder_app/models/medicine_schedule.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/date_picker_field.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/day_selector.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/frequency_selector.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/medicine_form_fields.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/phase_config_sheet.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/phase_item.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/time_selector.dart';
import 'package:medicine_remainder_app/widgets/add_medicine/type_selector.dart';
import 'package:medicine_remainder_app/widgets/common/common_widgets.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  final DateTime? initialStartDate;

  const AddMedicineScreen({super.key, this.medicine, this.initialStartDate});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  final List<TimeOfDay> _selectedTimes = [];
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  bool _takeWithFood = false;
  bool _isActive = true;
  String _frequency = 'daily';
  String _type = 'pill';
  final List<int> _selectedDaysOfMonth = [];
  final List<MedicineSchedule> _additionalSchedules = [];

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _loadMedicineData(widget.medicine!);
    } else {
      _startDate = widget.initialStartDate ?? DateTime.now();
    }
  }

  void _loadMedicineData(Medicine medicine) {
    _nameController.text = medicine.name;
    _dosageController.text = medicine.dosage;
    _notesController.text = medicine.notes ?? '';
    _startDate = medicine.startDate;
    _endDate = medicine.endDate;
    _takeWithFood = medicine.takeWithFood;
    _isActive = medicine.isActive;
    _frequency = medicine.frequency;
    _type = medicine.type;
    _selectedDaysOfMonth.clear();
    _selectedDaysOfMonth.addAll(medicine.daysOfMonth);

    for (int i = 0; i < 7; i++) {
      _selectedDays[i] = medicine.daysOfWeek.contains(i + 1);
    }

    _additionalSchedules.clear();
    if (medicine.schedules.isNotEmpty) {
      _additionalSchedules.addAll(medicine.schedules.skip(1));
    }

    _selectedTimes.clear();
    for (final time in medicine.times) {
      final parts = time.split(':');
      _selectedTimes.add(
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
      );
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _saveMedicine() {
    if (_formKey.currentState!.validate()) {
      if (_frequency == 'weekly' && _selectedDays.where((day) => day).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day')),
        );
        return;
      }

      if (_frequency == 'monthly' && _selectedDaysOfMonth.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day of month'),
          ),
        );
        return;
      }

      if (_selectedTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one time')),
        );
        return;
      }

      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a start date')),
        );
        return;
      }

      final List<int> selectedDayNumbers = [];
      for (int i = 0; i < _selectedDays.length; i++) {
        if (_selectedDays[i]) {
          selectedDayNumbers.add(i + 1);
        }
      }

      final List<String> timeStrings = _selectedTimes
          .map(
            (time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
          )
          .toList();

      final medicine = Medicine(
        id:
            widget.medicine?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        dosage: _dosageController.text,
        daysOfWeek: selectedDayNumbers,
        times: timeStrings,
        startDate: _startDate!,
        endDate: _endDate,
        isActive: _isActive,
        takeWithFood: _canTakeWithFood(_type) ? _takeWithFood : false,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        frequency: _frequency,
        daysOfMonth: _selectedDaysOfMonth,
        type: _type,
        schedules: _additionalSchedules.isEmpty
            ? []
            : [
                MedicineSchedule(
                  dosage: _dosageController.text,
                  times: timeStrings,
                  frequency: _frequency,
                  daysOfWeek: selectedDayNumbers,
                  daysOfMonth: List.from(_selectedDaysOfMonth),
                  startDate: _startDate!,
                  endDate: _endDate,
                ),
                ..._additionalSchedules,
              ],
      );

      if (widget.medicine == null) {
        context.read<MedicineBloc>().add(AddMedicineEvent(medicine));
      } else {
        context.read<MedicineBloc>().add(UpdateMedicineEvent(medicine));
      }
    }
  }

  bool _canTakeWithFood(String type) =>
      type != 'drops' && type != 'ointment' && type != 'syringe';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return BlocListener<MedicineBloc, MedicineState>(
      listener: (context, state) {
        if (state is MedicineOperationSuccess) {
          context.go('/');
        } else if (state is MedicineError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toUpperCase()),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(48),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, true),
              const SizedBox(height: 48),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: 'IDENTIFICATION'),
                        SectionCard(
                          child: Column(
                            children: [
                              TypeSelector(
                                selectedType: _type,
                                onTypeSelected: (t) =>
                                    setState(() => _type = t),
                              ),
                              const SizedBox(height: 24),
                              MedicineNameField(controller: _nameController),
                              const SizedBox(height: 20),
                              DosageField(controller: _dosageController),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const SectionTitle(title: 'PREFERENCES'),
                        SectionCard(child: _buildPreferencesSection(context)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: 'SCHEDULE'),
                        SectionCard(child: _buildScheduleSection(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          (widget.medicine == null ? 'ADD MEDICINE' : 'EDIT MEDICINE'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'IDENTIFICATION'),
                  SectionCard(
                    child: Column(
                      children: [
                        TypeSelector(
                          selectedType: _type,
                          onTypeSelected: (t) => setState(() => _type = t),
                        ),
                        const SizedBox(height: 24),
                        MedicineNameField(controller: _nameController),
                        const SizedBox(height: 20),
                        DosageField(controller: _dosageController),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'SCHEDULE'),
                  SectionCard(child: _buildScheduleSection(context)),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'PREFERENCES'),
                  SectionCard(child: _buildPreferencesSection(context)),
                  const SizedBox(height: 48),
                  _buildSubmitButton(context),
                  if (widget.medicine != null) _buildDeleteButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COLLECTIVE',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (widget.medicine == null ? 'NEW MEDICINE' : 'EDIT MEDICINE'),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (widget.medicine != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextButton.icon(
                  onPressed: () {
                    _showDeleteDialog(context);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    'DELETE',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                _saveMedicine();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                (widget.medicine == null ? 'CREATE' : 'SAVE'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.05,
                ),
                foregroundColor: theme.colorScheme.onSurface,
                padding: const EdgeInsets.all(12),
              ),
              tooltip: 'Close',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrequencySelector(
          selectedFrequency: _frequency,
          onFrequencyChanged: (f) => setState(() => _frequency = f),
        ),
        const SizedBox(height: 32),
        if (_frequency == 'daily') ...[
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'REPEATS EVERY DAY',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Notifications will be sent every day at the times you select.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ] else if (_frequency == 'weekly') ...[
          _buildWeeklyHeader(context),
          const SizedBox(height: 12),
          WeeklyDaySelector(
            isSelected: _selectedDays,
            onDayToggled: (index) =>
                setState(() => _selectedDays[index] = !_selectedDays[index]),
          ),
        ] else if (_frequency == 'monthly') ...[
          Text(
            'DAYS OF MONTH',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          MonthlyDaySelector(
            selectedDays: _selectedDaysOfMonth,
            onDayToggled: (day) => setState(() {
              if (_selectedDaysOfMonth.contains(day)) {
                _selectedDaysOfMonth.remove(day);
              } else {
                _selectedDaysOfMonth.add(day);
              }
            }),
          ),
        ] else if (_frequency == 'yearly') ...[
          Text(
            'REPEATS EVERY YEAR ON ${DateFormat('MMMM dd').format(_startDate ?? DateTime.now()).toUpperCase()}',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on the Start Date below.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
        const SizedBox(height: 32),
        TimeSelector(
          selectedTimes: _selectedTimes,
          onTimeAdded: (t) => setState(() => _selectedTimes.add(t)),
          onTimeRemoved: (t) => setState(() => _selectedTimes.remove(t)),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: DatePickerField(
                label: 'START DATE',
                value: _startDate,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DatePickerField(
                label: 'END DATE',
                value: _endDate,
                onTap: () => _selectDate(false),
                isOptional: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildPhasesSection(context),
      ],
    );
  }

  Widget _buildWeeklyHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'DAYS OF WEEK',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 1,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Row(
          children: [
            _buildQuickSelectButton(context, 'ALL', () {
              setState(() {
                for (int i = 0; i < 7; i++) {
                  _selectedDays[i] = true;
                }
              });
            }),
            _buildQuickSelectButton(context, 'WEEKDAYS', () {
              setState(() {
                for (int i = 0; i < 7; i++) {
                  _selectedDays[i] = i < 5;
                }
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickSelectButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (_canTakeWithFood(_type)) ...[
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'TAKE AFTER MEAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: theme.colorScheme.onSurface,
              ),
            ),
            secondary: Icon(
              Icons.restaurant,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            value: _takeWithFood,
            activeThumbColor: theme.colorScheme.primary,
            activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.38),
            onChanged: (value) => setState(() {
              _takeWithFood = value;
            }),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ],
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'REMINDERS ACTIVE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: theme.colorScheme.onSurface,
            ),
          ),
          secondary: Icon(
            Icons.notifications_active_outlined,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          value: _isActive,
          activeThumbColor: theme.colorScheme.primary,
          activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.38),
          onChanged: (value) => setState(() {
            _isActive = value;
          }),
        ),
      ],
    );
  }

  Widget _buildPhasesSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FUTURE PHASES',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 1,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add different dosages or schedules for future dates.',
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 16),
        ..._additionalSchedules.asMap().entries.map((entry) {
          return PhaseItem(
            phaseNumber: entry.key + 2,
            schedule: entry.value,
            onEdit: () => _editPhase(entry.key),
            onDelete: () =>
                setState(() => _additionalSchedules.removeAt(entry.key)),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addPhase,
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text(
            'ADD FUTURE PHASE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            side: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _addPhase() async {
    final lastEnd = _additionalSchedules.isNotEmpty
        ? _additionalSchedules.last.endDate
        : _endDate;
    final nextStart = (lastEnd ?? DateTime.now()).add(const Duration(days: 1));

    final newSchedule = await showModalBottomSheet<MedicineSchedule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhaseConfigSheet(
        initialSchedule: MedicineSchedule(
          dosage: _dosageController.text,
          times: _selectedTimes
              .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
              .toList(),
          startDate: nextStart,
        ),
      ),
    );

    if (newSchedule != null) {
      setState(() => _additionalSchedules.add(newSchedule));
    }
  }

  void _editPhase(int index) async {
    final updated = await showModalBottomSheet<MedicineSchedule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PhaseConfigSheet(initialSchedule: _additionalSchedules[index]),
    );

    if (updated != null) setState(() => _additionalSchedules[index] = updated);
  }

  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          final isLoading = state is MedicineLoading;
          return ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    _saveMedicine();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
              disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.54,
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    (widget.medicine == null
                        ? 'CREATE REMINDER'
                        : 'SAVE CHANGES'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: OutlinedButton.icon(
          onPressed: () {
            _showDeleteDialog(context);
          },
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          label: Text(
            'DELETE MEDICINE',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.colorScheme.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'DELETE MEDICINE?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This will permanently remove this medicine and all its reminder history.',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MedicineBloc>().add(
                DeleteMedicineEvent(widget.medicine!.id),
              );
            },
            child: Text(
              'DELETE',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
