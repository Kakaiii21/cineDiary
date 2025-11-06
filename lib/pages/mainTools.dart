import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proj1/pages/movie.dart';
import 'package:proj1/pages/notes.dart';
import 'package:proj1/pages/profile.dart';
import 'package:proj1/pages/watchlist.dart';
import 'package:proj1/pages/weather.dart';
import 'package:provider/provider.dart';

import '../firebase/auth_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2;

  final List<String> _titles = [
    'WEATHER',
    'NOTES',
    'MOVIE REVIEW',
    'WATCHLIST',
    'PROFILE',
  ];

  final List<Widget> _pages = [
    WeatherScreen(),
    NotesScreen(),
    MovieScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // close drawer if open
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ Gradient background
        Container(
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

        // ✅ Noise overlay
        Positioned.fill(
          child: Opacity(
            opacity: 1, // adjust strength of noise
            child: Image.asset(
              'assets/images/noise.png', // make sure this file exists
              repeat: ImageRepeat.repeat, // tile across screen
            ),
          ),
        ),

        // ✅ Foreground Scaffold (transparent so background shows)
        Scaffold(
          extendBody: true, // 🔑 let background extend under nav bar
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            automaticallyImplyLeading: true,
            centerTitle: true,
            title: Text(
              _titles[_selectedIndex],
              style: GoogleFonts.montserrat(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                color: Colors.white,
                onPressed: () {},
              ),
            ],
          ),

          drawer: Drawer(
            backgroundColor: const Color.fromRGBO(39, 59, 94, 1),
            child: ListView(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(39, 59, 94, 1),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                        child: Image.asset(
                          "assets/images/drawerCD.png",
                          height: 70,
                        ),
                      ),
                      SizedBox(width: 80),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.menu, color: Colors.black, size: 50),
                      ),
                    ],
                  ),
                ),

                Divider(color: Colors.white24, thickness: 2, height: 0),
                ListTile(
                  leading: Image.asset("assets/images/weather.png", height: 20),
                  title: const Text(
                    'Weather',
                    style: TextStyle(color: Color.fromRGBO(155, 155, 155, 1)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(0);
                  },
                ),

                Divider(color: Colors.white24, thickness: 2, height: 0),
                ListTile(
                  leading: Image.asset("assets/images/notes.png", height: 20),
                  title: const Text(
                    'Notes',
                    style: TextStyle(color: Color.fromRGBO(155, 155, 155, 1)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(1);
                  },
                ),

                Divider(color: Colors.white24, thickness: 2, height: 0),
                ListTile(
                  leading: Image.asset("assets/images/movie.png", height: 20),
                  title: const Text(
                    'Movie Review',
                    style: TextStyle(color: Color.fromRGBO(155, 155, 155, 1)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(2);
                  },
                ),

                Divider(color: Colors.white24, thickness: 2, height: 0),
                ListTile(
                  leading: Image.asset("assets/images/list.png", height: 20),
                  title: const Text(
                    'Watchlist',
                    style: TextStyle(color: Color.fromRGBO(155, 155, 155, 1)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(3);
                  },
                ),

                Divider(color: Colors.white24, thickness: 2, height: 0),
                ListTile(
                  leading: Image.asset("assets/images/user.png", height: 20),
                  title: const Text(
                    'Profile',
                    style: TextStyle(color: Color.fromRGBO(155, 155, 155, 1)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(4);
                  },
                ),

                Divider(color: Colors.white24, thickness: 2, height: 0),
                ListTile(
                  leading: Image.asset(
                    "assets/images/settings.png",
                    height: 20,
                  ),
                  title: const Text(
                    'Settings',
                    style: TextStyle(color: Color.fromRGBO(155, 155, 155, 1)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(4);
                  },
                ),

                Divider(color: Colors.white24, thickness: 2, height: 0),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context); // Close drawer first

                    final authService = Provider.of<AuthService>(
                      context,
                      listen: false,
                    );
                    await authService.signOut();

                    // ✅ Use GoRouter to redirect properly
                    if (context.mounted) {
                      context.go('/'); // GoRouter navigation back to login
                    }
                  },
                ),

                Divider(color: Colors.white24, thickness: 2, height: 0),
              ],
            ),
          ),

          body: SafeArea(
            top: true,
            bottom: false,
            child: _pages[_selectedIndex],
          ),

          // Replace your bottomNavigationBar with this:
          bottomNavigationBar: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // navbg.png background (now transparent)
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/navbg.png'),
                    fit: BoxFit.cover,
                    opacity:
                        0.8, // Optional: adjust transparency of the image itself
                  ),
                ),
              ),

              // Transparent BottomNavigationBar overlaying navbg.png
              BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color.fromRGBO(15, 29, 56, 1),
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Image.asset(
                        'assets/images/weather.png',
                        width: 24,
                        height: 24,
                        color: _selectedIndex == 0
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Image.asset(
                        'assets/images/notes.png',
                        width: 24,
                        height: 24,
                        color: _selectedIndex == 1
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                      child: Image.asset(
                        'assets/images/movieActive.png',
                        width: 24,
                        height: 24,
                        color: _selectedIndex == 2
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Image.asset(
                        'assets/images/list.png',
                        width: 24,
                        height: 24,
                        color: _selectedIndex == 3
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Image.asset(
                        'assets/images/user.png',
                        width: 24,
                        height: 24,
                        color: _selectedIndex == 4
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                    ),
                    label: '',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
