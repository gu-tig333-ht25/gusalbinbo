import 'package:flutter/foundation.dart';
import 'todo_api.dart';
import 'todo_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoStore extends ChangeNotifier {
  final TodoApi api;
  TodoStore(this.api);

  final List<TodoItem> _items = [];
  final List<TodoItem> _history = [];
  String? _key;
  bool _loading = true;
  String? _error;

  List<TodoItem> get items => List.unmodifiable(_items);
  List<TodoItem> get history => List.unmodifiable(_history);
  bool get hasHistory => _history.isNotEmpty;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> init() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final sp = await SharedPreferences.getInstance();
      _key = sp.getString('todo_key') ?? await api.register();
      await sp.setString('todo_key', _key!);
      await refresh();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final raw = await api.list(_key!);
    _items
      ..clear()
      ..addAll(raw.map(TodoItem.fromJson));
    notifyListeners();
  }

  Future<void> add(String text) async {
    final raw = await api.add(_key!, TodoItem(text).toJson());
    _items
      ..clear()
      ..addAll(raw.map(TodoItem.fromJson));
    notifyListeners();
  }

  Future<void> toggle(int index, bool value) async {
    final t = _items[index];
    t.done = value;
    notifyListeners();
    await api.update(_key!, t.id!, t.toJson());
  }

  Future<void> removeAt(int index) async {
    final removed = _items.removeAt(index);
    _history.insert(0, removed);
    notifyListeners();
    if (removed.id != null) {
      await api.remove(_key!, removed.id!);
    }
  }

  Future<void> restore(TodoItem item) async {
    _history.remove(item);
    notifyListeners();
    await add(item.text);
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
