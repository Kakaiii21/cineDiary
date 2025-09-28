import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1) // make sure this typeId is unique in your app
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool isPinned; // ✅ new field

  Note({
    required this.title,
    required this.content,
    required this.date,
    this.isPinned = false, // default is not pinned
  });
}
