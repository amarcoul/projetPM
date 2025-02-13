import 'package:flutter/material.dart';

class ParentCoursPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cours et Leçons")),
      body: Center(
        child: Text("Liste des cours suivis par l'enfant."),
      ),
    );
  }
}
