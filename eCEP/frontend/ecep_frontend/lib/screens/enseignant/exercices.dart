import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class Exercise {
  final int? id;
  final String title;
  final String description;
  final String subject;
  final String type;
  final int difficultyLevel;
  final int duration;
  final int courseId;
  final String correction;
  final String? pdfFile;
  final List<Question> questions;

  Exercise({
    this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.difficultyLevel,
    required this.duration,
    required this.courseId,
    required this.correction,
    this.pdfFile,
    this.questions = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    List<Question> questions = [];
    if (json['questions'] != null) {
      questions = (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
    }

    return Exercise(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subject: json['subject'] ?? '',
      type: json['type'],
      difficultyLevel: json['difficulty_level'],
      duration: json['duration'],
      courseId: json['course'],
      correction: json['correction'],
      pdfFile: json['pdf_file'],
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'subject': subject,
    'type': type,
    'difficulty_level': difficultyLevel,
    'duration': duration,
    'course': courseId,
    'correction': correction,
  };
}

class Question {
  final int? id;
  final String text;
  final String explanation;
  final List<Answer> answers;

  Question({
    this.id,
    required this.text,
    required this.explanation,
    this.answers = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<Answer> answers = [];
    if (json['answers'] != null) {
      answers = (json['answers'] as List)
          .map((a) => Answer.fromJson(a))
          .toList();
    }

    return Question(
      id: json['id'],
      text: json['text'],
      explanation: json['explanation'],
      answers: answers,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'explanation': explanation,
  };
}

class Answer {
  final int? id;
  final String text;
  final bool isCorrect;
  final String explanation;

  Answer({
    this.id,
    required this.text,
    required this.isCorrect,
    required this.explanation,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'is_correct': isCorrect,
    'explanation': explanation,
  };
}

class ExercisesEvaluationsPage extends StatefulWidget {
  final int courseId;
  
  const ExercisesEvaluationsPage({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  _ExercisesEvaluationsPageState createState() => _ExercisesEvaluationsPageState();
}

class _ExercisesEvaluationsPageState extends State<ExercisesEvaluationsPage> {
  bool isLoading = true;
  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.100.8:8000/api/exercises/course/${widget.courseId}/"),
      );

      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
          exercises = jsonData.map((data) => Exercise.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Échec du chargement des exercices");
      }
    } catch (error) {
      debugPrint("Erreur : $error");
      setState(() {
        exercises = [];
        isLoading = false;
      });
    }
  }

  void _showAddExerciseDialog({Exercise? exercise}) {
    final titleController = TextEditingController(text: exercise?.title ?? '');
    final descriptionController = TextEditingController(text: exercise?.description ?? '');
    final durationController = TextEditingController(text: exercise?.duration.toString() ?? '30');
    final correctionController = TextEditingController(text: exercise?.correction ?? '');
    
    String selectedType = exercise?.type ?? 'qcm';
    int selectedDifficulty = exercise?.difficultyLevel ?? 1;
    List<Question> questions = exercise?.questions ?? [];
    PlatformFile? pdfFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(exercise == null ? 'Ajouter un exercice' : 'Modifier l\'exercice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type d\'exercice'),
                  items: [
                    DropdownMenuItem(value: 'quiz', child: Text('Quiz temporisé')),
                    DropdownMenuItem(value: 'pdf', child: Text('Exercice PDF')),
                    DropdownMenuItem(value: 'qcm', child: Text('QCM simple')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                DropdownButtonFormField<int>(
                  value: selectedDifficulty,
                  decoration: const InputDecoration(labelText: 'Niveau de difficulté'),
                  items: [
                    DropdownMenuItem(value: 1, child: Text('Facile')),
                    DropdownMenuItem(value: 2, child: Text('Moyen')),
                    DropdownMenuItem(value: 3, child: Text('Difficile')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedDifficulty = value);
                    }
                  },
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Durée (minutes)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: correctionController,
                  decoration: const InputDecoration(labelText: 'Correction'),
                  maxLines: 3,
                ),
                if (selectedType == 'pdf')
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );

                      if (result != null) {
                        setState(() => pdfFile = result.files.first);
                      }
                    },
                    child: Text(pdfFile != null ? 'Changer le PDF' : 'Ajouter un PDF'),
                  ),
                if (selectedType != 'pdf')
                  ElevatedButton(
                    onPressed: () => _showQuestionsDialog(questions, (updatedQuestions) {
                      setState(() => questions = updatedQuestions);
                    }),
                    child: const Text('Gérer les questions'),
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
                final exerciseData = Exercise(
                  id: exercise?.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  subject: 'General', // À adapter selon vos besoins
                  type: selectedType,
                  difficultyLevel: selectedDifficulty,
                  duration: int.parse(durationController.text),
                  courseId: widget.courseId,
                  correction: correctionController.text,
                );

                if (exercise == null) {
                  await _createExercise(exerciseData, questions, pdfFile);
                } else {
                  await _updateExercise(exerciseData, questions, pdfFile);
                }

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(exercise == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionsDialog(List<Question> questions, Function(List<Question>) onUpdate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gérer les questions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(question.text),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showQuestionDialog(
                        question: question,
                        onSave: (updatedQuestion) {
                          questions[index] = updatedQuestion;
                          onUpdate(questions);
                        },
                      ),
                    ),
                  ),
                );
              }),
              ElevatedButton(
                onPressed: () => _showQuestionDialog(
                  onSave: (newQuestion) {
                    questions.add(newQuestion);
                    onUpdate(questions);
                  },
                ),
                child: const Text('Ajouter une question'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showQuestionDialog({Question? question, required Function(Question) onSave}) {
    final textController = TextEditingController(text: question?.text ?? '');
    final explanationController = TextEditingController(text: question?.explanation ?? '');
    List<Answer> answers = question?.answers ?? [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(question == null ? 'Nouvelle question' : 'Modifier la question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: 'Question'),
                  maxLines: 2,
                ),
                TextField(
                  controller: explanationController,
                  decoration: const InputDecoration(labelText: 'Explication'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ...answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  return Card(
                    child: ListTile(
                      title: Text(answer.text),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: answer.isCorrect,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  answers[index] = Answer(
                                    id: answer.id,
                                    text: answer.text,
                                    isCorrect: value,
                                    explanation: answer.explanation,
                                  );
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAnswerDialog(
                              answer: answer,
                              onSave: (updatedAnswer) {
                                setState(() {
                                  answers[index] = updatedAnswer;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                ElevatedButton(
                  onPressed: () => _showAnswerDialog(
                    onSave: (newAnswer) {
                      setState(() {
                        answers.add(newAnswer);
                      });
                    },
                  ),
                  child: const Text('Ajouter une réponse'),
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
              onPressed: () {
                final newQuestion = Question(
                  id: question?.id,
                  text: textController.text,
                  explanation: explanationController.text,
                  answers: answers,
                );
                onSave(newQuestion);
                Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnswerDialog({Answer? answer, required Function(Answer) onSave}) {
    final textController = TextEditingController(text: answer?.text ?? '');
    final explanationController = TextEditingController(text: answer?.explanation ?? '');
    bool isCorrect = answer?.isCorrect ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(answer == null ? 'Nouvelle réponse' : 'Modifier la réponse'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: 'Réponse'),
                maxLines: 2,
              ),
              TextField(
                controller: explanationController,
                decoration: const InputDecoration(labelText: 'Explication'),
                maxLines: 2,
              ),
              CheckboxListTile(
                title: const Text('Réponse correcte'),
                value: isCorrect,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => isCorrect = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAnswer = Answer(
                  id: answer?.id,
                  text: textController.text,
                  isCorrect: isCorrect,
                  explanation: explanationController.text,
                );
                onSave(newAnswer);
                Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createExercise(Exercise exercise, List<Question> questions, PlatformFile? pdfFile) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.100.8:8000/api/create_exercises/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          ...exercise.toJson(),
          'questions': questions.map((q) => q.toJson()).toList(),
        }),
      );

      if (response.statusCode == 201) {
        _fetchExercises();
      } else {
        throw Exception("Échec de la création de l'exercice");
      }
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }

  Future<void> _updateExercise(Exercise exercise, List<Question> questions, PlatformFile? pdfFile) async {
    try {
      final response = await http.put(
        Uri.parse("http://192.168.100.8:8000/api/exercises/${exercise.id}/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          ...exercise.toJson(),
          'questions': questions.map((q) => q.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        _fetchExercises();
      } else {
        throw Exception("Échec de la mise à jour de l'exercice");
      }
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercices et Évaluations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExerciseDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  title: Text(exercise.title),
                  subtitle: Text(exercise.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddExerciseDialog(exercise: exercise),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteExercise(exercise.id!),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Naviguer vers la page de détail de l'exercice
                  },
                );
              },
            ),
    );
  }

  Future<void> _deleteExercise(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("http://192.168.100.8:8000/api/exercises/$id/"),
      );

      if (response.statusCode == 204) {
        _fetchExercises();
      } else {
        throw Exception("Échec de la suppression de l'exercice");
      }
    } catch (error) {
      debugPrint("Erreur : $error");
    }
  }
}