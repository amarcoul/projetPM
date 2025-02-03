import 'package:flutter/material.dart';
import 'screens/auth/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eCEP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegisterScreen(), // Démarre toujours sur la page de connexion
    );
  }
}
