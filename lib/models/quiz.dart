import 'question.dart';

class Quiz {
  final String id;
  String title;
  List<Question> questions;
  final String createdBy;
  final DateTime createdAt;
  DateTime updatedAt; // Campo requerido

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    required this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Quiz copyWith({
    String? id,
    String? title,
    List<Question>? questions,
    String? createdBy,
    DateTime? updatedAt, // Parámetro nuevo
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      questions: questions ?? List.from(this.questions),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt, // Mantener el original
      updatedAt: updatedAt ?? DateTime.now(), // Actualizar automáticamente
    );
  }
}
