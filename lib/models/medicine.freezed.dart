// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medicine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Medicine {

@HiveField(0) String get id;@HiveField(1) String get name;@HiveField(2) String get dosage;@HiveField(3) List<int> get daysOfWeek;@HiveField(4) List<String> get times;@HiveField(5) DateTime get startDate;@HiveField(6) DateTime? get endDate;@HiveField(7) bool get isActive;@HiveField(8) bool get takeWithFood;@HiveField(9) String? get notes;@HiveField(10) String get frequency;@HiveField(11) List<int> get daysOfMonth;@HiveField(12) List<MedicineSchedule> get schedules;@HiveField(13) String get type;@HiveField(14) String get dosageUnit;@HiveField(15) List<DateTime> get skippedDates;@HiveField(16) List<DateTime> get manualActiveDates;@HiveField(17) List<String> get deactivatedTimes;
/// Create a copy of Medicine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineCopyWith<Medicine> get copyWith => _$MedicineCopyWithImpl<Medicine>(this as Medicine, _$identity);

  /// Serializes this Medicine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Medicine&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&const DeepCollectionEquality().equals(other.daysOfWeek, daysOfWeek)&&const DeepCollectionEquality().equals(other.times, times)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.takeWithFood, takeWithFood) || other.takeWithFood == takeWithFood)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&const DeepCollectionEquality().equals(other.daysOfMonth, daysOfMonth)&&const DeepCollectionEquality().equals(other.schedules, schedules)&&(identical(other.type, type) || other.type == type)&&(identical(other.dosageUnit, dosageUnit) || other.dosageUnit == dosageUnit)&&const DeepCollectionEquality().equals(other.skippedDates, skippedDates)&&const DeepCollectionEquality().equals(other.manualActiveDates, manualActiveDates)&&const DeepCollectionEquality().equals(other.deactivatedTimes, deactivatedTimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,dosage,const DeepCollectionEquality().hash(daysOfWeek),const DeepCollectionEquality().hash(times),startDate,endDate,isActive,takeWithFood,notes,frequency,const DeepCollectionEquality().hash(daysOfMonth),const DeepCollectionEquality().hash(schedules),type,dosageUnit,const DeepCollectionEquality().hash(skippedDates),const DeepCollectionEquality().hash(manualActiveDates),const DeepCollectionEquality().hash(deactivatedTimes));

@override
String toString() {
  return 'Medicine(id: $id, name: $name, dosage: $dosage, daysOfWeek: $daysOfWeek, times: $times, startDate: $startDate, endDate: $endDate, isActive: $isActive, takeWithFood: $takeWithFood, notes: $notes, frequency: $frequency, daysOfMonth: $daysOfMonth, schedules: $schedules, type: $type, dosageUnit: $dosageUnit, skippedDates: $skippedDates, manualActiveDates: $manualActiveDates, deactivatedTimes: $deactivatedTimes)';
}


}

