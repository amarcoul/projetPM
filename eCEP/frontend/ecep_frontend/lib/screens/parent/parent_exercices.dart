import 'package:flutter/material.dart';

class ParentExercicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Exercices et Évaluations")),
      body: Center(
        child: Text("Exercices réalisés par l'enfant."),
      ),
    );
  }
}
