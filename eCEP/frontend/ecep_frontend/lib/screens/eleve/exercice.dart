import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';


// SearchDialog Widget
class SearchDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Search Exercises'),
      content: TextField(
        onChanged: (value) {
          context.read<ExerciseProvider>().setSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Enter search term...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}

// FilterBottomSheet Widget
class FilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();
    final subjects = provider.exercises
        .map((e) => e['course_title'] as String)
        .toSet()
        .toList();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter by Subject',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return ListTile(
                  title: Text(subject),
                  trailing: provider.selectedSubject == subject
                      ? Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    provider.setSelectedSubject(
                      provider.selectedSubject == subject ? null : subject
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// State management for exercises
class ExerciseProvider extends ChangeNotifier {
  List<dynamic> _exercises = [];
  List<dynamic> _filteredExercises = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String? _selectedSubject;
  Map<String, Map<int, List<int>>> _selectedAnswers = {};

  List<dynamic> get exercises => _exercises;
  List<dynamic> get filteredExercises => _filteredExercises;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedSubject => _selectedSubject;
  Map<String, Map<int, List<int>>> get selectedAnswers => _selectedAnswers;

  Future<void> fetchExercises() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.100.8:8000/api/exercises/"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _exercises = data;
        _filteredExercises = data;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to load exercises');
    }
  }

  void filterExercises() {
    _filteredExercises = _exercises.where((exercise) {
      bool matchesSearch = exercise['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesSubject = _selectedSubject == null || exercise['course_title'] == _selectedSubject;
      return matchesSearch && matchesSubject;
    }).toList();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    filterExercises();
  }

  void setSelectedSubject(String? subject) {
    _selectedSubject = subject;
    filterExercises();
  }

  void updateAnswers(String exerciseId, int questionId, int answerId, bool isSelected) {
    _selectedAnswers[exerciseId] ??= {};
    _selectedAnswers[exerciseId]![questionId] ??= [];
    
    if (isSelected) {
      _selectedAnswers[exerciseId]![questionId]!.add(answerId);
    } else {
      _selectedAnswers[exerciseId]![questionId]!.remove(answerId);
    }
    notifyListeners();
  }
}

// Main Exercise Page
class ExercisesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider()..fetchExercises(),
        ),
      ],
      child: ExercisesView(),
    );
  }
}

class ExercisesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          if (provider.isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            )
          else if (provider.filteredExercises.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No exercises found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ExerciseCard(
                    exercise: provider.filteredExercises[index],
                  ),
                  childCount: provider.filteredExercises.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterOptions(context),
        child: Icon(Icons.filter_list),
        tooltip: 'Filter exercises',
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Exercises'),
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
          onPressed: () => _showSearchDialog(context),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SearchDialog(),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(),
    );
  }
}

// Exercise Card Widget
class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseCard({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (exercise['progress'] ?? 0.0) / 100;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Divider(height: 1),
            _buildBody(),
            if (progress > 0) _buildProgress(progress),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          _buildDifficultyBadge(exercise['difficulty_level'] ?? 1),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final type = exercise['type'] ?? 'qcm';
    final typeIcon = {
      'quiz': Icons.timer,
      'pdf': Icons.picture_as_pdf,
      'qcm': Icons.check_box,
    }[type] ?? Icons.help_outline;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            typeIcon,
            _getTypeLabel(type),
            'Type',
          ),
          _buildInfoItem(
            Icons.help_outline,
            '${(exercise['questions'] as List?)?.length ?? 0}',
            'Questions',
          ),
          _buildInfoItem(
            Icons.timer,
            '${exercise['duration']}',
            'Minutes',
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'quiz':
        return 'Quiz';
      case 'pdf':
        return 'PDF';
      case 'qcm':
        return 'QCM';
      default:
        return 'Unknown';
    }
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

  Widget _buildProgress(double progress) {
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

  void _navigateToDetail(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider.value(
        value: context.read<ExerciseProvider>(),
        child: ExerciseDetailPage(exercise: exercise),
      ),
    ),
  );
}

}


// Exercise Detail Page
class ExerciseDetailPage extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailPage({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  _ExerciseDetailPageState createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  late Timer? timer;
  int timeSpent = 0;
  bool isSubmitting = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.exercise['type'] == 'quiz') {
      startTimer();
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeSpent++;
        if (timeSpent >= widget.exercise['duration'] * 60) {
          submitExercise();
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> submitExercise() async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);
    timer?.cancel();

    try {
      final provider = context.read<ExerciseProvider>();
      final answers = provider.selectedAnswers[widget.exercise['id'].toString()]
          ?.entries
          .map((entry) => {
                'question_id': entry.key,
                'selected_answers': entry.value,
              })
          .toList() ??
          [];

      final response = await http.post(
        Uri.parse("http://192.168.100.8:8000/api/exercises/submit/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'exercise_id': widget.exercise['id'],
          'answers': answers,
          'time_spent': timeSpent,
          'completed': widget.exercise['type'] == 'pdf',
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _showResults(result);
      } else {
        throw Exception('Failed to submit exercise');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
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
        builder: (context, scrollController) => ResultsSheet(
          result: result,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<ExerciseProvider>(context, listen: false),
      child: Builder(
        builder: (context) => Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (widget.exercise['type'] == 'quiz') _buildTimer(),
                _buildExerciseInfo(),
              ],
            ),
          ),
          _buildContent(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildSubmitButton(),
            ),
          ),
        ],
      ),
    ),
    ),
  );
  }