/// @nodoc
abstract mixin class $MedicineCopyWith<$Res>  {
  factory $MedicineCopyWith(Medicine value, $Res Function(Medicine) _then) = _$MedicineCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String name,@HiveField(2) String dosage,@HiveField(3) List<int> daysOfWeek,@HiveField(4) List<String> times,@HiveField(5) DateTime startDate,@HiveField(6) DateTime? endDate,@HiveField(7) bool isActive,@HiveField(8) bool takeWithFood,@HiveField(9) String? notes,@HiveField(10) String frequency,@HiveField(11) List<int> daysOfMonth,@HiveField(12) List<MedicineSchedule> schedules,@HiveField(13) String type,@HiveField(14) String dosageUnit,@HiveField(15) List<DateTime> skippedDates,@HiveField(16) List<DateTime> manualActiveDates,@HiveField(17) List<String> deactivatedTimes
});




}
/// @nodoc
class _$MedicineCopyWithImpl<$Res>
    implements $MedicineCopyWith<$Res> {
  _$MedicineCopyWithImpl(this._self, this._then);

  final Medicine _self;
  final $Res Function(Medicine) _then;

/// Create a copy of Medicine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? dosage = null,Object? daysOfWeek = null,Object? times = null,Object? startDate = null,Object? endDate = freezed,Object? isActive = null,Object? takeWithFood = null,Object? notes = freezed,Object? frequency = null,Object? daysOfMonth = null,Object? schedules = null,Object? type = null,Object? dosageUnit = null,Object? skippedDates = null,Object? manualActiveDates = null,Object? deactivatedTimes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,daysOfWeek: null == daysOfWeek ? _self.daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,times: null == times ? _self.times : times // ignore: cast_nullable_to_non_nullable
as List<String>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,takeWithFood: null == takeWithFood ? _self.takeWithFood : takeWithFood // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,daysOfMonth: null == daysOfMonth ? _self.daysOfMonth : daysOfMonth // ignore: cast_nullable_to_non_nullable
as List<int>,schedules: null == schedules ? _self.schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<MedicineSchedule>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,dosageUnit: null == dosageUnit ? _self.dosageUnit : dosageUnit // ignore: cast_nullable_to_non_nullable
as String,skippedDates: null == skippedDates ? _self.skippedDates : skippedDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,manualActiveDates: null == manualActiveDates ? _self.manualActiveDates : manualActiveDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,deactivatedTimes: null == deactivatedTimes ? _self.deactivatedTimes : deactivatedTimes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Medicine].
extension MedicinePatterns on Medicine {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Medicine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Medicine() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Medicine value)  $default,){
final _that = this;
switch (_that) {
case _Medicine():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Medicine value)?  $default,){
final _that = this;
switch (_that) {
case _Medicine() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String name, @HiveField(2)  String dosage, @HiveField(3)  List<int> daysOfWeek, @HiveField(4)  List<String> times, @HiveField(5)  DateTime startDate, @HiveField(6)  DateTime? endDate, @HiveField(7)  bool isActive, @HiveField(8)  bool takeWithFood, @HiveField(9)  String? notes, @HiveField(10)  String frequency, @HiveField(11)  List<int> daysOfMonth, @HiveField(12)  List<MedicineSchedule> schedules, @HiveField(13)  String type, @HiveField(14)  String dosageUnit, @HiveField(15)  List<DateTime> skippedDates, @HiveField(16)  List<DateTime> manualActiveDates, @HiveField(17)  List<String> deactivatedTimes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Medicine() when $default != null:
return $default(_that.id,_that.name,_that.dosage,_that.daysOfWeek,_that.times,_that.startDate,_that.endDate,_that.isActive,_that.takeWithFood,_that.notes,_that.frequency,_that.daysOfMonth,_that.schedules,_that.type,_that.dosageUnit,_that.skippedDates,_that.manualActiveDates,_that.deactivatedTimes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String name, @HiveField(2)  String dosage, @HiveField(3)  List<int> daysOfWeek, @HiveField(4)  List<String> times, @HiveField(5)  DateTime startDate, @HiveField(6)  DateTime? endDate, @HiveField(7)  bool isActive, @HiveField(8)  bool takeWithFood, @HiveField(9)  String? notes, @HiveField(10)  String frequency, @HiveField(11)  List<int> daysOfMonth, @HiveField(12)  List<MedicineSchedule> schedules, @HiveField(13)  String type, @HiveField(14)  String dosageUnit, @HiveField(15)  List<DateTime> skippedDates, @HiveField(16)  List<DateTime> manualActiveDates, @HiveField(17)  List<String> deactivatedTimes)  $default,) {final _that = this;
switch (_that) {
case _Medicine():
return $default(_that.id,_that.name,_that.dosage,_that.daysOfWeek,_that.times,_that.startDate,_that.endDate,_that.isActive,_that.takeWithFood,_that.notes,_that.frequency,_that.daysOfMonth,_that.schedules,_that.type,_that.dosageUnit,_that.skippedDates,_that.manualActiveDates,_that.deactivatedTimes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String name, @HiveField(2)  String dosage, @HiveField(3)  List<int> daysOfWeek, @HiveField(4)  List<String> times, @HiveField(5)  DateTime startDate, @HiveField(6)  DateTime? endDate, @HiveField(7)  bool isActive, @HiveField(8)  bool takeWithFood, @HiveField(9)  String? notes, @HiveField(10)  String frequency, @HiveField(11)  List<int> daysOfMonth, @HiveField(12)  List<MedicineSchedule> schedules, @HiveField(13)  String type, @HiveField(14)  String dosageUnit, @HiveField(15)  List<DateTime> skippedDates, @HiveField(16)  List<DateTime> manualActiveDates, @HiveField(17)  List<String> deactivatedTimes)?  $default,) {final _that = this;
switch (_that) {
case _Medicine() when $default != null:
return $default(_that.id,_that.name,_that.dosage,_that.daysOfWeek,_that.times,_that.startDate,_that.endDate,_that.isActive,_that.takeWithFood,_that.notes,_that.frequency,_that.daysOfMonth,_that.schedules,_that.type,_that.dosageUnit,_that.skippedDates,_that.manualActiveDates,_that.deactivatedTimes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Medicine implements Medicine {
  const _Medicine({@HiveField(0) required this.id, @HiveField(1) required this.name, @HiveField(2) required this.dosage, @HiveField(3) required final  List<int> daysOfWeek, @HiveField(4) required final  List<String> times, @HiveField(5) required this.startDate, @HiveField(6) this.endDate, @HiveField(7) this.isActive = false, @HiveField(8) this.takeWithFood = false, @HiveField(9) this.notes, @HiveField(10) this.frequency = 'weekly', @HiveField(11) final  List<int> daysOfMonth = const [], @HiveField(12) final  List<MedicineSchedule> schedules = const [], @HiveField(13) this.type = 'pill', @HiveField(14) this.dosageUnit = 'tablet', @HiveField(15) final  List<DateTime> skippedDates = const [], @HiveField(16) final  List<DateTime> manualActiveDates = const [], @HiveField(17) final  List<String> deactivatedTimes = const []}): _daysOfWeek = daysOfWeek,_times = times,_daysOfMonth = daysOfMonth,_schedules = schedules,_skippedDates = skippedDates,_manualActiveDates = manualActiveDates,_deactivatedTimes = deactivatedTimes;
  factory _Medicine.fromJson(Map<String, dynamic> json) => _$MedicineFromJson(json);

@override@HiveField(0) final  String id;
@override@HiveField(1) final  String name;
@override@HiveField(2) final  String dosage;
 final  List<int> _daysOfWeek;
@override@HiveField(3) List<int> get daysOfWeek {
  if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daysOfWeek);
}

 final  List<String> _times;
@override@HiveField(4) List<String> get times {
  if (_times is EqualUnmodifiableListView) return _times;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_times);
}

@override@HiveField(5) final  DateTime startDate;
@override@HiveField(6) final  DateTime? endDate;
@override@JsonKey()@HiveField(7) final  bool isActive;
@override@JsonKey()@HiveField(8) final  bool takeWithFood;
@override@HiveField(9) final  String? notes;
@override@JsonKey()@HiveField(10) final  String frequency;
 final  List<int> _daysOfMonth;
@override@JsonKey()@HiveField(11) List<int> get daysOfMonth {
  if (_daysOfMonth is EqualUnmodifiableListView) return _daysOfMonth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daysOfMonth);
}

 final  List<MedicineSchedule> _schedules;
@override@JsonKey()@HiveField(12) List<MedicineSchedule> get schedules {
  if (_schedules is EqualUnmodifiableListView) return _schedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedules);
}

@override@JsonKey()@HiveField(13) final  String type;
@override@JsonKey()@HiveField(14) final  String dosageUnit;
 final  List<DateTime> _skippedDates;
@override@JsonKey()@HiveField(15) List<DateTime> get skippedDates {
  if (_skippedDates is EqualUnmodifiableListView) return _skippedDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skippedDates);
}

 final  List<DateTime> _manualActiveDates;
@override@JsonKey()@HiveField(16) List<DateTime> get manualActiveDates {
  if (_manualActiveDates is EqualUnmodifiableListView) return _manualActiveDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_manualActiveDates);
}

 final  List<String> _deactivatedTimes;
