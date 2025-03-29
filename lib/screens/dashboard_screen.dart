import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../services/auth_service.dart';
import '../widgets/quiz_item.dart';
import '../screens/edit_quiz_screen.dart';
import 'create_quiz_screen.dart';
import 'quiz_screen.dart';
import '../models/quiz.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Quiz> _filteredQuizzes = [];

  @override
  void initState() {
    super.initState();
    _filterQuizzes();
  }

  void _refresh() {
    setState(() {
      _filterQuizzes();
    });
  }

  void _filterQuizzes() {
    _filteredQuizzes =
        QuizService.quizzes.where((quiz) {
          return quiz.title.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
  }

  Future<void> _confirmDelete(String quizId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Quiz'),
            content: const Text('¿Estás seguro de querer eliminar este quiz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      QuizService.deleteQuiz(quizId);
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz eliminado exitosamente')),
      );
    }
  }

  void _logout() {
    AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar quizzes...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _filterQuizzes();
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterQuizzes();
                });
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Quiz'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateQuizScreen()),
          );
          _refresh();
        },
      ),
      body:
          _filteredQuizzes.isEmpty
              ? _buildEmptyState()
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 2 : 1,
                    childAspectRatio: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _filteredQuizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = _filteredQuizzes[index];
                    return QuizItem(
                      quiz: quiz,
                      onEdit: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditQuizScreen(initialQuiz: quiz),
                          ),
                        );
                        if (result == true) _refresh();
                      },
                      onDelete: () => _confirmDelete(quiz.id),
                      onPlay:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(quizId: quiz.id),
                            ),
                          ),
                    );
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
          const Icon(Icons.quiz_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isEmpty
                ? 'No tienes ningún quiz creado\n¡Empieza creando uno nuevo!'
                : 'No se encontraron resultados para "${_searchQuery}"',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
