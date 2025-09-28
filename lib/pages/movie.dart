import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'newMovie.dart';
import 'movie_detail.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  @override
  Widget build(BuildContext context) {
    var movieBox = Hive.box('movies');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(43, 82, 158, 1),
              Color.fromRGBO(15, 29, 56, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: movieBox.listenable(),
            builder: (context, movies, _) {
              // Group movies by library
              Map<String, List> groupedMovies = {};
              for (int i = 0; i < movies.length; i++) {
                final movie = movies.getAt(i);
                String library = movie['library'] ?? "BEST RATINGS";
                groupedMovies.putIfAbsent(library, () => []);
                groupedMovies[library]!.add(movie);
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Top "New Movie" Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewMovieScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(15, 29, 56, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,
                                size: 40,
                                color: Color.fromRGBO(183, 151, 1, 1)),
                            SizedBox(height: 8),
                            Text(
                              "NEW MOVIE",
                              style: TextStyle(
                                color: Color.fromRGBO(183, 151, 1, 1),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Library Sections
                  ...groupedMovies.entries.map((entry) {
                    String libraryName = entry.key;
                    List libraryMovies = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + "See all"
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  libraryName.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to See All Page
                                  },
                                  child: const Text(
                                    "See all",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Horizontal scrollable list of movies
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: libraryMovies.length,
                              itemBuilder: (context, index) {
                                final movie = libraryMovies[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MovieDetailScreen(movie: movie),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 130,
                                        height: 190,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: (movie['poster'] != null &&
                                                File(movie['poster'])
                                                    .existsSync())
                                                ? FileImage(
                                                File(movie['poster']))
                                                : const AssetImage(
                                                "assets/placeholder.jpg")
                                            as ImageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          movie['title'] ?? "Untitled",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
