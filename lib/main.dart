import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brooski_app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized!");
  } catch (e) {
    print("❌ Firebase init failed: $e");
  }
  runApp(const BrooskiApp());
}

class BrooskiApp extends StatelessWidget {
  const BrooskiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brooski',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: appRoutes,
      // Optional: onGenerateRoute: generateRoute, for dynamic routes
    );
  }
}
