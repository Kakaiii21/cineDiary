import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  /// Check if note has any content
  bool _hasContent() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // If title is "UNTITLED" and content is empty, consider it as no content
    final hasTitle = title.isNotEmpty && title.toUpperCase() != "UNTITLED";
    final hasContent = content.isNotEmpty;

    return hasTitle || hasContent;
  }

  Future<void> _saveNote() async {
    // ✅ Don't save if it's a new note with no content
    if (widget.isNew && !_hasContent()) {
      debugPrint("⚠️ Empty note - not saving");
      Navigator.pop(context);
      return;
    }

    // ✅ Don't save if existing note has no content (user deleted everything)
    if (!widget.isNew && !_hasContent()) {
      debugPrint("⚠️ Note content cleared - not saving");
      Navigator.pop(context);
      return;
    }

    final notesBox = Hive.box<Note>('notes');

    widget.note.title = _titleController.text.isEmpty
        ? "UNTITLED"
        : _titleController.text;
    widget.note.content = _contentController.text;
    widget.note.date = DateTime.now();

    // ✅ Save locally with Hive
    if (widget.isNew) {
      await notesBox.add(widget.note);
    } else {
      await widget.note.save();
    }

    // ✅ Get current user
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("⚠️ No logged-in user — note saved locally only.");
      Navigator.pop(context);
      return;
    }

    // ✅ Note data structure with ID
    final noteData = {
      'id': widget.note.id,
      'title': widget.note.title,
      'content': widget.note.content,
      'date': widget.note.date.toIso8601String(),
      'isPinned': widget.note.isPinned,
    };

    // ✅ Save to Firestore
    try {
      final userNotesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes');

      if (widget.isNew) {
        await userNotesRef.doc(widget.note.id).set(noteData);
        debugPrint("✅ Note saved to Firestore with ID: ${widget.note.id}");
      } else {
        await userNotesRef.doc(widget.note.id).update(noteData);
        debugPrint("✅ Note updated in Firestore with ID: ${widget.note.id}");
      }
    } catch (e) {
      debugPrint("❌ Firestore save error: $e");
    }

    // ✅ Save to Realtime Database
    try {
      final realtimeRef = _realtimeDB.ref(
        'users/${user.uid}/notes/${widget.note.id}',
      );

      await realtimeRef.set(noteData);

      if (widget.isNew) {
        debugPrint(
          "✅ Note saved to Realtime Database with ID: ${widget.note.id}",
        );
      } else {
        debugPrint(
          "✅ Note updated in Realtime Database with ID: ${widget.note.id}",
        );
      }
    } catch (e) {
      debugPrint("❌ Realtime Database save error: $e");
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveNote();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.isNew ? "NEW NOTE" : "EDIT NOTE",
            style: const TextStyle(
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
            ),
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
