import '../models/quiz.dart';
import '../models/question.dart';
import '../services/auth_service.dart';

class QuizService {
  static final List<Quiz> _quizzes = [];

  static List<Quiz> get quizzes => List.unmodifiable(_quizzes);

  static void createQuiz(String title, List<Question> questions) {
    if (title.isEmpty) throw ArgumentError('El título del quiz es requerido');
    if (questions.isEmpty)
      throw ArgumentError('Debe contener al menos una pregunta');

    final userEmail = AuthService.currentUser?.email ?? 'Anónimo';

    _quizzes.add(
      Quiz(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        questions: questions,
        createdBy: userEmail,
        createdAt: DateTime.now(),
      ),
    );
  }

  static bool updateQuiz(String quizId, Quiz updatedQuiz) {
    _validateQuizOwnership(quizId);

    final index = _quizzes.indexWhere((q) => q.id == quizId);
    if (index == -1) return false;

    if (updatedQuiz.title.isEmpty) throw ArgumentError('Título inválido');
    if (updatedQuiz.questions.isEmpty)
      throw ArgumentError('Debe contener preguntas');

    _quizzes[index] = updatedQuiz.copyWith(updatedAt: DateTime.now());
    return true;
  }

  static bool deleteQuiz(String quizId) {
    _validateQuizOwnership(quizId);
    final initialLength = _quizzes.length;
    _quizzes.removeWhere((quiz) => quiz.id == quizId);
    return _quizzes.length < initialLength; // Verifica si se eliminó
  }

  static bool deleteQuestion(String quizId, int questionIndex) {
    _validateQuizOwnership(quizId);

    final quiz = _quizzes.firstWhere(
      (q) => q.id == quizId,
      orElse: () => throw Exception('Quiz no encontrado'),
    );

    if (questionIndex < 0 || questionIndex >= quiz.questions.length) {
      throw RangeError('Índice de pregunta inválido');
    }

    quiz.questions.removeAt(questionIndex);
    return true;
  }

  static bool updateQuestion(
    String quizId,
    int questionIndex,
    Question updatedQuestion,
  ) {
    _validateQuizOwnership(quizId);

    final quiz = _quizzes.firstWhere(
      (q) => q.id == quizId,
      orElse: () => throw Exception('Quiz no encontrado'),
    );

    if (questionIndex < 0 || questionIndex >= quiz.questions.length) {
      throw RangeError('Índice de pregunta inválido');
    }

    quiz.questions[questionIndex] = updatedQuestion;
    return true;
  }

  static Quiz? getQuizById(String quizId) {
    try {
      return _quizzes.firstWhere((q) => q.id == quizId);
    } catch (e) {
      return null;
    }
  }

  // Nuevo: Búsqueda de quizzes
  static List<Quiz> searchQuizzes(String query) {
    return _quizzes
        .where(
          (quiz) =>
              quiz.title.toLowerCase().contains(query.toLowerCase()) ||
              quiz.createdBy.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Nuevo: Obtener quizzes de un usuario
  static List<Quiz> getUserQuizzes(String userEmail) {
    return _quizzes.where((q) => q.createdBy == userEmail).toList();
  }

  // Validación de propiedad
  static void _validateQuizOwnership(String quizId) {
    final quiz = getQuizById(quizId);
    final currentUser = AuthService.currentUser?.email;

    if (quiz != null && quiz.createdBy != currentUser) {
      throw Exception('No tienes permisos para modificar este quiz');
    }
  }
}
