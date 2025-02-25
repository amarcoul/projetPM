import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Course {
  final String eleve;
  final String course;
  final String date;

  Course({required this.eleve, required this.course, required this.date});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      eleve: json['eleve'],
      course: json['course'],
      date: json['date'],
    );
  }
}
class ApiService {
  static Future<List<Course>> fetchParentCourses(int parentId) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/parent/$parentId/cours/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['cours_suivis'] as List;
      return data.map((item) => Course.fromJson(item)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des cours");
    }
  }
}

class ParentCoursPage extends StatefulWidget {
  final int parentId;

  ParentCoursPage({required this.parentId});

  @override
  _ParentCoursPageState createState() => _ParentCoursPageState();
}

class _ParentCoursPageState extends State<ParentCoursPage> {
  late Future<List<Course>> futureCourses;

  @override
  void initState() {
    super.initState();
    futureCourses = ApiService.fetchParentCourses(widget.parentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cours suivis par les enfants")),
      body: FutureBuilder<List<Course>>(
        future: futureCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun cours suivi."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final course = snapshot.data![index];
                return ListTile(
                  title: Text(course.course),
                  subtitle: Text("Suivi par ${course.eleve} le ${course.date}"),
                  leading: Icon(Icons.book),
                );
              },
            );
          }
        },
      ),
    );
  }
}
