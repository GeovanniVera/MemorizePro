import 'package:flutter/material.dart';
import '../models/question.dart';

class EditQuestionDialog extends StatefulWidget {
  final Question initialQuestion;

  const EditQuestionDialog({super.key, required this.initialQuestion});

  @override
  _EditQuestionDialogState createState() => _EditQuestionDialogState();
}

class _EditQuestionDialogState extends State<EditQuestionDialog> {
  late Question _editedQuestion;
  final List<TextEditingController> _wrongAnswerControllers = [];

  @override
  void initState() {
    super.initState();
    // Crear copia editable de la pregunta
    _editedQuestion = Question(
      questionText: widget.initialQuestion.questionText,
      correctAnswer: widget.initialQuestion.correctAnswer,
      wrongAnswers: List.from(widget.initialQuestion.wrongAnswers),
    );

    // Inicializar controladores con valores actuales
    for (var answer in _editedQuestion.wrongAnswers) {
      _wrongAnswerControllers.add(TextEditingController(text: answer));
    }
  }

  @override
  void dispose() {
    // Limpiar controladores
    for (var c in _wrongAnswerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveChanges() {
    // Validar campos
    if (_editedQuestion.questionText.isEmpty ||
        _editedQuestion.correctAnswer.isEmpty ||
        _wrongAnswerControllers.any((c) => c.text.isEmpty)) {
      return;
    }

    // Crear nueva pregunta actualizada
    final updatedQuestion = Question(
      questionText: _editedQuestion.questionText,
      correctAnswer: _editedQuestion.correctAnswer,
      wrongAnswers: _wrongAnswerControllers.map((c) => c.text).toList(),
    );

    Navigator.pop(context, updatedQuestion);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Pregunta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _editedQuestion.questionText,
              onChanged: (value) => _editedQuestion.questionText = value,
              decoration: InputDecoration(
                labelText: 'Pregunta',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              initialValue: _editedQuestion.correctAnswer,
              onChanged: (value) => _editedQuestion.correctAnswer = value,
              decoration: InputDecoration(
                labelText: 'Respuesta Correcta',
                border: OutlineInputBorder(),
              ),
            ),
            ..._wrongAnswerControllers.map(
              (controller) => Padding(
                padding: EdgeInsets.only(top: 10),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Respuesta Incorrecta',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _saveChanges, child: Text('Guardar Cambios')),
      ],
    );
  }
}
