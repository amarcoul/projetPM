import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text("Bienvenue sur la page des paramètres !"),
      ),
    );
  }
}