// Continuation de la classe _ExerciseDetailPageState...

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.exercise['title'] ?? 'Exercise',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.blue.shade800],
                ),
              ),
            ),
            Center(
              child: Icon(
                _getExerciseTypeIcon(),
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getExerciseTypeIcon() {
    switch (widget.exercise['type']) {
      case 'quiz':
        return Icons.timer;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'qcm':
        return Icons.check_box;
      default:
        return Icons.assignment;
    }
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
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimer() {
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;
    final duration = widget.exercise['duration'] * 60;
    final remainingTime = duration - timeSpent;
    final remainingMinutes = remainingTime ~/ 60;
    final remainingSeconds = remainingTime % 60;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            'Time Remaining: ${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfo() {
    return Card(
      margin: EdgeInsets.all(16),
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
              widget.exercise['subject'] ?? 'No Subject',
            ),
            Divider(height: 24),
            _buildInfoRow(
              Icons.timer,
              "Duration",
              "${widget.exercise['duration']} minutes",
            ),
            Divider(height: 24),
            _buildInfoRow(
              Icons.trending_up,
              "Difficulty",
              _getDifficultyText(widget.exercise['difficulty_level'] ?? 1),
              _getDifficultyColor(widget.exercise['difficulty_level'] ?? 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.exercise['type']) {
      case 'pdf':
        return SliverToBoxAdapter(
          child: _buildPdfViewer(),
        );
      case 'quiz':
      case 'qcm':
      default:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildQuestionCard(
              widget.exercise['questions'][index],
              index + 1,
            ),
            childCount: (widget.exercise['questions'] as List?)?.length ?? 0,
          ),
        );
    }
  }

  Widget _buildPdfViewer() {
    if (widget.exercise['pdf_file'] == null) {
      return Center(
        child: Text('No PDF file available'),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PDFView(
          filePath: widget.exercise['pdf_file'],
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
          onError: (error) {
            print(error.toString());
          },
          onPageError: (page, error) {
            print('$page: ${error.toString()}');
          },
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int questionNumber) {
    final answers = question['answers'] as List? ?? [];
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionHeader(question, questionNumber),
          ...answers.map((answer) => _buildAnswerTile(answer, question['id'])),
          if (widget.exercise['type'] == 'quiz')
            _buildExplanationBox(question['explanation']),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(Map<String, dynamic> question, int questionNumber) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              questionNumber.toString(),
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              question['text'] ?? 'No question text',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerTile(Map<String, dynamic> answer, int questionId) {
    final provider = context.watch<ExerciseProvider>();
    final answerId = answer['id'];
    final isSelected = provider.selectedAnswers[widget.exercise['id'].toString()]
            ?.containsKey(questionId) ??
        false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
        ),
        color: isSelected ? Colors.blue.shade50 : null,
      ),
      child: InkWell(
        onTap: () => _handleAnswerSelection(questionId, answerId),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  answer['text'] ?? 'No answer text',
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

  void _handleAnswerSelection(int questionId, int answerId) {
    final provider = context.read<ExerciseProvider>();
    final exerciseId = widget.exercise['id'].toString();
    final isCurrentlySelected = provider
            .selectedAnswers[exerciseId]?[questionId]
            ?.contains(answerId) ??
        false;
    
    provider.updateAnswers(
      exerciseId,
      questionId,
      answerId,
      !isCurrentlySelected,
    );
  }

  Widget _buildExplanationBox(String? explanation) {
    if (explanation == null || explanation.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Explanation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            explanation,
            style: TextStyle(color: Colors.orange.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isSubmitting ? null : submitExercise,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isSubmitting
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              widget.exercise['type'] == 'pdf' ? 'Mark as Complete' : 'Submit',
              style: TextStyle(fontSize: 18),
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

// Results Sheet Widget
class ResultsSheet extends StatelessWidget {
  final Map<String, dynamic> result;
  final ScrollController scrollController;

  const ResultsSheet({
    Key? key,
    required this.result,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildScoreSection(),
          _buildCorrection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildScoreSection() {
    final score = result['score'] as double;
    final isPass = score >= 60;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            isPass ? 'Congratulations!' : 'Keep practicing!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPass ? Colors.green : Colors.orange,
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Score',
                  '${score.toStringAsFixed(1)}%',
                  isPass ? Colors.green : Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildScoreCard(
                  'Correct Answers',
                  '${result['correct_count']} / ${result['total_questions']}',
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrection() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Text(
                  result['correction'] ?? 'No correction available',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}