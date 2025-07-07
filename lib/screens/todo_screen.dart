import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  Priority _selectedPriority = Priority.medium;
  bool _showCompleted = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    final todos = await TodoService.getTodos();
    setState(() {
      _todos = TodoService.sortTodosByDueDate(todos);
      _filteredTodos = _todos;
      _isLoading = false;
    });
  }

  void _filterTodos() {
    setState(() {
      _filteredTodos = _todos.where((todo) {
        if (!_showCompleted && todo.isCompleted) return false;
        return true;
      }).toList();
    });
  }

  Future<void> _addTodo() async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => AddTodoDialog(),
    );

    if (result != null) {
      await TodoService.addTodo(result);
      await _loadTodos();
    }
  }

  Future<void> _editTodo(Todo todo) async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => AddTodoDialog(todo: todo),
    );

    if (result != null) {
      await TodoService.updateTodo(result);
      await _loadTodos();
    }
  }

  Future<void> _deleteTodo(String todoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text('Delete Todo', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this todo?', style: TextStyle(color: Colors.grey[300])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red[400]),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TodoService.deleteTodo(todoId);
      await _loadTodos();
    }
  }

  Future<void> _toggleTodoCompletion(String todoId) async {
    await TodoService.toggleTodoCompletion(todoId);
    await _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
              ),
            )
          : Column(
              children: [
                _buildFilterSection(),
                Expanded(
                  child: _filteredTodos.isEmpty
                      ? _buildEmptyState()
                      : _buildTodoList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Colors.red[600],
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Todo',
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SwitchListTile(
              title: Text('Show Completed', style: TextStyle(color: Colors.white)),
              value: _showCompleted,
              onChanged: (value) {
                setState(() {
                  _showCompleted = value;
                  _filterTodos();
                });
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _showSortDialog(),
              icon: Icon(Icons.sort, color: Colors.red[400]),
              tooltip: 'Sort',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.task_alt, size: 64, color: Colors.red[400]),
          ),
          SizedBox(height: 16),
          Text(
            'No todos yet!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first todo',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredTodos.length,
      itemBuilder: (context, index) {
        final todo = _filteredTodos[index];
        return _buildTodoCard(todo);
      },
    );
  }

  Widget _buildTodoCard(Todo todo) {
    final isOverdue = todo.dueDate.isBefore(DateTime.now()) && !todo.isCompleted;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          decoration: BoxDecoration(
            color: todo.isCompleted ? Colors.green : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: todo.isCompleted ? Colors.green : Colors.grey[600]!,
              width: 2,
            ),
          ),
          child: Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => _toggleTodoCompletion(todo.id),
            activeColor: Colors.green,
            checkColor: Colors.white,
            side: BorderSide.none,
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  todo.description,
                  style: TextStyle(
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.red[400]),
                SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(todo.dueDate),
                  style: TextStyle(
                    color: isOverdue ? Colors.red[400] : Colors.grey[400],
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: todo.priority.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: todo.priority.color.withOpacity(0.5)),
                  ),
                  child: Text(
                    todo.priority.name,
                    style: TextStyle(
                      color: todo.priority.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[400]),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.red[400]),
                  SizedBox(width: 8),
                  Text('Edit', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red[400]),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red[400])),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editTodo(todo);
            } else if (value == 'delete') {
              _deleteTodo(todo.id);
            }
          },
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text('Sort Todos', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Due Date', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  _filteredTodos = TodoService.sortTodosByDueDate(_filteredTodos);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Priority', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  _filteredTodos.sort((a, b) => b.priority.index.compareTo(a.priority.index));
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Created Date', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  _filteredTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddTodoDialog extends StatefulWidget {
  final Todo? todo;

  const AddTodoDialog({Key? key, this.todo}) : super(key: key);

  @override
  _AddTodoDialogState createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Priority _selectedPriority = Priority.medium;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description;
      _selectedDate = widget.todo!.dueDate;
      _selectedPriority = widget.todo!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF1A1A1A),
      title: Text(
        widget.todo == null ? 'Add Todo' : 'Edit Todo',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[400]!),
                ),
              ),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[400]!),
                ),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Due Date', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: TextStyle(color: Colors.red[400]),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: DropdownButtonFormField<Priority>(
                      value: _selectedPriority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[400]!),
                        ),
                      ),
                      dropdownColor: Color(0xFF2A2A2A),
                      style: TextStyle(color: Colors.white),
                      items: Priority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: priority.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(priority.name, style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
        ),
        ElevatedButton(
          onPressed: _saveTodo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
          child: Text(widget.todo == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.red[400]!,
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF1A1A1A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final todo = Todo(
        id: widget.todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate,
        priority: _selectedPriority,
        createdAt: widget.todo?.createdAt ?? DateTime.now(),
      );
      Navigator.pop(context, todo);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
