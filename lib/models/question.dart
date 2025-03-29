class Question {
  final String id;
  String questionText;
  String correctAnswer;
  List<String> wrongAnswers;
  final DateTime createdAt;

  Question({
    this.id = '',
    required this.questionText,
    required this.correctAnswer,
    required this.wrongAnswers,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       assert(questionText.isNotEmpty, 'El texto de la pregunta es requerido'),
       assert(correctAnswer.isNotEmpty, 'La respuesta correcta es requerida'),
       assert(wrongAnswers.length == 2, 'Debe tener 2 respuestas incorrectas'),
       assert(
         wrongAnswers.every((a) => a.isNotEmpty),
         'Respuestas incorrectas no pueden estar vacías',
       );

  Question copyWith({
    String? questionText,
    String? correctAnswer,
    List<String>? wrongAnswers,
  }) {
    return Question(
      id: id,
      questionText: questionText?.trim() ?? this.questionText,
      correctAnswer: correctAnswer?.trim() ?? this.correctAnswer,
      wrongAnswers:
          wrongAnswers?.map((a) => a.trim()).toList() ??
          List.from(this.wrongAnswers),
      createdAt: createdAt,
    );
  }

  List<String> getShuffledAnswers() {
    final answers = [...wrongAnswers, correctAnswer];
    answers.shuffle();
    return answers;
  }

  // Método para crear una pregunta vacía
  static Question empty() =>
      Question(questionText: '', correctAnswer: '', wrongAnswers: ['', '', '']);

  // Conversión a Map básica
  Map<String, dynamic> toMap() => {
    'id': id,
    'questionText': questionText,
    'correctAnswer': correctAnswer,
    'wrongAnswers': wrongAnswers,
    'createdAt': createdAt.toIso8601String(),
  };

  // Constructor desde Map
  factory Question.fromMap(Map<String, dynamic> map) => Question(
    id: map['id'] ?? '',
    questionText: map['questionText'],
    correctAnswer: map['correctAnswer'],
    wrongAnswers: List<String>.from(map['wrongAnswers']),
    createdAt: DateTime.parse(map['createdAt']),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          questionText == other.questionText &&
          correctAnswer == other.correctAnswer;

  @override
  int get hashCode => questionText.hashCode ^ correctAnswer.hashCode;
}
