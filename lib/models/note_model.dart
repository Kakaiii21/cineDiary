import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool isPinned;

  @HiveField(4)
  String id; // ✅ Unique ID to track across databases

  Note({
    required this.title,
    required this.content,
    required this.date,
    this.isPinned = false,
    String? id,
  }) : id = id ?? const Uuid().v4(); // Generate unique ID if not provided
}