@override@JsonKey()@HiveField(17) List<String> get deactivatedTimes {
  if (_deactivatedTimes is EqualUnmodifiableListView) return _deactivatedTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deactivatedTimes);
}


/// Create a copy of Medicine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineCopyWith<_Medicine> get copyWith => __$MedicineCopyWithImpl<_Medicine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Medicine&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&const DeepCollectionEquality().equals(other._daysOfWeek, _daysOfWeek)&&const DeepCollectionEquality().equals(other._times, _times)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.takeWithFood, takeWithFood) || other.takeWithFood == takeWithFood)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&const DeepCollectionEquality().equals(other._daysOfMonth, _daysOfMonth)&&const DeepCollectionEquality().equals(other._schedules, _schedules)&&(identical(other.type, type) || other.type == type)&&(identical(other.dosageUnit, dosageUnit) || other.dosageUnit == dosageUnit)&&const DeepCollectionEquality().equals(other._skippedDates, _skippedDates)&&const DeepCollectionEquality().equals(other._manualActiveDates, _manualActiveDates)&&const DeepCollectionEquality().equals(other._deactivatedTimes, _deactivatedTimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,dosage,const DeepCollectionEquality().hash(_daysOfWeek),const DeepCollectionEquality().hash(_times),startDate,endDate,isActive,takeWithFood,notes,frequency,const DeepCollectionEquality().hash(_daysOfMonth),const DeepCollectionEquality().hash(_schedules),type,dosageUnit,const DeepCollectionEquality().hash(_skippedDates),const DeepCollectionEquality().hash(_manualActiveDates),const DeepCollectionEquality().hash(_deactivatedTimes));

