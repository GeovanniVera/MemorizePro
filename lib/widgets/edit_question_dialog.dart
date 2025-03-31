import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizlet/models/question.dart';

class EditQuestionDialog extends StatefulWidget {
  final Question initialQuestion;

  const EditQuestionDialog({super.key, required this.initialQuestion});

  @override
  _EditQuestionDialogState createState() => _EditQuestionDialogState();
}

class _EditQuestionDialogState extends State<EditQuestionDialog> {
  late Question _editedQuestion;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _editedQuestion = widget.initialQuestion.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Pregunta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuestionField(),
              const SizedBox(height: 20),
              _buildCorrectAnswerField(),
              const SizedBox(height: 20),
              ..._buildWrongAnswersFields(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _saveChanges, child: const Text('Guardar')),
      ],
    );
  }

  Widget _buildQuestionField() {
    return TextFormField(
      initialValue: _editedQuestion.questionText,
      decoration: const InputDecoration(
        labelText: 'Pregunta',
        border: OutlineInputBorder(),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'^\s|')),
        LengthLimitingTextInputFormatter(50),
      ],
      maxLength: 50,
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) return 'Campo obligatorio';
        if (trimmedValue.length > 50) return 'Máximo 50 caracteres';
        if (value!.contains('  ')) return 'No espacios dobles';
        return null;
      },
      onChanged: (value) => _editedQuestion.questionText = value.trim(),
    );
  }

  Widget _buildCorrectAnswerField() {
    return TextFormField(
      initialValue: _editedQuestion.correctAnswer,
      decoration: const InputDecoration(
        labelText: 'Respuesta Correcta',
        border: OutlineInputBorder(),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'^\s|')),
        LengthLimitingTextInputFormatter(50),
      ],
      maxLength: 50,
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) return 'Campo obligatorio';
        if (trimmedValue.length > 50) return 'Máximo 50 caracteres';
        if (value!.contains('  ')) return 'No espacios dobles';
        return null;
      },
      onChanged: (value) => _editedQuestion.correctAnswer = value.trim(),
    );
  }

  List<Widget> _buildWrongAnswersFields() {
    return List.generate(
      _editedQuestion.wrongAnswers.length,
      (index) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextFormField(
          initialValue: _editedQuestion.wrongAnswers[index],
          decoration: InputDecoration(
            labelText: 'Respuesta Incorrecta ${index + 1}',
            border: const OutlineInputBorder(),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'^\s|')),
            LengthLimitingTextInputFormatter(50),
          ],
          maxLength: 50,
          validator: (value) {
            final trimmedValue = value?.trim() ?? '';
            if (trimmedValue.isEmpty) return 'Campo obligatorio';
            if (trimmedValue.length > 50) return 'Máximo 50 caracteres';
            if (value!.contains('  ')) return 'No espacios dobles';
            return null;
          },
          onChanged:
              (value) => _editedQuestion.wrongAnswers[index] = value.trim(),
        ),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _editedQuestion);
    }
  }
}
