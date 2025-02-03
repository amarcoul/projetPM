class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class Course {
  final int id;
  final String title;
  final String description;
  final String subject;
  final String mediaType;
  final double progress; // Peut-être que ce champ n'existe pas dans l'API

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.mediaType,
    this.progress = 0.0, // ✅ Met une valeur par défaut si inexistant
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subject: json['subject'],
      mediaType: json['media_type'],
      progress: (json['progress'] ?? 0.0).toDouble(), // ✅ Gère le cas où progress est absent
    );
  }
}

class Exercise {
  final int id;
  final String title;
  final String description;
  final String type;
  final int difficultyLevel;
  final int courseId;
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficultyLevel,
    required this.courseId,
    required this.createdAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      difficultyLevel: json['difficulty_level'],
      courseId: json['course'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class LearningResult {
  final int id;
  final int userId;
  final int exerciseId;
  final int score;
  final DateTime submittedAt;

  LearningResult({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.score,
    required this.submittedAt,
  });

  factory LearningResult.fromJson(Map<String, dynamic> json) {
    return LearningResult(
      id: json['id'],
      userId: json['user'],
      exerciseId: json['exercise'],
      score: json['score'],
      submittedAt: DateTime.parse(json['submitted_at']),
    );
  }
}

class Badge {
  final int id;
  final String title;
  final String description;
  final String condition;
  final DateTime createdAt;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.condition,
    required this.createdAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      condition: json['condition'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class UserBadge {
  final int id;
  final int userId;
  final int badgeId;
  final DateTime obtainedAt;

  UserBadge({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.obtainedAt,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'],
      userId: json['user'],
      badgeId: json['badge'],
      obtainedAt: DateTime.parse(json['obtained_at']),
    );
  }
}

class Exam {
  final int id;
  final String title;
  final String description;
  final String examType;
  final DateTime date;
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.examType,
    required this.date,
    required this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      examType: json['exam_type'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ExamExercise {
  final int id;
  final int examId;
  final int exerciseId;
  final DateTime createdAt;

  ExamExercise({
    required this.id,
    required this.examId,
    required this.exerciseId,
    required this.createdAt,
  });

  factory ExamExercise.fromJson(Map<String, dynamic> json) {
    return ExamExercise(
      id: json['id'],
      examId: json['exam'],
      exerciseId: json['exercise'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class LearningHistory {
  final int id;
  final int userId;
  final int courseId;
  final DateTime viewedAt;

  LearningHistory({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.viewedAt,
  });

  factory LearningHistory.fromJson(Map<String, dynamic> json) {
    return LearningHistory(
      id: json['id'],
      userId: json['user'],
      courseId: json['course'],
      viewedAt: DateTime.parse(json['viewed_at']),
    );
  }
}

class Payment {
  final int id;
  final int userId;
  final double amount;
  final String status;
  final String serialNumber;
  final DateTime paidAt;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.serialNumber,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      serialNumber: json['serial_number'],
      paidAt: DateTime.parse(json['paid_at']),
    );
  }
}
