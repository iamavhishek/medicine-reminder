// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medicine_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicineSchedule {

@HiveField(0) String get dosage;@HiveField(1) List<String> get times;@HiveField(2) String get frequency;@HiveField(3) List<int> get daysOfWeek;@HiveField(4) List<int> get daysOfMonth;@HiveField(5) DateTime get startDate;@HiveField(6) DateTime? get endDate;@HiveField(7) List<String> get deactivatedTimes;
/// Create a copy of MedicineSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineScheduleCopyWith<MedicineSchedule> get copyWith => _$MedicineScheduleCopyWithImpl<MedicineSchedule>(this as MedicineSchedule, _$identity);

  /// Serializes this MedicineSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineSchedule&&(identical(other.dosage, dosage) || other.dosage == dosage)&&const DeepCollectionEquality().equals(other.times, times)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&const DeepCollectionEquality().equals(other.daysOfWeek, daysOfWeek)&&const DeepCollectionEquality().equals(other.daysOfMonth, daysOfMonth)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.deactivatedTimes, deactivatedTimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dosage,const DeepCollectionEquality().hash(times),frequency,const DeepCollectionEquality().hash(daysOfWeek),const DeepCollectionEquality().hash(daysOfMonth),startDate,endDate,const DeepCollectionEquality().hash(deactivatedTimes));

@override
String toString() {
  return 'MedicineSchedule(dosage: $dosage, times: $times, frequency: $frequency, daysOfWeek: $daysOfWeek, daysOfMonth: $daysOfMonth, startDate: $startDate, endDate: $endDate, deactivatedTimes: $deactivatedTimes)';
}


}

