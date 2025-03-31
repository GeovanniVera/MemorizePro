import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizItem extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPlay;

  const QuizItem({
    super.key,
    required this.quiz,
    required this.onEdit,
    required this.onDelete,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onPlay,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenido principal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${quiz.questions.length} pregunta${quiz.questions.length != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              
              // Espaciado y división visual
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              
              // Botones en fila
              _buildButtonRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Jugar'),
            onPressed: onPlay,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.edit, size: 20),
            label: const Text('Editar'),
            onPressed: onEdit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: onDelete,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}