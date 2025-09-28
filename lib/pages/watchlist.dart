import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'movie_detail.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  int selectedTab = 0; // 0 = Library, 1 = Reviews
  String? selectedLibrary; // which library is opened

  Widget buildMovieCard(Map movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
        );
      },
      child: Column(
        children: [
          Container(
            width: 110,
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image:
                    (movie['poster'] != null &&
                        File(movie['poster']).existsSync())
                    ? FileImage(File(movie['poster']))
                    : const AssetImage("assets/placeholder.jpg")
                          as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 120,
            child: Text(
              movie['title'] ?? "Untitled",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var movieBox = Hive.box('movies');
    return Stack(
      children: [
        // Gradient background
        Container(
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
        ),

        // Noise overlay
        Positioned.fill(
          child: Opacity(
            opacity: 1, // adjust intensity here
            child: Image.asset(
              'assets/images/noise.png', // must exist in assets
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),

        // Main content scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// Toggle (Library / Reviews)
                Container(
                  width: 260,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedTab = 0;
                            selectedLibrary = null; // reset
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedTab == 0
                                  ? const Color.fromRGBO(183, 151, 1, 1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                "LIBRARY",
                                style: TextStyle(
                                  color: selectedTab == 0
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedTab = 1;
                            selectedLibrary = null; // reset
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedTab == 1
                                  ? const Color.fromRGBO(183, 151, 1, 1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                "REVIEWS",
                                style: TextStyle(
                                  color: selectedTab == 1
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Movies content
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: movieBox.listenable(),
                    builder: (context, movies, _) {
                      // Separate movies into libraries
                      Map<String, List<Map>> libraries = {};
                      List allMovies = [];

                      for (int i = 0; i < movies.length; i++) {
                        final movie = Map<String, dynamic>.from(
                          movies.getAt(i),
                        );
                        final library = movie['library'] ?? "Uncategorized";

                        libraries.putIfAbsent(library, () => []);
                        libraries[library]!.add(movie);

                        allMovies.add(movie);
                      }

                      /// REVIEWS TAB
                      if (selectedTab == 1) {
                        if (allMovies.isEmpty) {
                          return const Center(
                            child: Text(
                              "No movies yet",
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                                childAspectRatio: 0.65,
                              ),
                          itemCount: allMovies.length,
                          itemBuilder: (context, index) =>
                              buildMovieCard(allMovies[index]),
                        );
                      }

                      /// LIBRARY TAB (list of libraries)
                      if (selectedLibrary == null) {
                        if (libraries.isEmpty) {
                          return const Center(
                            child: Text(
                              "No libraries yet",
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        final libEntries = libraries.entries.toList();

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.62,
                              ),
                          itemCount: libEntries.length,
                          itemBuilder: (context, index) {
                            final libName = libEntries[index].key;
                            final moviesInLib = libEntries[index].value;

                            final coverPoster =
                                (moviesInLib.isNotEmpty &&
                                    moviesInLib[0]['poster'] != null &&
                                    File(moviesInLib[0]['poster']).existsSync())
                                ? FileImage(File(moviesInLib[0]['poster']))
                                : const AssetImage("assets/placeholder.jpg")
                                      as ImageProvider;

                            return GestureDetector(
                              onTap: () => setState(() {
                                selectedLibrary = libName;
                              }),
                              child: Column(
                                children: [
                                  // Stacked card look
                                  Stack(
                                    children: [
                                      Positioned(
                                        left: 6,
                                        top: 6,
                                        child: Container(
                                          width: 110,
                                          height: 160,
                                          decoration: BoxDecoration(
                                            color: Colors.black26,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 110,
                                        height: 155,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(2, 4),
                                            ),
                                          ],
                                          image: DecorationImage(
                                            image: coverPoster,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 110,
                                    child: Text(
                                      libName.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }

                      /// INSIDE a library (with back button)
                      final selectedMovies = libraries[selectedLibrary] ?? [];

                      return Column(
                        children: [
                          // 🔙 Back Button
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedLibrary = null;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  selectedLibrary!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Movies inside this library
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 0.65,
                                  ),
                              itemCount: selectedMovies.length,
                              itemBuilder: (context, index) =>
                                  buildMovieCard(selectedMovies[index]),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
