import 'package:go_getter/src/models/Levels/condition.dart';

class Level {
  final int idx;
  final List<Condition> conditions;

  Level(this.idx, this.conditions);
  
  Level.fromJson(this.idx, Map<String, dynamic> json)
    : conditions = [for (var condition in json['conditions']) Condition.fromJson(condition)];
}