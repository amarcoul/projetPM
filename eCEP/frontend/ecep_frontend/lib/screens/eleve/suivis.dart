import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SuiviPerformancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Suivi des Performances"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard("Moyenne Générale", "15.5/20", "+0.8 ce mois", Icons.trending_up, Colors.green),
            _buildStatCard("Temps d'étude", "45h", "+5h ce mois", Icons.timer, Colors.blue),
            _buildStatCard("Exercices Réussis", "85%", "+12% ce mois", Icons.task_alt, Colors.purple),
            _buildStatCard("Points Gagnés", "1250", "+150 ce mois", Icons.star, Colors.orange),
            SizedBox(height: 20),
            _buildTitle("Évolution des Notes"),
            _buildLineChart(),
            SizedBox(height: 20),
            _buildTitle("Performance par Matière"),
            _buildProgressBar("Mathématiques", 85, Colors.blue),
            _buildProgressBar("Français", 78, Colors.green),
            _buildProgressBar("Sciences", 92, Colors.purple),
            _buildProgressBar("Histoire-Géo", 88, Colors.orange),
            SizedBox(height: 20),
            _buildTitle("Dernières Réalisations"),
            _buildAchievement("Examen blanc réussi", "Mathématiques - Géométrie", "16/20", "Hier"),
            _buildAchievement("Badge obtenu", "Expert en Conjugaison", "Niveau Or", "Il y a 2 jours"),
            _buildAchievement("Série d'exercices terminée", "Sciences - Le corps humain", "90%", "Il y a 3 jours"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String change, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(change, style: TextStyle(color: Colors.green)),
        trailing: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProgressBar(String subject, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subject, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 8,
        ),
        SizedBox(height: 5),
        Text("$score/100", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAchievement(String title, String subtitle, String score, String date) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.emoji_events, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(score, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(date, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
              switch (value.toInt()) {
                case 1:
                  return Text("Sept");
                case 2:
                  return Text("Oct");
                case 3:
                  return Text("Nov");
                case 4:
                  return Text("Déc");
                case 5:
                  return Text("Jan");
                case 6:
                  return Text("Fév");
                default:
                  return Text("");
              }
            })),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [FlSpot(1, 12), FlSpot(2, 13), FlSpot(3, 14), FlSpot(4, 15), FlSpot(5, 16), FlSpot(6, 17)],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
            ),
            LineChartBarData(
              spots: [FlSpot(1, 10), FlSpot(2, 11), FlSpot(3, 12), FlSpot(4, 14), FlSpot(5, 15), FlSpot(6, 16)],
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
            ),
            LineChartBarData(
              spots: [FlSpot(1, 11), FlSpot(2, 12), FlSpot(3, 13), FlSpot(4, 14), FlSpot(5, 15), FlSpot(6, 17)],
              isCurved: true,
              color: Colors.purple,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
