import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MovieDetailScreen extends StatelessWidget {
  final Map movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          movie['library'] ?? "Movie",
          style: const TextStyle(
            color: Color.fromRGBO(236, 197, 61, 1),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // make it transparent
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(15, 29, 56, 1),
                Color.fromRGBO(42, 82, 158, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),


      backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
      body: SafeArea(
        child: Column(
          children: [



            const SizedBox(height: 15),

            // === POSTER ===
            Container(
              height: 220,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: movie['poster'] != null
                    ? DecorationImage(
                  image: FileImage(File(movie['poster'])),
                  fit: BoxFit.cover,
                )
                    : null,
                color: Colors.grey[800],

              ),
              child: movie['poster'] == null
                  ? const Center(
                child:
                Icon(Icons.movie, size: 80, color: Colors.white70),
              )
                  : null,
            ),

            const SizedBox(height: 12),

            // === TITLE & YEAR ===
            Text(
              (movie['title'] ?? "UNTITLED").toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (movie['year'] != null)
              Text(
                movie['year'].toString(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

            const SizedBox(height: 16),

            // === REVIEWS + BUTTONS CONTAINER ===
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(22, 44, 85, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reviews Title
                    const Center(
                      child: Text(
                        "REVIEWS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // === REVIEW CARD ===
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(15, 29, 56, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile + Username + Stars
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person,
                                    size: 20, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  movie['user'] ?? "User",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  int rating = (movie['rating'] ?? 0).toInt();
                                  return Icon(
                                    index < rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color:
                                    const Color.fromRGBO(183, 151, 1, 1),
                                    size: 20,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Review Text
                          Text(
                            movie['description'] ??
                                "No review has been added yet.",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // === ACTION BUTTONS ===
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color.fromRGBO(15, 29, 56, 1),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () => _confirmDelete(context),
                            icon:
                            const Icon(Icons.delete, color: Colors.white),
                            label: const Text(
                              "DISCARD",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color.fromRGBO(183, 151, 1, 1),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              // TODO: edit movie
                            },
                            icon: const Icon(Icons.edit, color: Colors.black),
                            label: const Text(
                              "EDIT",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Delete Review",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this movie review?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final box = Hive.box('movies');

              final key = box.keys.firstWhere(
                    (k) => box.get(k) == movie,
                orElse: () => null,
              );

              if (key != null) {
                await box.delete(key);
              }

              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // back to previous screen
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Color.fromRGBO(183, 151, 1, 1)),
            ),
          ),
        ],
      ),
    );
  }
}
