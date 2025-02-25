import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoriquePage extends StatefulWidget {
  final int userId;

  const HistoriquePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  List<dynamic> historiques = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHistorique();
  }

  // 🔹 Récupération des activités de l'utilisateur
  Future<void> _fetchHistorique() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.100.8:8000/api/historique/${widget.userId}/"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            historiques = data;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Échec du chargement de l'historique");
      }
    } catch (error) {
      debugPrint("Erreur de chargement de l'historique : $error");
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Impossible de récupérer l'historique.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique des Activités")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)))
              : historiques.isEmpty
                  ? const Center(child: Text("Aucune activité enregistrée."))
                  : ListView.builder(
                      itemCount: historiques.length,
                      itemBuilder: (context, index) {
                        final historique = historiques[index];
                        return _buildHistoriqueItem(historique);
                      },
                    ),
    );
  }

  // 🎯 **Affichage des activités**
  Widget _buildHistoriqueItem(Map<String, dynamic> historique) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(Icons.history, color: Colors.blue),
        title: Text(historique['course_title'] ?? "Cours inconnu"),
        subtitle: Text("Date : ${historique['date'] ?? 'Inconnue'}"),
        trailing: _getStatusIcon(historique['status']),
      ),
    );
  }

  // 📌 **Icône d'état**
  Widget _getStatusIcon(String? status) {
    switch (status) {
      case "Terminé":
        return const Icon(Icons.check_circle, color: Colors.green);
      case "En cours":
        return const Icon(Icons.timelapse, color: Colors.orange);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }
}
