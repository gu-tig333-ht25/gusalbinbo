class TodoItem {
  String? id;
  String text;
  bool done;

  TodoItem(this.text, {this.done = false, this.id});

  factory TodoItem.fromJson(Map<String, dynamic> j) => TodoItem(
    j['title'] as String,
    done: j['done'] as bool? ?? false,
    id: j['id']?.toString(),
  );

  Map<String, dynamic> toJson() => {'title': text, 'done': done};
}
