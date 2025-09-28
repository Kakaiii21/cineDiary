import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';
import 'newNote.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String query = "";

  @override
  Widget build(BuildContext context) {
    final notesBox = Hive.box<Note>('notes');

    return Scaffold(
      backgroundColor: const Color.fromRGBO(35, 82, 158, 1),
      body: ValueListenableBuilder(
        valueListenable: notesBox.listenable(),
        builder: (context, Box<Note> box, _) {
          final allNotes = box.values.toList();

          // ✅ Filter + sort
          final notes = allNotes.where((note) {
            final lowerQuery = query.toLowerCase();
            return note.title.toLowerCase().contains(lowerQuery) ||
                note.content.toLowerCase().contains(lowerQuery);
          }).toList()
            ..sort((a, b) {
              if (a.isPinned && !b.isPinned) return -1;
              if (!a.isPinned && b.isPinned) return 1;
              return b.date.compareTo(a.date);
            });

          return Column(
            children: [
              // 🔎 Search bar
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
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
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
                        // ➕ Add Note
                        return GestureDetector(
                          onTap: () async {
                            final newNote = await Navigator.push(
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
                            if (newNote != null) {
                              box.add(newNote);
                            }
                          },
                          child: Container(
                            width: 150,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(183, 151, 1, 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.add,
                                  size: 80,
                                  color: Color.fromRGBO(15, 29, 56, 1)),
                            ),
                          ),
                        );
                      }

                      final note = notes[index - 1];
                      return GestureDetector(
                        onTap: () async {
                          final editedNote = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditor(note: note),
                            ),
                          );
                          if (editedNote != null) {
                            note.title = editedNote.title;
                            note.content = editedNote.content;
                            note.date = editedNote.date;
                            note.save();
                          }
                        },
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(22, 44, 85, 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title + menu
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: const TextStyle(
                                        color: Color.fromRGBO(183, 151, 1, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // ⬇️ Wrap menu in Align
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: PopupMenuButton<String>(
                                      color: const Color.fromRGBO(22, 44, 85, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      icon: const Icon(Icons.more_horiz, color: Colors.white70),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          note.delete();
                                        } else if (value == 'pin') {
                                          note.isPinned = !note.isPinned;
                                          note.save();
                                          setState(() {});
                                        } else if (value == 'share') {
                                          Share.share("${note.title}\n\n${note.content}");
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'pin',
                                          child: Text(
                                            note.isPinned ? "Unpin" : "Pin",
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'share',
                                          child: Text("Share", style: TextStyle(color: Colors.white)),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text("Delete",
                                              style: TextStyle(color: Colors.redAccent)),
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
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
