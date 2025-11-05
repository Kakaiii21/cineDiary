import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note_model.dart';
import 'newNote.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;
  String query = "";

  @override
  void initState() {
    super.initState();
    _syncNotesFromFirestore();
    _syncNotesFromRealtimeDB();
  }

  /// 🔄 Fetch notes from Firestore and cache into Hive
  Future<void> _syncNotesFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final notesBox = Hive.box<Note>('notes');
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final id = data['id'] ?? doc.id;
      final title = data['title'] ?? 'Untitled';
      final content = data['content'] ?? '';
      final date = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
      final isPinned = data['isPinned'] ?? false;

      final existingNote = notesBox.values.firstWhere(
        (n) => n.id == id,
        orElse: () =>
            Note(title: '', content: '', date: DateTime.now(), id: ''),
      );

      if (existingNote.id.isEmpty) {
        await notesBox.add(
          Note(
            title: title,
            content: content,
            date: date,
            isPinned: isPinned,
            id: id,
          ),
        );
      }
    }
  }

  /// 🔄 Fetch notes from Realtime Database and cache into Hive
  Future<void> _syncNotesFromRealtimeDB() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final notesBox = Hive.box<Note>('notes');
    final ref = _realtimeDB.ref('users/${user.uid}/notes');

    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final notesData = Map<String, dynamic>.from(snapshot.value as Map);

        for (var entry in notesData.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          final title = data['title'] ?? 'Untitled';
          final content = data['content'] ?? '';
          final date = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
          final isPinned = data['isPinned'] ?? false;

          final existingNote = notesBox.values.firstWhere(
            (n) => n.title == title && n.content == content,
            orElse: () => Note(title: '', content: '', date: DateTime.now()),
          );

          if (existingNote.title.isEmpty) {
            await notesBox.add(
              Note(
                title: title,
                content: content,
                date: date,
                isPinned: isPinned,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error syncing from Realtime Database: $e");
    }
  }

  /// ➕ Save new note to both databases
  Future<void> _saveNoteToBothDatabases(Note note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final noteData = {
      'title': note.title,
      'content': note.content,
      'date': note.date.toIso8601String(),
      'isPinned': note.isPinned,
    };

    // Save to Firestore
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .add(noteData);
    } catch (e) {
      debugPrint("⚠️ Error saving to Firestore: $e");
    }

    // Save to Realtime Database
    try {
      await _realtimeDB.ref('users/${user.uid}/notes').push().set(noteData);
    } catch (e) {
      debugPrint("⚠️ Error saving to Realtime Database: $e");
    }
  }

  /// 🔄 Update note in both databases
  Future<void> _updateNoteInBothDatabases(Note note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final noteData = {
      'title': note.title,
      'content': note.content,
      'date': note.date.toIso8601String(),
      'isPinned': note.isPinned,
    };

    // Update in Firestore
    try {
      final notesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes');

      final querySnapshot = await notesRef
          .where('title', isEqualTo: note.title)
          .where('content', isEqualTo: note.content)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update(noteData);
      }
    } catch (e) {
      debugPrint("⚠️ Error updating in Firestore: $e");
    }

    // Update in Realtime Database
    try {
      final ref = _realtimeDB.ref('users/${user.uid}/notes');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final notesData = Map<String, dynamic>.from(snapshot.value as Map);

        for (var entry in notesData.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          if (data['title'] == note.title && data['content'] == note.content) {
            await ref.child(entry.key).update(noteData);
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error updating in Realtime Database: $e");
    }
  }

  /// ❌ Delete note from Firestore
  Future<void> _deleteNoteFromFirestore(Note note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final notesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes');

      final querySnapshot = await notesRef
          .where('title', isEqualTo: note.title)
          .where('content', isEqualTo: note.content)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint("⚠️ Error deleting note from Firestore: $e");
    }
  }

  /// ❌ Delete note from Realtime Database
  Future<void> _deleteNoteFromRealtimeDB(Note note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = _realtimeDB.ref('users/${user.uid}/notes');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final notesData = Map<String, dynamic>.from(snapshot.value as Map);

        for (var entry in notesData.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          if (data['title'] == note.title && data['content'] == note.content) {
            await ref.child(entry.key).remove();
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error deleting note from Realtime Database: $e");
    }
  }

  /// 🗑️ Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(22, 44, 85, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Delete Note?',
            style: TextStyle(
              color: Color.fromRGBO(183, 151, 1, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${note.title}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteNoteFromFirestore(note);
      await _deleteNoteFromRealtimeDB(note);
      await note.delete();
    }
  }

  /// 📌 Update pin status in both databases
  Future<void> _updatePinStatus(Note note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    note.isPinned = !note.isPinned;
    note.save();
    setState(() {});

    // Update in Firestore
    try {
      final notesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes');

      final querySnapshot = await notesRef
          .where('title', isEqualTo: note.title)
          .where('content', isEqualTo: note.content)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'isPinned': note.isPinned});
      }
    } catch (e) {
      debugPrint("⚠️ Error updating pin in Firestore: $e");
    }

    // Update in Realtime Database
    try {
      final ref = _realtimeDB.ref('users/${user.uid}/notes');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final notesData = Map<String, dynamic>.from(snapshot.value as Map);

        for (var entry in notesData.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          if (data['title'] == note.title && data['content'] == note.content) {
            await ref.child(entry.key).update({'isPinned': note.isPinned});
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error updating pin in Realtime Database: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesBox = Hive.box<Note>('notes');

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background
          Container(color: const Color.fromRGBO(35, 82, 158, 1)),
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/images/noise.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // ✅ Foreground
          ValueListenableBuilder(
            valueListenable: notesBox.listenable(),
            builder: (context, Box<Note> box, _) {
              final allNotes = box.values.toList();

              final notes =
                  allNotes.where((note) {
                    final lowerQuery = query.toLowerCase();
                    return note.title.toLowerCase().contains(lowerQuery) ||
                        note.content.toLowerCase().contains(lowerQuery);
                  }).toList()..sort((a, b) {
                    if (a.isPinned && !b.isPinned) return -1;
                    if (!a.isPinned && b.isPinned) return 1;
                    return b.date.compareTo(a.date);
                  });

              return Column(
                children: [
                  // 🔎 Search Bar
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          query = val;
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search notes...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: const Color.fromRGBO(22, 44, 85, 1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // 📝 Notes grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 25,
                        crossAxisSpacing: 25,
                        itemCount: notes.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // ➕ Add Note button
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NoteEditor(
                                      note: Note(
                                        title: "UNTITLED",
                                        content: "",
                                        date: DateTime.now(),
                                      ),
                                      isNew: true,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 150,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(183, 151, 1, 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 80,
                                    color: Color.fromRGBO(15, 29, 56, 1),
                                  ),
                                ),
                              ),
                            );
                          }

                          final note = notes[index - 1];

                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NoteEditor(note: note),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                // Note card
                                Container(
                                  height: 300,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(22, 44, 85, 1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title + menu
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              note.title,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(
                                                  183,
                                                  151,
                                                  1,
                                                  1,
                                                ),
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: PopupMenuButton<String>(
                                              color: const Color.fromRGBO(
                                                22,
                                                44,
                                                85,
                                                1,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              icon: const Icon(
                                                Icons.more_horiz,
                                                color: Colors.white70,
                                              ),
                                              onSelected: (value) async {
                                                if (value == 'delete') {
                                                  await _showDeleteConfirmation(
                                                    note,
                                                  );
                                                } else if (value == 'pin') {
                                                  await _updatePinStatus(note);
                                                } else if (value == 'share') {
                                                  Share.share(
                                                    "${note.title}\n\n${note.content}",
                                                  );
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 'pin',
                                                  child: Text(
                                                    note.isPinned
                                                        ? "Unpin"
                                                        : "Pin",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'share',
                                                  child: Text(
                                                    "Share",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${note.date.toLocal().toString().split(' ')[0]}",
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Expanded(
                                        child: Text(
                                          note.content,
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 📌 Pinned indicator (visible when pinned)
                                if (note.isPinned)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.yellow.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.push_pin,
                                        size: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
