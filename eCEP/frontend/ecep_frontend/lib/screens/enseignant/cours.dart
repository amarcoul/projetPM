import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class Course {
  final int? id;
  final String titre;
  final String description;
  final String matiere;
  final List<Chapter> chapitres;
  final String enseignantId;

  Course({
    this.id,
    required this.titre,
    required this.description,
    required this.matiere,
    required this.enseignantId,
    this.chapitres = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    List<Chapter> chapitres = [];
    if (json['chapitres'] != null) {
      chapitres = (json['chapitres'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList();
    }

    return Course(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      matiere: json['matiere'],
      enseignantId: json['enseignant'].toString(),
      chapitres: chapitres,
    );
  }

  Map<String, dynamic> toJson() => {
    'titre': titre,
    'description': description,
    'matiere': matiere,
    'enseignant': enseignantId,
  };
}

class Chapter {
  final int? id;
  final String titre;
  final int numero;
  final List<Lesson> lecons;

  Chapter({
    this.id,
    required this.titre,
    required this.numero,
    this.lecons = const [],
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    List<Lesson> lecons = [];
    if (json['lecons'] != null) {
      lecons = (json['lecons'] as List)
          .map((lesson) => Lesson.fromJson(lesson))
          .toList();
    }

    return Chapter(
      id: json['id'],
      titre: json['titre'],
      numero: json['numero'],
      lecons: lecons,
    );
  }

  Map<String, dynamic> toJson() => {
    'titre': titre,
    'numero': numero,
  };
}

class Lesson {
  final int? id;
  final String titre;
  final int numero;
  final String? fichierPdf;
  final String? videoUrl;

  Lesson({
    this.id,
    required this.titre,
    required this.numero,
    this.fichierPdf,
    this.videoUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      titre: json['titre'],
      numero: json['numero'],
      fichierPdf: json['fichier_pdf'],
      videoUrl: json['video_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'titre': titre,
    'numero': numero,
    'fichier_pdf': fichierPdf,
    'video_url': videoUrl,
  };
}

class CoursEnseignantPage extends StatefulWidget {
  final String enseignantId;
  const CoursEnseignantPage({Key? key, required this.enseignantId}) : super(key: key);

  @override
  _CoursEnseignantPageState createState() => _CoursEnseignantPageState();
}

class _CoursEnseignantPageState extends State<CoursEnseignantPage> {
  List<String> matieres = ["Mathématiques", "Français", "Histoire-Géographie", "Sciences"];
  List<IconData> icons = [Icons.calculate, Icons.book, Icons.public, Icons.science];
  bool isLoading = true;
  List<Course> cours = [];

  @override
  void initState() {
    super.initState();
    _fetchCours();
  }

  Future<void> _fetchCours() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.100.8:8000/api/cours/enseignant/${widget.enseignantId}/"),
      );
     debugPrint("Réponse API brute : ${response.body}");
      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
          cours = jsonData.map((data) => Course.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Échec du chargement des cours");
      }
    } catch (error) {
      debugPrint("Erreur : $error");
      setState(() {
        cours = [];
        isLoading = false;
      });
    }
  }

  void _showAddChapterDialog(Course course) {
    final titleController = TextEditingController();
    final numeroController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un chapitre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titre du chapitre'),
            ),
            TextField(
              controller: numeroController,
              decoration: const InputDecoration(labelText: 'Numéro du chapitre'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Implement chapter creation API call
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showAddLessonDialog(Chapter chapter) {
    final titleController = TextEditingController();
    final numeroController = TextEditingController();
    final videoUrlController = TextEditingController();
    PlatformFile? selectedPdfFile;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une leçon'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre de la leçon'),
              ),
              TextField(
                controller: numeroController,
                decoration: const InputDecoration(labelText: 'Numéro de la leçon'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(labelText: 'URL de la vidéo (optionnel)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (result != null) {
                    selectedPdfFile = result.files.first;
                  }
                },
                child: const Text('Sélectionner un fichier PDF'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Implement lesson creation API call
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showAddEditCourseDialog({Course? course}) {
    final titleController = TextEditingController(text: course?.titre ?? '');
    final descriptionController = TextEditingController(text: course?.description ?? '');
    String selectedMatiere = course?.matiere ?? matieres[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course == null ? 'Ajouter un cours' : 'Modifier le cours'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre du cours'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMatiere,
                decoration: const InputDecoration(labelText: 'Matière'),
                items: matieres.map((String matiere) {
                  return DropdownMenuItem<String>(
                    value: matiere,
                    child: Text(matiere),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    selectedMatiere = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = Course(
                id: course?.id,
                titre: titleController.text,
                description: descriptionController.text,
                matiere: selectedMatiere,
                enseignantId: widget.enseignantId,
              );

              if (course == null) {
                await _createCourse(data);
              } else {
                await _updateCourse(data);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(course == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCourse(Course course) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://192.168.100.8:8000/api/create_cours/"),
    );

    // 🔹 Ajout des champs du cours dans la requête
    request.fields['titre'] = course.titre;
    request.fields['description'] = course.description;
    request.fields['matiere'] = course.matiere;
    request.fields['enseignant'] = course.enseignantId;

    var response = await request.send();

    if (response.statusCode == 201) {
      _fetchCours();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cours créé avec succès')),
        );
      }
    } else {
      throw Exception('Erreur lors de la création du cours');
    }
  } catch (error) {
    debugPrint("Erreur : $error");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la création du cours')),
      );
    }
  }
}


  Future<void> _updateCourse(Course course) async {
    try {
      final response = await http.put(
        Uri.parse("http://192.168.100.8:8000/api/cours/${course.id}/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(course.toJson()),
      );

      if (response.statusCode == 200) {
        _fetchCours();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cours modifié avec succès')),
          );
        }
      } else {
        throw Exception('Erreur lors de la modification du cours');
      }
    } catch (error) {
      debugPrint("Erreur : $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la modification du cours')),
        );
      }
    }
  }

  Future<void> _deleteCourse(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("http://192.168.100.8:8000/api/cours/$id/"),
      );

      if (response.statusCode == 204) {
        _fetchCours();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cours supprimé avec succès')),
          );
        }
      } else {
        throw Exception('Erreur lors de la suppression du cours');
      }
    } catch (error) {
      debugPrint("Erreur : $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression du cours')),
        );
      }
    }
  }

  Widget _buildChaptersList(Course course) {
    return ExpansionTile(
      title: const Text('Chapitres'),
      children: [
        ...course.chapitres.map((chapter) => Card(
          child: Column(
            children: [
              ListTile(
                title: Text('${chapter.numero}. ${chapter.titre}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddLessonDialog(chapter),
                ),
              ),
              if (chapter.lecons.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: chapter.lecons.map((lesson) => ListTile(
                      title: Text('${lesson.numero}. ${lesson.titre}'),
                      subtitle: lesson.videoUrl != null ? const Text('Vidéo disponible') : null,
                      trailing: lesson.fichierPdf != null 
                        ? const Icon(Icons.picture_as_pdf) 
                        : null,
                    )).toList(),
                  ),
                ),
            ],
          ),
        )).toList(),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Ajouter un chapitre'),
          onTap: () => _showAddChapterDialog(course),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Cours"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditCourseDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cours.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "Aucun cours disponible",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(icon: const Icon(Icons.add),
                        label: const Text("Ajouter un cours"),
                        onPressed: () => _showAddEditCourseDialog(),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cours.length,
                  itemBuilder: (context, index) {
                    final course = cours[index];
                    IconData matiereIcon = Icons.school;
                    
                    // Déterminer l'icône en fonction de la matière
                    final matiereIndex = matieres.indexOf(course.matiere);
                    if (matiereIndex != -1) {
                      matiereIcon = icons[matiereIndex];
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Icon(matiereIcon, color: Theme.of(context).primaryColor),
                            ),
                            title: Text(
                              course.titre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(course.matiere),
                                const SizedBox(height: 2),
                                Text(
                                  course.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showAddEditCourseDialog(course: course),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmationDialog(course.id!),
                                ),
                              ],
                            ),
                          ),
                          _buildChaptersList(course),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteConfirmationDialog(int courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer ce cours ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCourse(courseId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }


  Future<void> createChapter(int courseId, Chapter chapter) async {
  try {
    debugPrint("Envoi de la requête à : http://192.168.100.8:8000/api/cours/$courseId/chapitres/");
    debugPrint("Données envoyées : ${jsonEncode(chapter.toJson())}");

    final response = await http.post(
      Uri.parse("http://192.168.100.8:8000/api/cours/$courseId/chapitres/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(chapter.toJson()),
    );

    debugPrint("Réponse API Chapitre: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création du chapitre: ${response.body}');
    }
  } catch (e) {
    debugPrint("Erreur Flutter Chapitre: $e");
    rethrow;
  }
}



Future<void> createLesson(int chapterId, Lesson lesson, PlatformFile? pdfFile) async {
  try {
    debugPrint("Envoi de la requête à : http://192.168.100.8:8000/api/chapitres/$chapterId/lecons/");
    debugPrint("Données envoyées : titre=${lesson.titre}, numéro=${lesson.numero}, vidéo=${lesson.videoUrl}");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://192.168.100.8:8000/api/chapitres/$chapterId/lecons/"),
    );

    request.fields['titre'] = lesson.titre;
    request.fields['numero'] = lesson.numero.toString();
    if (lesson.videoUrl != null) {
      request.fields['video_url'] = lesson.videoUrl!;
    }

    if (pdfFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'fichier_pdf',
          pdfFile.path!,
        ),
      );
    }

    debugPrint("Requête préparée, envoi en cours...");
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    
    debugPrint("Réponse API Leçon: ${response.statusCode} - $responseBody");

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création de la leçon: $responseBody');
    }
  } catch (e) {
    debugPrint("Erreur Flutter Leçon: $e");
    rethrow;
  }
}
}


