import 'package:flutter/material.dart';

class ParentBadgesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Badges et Récompenses")),
      body: Center(
        child: Text("Liste des badges obtenus par l'enfant."),
      ),
    );
  }
}
