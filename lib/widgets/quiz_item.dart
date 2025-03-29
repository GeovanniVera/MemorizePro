import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizItem extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPlay;

  const QuizItem({
    required this.quiz,
    required this.onEdit,
    required this.onDelete,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onPlay, // Agregar este gesto de tap
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${quiz.questions.length} preguntas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: onPlay, // Botón de play adicional
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
