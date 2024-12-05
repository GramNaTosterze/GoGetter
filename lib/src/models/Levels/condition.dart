import 'dart:core';

class Condition {
  final String start;
  final String end;
  final bool shouldConnect;

  Condition(this.start, this.end) : shouldConnect = true;

  Condition.fromJson(Map<String, dynamic> json)
    : start = json['start'] as String,
      end = json['end'] as String,
      shouldConnect = json['shouldConnect'] as bool;
}