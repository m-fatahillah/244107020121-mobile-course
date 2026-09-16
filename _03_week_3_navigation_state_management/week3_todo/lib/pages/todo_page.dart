import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodoListProvider);
    final currentFilter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(
                  value: TodoFilter.all,
                  label: Text('Semua'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: TodoFilter.active,
                  label: Text('Aktif'),
                  icon: Icon(Icons.radio_button_unchecked),
                ),
                ButtonSegment(
                  value: TodoFilter.completed,
                  label: Text('Selesai'),
                  icon: Icon(Icons.check_circle),
                ),
              ],
              selected: {currentFilter},
              onSelectionChanged: (Set<TodoFilter> newSelection) {
                ref.read(todoFilterProvider.notifier).setFilter(newSelection.first);
              },
            ),
          ),
        ),
      ),
      body: todos.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) => TodoTile(
                todo: todos[index],
                index: _getOriginalIndex(ref, todos[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Karena index dari filtered list bisa beda dengan original list, 
  // kita perlu mencari index asli untuk digunakan di fungsi toggle dan remove 
  // (meskipun cara lebih baik adalah Todo memiliki ID, tapi demi keep it simple 
  // kita sesuaikan index dengan list asli).
  int _getOriginalIndex(WidgetRef ref, Todo todo) {
    return ref.read(todoListProvider).indexOf(todo);
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(todoListProvider.notifier)
                    .add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}