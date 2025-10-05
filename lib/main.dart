import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proj1/firebase/auth_service.dart';
import 'package:proj1/pages/authentication.dart';
import 'package:proj1/pages/mainTools.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/note_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox('movies');
  await Hive.openBox('libraries');
  await Hive.openBox<Note>('notes');
  await Hive.openBox('profileBox');

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    ChangeNotifierProvider(create: (_) => AuthService(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
        nextScreen: const RouterWidget(), // ✅ start router after splash
        duration: 3100,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

/// ✅ Router starts *after* splash
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const Authentication()),
    GoRoute(path: '/home', builder: (context, state) => const MainPage()),
  ],
);

class RouterWidget extends StatelessWidget {
  const RouterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
