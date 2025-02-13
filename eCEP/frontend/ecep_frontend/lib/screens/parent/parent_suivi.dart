import 'package:flutter/material.dart';

class ParentSuiviPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Suivi des Performances")),
      body: Center(
        child: Text("Statistiques et suivi des progrès de l'enfant."),
      ),
    );
  }
}
