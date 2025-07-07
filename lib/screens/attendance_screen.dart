import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Attendance> _attendanceRecords = [];
  List<SubjectAttendance> _subjectAttendances = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);
    final records = await AttendanceService.getAttendanceRecords();
    setState(() {
      _attendanceRecords = records;
      _subjectAttendances = AttendanceService.calculateAllSubjectAttendance(records);
      _isLoading = false;
    });
  }

  Future<void> _addAttendanceRecord() async {
    final result = await showDialog<Attendance>(
      context: context,
      builder: (context) => AddAttendanceDialog(selectedDate: _selectedDate),
    );

    if (result != null) {
      await AttendanceService.addAttendanceRecord(result);
      await _loadAttendanceData();
    }
  }

  Future<void> _editAttendanceRecord(Attendance record) async {
    final result = await showDialog<Attendance>(
      context: context,
      builder: (context) => AddAttendanceDialog(attendance: record),
    );

    if (result != null) {
      await AttendanceService.updateAttendanceRecord(result);
      await _loadAttendanceData();
    }
  }

  List<Attendance> _getRecordsForDate(DateTime date) {
    return AttendanceService.getRecordsByDate(_attendanceRecords, date);
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
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildDateSelector(),
                  _buildAttendanceList(),
                  _buildSubjectAttendanceSummary(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAttendanceRecord,
        backgroundColor: Colors.red[600],
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Attendance',
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.red[400]),
                  SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _selectDate(context),
              icon: Icon(Icons.edit, color: Colors.red[400]),
              tooltip: 'Change Date',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
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

  Widget _buildAttendanceList() {
    final recordsForSelectedDate = _getRecordsForDate(_selectedDate);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${recordsForSelectedDate.length} records',
                style: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          recordsForSelectedDate.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: recordsForSelectedDate.map((record) {
                    return _buildAttendanceCard(record);
                  }).toList(),
                ),
        ],
      ),
    );
  }



  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_note, size: 64, color: Colors.red[400]),
          ),
          SizedBox(height: 16),
          Text(
            'No attendance records for this date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add attendance',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }



  Widget _buildAttendanceCard(Attendance record) {
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
        leading: CircleAvatar(
          backgroundColor: record.isPresent ? Colors.green : Colors.red,
          child: Icon(
            record.isPresent ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          record.subjectName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              record.isPresent ? 'Present' : 'Absent',
              style: TextStyle(
                color: record.isPresent ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (record.remarks != null && record.remarks!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Remarks: ${record.remarks}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
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
              _editAttendanceRecord(record);
            } else if (value == 'delete') {
              _deleteAttendanceRecord(record.id);
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteAttendanceRecord(String recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text('Delete Attendance Record', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this attendance record?', style: TextStyle(color: Colors.grey[300])),
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
      await AttendanceService.deleteAttendanceRecord(recordId);
      await _loadAttendanceData();
    }
  }

  Widget _buildSubjectAttendanceSummary() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject-wise Attendance Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            _subjectAttendances.isEmpty
                ? Center(
                    child: Text(
                      'No attendance data available',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  )
                : Column(
                    children: _subjectAttendances.map((attendance) {
                      return _buildSubjectAttendanceCard(attendance);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectAttendanceCard(SubjectAttendance attendance) {
    Color statusColor;
    switch (attendance.attendanceStatus) {
      case 'Good':
        statusColor = Colors.green[400]!;
        break;
      case 'Warning':
        statusColor = Colors.orange[400]!;
        break;
      case 'Critical':
        statusColor = Colors.red[400]!;
        break;
      default:
        statusColor = Colors.grey[400]!;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.subjectName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${attendance.presentClasses}/${attendance.totalClasses} classes',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${attendance.attendancePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: statusColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  attendance.attendanceStatus,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddAttendanceDialog extends StatefulWidget {
  final DateTime? selectedDate;
  final Attendance? attendance;

  const AddAttendanceDialog({
    Key? key,
    this.selectedDate,
    this.attendance,
  }) : super(key: key);

  @override
  _AddAttendanceDialogState createState() => _AddAttendanceDialogState();
}

class _AddAttendanceDialogState extends State<AddAttendanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _remarksController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isPresent = true;

  @override
  void initState() {
    super.initState();
    if (widget.attendance != null) {
      _subjectController.text = widget.attendance!.subjectName;
      _remarksController.text = widget.attendance!.remarks ?? '';
      _selectedDate = widget.attendance!.date;
      _isPresent = widget.attendance!.isPresent;
    } else if (widget.selectedDate != null) {
      _selectedDate = widget.selectedDate!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF1A1A1A),
      title: Text(
        widget.attendance == null ? 'Add Attendance' : 'Edit Attendance',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
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
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Date', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: TextStyle(color: Colors.red[400]),
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.red[400]),
                onTap: () => _selectDate(context),
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: SwitchListTile(
                title: Text('Present', style: TextStyle(color: Colors.white)),
                value: _isPresent,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    _isPresent = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _remarksController,
              decoration: InputDecoration(
                labelText: 'Remarks (optional)',
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
        ),
        ElevatedButton(
          onPressed: _saveAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
          child: Text(widget.attendance == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
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

  void _saveAttendance() {
    if (_formKey.currentState!.validate()) {
      final attendance = Attendance(
        id: widget.attendance?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        subjectId: widget.attendance?.subjectId ?? 'subject_${DateTime.now().millisecondsSinceEpoch}',
        subjectName: _subjectController.text,
        date: _selectedDate,
        isPresent: _isPresent,
        remarks: _remarksController.text.isEmpty ? null : _remarksController.text,
      );
      Navigator.pop(context, attendance);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
} 