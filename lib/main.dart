import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todo_api.dart';
import 'todo_store.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoStore(TodoApi())..init(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Shoppinglista', home: MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  TextStyle _itemTextStyle(bool done) => TextStyle(
    decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
    color: done ? Colors.grey : null,
  );

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TodoStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TIG333 TODO List'),
        backgroundColor: const Color.fromARGB(255, 207, 204, 204),
      ),
      body: store.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: store.items.length,
              itemBuilder: (context, index) {
                final item = store.items[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Checkbox(
                        value: item.done,
                        onChanged: (v) =>
                            context.read<TodoStore>().toggle(index, v ?? false),
                      ),
                      title: Text(item.text, style: _itemTextStyle(item.done)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Ta bort (hamnar i historik)',
                        onPressed: () =>
                            context.read<TodoStore>().removeAt(index),
                      ),
                    ),
                    const Divider(
                      height: 0,
                      thickness: 1,
                      indent: 72,
                      endIndent: 16,
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemPage()),
        ),
      ),
    );
  }
}

class AddItemPage extends StatelessWidget {
  const AddItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    void submit() {
      final t = controller.text.trim();
      if (t.isEmpty) return;
      context.read<TodoStore>().add(t);
      controller.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Items To Your List')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onSubmitted: (_) => submit(),
              decoration: const InputDecoration(
                hintText: 'What are you going to do?',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
              ),
              cursorColor: Colors.black,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: submit,
                child: Text(
                  '+ ADD',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//final