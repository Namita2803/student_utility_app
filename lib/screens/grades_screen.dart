import 'package:flutter/material.dart';
import '../models/grades.dart';
import '../services/grades_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({Key? key}) : super(key: key);

  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<Grade> _grades = [];
  List<Subject> _subjects = [];
  AcademicRecord? _academicRecord;
  String _selectedSemester = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGradesData();
  }

  Future<void> _loadGradesData() async {
    setState(() => _isLoading = true);
    final grades = await GradesService.getGrades();
    final subjects = await GradesService.getSubjects();
    
    setState(() {
      _grades = grades;
      _subjects = subjects;
      _academicRecord = GradesService.calculateAcademicRecord(grades);
      _isLoading = false;
    });
  }

  Future<void> _addSubject() async {
    final result = await showDialog<Subject>(
      context: context,
      builder: (context) => AddSubjectDialog(),
    );

    if (result != null) {
      await GradesService.addSubject(result);
      await _loadGradesData();
    }
  }

  Future<void> _addGrade() async {
    final result = await showDialog<Grade>(
      context: context,
      builder: (context) => AddGradeDialog(subjects: _subjects),
    );

    if (result != null) {
      await GradesService.addGrade(result);
      await _loadGradesData();
    }
  }

  Future<void> _editGrade(Grade grade) async {
    final result = await showDialog<Grade>(
      context: context,
      builder: (context) => AddGradeDialog(subjects: _subjects, grade: grade),
    );

    if (result != null) {
      await GradesService.updateGrade(result);
      await _loadGradesData();
    }
  }

  Future<void> _deleteGrade(String gradeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Grade'),
        content: Text('Are you sure you want to delete this grade?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await GradesService.deleteGrade(gradeId);
      await _loadGradesData();
    }
  }

  List<Grade> _getFilteredGrades() {
    if (_selectedSemester == 'All') {
      return _grades;
    }
    return _grades.where((grade) => grade.semester == _selectedSemester).toList();
  }

  List<String> _getAvailableSemesters() {
    final semesters = _grades.map((grade) => grade.semester).toSet().toList();
    semesters.sort();
    return ['All', ...semesters];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildAcademicSummary(),
                _buildFilterSection(),
                Expanded(
                  child: _buildGradesList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGrade,
        child: Icon(Icons.add),
        tooltip: 'Add Grade',
      ),
    );
  }

  Widget _buildAcademicSummary() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'CGPA',
                    _academicRecord?.cgpa.toStringAsFixed(2) ?? '0.00',
                    Icons.school,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Credits',
                    _academicRecord?.totalCredits.toString() ?? '0',
                    Icons.credit_card,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Semesters',
                    _academicRecord?.semesterResults.length.toString() ?? '0',
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Subjects',
                    _subjects.length.toString(),
                    Icons.book,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSemester,
              decoration: InputDecoration(
                labelText: 'Filter by Semester',
                border: OutlineInputBorder(),
              ),
              items: _getAvailableSemesters().map((semester) {
                return DropdownMenuItem(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value!;
                });
              },
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _addSubject,
            icon: Icon(Icons.add),
            label: Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesList() {
    final filteredGrades = _getFilteredGrades();
    
    if (filteredGrades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No grades found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Add subjects and grades to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredGrades.length,
      itemBuilder: (context, index) {
        final grade = filteredGrades[index];
        return _buildGradeCard(grade);
      },
    );
  }

  Widget _buildGradeCard(Grade grade) {
    final subject = _subjects.firstWhere(
      (s) => s.id == grade.subjectId,
      orElse: () => Subject(
        id: grade.subjectId,
        name: grade.subjectName,
        code: '',
        credits: grade.credits,
        semester: grade.semester,
      ),
    );

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getGradeColor(grade.grade),
          child: Text(
            grade.grade,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          grade.subjectName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Semester: ${grade.semester}'),
            Text('Marks: ${grade.marks}/${grade.maxMarks} (${grade.percentage.toStringAsFixed(1)}%)'),
            Text('Credits: ${grade.credits} • Grade Points: ${grade.gradePoints}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editGrade(grade);
            } else if (value == 'delete') {
              _deleteGrade(grade.id);
            }
          },
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class AddSubjectDialog extends StatefulWidget {
  const AddSubjectDialog({Key? key}) : super(key: key);

  @override
  _AddSubjectDialogState createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _creditsController = TextEditingController();
  final _semesterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Subject'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter subject name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Subject Code',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter subject code';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _creditsController,
              decoration: InputDecoration(
                labelText: 'Credits',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter credits';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _semesterController,
              decoration: InputDecoration(
                labelText: 'Semester',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter semester';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSubject,
          child: Text('Add'),
        ),
      ],
    );
  }

  void _saveSubject() {
    if (_formKey.currentState!.validate()) {
      final subject = Subject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        code: _codeController.text,
        credits: int.parse(_creditsController.text),
        semester: _semesterController.text,
      );
      Navigator.pop(context, subject);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    _semesterController.dispose();
    super.dispose();
  }
}