@override
String toString() {
  return 'Medicine(id: $id, name: $name, dosage: $dosage, daysOfWeek: $daysOfWeek, times: $times, startDate: $startDate, endDate: $endDate, isActive: $isActive, takeWithFood: $takeWithFood, notes: $notes, frequency: $frequency, daysOfMonth: $daysOfMonth, schedules: $schedules, type: $type, dosageUnit: $dosageUnit, skippedDates: $skippedDates, manualActiveDates: $manualActiveDates, deactivatedTimes: $deactivatedTimes)';
}


}

/// @nodoc
abstract mixin class _$MedicineCopyWith<$Res> implements $MedicineCopyWith<$Res> {
  factory _$MedicineCopyWith(_Medicine value, $Res Function(_Medicine) _then) = __$MedicineCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String name,@HiveField(2) String dosage,@HiveField(3) List<int> daysOfWeek,@HiveField(4) List<String> times,@HiveField(5) DateTime startDate,@HiveField(6) DateTime? endDate,@HiveField(7) bool isActive,@HiveField(8) bool takeWithFood,@HiveField(9) String? notes,@HiveField(10) String frequency,@HiveField(11) List<int> daysOfMonth,@HiveField(12) List<MedicineSchedule> schedules,@HiveField(13) String type,@HiveField(14) String dosageUnit,@HiveField(15) List<DateTime> skippedDates,@HiveField(16) List<DateTime> manualActiveDates,@HiveField(17) List<String> deactivatedTimes
});




}
/// @nodoc
class __$MedicineCopyWithImpl<$Res>
    implements _$MedicineCopyWith<$Res> {
  __$MedicineCopyWithImpl(this._self, this._then);

  final _Medicine _self;
  final $Res Function(_Medicine) _then;

/// Create a copy of Medicine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? dosage = null,Object? daysOfWeek = null,Object? times = null,Object? startDate = null,Object? endDate = freezed,Object? isActive = null,Object? takeWithFood = null,Object? notes = freezed,Object? frequency = null,Object? daysOfMonth = null,Object? schedules = null,Object? type = null,Object? dosageUnit = null,Object? skippedDates = null,Object? manualActiveDates = null,Object? deactivatedTimes = null,}) {
  return _then(_Medicine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,daysOfWeek: null == daysOfWeek ? _self._daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,times: null == times ? _self._times : times // ignore: cast_nullable_to_non_nullable
as List<String>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,takeWithFood: null == takeWithFood ? _self.takeWithFood : takeWithFood // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,daysOfMonth: null == daysOfMonth ? _self._daysOfMonth : daysOfMonth // ignore: cast_nullable_to_non_nullable
as List<int>,schedules: null == schedules ? _self._schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<MedicineSchedule>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,dosageUnit: null == dosageUnit ? _self.dosageUnit : dosageUnit // ignore: cast_nullable_to_non_nullable
as String,skippedDates: null == skippedDates ? _self._skippedDates : skippedDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,manualActiveDates: null == manualActiveDates ? _self._manualActiveDates : manualActiveDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,deactivatedTimes: null == deactivatedTimes ? _self._deactivatedTimes : deactivatedTimes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
