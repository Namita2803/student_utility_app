import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timetable.dart';

class TimetableService {
  static const String _timetableKey = 'timetable';
  
  static Future<List<TimetableEntry>> getTimetableEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList(_timetableKey) ?? [];
    
    return entriesJson
        .map((entryJson) => TimetableEntry.fromJson(jsonDecode(entryJson)))
        .toList();
  }

  static Future<void> addTimetableEntry(TimetableEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getTimetableEntries();
    entries.add(entry);
    
    final entriesJson = entries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    
    await prefs.setStringList(_timetableKey, entriesJson);
  }

  static Future<void> updateTimetableEntry(TimetableEntry updatedEntry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getTimetableEntries();
    
    final index = entries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (index != -1) {
      entries[index] = updatedEntry;
      
      final entriesJson = entries
          .map((entry) => jsonEncode(entry.toJson()))
          .toList();
      
      await prefs.setStringList(_timetableKey, entriesJson);
    }
  }

  static Future<void> deleteTimetableEntry(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getTimetableEntries();
    
    entries.removeWhere((entry) => entry.id == entryId);
    
    final entriesJson = entries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    
    await prefs.setStringList(_timetableKey, entriesJson);
  }

  static List<TimetableEntry> getEntriesByDay(List<TimetableEntry> entries, String day) {
    return entries.where((entry) => entry.day == day).toList();
  }

  static List<TimetableEntry> sortEntriesByTime(List<TimetableEntry> entries) {
    final sortedEntries = List<TimetableEntry>.from(entries);
    sortedEntries.sort((a, b) {
      final aStart = a.timeSlot.startHour * 60 + a.timeSlot.startMinute;
      final bStart = b.timeSlot.startHour * 60 + b.timeSlot.startMinute;
      return aStart.compareTo(bStart);
    });
    return sortedEntries;
  }

  static List<String> getAvailableDays() {
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  }

  static List<TimeSlot> getDefaultTimeSlots() {
    return [
      TimeSlot(startHour: 8, startMinute: 0, endHour: 9, endMinute: 0),
      TimeSlot(startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
      TimeSlot(startHour: 10, startMinute: 0, endHour: 11, endMinute: 0),
      TimeSlot(startHour: 11, startMinute: 0, endHour: 12, endMinute: 0),
      TimeSlot(startHour: 12, startMinute: 0, endHour: 13, endMinute: 0),
      TimeSlot(startHour: 14, startMinute: 0, endHour: 15, endMinute: 0),
      TimeSlot(startHour: 15, startMinute: 0, endHour: 16, endMinute: 0),
      TimeSlot(startHour: 16, startMinute: 0, endHour: 17, endMinute: 0),
    ];
  }
} 