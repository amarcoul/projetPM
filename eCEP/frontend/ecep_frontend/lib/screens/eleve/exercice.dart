import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExercicesPage extends StatefulWidget {
  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercicesPage> {
  List<dynamic> exercises = [];
  List<dynamic> filteredExercises = [];
  bool isLoading = true;
  String searchQuery = "";
  String? selectedSubject;
  Map<String, Map<int, List<int>>> selectedAnswers = {};
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  void _fetchExercises() async {
  try {
    final response = await http.get(Uri.parse("http://192.168.100.8:8000/api/exercises/"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data); // Affiche les données reçues pour vérification
      if (mounted) {
        setState(() {
          exercises = data;
          filteredExercises = exercises;
          isLoading = false;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      _showError("Failed to load exercises");
    }
  }
}

  void _filterExercises() {
    setState(() {
      filteredExercises = exercises.where((exercise) {
        bool matchesSearch = exercise['title'].toString().toLowerCase().contains(searchQuery.toLowerCase());
        bool matchesSubject = selectedSubject == null || exercise['course_title'] == selectedSubject;
        return matchesSearch && matchesSubject;
      }).toList();
    });
  }

  Future<void> _submitExercise(int exerciseId) async {
  if (!selectedAnswers.containsKey(exerciseId.toString())) {
    _showError("Please answer at least one question");
    return;
  }

  setState(() => isSubmitting = true);

  try {
    final answers = selectedAnswers[exerciseId.toString()]!.entries.map((entry) {
      return {
        'question_id': entry.key,
        'selected_answers': entry.value,
      };
    }).toList();

    final response = await http.post(
      Uri.parse("http://192.168.100.8:8000/api/exercises/submit/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'exercise_id': exerciseId,
        'answers': answers,
      }),
    );

    print("Status Code: ${response.statusCode}"); // Affiche le code de statut
    print("Response Body: ${response.body}"); // Affiche le corps de la réponse

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      _showResults(result);
      _updateExerciseProgress(exerciseId, result['score']);
    } else {
      _showError("Failed to submit exercise: ${response.body}");
    }
  } catch (e) {
    _showError("An error occurred: $e");
  } finally {
    setState(() => isSubmitting = false);
  }
}
  void _updateExerciseProgress(int exerciseId, double score) {
    setState(() {
      final index = exercises.indexWhere((e) => e['id'] == exerciseId);
      if (index != -1) {
        exercises[index]['progress'] = score;
        _filterExercises();
      }
    });
  }

  void _showResults(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                "Results",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildResultCard(
                "Score",
                "${result['score'].toStringAsFixed(1)}%",
                Icons.score,
                Colors.blue,
              ),
              SizedBox(height: 12),
              _buildResultCard(
                "Correct Answers",
                "${result['correct_count']} / ${result['total_questions']}",
                Icons.check_circle,
                Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                "Correction",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    result['correction'] ?? "No correction available",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (isLoading)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildExerciseCard(filteredExercises[index]),
                  childCount: filteredExercises.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text("Exercises"),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.blue.shade800],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => _showSearchDialog(),
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    final progress = (exercise['progress'] ?? 0.0) / 100;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showExerciseDetails(exercise),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExerciseHeader(exercise),
            Divider(),
            _buildExerciseBody(exercise),
            if (progress > 0)
              _buildProgressIndicator(progress),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader(Map<String, dynamic> exercise) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['title'] ?? 'No Title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  exercise['course_title'] ?? 'No Subject',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          _buildDifficultyBadge(exercise['difficulty_level']?? 1),
        ],
      ),
    );
  }

  Widget _buildExerciseBody(Map<String, dynamic> exercise) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            Icons.help_outline,
            '${(exercise['questions'] as List).length}',
            'Questions',
          ),
          _buildInfoItem(
            Icons.timer,
            '${exercise['duration']}',
            'Minutes',
          ),
          _buildInfoItem(
            Icons.assessment,
            '${(exercise['progress'] ?? 0).toStringAsFixed(0)}%',
            'Progress',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(int level) {
    final colors = {
      1: Colors.green,
      2: Colors.orange,
      3: Colors.red,
    };
    final labels = {
      1: 'Easy',
      2: 'Medium',
      3: 'Hard',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors[level]!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[level]!),
      ),
      child: Text(
        labels[level]!,
        style: TextStyle(
          color: colors[level],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showExerciseDetails(Map<String, dynamic> exercise) {
  // Vérifiez que les propriétés nécessaires ne sont pas null
  if (exercise['title'] == null || exercise['subject'] == null || exercise['questions'] == null) {
    _showError("Exercise data is incomplete");
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ExerciseDetailPage(
        exercise: exercise,
        onSubmit: _submitExercise,
        onAnswerSelected: (questionId, answerId, isSelected) {
          setState(() {
            final exerciseId = exercise['id'].toString();
            selectedAnswers[exerciseId] ??= {};
            selectedAnswers[exerciseId]![questionId] ??= [];
            
            if (isSelected) {
              selectedAnswers[exerciseId]![questionId]!.add(answerId);
            } else {
              selectedAnswers[exerciseId]![questionId]!.remove(answerId);
            }
          });
        },
      ),
    ),
  );
}

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Search Exercises"),
        content: TextField(
          onChanged: (value) {
            searchQuery = value;
            _filterExercises();
          },
          decoration: InputDecoration(
            hintText: "Enter exercise title",
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final subjects = exercises
        .map((e) => e['course_title'].toString())
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Filter by Subject"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("All Subjects"),
                selected: selectedSubject == null,
                onTap: () {
                  setState(() {
                    selectedSubject = null;
                    _filterExercises();
                  });
                  Navigator.pop(context);
                },
              ),
              ...subjects.map((subject) => ListTile(
                title: Text(subject),
                selected: selectedSubject == subject,
                onTap: () {
                  setState(() {
                    selectedSubject = subject;
                    _filterExercises();
                  });
                  Navigator.pop(context);
                },
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseDetailPage extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Function(int) onSubmit;
  final Function(int, int, bool) onAnswerSelected;

  const ExerciseDetailPage({
    Key? key,
    required this.exercise,
    required this.onSubmit,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  _ExerciseDetailPageState createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  Map<int, List<int>> selectedAnswers = {};
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.exercise['title'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.blue.shade800],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.assignment,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExerciseInfo(),
                  SizedBox(height: 24),
                  Text(
                    "Questions",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildQuestionCard(
                widget.exercise['questions'][index],
                index + 1,
              ),
              childCount: widget.exercise['questions'].length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () => widget.onSubmit(widget.exercise['id']),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Submit Answers",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildExerciseInfo() {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.school,
            "Subject",
            widget.exercise['subject'] ?? 'No Subject', // Gestion de nullité
          ),
          Divider(height: 24),
          _buildInfoRow(
            Icons.timer,
            "Duration",
            "${widget.exercise['duration'] ?? 0} minutes", // Gestion de nullité
          ),
          Divider(height: 24),
          _buildInfoRow(
            Icons.trending_up,
            "Difficulty",
            _getDifficultyText(widget.exercise['difficulty_level'] ?? 1), // Gestion de nullité
            _getDifficultyColor(widget.exercise['difficulty_level'] ?? 1), // Gestion de nullité
          ),
        ],
      ),
    ),
  );
}

  Widget _buildInfoRow(IconData icon, String label, String value, [Color? valueColor]) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int questionNumber) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$questionNumber",
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  question['text'] ?? 'No Question Text', // Gestion de nullité
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...(question['answers'] ?? []).map<Widget>((answer) => _buildAnswerTile(
            answer,
            question['id'],
          )),
        ],
      ),
    ),
  );
}

  Widget _buildAnswerTile(Map<String, dynamic> answer, int questionId) {
  final answerId = answer['id'];
  final isSelected = selectedAnswers[questionId]?.contains(answerId) ?? false;

  return Container(
    margin: EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isSelected ? Colors.blue : Colors.grey.shade300,
      ),
      color: isSelected ? Colors.blue.shade50 : null,
    ),
    child: InkWell(
      onTap: () {
        setState(() {
          if (selectedAnswers[questionId] == null) {
            selectedAnswers[questionId] = [];
          }
          
          if (isSelected) {
            selectedAnswers[questionId]!.remove(answerId);
          } else {
            selectedAnswers[questionId]!.add(answerId);
          }
          
          widget.onAnswerSelected(questionId, answerId, !isSelected);
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                answer['text'] ?? 'No Answer Text', // Gestion de nullité
                style: TextStyle(
                  color: isSelected ? Colors.blue.shade700 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return "Easy";
      case 2:
        return "Medium";
      case 3:
        return "Hard";
      default:
        return "Unknown";
    }
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}