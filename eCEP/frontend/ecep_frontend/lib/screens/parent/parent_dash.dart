import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login.dart';

class ParentDashboard extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime toutes les données stockées (token, rôle, etc.)

    // Rediriger vers la page de connexion et empêcher le retour en arrière
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Enseignant'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app), // Icône de déconnexion
            onPressed: () => _logout(context),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Center(child: Text('Bienvenue sur le Dashboard Élève')),
    );
  }
}
