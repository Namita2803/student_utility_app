import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoService {
  static const String _todoKey = 'todos';
  
  static Future<List<Todo>> getTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList(_todoKey) ?? [];
    
    return todosJson
        .map((todoJson) => Todo.fromJson(jsonDecode(todoJson)))
        .toList();
  }

  static Future<void> addTodo(Todo todo) async {
    final prefs = await SharedPreferences.getInstance();
    final todos = await getTodos();
    todos.add(todo);
    
    final todosJson = todos
        .map((todo) => jsonEncode(todo.toJson()))
        .toList();
    
    await prefs.setStringList(_todoKey, todosJson);
  }

  static Future<void> updateTodo(Todo updatedTodo) async {
    final prefs = await SharedPreferences.getInstance();
    final todos = await getTodos();
    
    final index = todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      todos[index] = updatedTodo;
      
      final todosJson = todos
          .map((todo) => jsonEncode(todo.toJson()))
          .toList();
      
      await prefs.setStringList(_todoKey, todosJson);
    }
  }

  static Future<void> deleteTodo(String todoId) async {
    final prefs = await SharedPreferences.getInstance();
    final todos = await getTodos();
    
    todos.removeWhere((todo) => todo.id == todoId);
    
    final todosJson = todos
        .map((todo) => jsonEncode(todo.toJson()))
        .toList();
    
    await prefs.setStringList(_todoKey, todosJson);
  }

  static Future<void> toggleTodoCompletion(String todoId) async {
    final todos = await getTodos();
    final todo = todos.firstWhere((todo) => todo.id == todoId);
    
    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      dueDate: todo.dueDate,
      priority: todo.priority,
      isCompleted: !todo.isCompleted,
      createdAt: todo.createdAt,
    );
    
    await updateTodo(updatedTodo);
  }

  static List<Todo> filterTodosByPriority(List<Todo> todos, Priority priority) {
    return todos.where((todo) => todo.priority == priority).toList();
  }

  static List<Todo> filterTodosByCompletion(List<Todo> todos, bool isCompleted) {
    return todos.where((todo) => todo.isCompleted == isCompleted).toList();
  }

  static List<Todo> sortTodosByDueDate(List<Todo> todos) {
    final sortedTodos = List<Todo>.from(todos);
    sortedTodos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sortedTodos;
  }
} 