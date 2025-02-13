import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class CoursPage extends StatefulWidget {
  const CoursPage({Key? key}) : super(key: key);

  @override
  _CoursPageState createState() => _CoursPageState();
}

class _CoursPageState extends State<CoursPage> {
  List<String> matieres = ["Mathématiques", "Français", "Histoire-Géographie", "Sciences"];
  List<IconData> icons = [Icons.calculate, Icons.book, Icons.public, Icons.science];
  bool isLoading = true;
  List<dynamic> cours = [];
  List<dynamic> filteredCours = [];
  String searchQuery = "";
  String? selectedFilter;
  int userId = 1;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.100.8:8000/api/cours/"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Réponse de l'API: $data");

        if (mounted) {
          setState(() {
            cours = data; // Supposons que data est une liste de cours
            filteredCours = cours;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Échec du chargement des cours");
      }
    } catch (error) {
      debugPrint("Erreur de chargement des cours : $error");
      if (mounted) {
        setState(() {
          cours = [];
          filteredCours = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cours et Leçons"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: matieres.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProgrammePage(
                            matiere: matieres[index],
                            userId: userId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[index],
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          matieres[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ProgrammePage extends StatefulWidget {
  final String matiere;
  final int userId;

  const ProgrammePage({
    Key? key,
    required this.matiere,
    required this.userId,
  }) : super(key: key);

  @override
  _ProgrammePageState createState() => _ProgrammePageState();
}

class _ProgrammePageState extends State<ProgrammePage> {
  List<dynamic> chapitres = [];
  bool isLoading = true;
  Map<String, dynamic>? selectedLesson;
  int? selectedChapterIndex;
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  Set<String> completedLessons = {};
  String? pdfPath;
  bool isSmallScreen = false;
  bool showSidebar = true;

  @override
  void initState() {
    super.initState();
    _fetchChapitres();
    _loadCompletedLessons();
    // Initialiser showSidebar à true par défaut
    showSidebar = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isSmallScreen = MediaQuery.of(context).size.width < 800;
    // Sur petit écran, cacher la barre latérale par défaut
    if (isSmallScreen && showSidebar) {
      setState(() {
        showSidebar = false;
      });
    }
  }

  Future<void> _loadCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedLessons = Set<String>.from(
        prefs.getStringList('completed_lessons_${widget.userId}') ?? [],
      );
    });
  }

  Future<void> _saveCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'completed_lessons_${widget.userId}',
      completedLessons.toList(),
    );
  }

  Future<void> _fetchChapitres() async {
    try {
      final encodedMatiere = Uri.encodeComponent(widget.matiere);
      final response = await http.get(
        Uri.parse("http://192.168.100.8:8000/api/cours/$encodedMatiere/"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("📌 Réponse API (chapitres) : ${jsonEncode(data)}");

        if (mounted) {
          setState(() {
            chapitres = [];

            // 🔹 EXTRAIRE LES CHAPITRES IMBRIQUÉS
            if (data['chapitres'] != null) {
              for (var course in data['chapitres']) {
                if (course['chapitres'] != null) {
                  chapitres.addAll(List<dynamic>.from(course['chapitres']));
                }
              }
            }
            isLoading = false;
          });
        }
      } else {
        throw Exception("Échec du chargement des chapitres");
      }
    } catch (error) {
      debugPrint("❌ Erreur lors du chargement des chapitres : $error");
      if (mounted) {
        setState(() {
          chapitres = [];
          isLoading = false;
        });
      }
    }
  }

  void _initializeVideo(String videoUrl) {
    _disposeCurrentVideo();
    
    if (videoUrl.contains("youtube.com") || videoUrl.contains("youtu.be")) {
      String? videoId = YoutubePlayer.convertUrlToId(videoUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            hideControls: false,
            showLiveFullscreenButton: false,
          ),
        );
        setState(() {});
      }
    } else {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play();
          }
        });
    }
  }

  void _disposeCurrentVideo() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    _videoController = null;
    _youtubeController = null;
  }

  Future<void> _downloadAndOpenPdf(String url, String fileName) async {
    try {
      setState(() {
        isDownloading = true;
        downloadProgress = 0;
      });

      // Construction de l'URL avec le bon chemin
      final baseUrl = "http://192.168.100.8:8000";
      // Assurer que le chemin commence par /lecons_pdfs/
      final fullUrl = url.startsWith('http') 
          ? url 
          : '$baseUrl/lecons_pdfs/${url.startsWith('/') ? url.substring(1) : url}';
      
      debugPrint("Tentative de téléchargement depuis: $fullUrl");

      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));

      // Créer le répertoire local
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      
      final filePath = '${dir.path}/$fileName';
      pdfPath = filePath;

      // Vérifier si le fichier existe déjà en local
      final file = File(filePath);
      if (await file.exists()) {
        setState(() {
          isDownloading = false;
          pdfPath = filePath;
        });
        return;
      }

      // Téléchargement avec gestion de la progression
      final response = await dio.download(
        fullUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
        options: Options(
          headers: {
            'Accept': 'application/pdf',
            'Accept-Encoding': 'gzip, deflate',
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }

      if (!await file.exists()) {
        throw Exception("Le fichier n'a pas été créé");
      }

      setState(() {
        isDownloading = false;
      });
    } catch (e) {
      debugPrint("Erreur de téléchargement détaillée: ${e.toString()}");
      setState(() {
        isDownloading = false;
        pdfPath = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement du PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () => _downloadAndOpenPdf(url, fileName),
            ),
          ),
        );
      }
    }
  }

  void markLessonAsCompleted(String lessonId) {
    setState(() {
      completedLessons.add(lessonId);
      _saveCompletedLessons();
    });
  }

  void _goToNextLesson() {
    if (selectedLesson == null || selectedChapterIndex == null) return;

    List<dynamic> currentChapterLessons = chapitres[selectedChapterIndex!]['lecons'];
    int currentLessonIndex = currentChapterLessons.indexWhere((l) => l['id'] == selectedLesson!['id']);

    if (currentLessonIndex < currentChapterLessons.length - 1) {
      // Next lesson in current chapter
      _selectLesson(currentChapterLessons[currentLessonIndex + 1], selectedChapterIndex!);
    } else if (selectedChapterIndex! < chapitres.length - 1) {
      // First lesson of next chapter
      List<dynamic> nextChapterLessons = chapitres[selectedChapterIndex! + 1]['lecons'];
      if (nextChapterLessons.isNotEmpty) {
        _selectLesson(nextChapterLessons[0], selectedChapterIndex! + 1);
      }
    }
  }

  void _selectLesson(Map<String, dynamic> lesson, int chapterIndex) {
    setState(() {
      selectedLesson = lesson;
      selectedChapterIndex = chapterIndex;
      pdfPath = null; // Reset PDF path when selecting new lesson
      
      // Masquer la barre latérale dès qu'une leçon est sélectionnée
      showSidebar = false;
      
      if (lesson['video_url'] != null) {
        _initializeVideo(lesson['video_url']);
      } else if (lesson['fichier_pdf'] != null) {
        _downloadAndOpenPdf(lesson['fichier_pdf'], 'lesson_${lesson['id']}.pdf');
      }
    });
  }

  Widget _buildVideoControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                _videoController!.value.isPlaying
                    ? _videoController!.pause()
                    : _videoController!.play();
              });
            },
          ),
          Expanded(
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).primaryColor,
                bufferedColor: Colors.grey[300]!,
                backgroundColor: Colors.grey[100]!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonList() {
    return Container(
      width: 300,
      color: Colors.grey[50],
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chapitres.length,
        itemBuilder: (context, index) {
          final chapitre = chapitres[index];

          // 🔹 Vérification si la clé 'lecons' existe
          List<dynamic> lecons = chapitre.containsKey('lecons') && chapitre['lecons'] != null
              ? List<dynamic>.from(chapitre['lecons'])
              : [];
              debugPrint("🔹 Chapitre détecté : ${chapitre['titre']}");
          debugPrint("🔸 Nombre de leçons trouvées : ${lecons.length}");

          return ExpansionTile(
            initiallyExpanded: selectedChapterIndex == index,
            title: Text(
              "Chapitre ${index + 1}: ${chapitre['titre']}",
              style: const TextStyle(fontSize: 16),
            ),
            children: lecons.isNotEmpty
                ? lecons.map<Widget>((lecon) {
                    final isCompleted = completedLessons.contains(lecon['id'].toString());
                    final isSelected = selectedLesson?['id'] == lecon['id'];

                    return ListTile(
                      leading: Icon(
                        lecon['video_url'] != null ? Icons.play_circle_outline : Icons.picture_as_pdf,
                        color: isCompleted ? Colors.green : (isSelected ? Theme.of(context).primaryColor : Colors.grey[600]),
                      ),
                      title: Text(
                        lecon['titre'] ?? "Sans titre",
                        style: TextStyle(
                          color: isCompleted ? Colors.green : (isSelected ? Theme.of(context).primaryColor : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () => _selectLesson(lecon, index),
                    );
                  }).toList()
                : [const ListTile(title: Text("Aucune leçon disponible"))], // ✅ Message si vide
          );
        },
      ),
    );
  }

  Widget _buildLessonContent() {
    if (selectedLesson == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Sélectionnez une leçon pour commencer",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (isDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: downloadProgress),
            const SizedBox(height: 16),
            Text('${(downloadProgress * 100).toStringAsFixed(1)}%'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildLessonMainContent(),
        ),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildLessonMainContent() {
    if (selectedLesson == null) {
      return const Center(
        child: Text("Aucune leçon sélectionnée"),
      );
    }

    if (isDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: downloadProgress),
            const SizedBox(height: 16),
            Text('Téléchargement: ${(downloadProgress * 100).toStringAsFixed(1)}%'),
          ],
        ),
      );
    }

    if (selectedLesson?['video_url'] != null) {
      // Logique vidéo existante...
      if (_youtubeController != null) {
        return Center(
          child: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            onEnded: (metaData) {
              markLessonAsCompleted(selectedLesson!['id'].toString());
            },
          ),
        );
      } else if (_videoController != null && _videoController!.value.isInitialized) {
        return Column(
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            _buildVideoControls(),
          ],
        );
      }
    } else if (pdfPath != null) {
      debugPrint("Tentative d'affichage du PDF: $pdfPath");
      // Vérifier si le fichier existe
      final file = File(pdfPath!);
      if (!file.existsSync()) {
        debugPrint("Le fichier PDF n'existe pas: $pdfPath");
        return Center(
          child: Text("Erreur: Le fichier PDF n'a pas été trouvé"),
        );
      }

      debugPrint("Taille du fichier PDF: ${file.lengthSync()} bytes");
      
      return Stack(
        children: [
          PDFView(
            filePath: pdfPath!,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: 0,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (_pages) {
              debugPrint("PDF rendu avec $_pages pages");
            },
            onError: (error) {
              debugPrint("Erreur lors du rendu du PDF: $error");
            },
            onPageError: (page, error) {
              debugPrint("Erreur sur la page $page: $error");
            },
            onViewCreated: (controller) {
              debugPrint("Vue PDF créée");
            },
            onPageChanged: (int? page, int? total) {
              debugPrint("Page changée: $page/$total");
              if (page != null && total != null && page == (total - 1)) {
                markLessonAsCompleted(selectedLesson!['id'].toString());
              }
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // Recharger le PDF
                setState(() {
                  pdfPath = null;
                  _downloadAndOpenPdf(
                    selectedLesson!['fichier_pdf'],
                    'lesson_${selectedLesson!['id']}.pdf',
                  );
                });
              },
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isSmallScreen)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => setState(() => showSidebar = !showSidebar),
              tooltip: 'Afficher/Masquer la liste des leçons',
            ),
          if (!isSmallScreen)
            const SizedBox(width: 48), // Pour aligner avec le bouton menu
          Expanded(
            child: Text(
              selectedLesson?['titre'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.navigate_next),
            label: const Text('Suivant'),
            onPressed: _goToNextLesson,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    // Détecter si l'écran est petit ou grand
    isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: Text("Programme de ${widget.matiere}"),
        // Toujours afficher le bouton hamburger, qu'importe la taille d'écran
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => setState(() => showSidebar = !showSidebar),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Le contenu principal
                Positioned.fill(
                  child: _buildLessonContent(),
                ),
                
                // La barre latérale, en overlay et conditionnelle
                if (showSidebar)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 300,
                    child: Material(
                      elevation: 4,
                      child: _buildLessonList(),
                    ),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _disposeCurrentVideo();
    super.dispose();
  }
}

class CoursSearchDelegate extends SearchDelegate<String> {
  final List<dynamic> cours;
  final Function(String) onSearch;

  CoursSearchDelegate(this.cours, this.onSearch);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredList = cours.where((course) {
      return course['titre']?.toLowerCase()?.contains(query.toLowerCase()) == true;
    }).toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final course = filteredList[index];
        return ListTile(
          leading: const Icon(Icons.school),
          title: Text(course['titre'] ?? "Sans titre"),
          subtitle: Text(course['matiere'] ?? ""),
          onTap: () {
            close(context, course['titre'] ?? "");
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = cours.where((course) {
      return course['titre']?.toLowerCase()?.contains(query.toLowerCase()) == true;
    }).toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final course = filteredList[index];
        return ListTile(
          leading: const Icon(Icons.school),
          title: Text(course['titre'] ?? "Sans titre"),
          subtitle: Text(course['matiere'] ?? ""),
          onTap: () {
            query = course['titre'] ?? "";
            showResults(context);
          },
        );
      },
    );
  }
}