class AddGradeDialog extends StatefulWidget {
  final List<Subject> subjects;
  final Grade? grade;

  const AddGradeDialog({
    Key? key,
    required this.subjects,
    this.grade,
  }) : super(key: key);

  @override
  _AddGradeDialogState createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends State<AddGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _marksController = TextEditingController();
  final _maxMarksController = TextEditingController();
  
  Subject? _selectedSubject;
  String _selectedSemester = '';
  double _marks = 0.0;
  double _maxMarks = 100.0;

  @override
  void initState() {
    super.initState();
    if (widget.grade != null) {
      _selectedSubject = widget.subjects.firstWhere(
        (s) => s.id == widget.grade!.subjectId,
        orElse: () => Subject(
          id: widget.grade!.subjectId,
          name: widget.grade!.subjectName,
          code: '',
          credits: widget.grade!.credits,
          semester: widget.grade!.semester,
        ),
      );
      _selectedSemester = widget.grade!.semester;
      _marks = widget.grade!.marks;
      _maxMarks = widget.grade!.maxMarks;
      _marksController.text = _marks.toString();
      _maxMarksController.text = _maxMarks.toString();
    } else {
      _selectedSemester = widget.subjects.isNotEmpty ? widget.subjects.first.semester : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.grade == null ? 'Add Grade' : 'Edit Grade'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Subject>(
              value: _selectedSubject,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              items: widget.subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                  if (value != null) {
                    _selectedSemester = value.semester;
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a subject';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _marksController,
              decoration: InputDecoration(
                labelText: 'Marks Obtained',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _marks = double.tryParse(value) ?? 0.0;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter marks';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _maxMarksController,
              decoration: InputDecoration(
                labelText: 'Maximum Marks',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _maxMarks = double.tryParse(value) ?? 100.0;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter maximum marks';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Semester',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              controller: TextEditingController(text: _selectedSemester),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Grade Calculation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Percentage: ${_calculatePercentage().toStringAsFixed(1)}%'),
                  Text('Grade: ${_calculateGrade()}'),
                  Text('Grade Points: ${_calculateGradePoints().toStringAsFixed(1)}'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveGrade,
          child: Text(widget.grade == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  double _calculatePercentage() {
    if (_maxMarks == 0) return 0.0;
    return (_marks / _maxMarks) * 100;
  }

  String _calculateGrade() {
    final percentage = _calculatePercentage();
    return GradesService.calculateGrade(percentage);
  }

  double _calculateGradePoints() {
    return GradesService.calculateGradePoints(_calculateGrade());
  }

  void _saveGrade() {
    if (_formKey.currentState!.validate() && _selectedSubject != null) {
      final grade = Grade(
        id: widget.grade?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        subjectId: _selectedSubject!.id,
        subjectName: _selectedSubject!.name,
        semester: _selectedSemester,
        marks: _marks,
        maxMarks: _maxMarks,
        grade: _calculateGrade(),
        gradePoints: _calculateGradePoints(),
        credits: _selectedSubject!.credits,
      );
      Navigator.pop(context, grade);
    }
  }

  @override
  void dispose() {
    _marksController.dispose();
    _maxMarksController.dispose();
    super.dispose();
  }
} 