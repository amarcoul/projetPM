import 'package:flutter/material.dart';

// 6️⃣ Paramètres
class ParametresPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Paramètres")),
      body: Center(child: Text("Configuration du compte et préférences")),
    );
  }
}