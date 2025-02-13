import 'package:flutter/material.dart';

class ParentExamensPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sessions d'examens")),
      body: Center(
        child: Text("Examens passés et résultats."),
      ),
    );
  }
}
