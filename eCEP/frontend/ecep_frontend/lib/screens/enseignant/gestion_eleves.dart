import 'package:flutter/material.dart';

// 1️⃣ Gestion des élèves
class GestionElevesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Élèves")),
      body: Center(child: Text("Liste des élèves assignés à l'enseignant")),
    );
  }
}