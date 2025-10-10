import 'dart:convert';
import 'package:http/http.dart' as http;

class TodoApi {
  static const _base = 'https://todoapp-api.apps.k8s.gu.se';

  Future<String> register() async {
    final r = await http.get(Uri.parse('$_base/register'));
    if (r.statusCode != 200) throw Exception('register failed ${r.statusCode}');
    return r.body.trim();
  }

  Future<List<Map<String, dynamic>>> list(String key) async {
    final r = await http.get(Uri.parse('$_base/todos?key=$key'));
    if (r.statusCode != 200) throw Exception('list failed ${r.statusCode}');
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }

  // POST returnerar HELA listan enligt docs
  Future<List<Map<String, dynamic>>> add(
    String key,
    Map<String, dynamic> body,
  ) async {
    final r = await http.post(
      Uri.parse('$_base/todos?key=$key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('add failed ${r.statusCode}');
    }
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }

  Future<void> update(String key, String id, Map<String, dynamic> body) async {
    final r = await http.put(
      Uri.parse('$_base/todos/$id?key=$key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('update failed ${r.statusCode}');
    }
  }

  Future<void> remove(String key, String id) async {
    final r = await http.delete(Uri.parse('$_base/todos/$id?key=$key'));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('delete failed ${r.statusCode}');
    }
  }
}
