import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizlet/models/question.dart';
import 'package:quizlet/widgets/edit_question_dialog.dart';
import 'package:quizlet/models/quiz.dart';
import 'package:quizlet/services/quiz_service.dart';

class EditQuizScreen extends StatefulWidget {
  final Quiz initialQuiz;

  const EditQuizScreen({super.key, required this.initialQuiz});

  @override
  _EditQuizScreenState createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  late Quiz _editedQuiz;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _editedQuiz = widget.initialQuiz.copyWith();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      String? validationError;

      // Validación del título
      if (_editedQuiz.title.trim().isEmpty ||
          _editedQuiz.title.length > 50 ||
          _editedQuiz.title.contains('  ')) {
        validationError =
            'Título inválido: Máx 50 caracteres y sin espacios dobles';
      }

      // Validación de preguntas y respuestas
      if (validationError == null) {
        for (var question in _editedQuiz.questions) {
          if (question.questionText.trim().isEmpty ||
              question.questionText.length > 50 ||
              question.questionText.contains('  ')) {
            validationError = 'Pregunta inválida: Revise el formato';
            break;
          }

          if (question.correctAnswer.trim().isEmpty ||
              question.correctAnswer.length > 50 ||
              question.correctAnswer.contains('  ')) {
            validationError = 'Respuesta correcta inválida';
            break;
          }

          for (var answer in question.wrongAnswers) {
            if (answer.trim().isEmpty ||
                answer.length > 50 ||
                answer.contains('  ')) {
              validationError = 'Respuesta incorrecta inválida';
              break;
            }
          }
          if (validationError != null) break;
        }
      }

      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      if (_editedQuiz.questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El quiz debe tener al menos una pregunta'),
          ),
        );
        return;
      }

      QuizService.updateQuiz(widget.initialQuiz.id, _editedQuiz);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz actualizado exitosamente')),
      );
    }
  }

  void _editQuestion(int index) async {
    final updatedQuestion = await showDialog<Question>(
      context: context,
      builder:
          (context) =>
              EditQuestionDialog(initialQuestion: _editedQuiz.questions[index]),
    );

    if (updatedQuestion != null) {
      setState(() => _editedQuiz.questions[index] = updatedQuestion);
    }
  }

  void _deleteQuestion(int index) {
    if (_editedQuiz.questions.length > 1) {
      setState(() => _editedQuiz.questions.removeAt(index));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El quiz debe tener al menos una pregunta'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_editedQuiz == widget.initialQuiz) return true;
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('¿Descartar cambios?'),
                content: const Text(
                  'Tienes cambios sin guardar. ¿Seguro que quieres salir?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Salir'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Quiz'),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: _editedQuiz.title,
                  decoration: InputDecoration(
                    labelText: 'Título del Quiz',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.title),
                    counterText: '',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'^\s|')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  maxLength: 50,
                  validator: (value) {
                    final trimmedValue = value?.trim() ?? '';
                    if (trimmedValue.isEmpty) return 'Ingrese un título';
                    if (trimmedValue.length > 50) return 'Máximo 50 caracteres';
                    if (value!.contains('  ')) return 'No espacios dobles';
                    return null;
                  },
                  onChanged: (value) => _editedQuiz.title = value.trim(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:
                      _editedQuiz.questions.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                            itemCount: _editedQuiz.questions.length,
                            separatorBuilder:
                                (_, __) => const Divider(height: 20),
                            itemBuilder:
                                (context, index) => Card(
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    title: Text(
                                      _editedQuiz.questions[index].questionText,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    subtitle: Text(
                                      'Respuestas: ${_editedQuiz.questions[index].wrongAnswers.length + 1}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () => _editQuestion(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => _deleteQuestion(index),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _editQuestion(index),
                                  ),
                                ),
                          ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final newQuestion = await showDialog<Question>(
              context: context,
              builder:
                  (context) => EditQuestionDialog(
                    initialQuestion: Question(
                      questionText: 'Nueva pregunta',
                      correctAnswer: 'Respuesta correcta',
                      wrongAnswers: ['Opción 1', 'Opción 2'],
                    ),
                  ),
            );
            if (newQuestion != null) {
              setState(() => _editedQuiz.questions.add(newQuestion));
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No hay preguntas en este quiz\nPresiona el botón + para agregar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
