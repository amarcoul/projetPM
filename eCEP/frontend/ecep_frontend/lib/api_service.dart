import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database/course.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Course>> fetchCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses/'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((course) => Course.fromJson(course)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<User> fetchUserProfile() async {
  final response = await http.get(Uri.parse('$baseUrl/users/'));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    
    if (jsonData.isNotEmpty) {
      return User.fromJson(jsonData[0]); // ✅ Prend le premier utilisateur de la liste
    } else {
      throw Exception('Aucun utilisateur trouvé');
    }
  } else {
    throw Exception('Failed to load user profile');
  }
}

}
