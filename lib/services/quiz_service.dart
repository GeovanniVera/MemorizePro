import '../models/quiz.dart';
import '../models/question.dart';
import '../services/auth_service.dart';

class QuizService {
  static final List<Quiz> _quizzes = [];
  static List<Quiz> get quizzes => List.unmodifiable(_quizzes);

  static Quiz createQuiz(String title, List<Question> questions) {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception('Debes iniciar sesión para crear un quiz');
    }

    if (title.isEmpty) throw ArgumentError('El título del quiz es requerido');
    if (questions.isEmpty)
      throw ArgumentError('Debe contener al menos una pregunta');

    final newQuiz = Quiz(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      questions: questions,
      createdBy: user.id, // Usamos user.id en lugar de user.uid
      createdAt: DateTime.now(),
    );

    _quizzes.add(newQuiz);
    return newQuiz;
  }

  static Quiz updateQuiz(String quizId, Quiz updatedQuiz) {
    _validateQuizOwnership(quizId);

    final index = _quizzes.indexWhere((q) => q.id == quizId);
    if (index == -1) throw Exception('Quiz no encontrado');

    if (updatedQuiz.title.isEmpty) throw ArgumentError('Título inválido');
    if (updatedQuiz.questions.isEmpty)
      throw ArgumentError('Debe contener preguntas');

    final updated = updatedQuiz.copyWith(
      updatedAt: DateTime.now(),
      createdBy: _quizzes[index].createdBy, // Mantener el creador original
    );

    _quizzes[index] = updated;
    return updated;
  }

  static void deleteQuiz(String quizId) {
    _validateQuizOwnership(quizId);
    if (!_quizzes.any((q) => q.id == quizId)) {
      throw Exception('Quiz no encontrado');
    }
    _quizzes.removeWhere((quiz) => quiz.id == quizId);
  }

  static bool deleteQuestion(String quizId, int questionIndex) {
    _validateQuizOwnership(quizId);
    final quiz = getQuizById(quizId)!;

    if (questionIndex < 0 || questionIndex >= quiz.questions.length) {
      throw RangeError('Índice de pregunta inválido');
    }

    final updatedQuestions = List<Question>.from(quiz.questions)
      ..removeAt(questionIndex);
    updateQuiz(quizId, quiz.copyWith(questions: updatedQuestions));
    return true;
  }

  static Quiz updateQuestion(
    String quizId,
    int questionIndex,
    Question updatedQuestion,
  ) {
    _validateQuizOwnership(quizId);
    final quiz = getQuizById(quizId)!;

    if (questionIndex < 0 || questionIndex >= quiz.questions.length) {
      throw RangeError('Índice de pregunta inválido');
    }

    final updatedQuestions = List<Question>.from(quiz.questions)
      ..[questionIndex] = updatedQuestion;

    return updateQuiz(quizId, quiz.copyWith(questions: updatedQuestions));
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
    final user = AuthService.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final quiz = getQuizById(quizId);
    if (quiz == null) throw Exception('Quiz no encontrado');

    // Comparación segura convirtiendo a string
    if (quiz.createdBy != user.id) {
      throw Exception('Solo el creador puede modificar este quiz');
    }
  }
}
