import 'package:flutter/material.dart';
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
    if (_formKey.currentState!.validate() && _editedQuiz.questions.isNotEmpty) {
      QuizService.updateQuiz(widget.initialQuiz.id, _editedQuiz);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Quiz actualizado exitosamente')));
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
    setState(() => _editedQuiz.questions.removeAt(index));
  }

  Future<bool> _onWillPop() async {
    if (_editedQuiz == widget.initialQuiz) return true;
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('¿Descartar cambios?'),
                content: Text(
                  'Tienes cambios sin guardar. ¿Seguro que quieres salir?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Salir'),
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
          title: Text('Editar Quiz'),
          actions: [
            IconButton(icon: Icon(Icons.save), onPressed: _saveChanges),
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
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Ingrese un título' : null,
                  onChanged: (value) => _editedQuiz.title = value,
                ),
                SizedBox(height: 20),
                Expanded(
                  child:
                      _editedQuiz.questions.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                            itemCount: _editedQuiz.questions.length,
                            separatorBuilder: (_, __) => Divider(height: 20),
                            itemBuilder:
                                (context, index) => Card(
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
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
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () => _editQuestion(index),
                                        ),
                                        IconButton(
                                          icon: Icon(
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
          child: Icon(Icons.add),
          onPressed: () async {
            final newQuestion = await showDialog<Question>(
              context: context,
              builder:
                  (context) => EditQuestionDialog(
                    initialQuestion: Question(
                      questionText: '',
                      correctAnswer: '',
                      wrongAnswers: ['', ''],
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
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No hay preguntas en este quiz\nPresiona el botón + para agregar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
