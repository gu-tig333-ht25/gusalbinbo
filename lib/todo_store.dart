import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo_api.dart';
import 'todo_item.dart';

enum TodoFilter { all, done, notDone }

class TodoStore extends ChangeNotifier {
  final TodoApi api;
  TodoStore(this.api);

  final List<TodoItem> _items = [];
  final List<TodoItem> _history = [];
  String? _key;
  bool _loading = true;
  String? _error;

  TodoFilter _filter = TodoFilter.all;
  TodoFilter get filter => _filter;

  List<TodoItem> get items => List.unmodifiable(_items);
  List<TodoItem> get history => List.unmodifiable(_history);
  bool get hasHistory => _history.isNotEmpty;
  bool get loading => _loading;
  String? get error => _error;

  List<TodoItem> get visibleItems {
    switch (_filter) {
      case TodoFilter.done:
        return _items.where((t) => t.done).toList();
      case TodoFilter.notDone:
        return _items.where((t) => !t.done).toList();
      case TodoFilter.all:
      default:
        return List.unmodifiable(_items);
    }
  }

  void setFilter(TodoFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

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
    final previousValue = t.done;

    try {
      final updated = TodoItem(t.text, id: t.id, done: value);

      await api.update(_key!, t.id!, updated.toJson());

      t.done = value;
      notifyListeners();
    } catch (e) {
      t.done = previousValue;
      _error = 'Kunde inte uppdatera servern: $e';
      notifyListeners();
    }
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) return;

    final todo = _items[index];

    try {
      if (todo.id != null) {
        await api.remove(_key!, todo.id!);
      }

      final removed = _items.removeAt(index);
      _history.insert(0, removed);
    } catch (e) {
      _error = 'Kunde inte ta bort från servern: $e';
    } finally {
      notifyListeners();
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
