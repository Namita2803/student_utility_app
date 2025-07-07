import 'package:flutter/material.dart';
import '../models/timetable.dart';
import '../services/timetable_service.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<TimetableEntry> _entries = [];
  List<TimetableEntry> _filteredEntries = [];
  String _selectedDay = 'Monday';
  bool _isLoading = true;

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<TimeSlot> _timeSlots = TimetableService.getDefaultTimeSlots();

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    setState(() => _isLoading = true);
    final entries = await TimetableService.getTimetableEntries();
    setState(() {
      _entries = TimetableService.sortEntriesByTime(entries);
      _filteredEntries = TimetableService.getEntriesByDay(_entries, _selectedDay);
      _isLoading = false;
    });
  }

  void _filterByDay(String day) {
    setState(() {
      _selectedDay = day;
      _filteredEntries = TimetableService.getEntriesByDay(_entries, day);
    });
  }

  Future<void> _addEntry() async {
    final result = await showDialog<TimetableEntry>(
      context: context,
      builder: (context) => AddTimetableEntryDialog(),
    );

    if (result != null) {
      await TimetableService.addTimetableEntry(result);
      await _loadTimetable();
    }
  }

  Future<void> _editEntry(TimetableEntry entry) async {
    final result = await showDialog<TimetableEntry>(
      context: context,
      builder: (context) => AddTimetableEntryDialog(entry: entry),
    );

    if (result != null) {
      await TimetableService.updateTimetableEntry(result);
      await _loadTimetable();
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text('Delete Class', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this class?', style: TextStyle(color: Colors.grey[300])),
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
      await TimetableService.deleteTimetableEntry(entryId);
      await _loadTimetable();
    }
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
                _buildDaySelector(),
                Expanded(
                  child: _filteredEntries.isEmpty
                      ? _buildEmptyState()
                      : _buildTimetableGrid(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        backgroundColor: Colors.red[600],
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Class',
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          final isSelected = day == _selectedDay;
          
          return Container(
            margin: EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                day,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.red[600],
              backgroundColor: Color(0xFF2A2A2A),
              onSelected: (selected) {
                if (selected) {
                  _filterByDay(day);
                }
              },
            ),
          );
        },
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
            child: Icon(Icons.schedule, size: 64, color: Colors.red[400]),
          ),
          SizedBox(height: 16),
          Text(
            'No classes scheduled for $_selectedDay',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first class',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableGrid() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = _timeSlots[index];
        final entriesForSlot = _filteredEntries.where((entry) =>
          entry.timeSlot.startHour == timeSlot.startHour &&
          entry.timeSlot.startMinute == timeSlot.startMinute
        ).toList();

        return _buildTimeSlotRow(timeSlot, entriesForSlot);
      },
    );
  }

  Widget _buildTimeSlotRow(TimeSlot timeSlot, List<TimetableEntry> entries) {
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
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              child: Text(
                timeSlot.displayTime,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.red[400],
                ),
              ),
            ),
            Expanded(
              child: entries.isEmpty
                  ? Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: Center(
                        child: Text(
                          'Free',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  : Column(
                      children: entries.map((entry) => _buildClassCard(entry)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(TimetableEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: entry.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: entry.color.withOpacity(0.3)),
      ),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.subject,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                PopupMenuButton(
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
                      _editEntry(entry);
                    } else if (value == 'delete') {
                      _deleteEntry(entry.id);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              entry.teacher,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
            Text(
              'Room: ${entry.room}',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTimetableEntryDialog extends StatefulWidget {
  final TimetableEntry? entry;

  const AddTimetableEntryDialog({Key? key, this.entry}) : super(key: key);

  @override
  _AddTimetableEntryDialogState createState() => _AddTimetableEntryDialogState();
}

class _AddTimetableEntryDialogState extends State<AddTimetableEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _teacherController = TextEditingController();
  final _roomController = TextEditingController();
  
  String _selectedDay = 'Monday';
  late List<TimeSlot> _timeSlots;
  late TimeSlot _selectedTimeSlot;
  Color _selectedColor = Colors.red;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _timeSlots = TimetableService.getDefaultTimeSlots();
    if (widget.entry != null) {
      _subjectController.text = widget.entry!.subject;
      _teacherController.text = widget.entry!.teacher;
      _roomController.text = widget.entry!.room;
      _selectedDay = widget.entry!.day;
      _selectedTimeSlot = _timeSlots.firstWhere(
        (slot) => slot.displayTime == widget.entry!.timeSlot.displayTime,
        orElse: () => _timeSlots.first,
      );
      _selectedColor = widget.entry!.color;
    } else {
      _selectedTimeSlot = _timeSlots.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF1A1A1A),
      title: Text(
        widget.entry == null ? 'Add Class' : 'Edit Class',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
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
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _teacherController,
                decoration: InputDecoration(
                  labelText: 'Teacher',
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
                    return 'Please enter a teacher';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: InputDecoration(
                  labelText: 'Room',
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
                    return 'Please enter a room';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedDay,
                  decoration: InputDecoration(
                    labelText: 'Day',
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
                  items: TimetableService.getAvailableDays().map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: DropdownButtonFormField<TimeSlot>(
                  value: _selectedTimeSlot,
                  decoration: InputDecoration(
                    labelText: 'Time Slot',
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
                  items: _timeSlots.map((timeSlot) {
                    return DropdownMenuItem(
                      value: timeSlot,
                      child: Text(timeSlot.displayTime, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeSlot = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              Text('Color', style: TextStyle(color: Colors.white)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
        ),
        ElevatedButton(
          onPressed: _saveEntry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
          child: Text(widget.entry == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final entry = TimetableEntry(
        id: widget.entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        subject: _subjectController.text,
        teacher: _teacherController.text,
        room: _roomController.text,
        day: _selectedDay,
        timeSlot: _selectedTimeSlot,
        color: _selectedColor,
      );
      Navigator.pop(context, entry);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    super.dispose();
  }
}
