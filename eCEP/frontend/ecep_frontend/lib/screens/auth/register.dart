import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'login.dart'; // Pour rediriger après inscription

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _selectedRole = "eleve"; // Valeur par défaut
  final Dio dio = Dio();

  Future<void> register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    try {
      Response response = await dio.post(
        'http://127.0.0.1:8000/api/register/',
        data: {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _selectedRole, // Envoi du rôle choisi
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Inscription réussie, connectez-vous")),
        );

        // Redirection vers la page de connexion après succès
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'inscription")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _firstNameController, decoration: InputDecoration(labelText: 'Prénom')),
            TextField(controller: _lastNameController, decoration: InputDecoration(labelText: 'Nom')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Mot de passe')),
            TextField(controller: _confirmPasswordController, obscureText: true, decoration: InputDecoration(labelText: 'Confirmer le mot de passe')),

            // Sélection du rôle
            DropdownButton<String>(
              value: _selectedRole,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
              items: ['eleve', 'parent', 'enseignant', 'admin']
                  .map<DropdownMenuItem<String>>((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
            ),

            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text('S’inscrire')),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text("Déjà un compte ? Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}
