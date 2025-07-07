import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance.dart';

class AttendanceService {
  static const String _attendanceKey = 'attendance';
  
  static Future<List<Attendance>> getAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList(_attendanceKey) ?? [];
    
    return recordsJson
        .map((recordJson) => Attendance.fromJson(jsonDecode(recordJson)))
        .toList();
  }

  static Future<void> addAttendanceRecord(Attendance record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getAttendanceRecords();
    records.add(record);
    
    final recordsJson = records
        .map((record) => jsonEncode(record.toJson()))
        .toList();
    
    await prefs.setStringList(_attendanceKey, recordsJson);
  }

  static Future<void> updateAttendanceRecord(Attendance updatedRecord) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getAttendanceRecords();
    
    final index = records.indexWhere((record) => record.id == updatedRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      
      final recordsJson = records
          .map((record) => jsonEncode(record.toJson()))
          .toList();
      
      await prefs.setStringList(_attendanceKey, recordsJson);
    }
  }

  static Future<void> deleteAttendanceRecord(String recordId) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getAttendanceRecords();
    
    records.removeWhere((record) => record.id == recordId);
    
    final recordsJson = records
        .map((record) => jsonEncode(record.toJson()))
        .toList();
    
    await prefs.setStringList(_attendanceKey, recordsJson);
  }

  static List<Attendance> getRecordsBySubject(List<Attendance> records, String subjectId) {
    return records.where((record) => record.subjectId == subjectId).toList();
  }

  static List<Attendance> getRecordsByDate(List<Attendance> records, DateTime date) {
    return records.where((record) => 
      record.date.year == date.year &&
      record.date.month == date.month &&
      record.date.day == date.day
    ).toList();
  }

  static SubjectAttendance calculateSubjectAttendance(List<Attendance> records, String subjectId, String subjectName) {
    final subjectRecords = getRecordsBySubject(records, subjectId);
    final totalClasses = subjectRecords.length;
    final presentClasses = subjectRecords.where((record) => record.isPresent).length;
    final attendancePercentage = totalClasses > 0 ? (presentClasses / totalClasses) * 100 : 0.0;

    return SubjectAttendance(
      subjectId: subjectId,
      subjectName: subjectName,
      totalClasses: totalClasses,
      presentClasses: presentClasses,
      attendancePercentage: attendancePercentage,
    );
  }

  static List<SubjectAttendance> calculateAllSubjectAttendance(List<Attendance> records) {
    final subjectIds = records.map((record) => record.subjectId).toSet();
    final subjectNames = <String, String>{};
    
    for (final record in records) {
      subjectNames[record.subjectId] = record.subjectName;
    }

    return subjectIds.map((subjectId) {
      final subjectName = subjectNames[subjectId] ?? 'Unknown Subject';
      return calculateSubjectAttendance(records, subjectId, subjectName);
    }).toList();
  }

  static double calculateOverallAttendance(List<Attendance> records) {
    if (records.isEmpty) return 0.0;
    
    final totalClasses = records.length;
    final presentClasses = records.where((record) => record.isPresent).length;
    
    return (presentClasses / totalClasses) * 100;
  }
} 