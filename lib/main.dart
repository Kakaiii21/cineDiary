import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proj1/pages/authentication.dart';

// ✅ IMPORT YOUR MODEL (adjust the path if yours is different)
import 'models/note_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ✅ Register the adapter (works if note_model.g.dart exists)
  Hive.registerAdapter(NoteAdapter());

  // Open your Hive boxes
  await Hive.openBox('movies');
  await Hive.openBox('libraries');
  await Hive.openBox<Note>('notes'); // typed box is fine now
  await Hive.openBox('profileBox'); // ✅ Add this

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splash: Container(
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
          child: Center(
            child: Image.asset("assets/images/logo.png", height: 200),
          ),
        ),
        splashIconSize: double.infinity,
        nextScreen: const Authentication(),
        duration: 3100,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
