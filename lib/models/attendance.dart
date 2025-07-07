class Attendance {
  final String id;
  final String subjectId;
  final String subjectName;
  final DateTime date;
  final bool isPresent;
  final String? remarks;

  Attendance({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    required this.isPresent,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'date': date.toIso8601String(),
      'isPresent': isPresent,
      'remarks': remarks,
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      date: DateTime.parse(json['date']),
      isPresent: json['isPresent'],
      remarks: json['remarks'],
    );
  }
}

class SubjectAttendance {
  final String subjectId;
  final String subjectName;
  final int totalClasses;
  final int presentClasses;
  final double attendancePercentage;

  SubjectAttendance({
    required this.subjectId,
    required this.subjectName,
    required this.totalClasses,
    required this.presentClasses,
    required this.attendancePercentage,
  });

  String get attendanceStatus {
    if (attendancePercentage >= 75) {
      return 'Good';
    } else if (attendancePercentage >= 60) {
      return 'Warning';
    } else {
      return 'Critical';
    }
  }
} 