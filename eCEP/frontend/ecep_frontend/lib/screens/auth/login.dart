import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../eleve/eleve_dash.dart';
import '../parent/parent_dash.dart';
import '../enseignant/enseignant_dash.dart';
import '../admin/admin.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio dio = Dio();

  Future<void> login() async {
    try {
      Response response = await dio.post(
        'http://127.0.0.1:8000/api/login/',
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data['access']);
        await prefs.setString('refresh_token', response.data['refresh']);
        await prefs.setString('role', response.data['user']['role']); // Stocker le rôle

        _redirectToDashboard(response.data['user']['role']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion, vérifiez vos identifiants")),
      );
    }
  }

  void _redirectToDashboard(String role) {
    Widget nextScreen;
    switch (role) {
      case 'eleve':
        nextScreen = EleveDashboard();
        break;
      case 'parent':
        nextScreen = ParentDashboard();
        break;
      case 'enseignant':
        nextScreen = EnseignantDashboard();
        break;
      case 'admin':
        nextScreen = AdminDashboard();
        break;
      default:
        nextScreen = LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Mot de passe')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text('Se connecter')),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text("Pas encore de compte ? S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
