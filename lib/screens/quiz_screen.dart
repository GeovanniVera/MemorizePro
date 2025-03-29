import 'package:flutter/material.dart';
import 'package:quizlet/models/question.dart';
import 'package:quizlet/models/quiz.dart';
import '../services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Quiz _quiz;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answerSelected = false;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  void _loadQuiz() {
    final quiz = QuizService.quizzes.firstWhere(
      (q) => q.id == widget.quizId,
      orElse:
          () => Quiz(
            id: 'error',
            title: 'Quiz no encontrado',
            questions: [],
            createdBy: 'system',
          ),
    );

    if (quiz.questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showErrorDialog());
    }

    setState(() => _quiz = quiz);
  }

  void _answerQuestion(String selectedAnswer) {
    if (!_answerSelected) {
      setState(() {
        _answerSelected = true;
        _selectedAnswer = selectedAnswer;
        if (selectedAnswer == _currentQuestion.correctAnswer) _score++;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_currentQuestionIndex < _quiz.questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _answerSelected = false;
            _selectedAnswer = null;
          });
        } else {
          _showResults();
        }
      });
    }
  }

  // Resto de métodos (_showResults, _showErrorDialog, _getAnswerColor)

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Resultados Finales'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Puntaje: $_score/${_quiz.questions.length}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _score / _quiz.questions.length,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                ),
                SizedBox(height: 20),
                Text(
                  _score == _quiz.questions.length
                      ? '¡Perfecto! 🎉'
                      : _score > _quiz.questions.length / 2
                      ? '¡Buen trabajo! 👍'
                      : 'Sigue practicando 💪',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: [
              // Botón modificado para ir al dashboard
              TextButton(
                onPressed:
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/dashboard',
                      (route) => false,
                    ),
                child: Text('Inicio'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentQuestionIndex = 0;
                    _score = 0;
                    _answerSelected = false;
                    _selectedAnswer = null;
                  });
                },
                child: Text('Reintentar'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Este quiz no tiene preguntas disponibles'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  Question get _currentQuestion => _quiz.questions[_currentQuestionIndex];

  Color _getAnswerColor(String answer) {
    if (!_answerSelected) return Colors.blue;
    if (answer == _currentQuestion.correctAnswer) return Colors.green;
    if (answer == _selectedAnswer) return Colors.red;
    return Colors.grey;
  }

  // permanecen igual que en tu versión, solo asegúrate de los parámetros requeridos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _buildQuizContent(),
    );
  }

  Widget _buildQuizContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressHeader(),
          const SizedBox(height: 30),
          Expanded(child: _buildQuestionCard()),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pregunta ${_currentQuestionIndex + 1}/${_quiz.questions.length}',
            ),
            Text(
              'Puntos: $_score',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _quiz.questions.length,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Card(
        key: ValueKey(_currentQuestionIndex),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _currentQuestion.questionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ..._currentQuestion.getShuffledAnswers().map(
                (answer) => _buildAnswerButton(answer),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _getAnswerColor(answer),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () => _answerQuestion(answer),
        child: Text(answer, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