/// @nodoc
abstract mixin class $MedicineScheduleCopyWith<$Res>  {
  factory $MedicineScheduleCopyWith(MedicineSchedule value, $Res Function(MedicineSchedule) _then) = _$MedicineScheduleCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String dosage,@HiveField(1) List<String> times,@HiveField(2) String frequency,@HiveField(3) List<int> daysOfWeek,@HiveField(4) List<int> daysOfMonth,@HiveField(5) DateTime startDate,@HiveField(6) DateTime? endDate,@HiveField(7) List<String> deactivatedTimes
});




}
/// @nodoc
class _$MedicineScheduleCopyWithImpl<$Res>
    implements $MedicineScheduleCopyWith<$Res> {
  _$MedicineScheduleCopyWithImpl(this._self, this._then);

  final MedicineSchedule _self;
  final $Res Function(MedicineSchedule) _then;

/// Create a copy of MedicineSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dosage = null,Object? times = null,Object? frequency = null,Object? daysOfWeek = null,Object? daysOfMonth = null,Object? startDate = null,Object? endDate = freezed,Object? deactivatedTimes = null,}) {
  return _then(_self.copyWith(
dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,times: null == times ? _self.times : times // ignore: cast_nullable_to_non_nullable
as List<String>,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,daysOfWeek: null == daysOfWeek ? _self.daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,daysOfMonth: null == daysOfMonth ? _self.daysOfMonth : daysOfMonth // ignore: cast_nullable_to_non_nullable
as List<int>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deactivatedTimes: null == deactivatedTimes ? _self.deactivatedTimes : deactivatedTimes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineSchedule].
extension MedicineSchedulePatterns on MedicineSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineSchedule value)  $default,){
final _that = this;
switch (_that) {
case _MedicineSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String dosage, @HiveField(1)  List<String> times, @HiveField(2)  String frequency, @HiveField(3)  List<int> daysOfWeek, @HiveField(4)  List<int> daysOfMonth, @HiveField(5)  DateTime startDate, @HiveField(6)  DateTime? endDate, @HiveField(7)  List<String> deactivatedTimes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineSchedule() when $default != null:
return $default(_that.dosage,_that.times,_that.frequency,_that.daysOfWeek,_that.daysOfMonth,_that.startDate,_that.endDate,_that.deactivatedTimes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String dosage, @HiveField(1)  List<String> times, @HiveField(2)  String frequency, @HiveField(3)  List<int> daysOfWeek, @HiveField(4)  List<int> daysOfMonth, @HiveField(5)  DateTime startDate, @HiveField(6)  DateTime? endDate, @HiveField(7)  List<String> deactivatedTimes)  $default,) {final _that = this;
switch (_that) {
case _MedicineSchedule():
return $default(_that.dosage,_that.times,_that.frequency,_that.daysOfWeek,_that.daysOfMonth,_that.startDate,_that.endDate,_that.deactivatedTimes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String dosage, @HiveField(1)  List<String> times, @HiveField(2)  String frequency, @HiveField(3)  List<int> daysOfWeek, @HiveField(4)  List<int> daysOfMonth, @HiveField(5)  DateTime startDate, @HiveField(6)  DateTime? endDate, @HiveField(7)  List<String> deactivatedTimes)?  $default,) {final _that = this;
switch (_that) {
case _MedicineSchedule() when $default != null:
return $default(_that.dosage,_that.times,_that.frequency,_that.daysOfWeek,_that.daysOfMonth,_that.startDate,_that.endDate,_that.deactivatedTimes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicineSchedule implements MedicineSchedule {
  const _MedicineSchedule({@HiveField(0) required this.dosage, @HiveField(1) required final  List<String> times, @HiveField(2) this.frequency = 'weekly', @HiveField(3) final  List<int> daysOfWeek = const [], @HiveField(4) final  List<int> daysOfMonth = const [], @HiveField(5) required this.startDate, @HiveField(6) this.endDate, @HiveField(7) final  List<String> deactivatedTimes = const []}): _times = times,_daysOfWeek = daysOfWeek,_daysOfMonth = daysOfMonth,_deactivatedTimes = deactivatedTimes;
  factory _MedicineSchedule.fromJson(Map<String, dynamic> json) => _$MedicineScheduleFromJson(json);

@override@HiveField(0) final  String dosage;
 final  List<String> _times;
@override@HiveField(1) List<String> get times {
  if (_times is EqualUnmodifiableListView) return _times;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_times);
}

@override@JsonKey()@HiveField(2) final  String frequency;
 final  List<int> _daysOfWeek;
@override@JsonKey()@HiveField(3) List<int> get daysOfWeek {
  if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daysOfWeek);
}

 final  List<int> _daysOfMonth;
@override@JsonKey()@HiveField(4) List<int> get daysOfMonth {
  if (_daysOfMonth is EqualUnmodifiableListView) return _daysOfMonth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daysOfMonth);
}

@override@HiveField(5) final  DateTime startDate;
@override@HiveField(6) final  DateTime? endDate;
 final  List<String> _deactivatedTimes;
@override@JsonKey()@HiveField(7) List<String> get deactivatedTimes {
  if (_deactivatedTimes is EqualUnmodifiableListView) return _deactivatedTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deactivatedTimes);
}


/// Create a copy of MedicineSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineScheduleCopyWith<_MedicineSchedule> get copyWith => __$MedicineScheduleCopyWithImpl<_MedicineSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicineScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineSchedule&&(identical(other.dosage, dosage) || other.dosage == dosage)&&const DeepCollectionEquality().equals(other._times, _times)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&const DeepCollectionEquality().equals(other._daysOfWeek, _daysOfWeek)&&const DeepCollectionEquality().equals(other._daysOfMonth, _daysOfMonth)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._deactivatedTimes, _deactivatedTimes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dosage,const DeepCollectionEquality().hash(_times),frequency,const DeepCollectionEquality().hash(_daysOfWeek),const DeepCollectionEquality().hash(_daysOfMonth),startDate,endDate,const DeepCollectionEquality().hash(_deactivatedTimes));

@override
String toString() {
  return 'MedicineSchedule(dosage: $dosage, times: $times, frequency: $frequency, daysOfWeek: $daysOfWeek, daysOfMonth: $daysOfMonth, startDate: $startDate, endDate: $endDate, deactivatedTimes: $deactivatedTimes)';
}


}

/// @nodoc
abstract mixin class _$MedicineScheduleCopyWith<$Res> implements $MedicineScheduleCopyWith<$Res> {
  factory _$MedicineScheduleCopyWith(_MedicineSchedule value, $Res Function(_MedicineSchedule) _then) = __$MedicineScheduleCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String dosage,@HiveField(1) List<String> times,@HiveField(2) String frequency,@HiveField(3) List<int> daysOfWeek,@HiveField(4) List<int> daysOfMonth,@HiveField(5) DateTime startDate,@HiveField(6) DateTime? endDate,@HiveField(7) List<String> deactivatedTimes
});




}
/// @nodoc
class __$MedicineScheduleCopyWithImpl<$Res>
    implements _$MedicineScheduleCopyWith<$Res> {
  __$MedicineScheduleCopyWithImpl(this._self, this._then);

  final _MedicineSchedule _self;
  final $Res Function(_MedicineSchedule) _then;

/// Create a copy of MedicineSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dosage = null,Object? times = null,Object? frequency = null,Object? daysOfWeek = null,Object? daysOfMonth = null,Object? startDate = null,Object? endDate = freezed,Object? deactivatedTimes = null,}) {
  return _then(_MedicineSchedule(
dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,times: null == times ? _self._times : times // ignore: cast_nullable_to_non_nullable
as List<String>,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,daysOfWeek: null == daysOfWeek ? _self._daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,daysOfMonth: null == daysOfMonth ? _self._daysOfMonth : daysOfMonth // ignore: cast_nullable_to_non_nullable
as List<int>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,deactivatedTimes: null == deactivatedTimes ? _self._deactivatedTimes : deactivatedTimes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
