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

  File? _poster;
  String selectedLibrary = "BEST RATINGS"; // Store selected library

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _poster = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(15, 29, 56, 1),
              Color.fromRGBO(15, 29, 56, 1),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with gradient
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(42, 82, 158, 1),
                              Color.fromRGBO(15, 29, 56, 1),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              "NEW MOVIE",
                              style: TextStyle(
                                color: Color.fromRGBO(236, 197, 61, 1),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
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
                              borderRadius: BorderRadius.circular(1),
                              border: Border.all(
                                color: const Color.fromRGBO(196, 196, 196, 1),
                              ),
                            ),
                            child: _poster == null
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Color.fromRGBO(
                                            146,
                                            146,
                                            146,
                                            1,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Add an image",
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                              146,
                                              146,
                                              146,
                                              1,
                                            ),
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

                      // Input Box
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
                            // Title input
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(15, 29, 56, 1),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Text(
                                    "TITLE:",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: titleController,
                                    style: const TextStyle(color: Colors.grey),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
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
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
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
                                    backgroundColor: const Color.fromRGBO(
                                      183,
                                      151,
                                      1,
                                      1,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
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

                            // Show selected library
                            if (selectedLibrary.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "Library: $selectedLibrary",
                                  style: const TextStyle(
                                    color: Color.fromRGBO(183, 151, 1, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Rating
                            const Text(
                              "RATE IT",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
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
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
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
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  39,
                                  59,
                                  94,
                                  1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "DISCARD",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  183,
                                  151,
                                  1,
                                  1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                // Save the entire movie entry
                                final movieBox = Hive.box('movies');
                                movieBox.add({
                                  'title': titleController.text,
                                  'genre': genreController.text,
                                  'description': descriptionController.text,
                                  'rating': rating,
                                  'poster': _poster?.path,
                                  'library': selectedLibrary,
                                });

                                Navigator.pop(context);
                              },
                              child: const Text(
                                "SAVE",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLibraryBottomSheet(BuildContext context) {
    final movieBox = Hive.box('movies');
    final TextEditingController libraryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        // Get existing libraries
        List<String> libraries = [];
        for (int i = 0; i < movieBox.length; i++) {
          final movie = movieBox.getAt(i);
          if (movie['library'] != null) {
            libraries.add(movie['library']);
          }
        }
        libraries = libraries.toSet().toList(); // remove duplicates

        String? tempSelectedLibrary;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(15, 29, 56, 1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Choose a Library",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 12),

                    if (libraries.isNotEmpty)
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.black87,
                        value: tempSelectedLibrary,
                        hint: const Text(
                          "Select library",
                          style: TextStyle(color: Colors.white70),
                        ),
                        items: libraries
                            .map(
                              (lib) => DropdownMenuItem(
                                value: lib,
                                child: Text(
                                  lib,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setModalState(() {
                            tempSelectedLibrary = val;
                          });
                        },
                      ),

                    const SizedBox(height: 16),

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

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(183, 151, 1, 1),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Only save the library choice, not the entire entry
                        String libraryName =
                            libraryController.text.trim().isNotEmpty
                            ? libraryController.text.trim()
                            : (tempSelectedLibrary ?? "BEST RATINGS");

                        setState(() {
                          selectedLibrary = libraryName;
                        });

                        Navigator.pop(context); // close bottom sheet only
                      },
                      child: const Text(
                        "SELECT LIBRARY",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
