import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/quiz_service.dart';
import '../widgets/edit_question_dialog.dart'; // Asume que este widget existe

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final List<Question> _questions = [];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addQuestion() async {
    final result = await showDialog<Question>(
      context: context,
      builder: (context) => _QuestionDialog(),
    );

    if (result != null) {
      setState(() => _questions.add(result));
    }
  }

  void _editQuestion(int index) async {
    final updatedQuestion = await showDialog<Question>(
      context: context,
      builder:
          (context) => EditQuestionDialog(initialQuestion: _questions[index]),
    );

    if (updatedQuestion != null) {
      setState(() => _questions[index] = updatedQuestion);
    }
  }

  void _submitQuiz() {
    if (_formKey.currentState!.validate() && _questions.isNotEmpty) {
      QuizService.createQuiz(_titleController.text, _questions);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Quiz'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _submitQuiz)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título del Quiz',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Ingrese un título' : null,
              ),
              SizedBox(height: 20),
              Expanded(
                child:
                    _questions.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                          itemCount: _questions.length,
                          separatorBuilder: (_, __) => Divider(),
                          itemBuilder:
                              (context, index) => ListTile(
                                title: Text(
                                  _questions[index].questionText,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  'Respuestas: ${_questions[index].wrongAnswers.length + 1}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _editQuestion(index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed:
                                          () => setState(
                                            () => _questions.removeAt(index),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No hay preguntas aún\nPresiona el botón para agregar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.add_circle),
          label: Text('Agregar Pregunta'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: _addQuestion,
        ),
        SizedBox(height: 10),
        if (_questions.isNotEmpty)
          ElevatedButton.icon(
            icon: Icon(Icons.save),
            label: Text('Guardar Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: _submitQuiz,
          ),
      ],
    );
  }
}

class _QuestionDialog extends StatefulWidget {
  @override
  __QuestionDialogState createState() => __QuestionDialogState();
}

class __QuestionDialogState extends State<_QuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      final question = Question(
        questionText: _controllers[0].text,
        correctAnswer: _controllers[1].text,
        wrongAnswers: _controllers.sublist(2).map((c) => c.text).toList(),
      );
      Navigator.pop(context, question);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nueva Pregunta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuestionField(),
              SizedBox(height: 15),
              _buildAnswerFields(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _saveQuestion, child: Text('Guardar')),
      ],
    );
  }

  Widget _buildQuestionField() {
    return TextFormField(
      controller: _controllers[0],
      decoration: InputDecoration(
        labelText: 'Pregunta',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
    );
  }

  Widget _buildAnswerFields() {
    return Column(
      children: [
        TextFormField(
          controller: _controllers[1],
          decoration: InputDecoration(
            labelText: 'Respuesta Correcta',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
        ),
        ...List.generate(
          2,
          (index) => Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextFormField(
              controller: _controllers[index + 2],
              decoration: InputDecoration(
                labelText: 'Respuesta Incorrecta ${index + 1}',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
            ),
          ),
        ),
      ],
    );
  }
}
