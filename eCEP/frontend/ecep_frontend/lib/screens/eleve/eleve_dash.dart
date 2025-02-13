import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'elevelogin.dart'; // Assurez-vous que le chemin est correct
import 'cours.dart'; 
import 'exercice.dart'; 
import 'settings.dart';
import 'historique.dart'; 
import 'suivis.dart'; 
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EleveDashboard extends StatefulWidget {
  final String userId;

  EleveDashboard({required this.userId});

  @override
  _EleveDashboardState createState() => _EleveDashboardState();
}

class _EleveDashboardState extends State<EleveDashboard> {
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
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => StudentLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Élève'),
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
                color: Colors.blue,
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
                    'Bienvenue, Utilisateur ID: ${widget.userId}',
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
                  MaterialPageRoute(builder: (_) => CoursPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Exercices'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ExercicesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Historique des apprentissages'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HistoriquePage(userId: int.tryParse(widget.userId)??0)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Suivi des performances'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SuiviPerformancePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Paramètres'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsPage()),
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
          'Bienvenue, utilisateur ID: ${widget.userId}',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
