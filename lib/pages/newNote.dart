import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 for current user
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
  final FirebaseAuth _auth = FirebaseAuth.instance; // 👈 to get user ID

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  Future<void> _saveNote() async {
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

    // ✅ Get current user (required for Firestore path)
    final user = _auth.currentUser;
    if (user == null) {
      print("⚠️ No logged-in user — note saved locally only.");
      Navigator.pop(context);
      return;
    }

    // ✅ Firestore data structure
    final noteData = {
      'title': widget.note.title,
      'content': widget.note.content,
      'date': widget.note.date.toIso8601String(),
      'isPinned': widget.note.isPinned,
    };

    try {
      final userNotesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes');

      if (widget.isNew) {
        // ➕ Add new note
        await userNotesRef.add(noteData);
      } else {
        // 🔄 Update existing note if possible
        final query = await userNotesRef
            .where('title', isEqualTo: widget.note.title)
            .get();

        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update(noteData);
        } else {
          await userNotesRef.add(noteData);
        }
      }

      print("✅ Note saved to Firestore under user ${user.uid}");
    } catch (e) {
      print("❌ Firestore save error: $e");
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
}
