import 'package:go_getter/src/models/Levels/condition.dart';

class Level {
  final List<Condition> conditions;

  Level(this.conditions);
  
  Level.fromJson(Map<String, dynamic> json)
    : conditions = [for (var condition in json['conditions']) Condition.fromJson(condition)];
}