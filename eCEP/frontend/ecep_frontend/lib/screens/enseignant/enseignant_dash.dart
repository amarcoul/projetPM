import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cours.dart'; 
import 'exercices.dart'; 
import 'settings.dart';
import 'examens.dart'; 
import 'gestion_eleves.dart'; 
import 'dart:io';
import 'enseignantlogin.dart';
import 'package:image_picker/image_picker.dart';

class EnseignantDashboard extends StatefulWidget {
  final String enseignantId;

  EnseignantDashboard({required this.enseignantId});
  @override
  _EnseignantDashboard createState() => _EnseignantDashboard();
}

class _EnseignantDashboard extends State<EnseignantDashboard> {
   File? _profileImage;
   final picker = ImagePicker();
   Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Erreur lors de la sélection de l'image: $e");
    }
  }
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime toutes les données stockées (token, rôle, etc.)

    // Rediriger vers la page de connexion et empêcher le retour en arrière
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TeacherLoginPage()),
    );
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Enseignant'),
        actions: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: _profileImage != null && _profileImage!.existsSync()
                  ? FileImage(_profileImage!)
                  : null,
              child: _profileImage == null || !_profileImage!.existsSync()
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null && _profileImage!.existsSync()
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null || !_profileImage!.existsSync()
                          ? Icon(Icons.person, color: Colors.white, size: 40)
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bienvenue, Utilisateur ID: ${widget.enseignantId}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Tableau de Bord'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Cours'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CoursEnseignantPage(enseignantId: widget.enseignantId.toString())),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Exercices'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ExercicesEvaluationsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Examens'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ExamensPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('gestion des eleves'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GestionElevesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Paramètres'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ParametresPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Se déconnecter'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Bienvenue, utilisateur ID: ${widget.enseignantId}',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
