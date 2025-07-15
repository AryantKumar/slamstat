import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'splash_screen.dart';   // import your splash screen
import 'auth_wrapper.dart';    // import your auth wrapper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const Color seedColor = Colors.deepPurple; // customize if needed

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlamStat',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(
        onFinish: () {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
          );
        },
      ),
    );
  }
}
