import 'package:flutter/material.dart';

class TimetableEntry {
  final String id;
  final String subject;
  final String teacher;
  final String room;
  final String day;
  final TimeSlot timeSlot;
  final Color color;

  TimetableEntry({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.day,
    required this.timeSlot,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'teacher': teacher,
      'room': room,
      'day': day,
      'timeSlot': timeSlot.toJson(),
      'color': color.value,
    };
  }

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'],
      subject: json['subject'],
      teacher: json['teacher'],
      room: json['room'],
      day: json['day'],
      timeSlot: TimeSlot.fromJson(json['timeSlot']),
      color: Color(json['color']),
    );
  }
}

class TimeSlot {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  TimeSlot({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  String get displayTime {
    return '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')} - ${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startHour: json['startHour'],
      startMinute: json['startMinute'],
      endHour: json['endHour'],
      endMinute: json['endMinute'],
    );
  }
} 