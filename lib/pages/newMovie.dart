import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class NewMovieScreen extends StatefulWidget {
  const NewMovieScreen({super.key});

  @override
  State<NewMovieScreen> createState() => _NewMovieScreenState();
}

class _NewMovieScreenState extends State<NewMovieScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int rating = 0;

  File? _poster; // to store the selected image

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _poster = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(12, 20, 39, 1),
              Color.fromRGBO(12, 20, 39, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "NEW MOVIE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Poster Upload
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: 140,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(196, 196, 196, 1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromRGBO(196, 196, 196, 1),
                        ),
                      ),
                      child: _poster == null
                          ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image,
                                size: 40,
                                color: Color.fromRGBO(146, 146, 146, 1)),
                            SizedBox(height: 8),
                            Text(
                              "Add an image",
                              style: TextStyle(
                                color: Color.fromRGBO(146, 146, 146, 1),
                              ),
                            ),
                          ],
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _poster!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Background Box for inputs
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(39, 59, 94, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "TITLE :",
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Genre + Add to Library
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: genreController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "GENRE :",
                                labelStyle: const TextStyle(color: Colors.white),
                                filled: true,
                                fillColor: Colors.white12,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color.fromRGBO(183, 151, 1, 1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              _showLibraryBottomSheet(context);
                            },
                            child: const Text(
                              "ADD TO LIBRARY",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Rating
                      const Text(
                        "RATE IT",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                rating = index + 1;
                              });
                            },
                            icon: Icon(
                              Icons.star,
                              size: 32,
                              color: index < rating
                                  ? const Color.fromRGBO(183, 151, 1, 1)
                                  : Colors.white30,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        maxLength: 1000,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Say something...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show bottom sheet for choosing/creating a library
  void _showLibraryBottomSheet(BuildContext context) {
    final movieBox = Hive.box('movies');
    final TextEditingController libraryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        // get existing libraries
        List<String> libraries = [];
        for (int i = 0; i < movieBox.length; i++) {
          final movie = movieBox.getAt(i);
          if (movie['library'] != null) {
            libraries.add(movie['library']);
          }
        }
        libraries = libraries.toSet().toList(); // remove duplicates

        String? selectedLibrary;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Choose a Library",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 12),

                  // Dropdown existing libraries
                  if (libraries.isNotEmpty)
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.black87,
                      value: selectedLibrary,
                      hint: const Text("Select library",
                          style: TextStyle(color: Colors.white70)),
                      items: libraries
                          .map((lib) => DropdownMenuItem(
                        value: lib,
                        child: Text(lib,
                            style:
                            const TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedLibrary = val;
                        });
                      },
                    ),

                  const SizedBox(height: 16),

                  // Create new library
                  TextField(
                    controller: libraryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Or create new library",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(183, 151, 1, 1),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      String libraryName = libraryController.text.trim().isNotEmpty
                          ? libraryController.text.trim() // ✅ use newly created library
                          : (selectedLibrary ?? "BEST RATINGS"); // ✅ or existing one / default

                      movieBox.add({
                        'title': titleController.text,
                        'genre': genreController.text,
                        'description': descriptionController.text,
                        'rating': rating,
                        'poster': _poster?.path, // ✅ image stored
                        'library': libraryName,  // ✅ always saves to correct library
                      });

                      Navigator.pop(context); // close bottom sheet
                      Navigator.pop(context); // go back to MovieScreen
                    },
                    child: const Text("SAVE TO LIBRARY",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
