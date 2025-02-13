import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'eleve_dash.dart';
import '../../login.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({Key? key}) : super(key: key);

  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController parentEmailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  bool _isLoading = false; // Indicateur de chargement

  Future<void> registerStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://192.168.100.8:8000/api/registereleve/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'first_name': firstNameController.text,
            'last_name': lastNameController.text,
            'age': int.parse(ageController.text),
            'email': emailController.text,
            'password': passwordController.text,
            'parent_email': parentEmailController.text,
          }),
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          int userId = data['id']; // ✅ Récupération de l'ID utilisateur

          // ✅ Stocker l'ID utilisateur dans SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);
          await prefs.setString('role', 'eleve');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compte créé avec succès !')),
          );

          // ✅ Rediriger vers EleveDashboard en passant le userId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EleveDashboard(userId: userId.toString())),
          );
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : ${errorData['message']}")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur de connexion au serveur")),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription Élève', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre prénom' : null,
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Nom de famille'),
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre nom' : null,
                ),
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Âge'),
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre âge' : null,
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre email' : null,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  validator: (value) => value == null || value.length < 6 ? 'Le mot de passe doit contenir au moins 6 caractères' : null,
                ),
                TextFormField(
                  controller: parentEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email du parent'),
                  validator: (value) => value == null || value.isEmpty ? "Veuillez entrer l'email du parent" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : registerStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Créer un compte'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()), // ❌ Correction : Supprime `const`
                    );
                  },
                  child: const Text("Déjà un compte ? Se connecter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
