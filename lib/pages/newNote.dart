import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NoteEditor extends StatefulWidget {
  final Note note;
  final bool isNew;

  const NoteEditor({super.key, required this.note, this.isNew = false});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  Future<void> _saveNote() async {
    final notesBox = Hive.box<Note>('notes');

    widget.note.title =
    _titleController.text.isEmpty ? "UNTITLED" : _titleController.text;
    widget.note.content = _contentController.text;
    widget.note.date = DateTime.now();

    if (widget.isNew) {
      await notesBox.add(widget.note); // add new
    } else {
      await widget.note.save(); // update existing
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveNote(); // 👈 auto-save when pressing back
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.isNew ? "NEW NOTE" : "EDIT NOTE", style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,

          ),
          ),

          actions: [
            TextButton(
              onPressed: _saveNote,
              child: const Text(
                "SAVE",
                style: TextStyle(
                  color: Color.fromRGBO(183, 151, 1, 1),
                  fontSize: 20,

                ),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  color: Color.fromRGBO(183, 151, 1, 1),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Write your note...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

