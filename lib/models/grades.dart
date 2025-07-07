class Subject {
  final String id;
  final String name;
  final String code;
  final int credits;
  final String semester;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.credits,
    required this.semester,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'credits': credits,
      'semester': semester,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      credits: json['credits'],
      semester: json['semester'],
    );
  }
}

class Grade {
  final String id;
  final String subjectId;
  final String subjectName;
  final String semester;
  final double marks;
  final double maxMarks;
  final String grade;
  final double gradePoints;
  final int credits;

  Grade({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.semester,
    required this.marks,
    required this.maxMarks,
    required this.grade,
    required this.gradePoints,
    required this.credits,
  });

  double get percentage => (marks / maxMarks) * 100;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'semester': semester,
      'marks': marks,
      'maxMarks': maxMarks,
      'grade': grade,
      'gradePoints': gradePoints,
      'credits': credits,
    };
  }

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      semester: json['semester'],
      marks: json['marks'].toDouble(),
      maxMarks: json['maxMarks'].toDouble(),
      grade: json['grade'],
      gradePoints: json['gradePoints'].toDouble(),
      credits: json['credits'],
    );
  }
}

class SemesterResult {
  final String semester;
  final List<Grade> grades;
  final double sgpa;
  final int totalCredits;

  SemesterResult({
    required this.semester,
    required this.grades,
    required this.sgpa,
    required this.totalCredits,
  });

  double get totalGradePoints {
    return grades.fold(0.0, (sum, grade) => sum + (grade.gradePoints * grade.credits));
  }
}

class AcademicRecord {
  final List<SemesterResult> semesterResults;
  final double cgpa;
  final int totalCredits;

  AcademicRecord({
    required this.semesterResults,
    required this.cgpa,
    required this.totalCredits,
  });

  double get totalGradePoints {
    return semesterResults.fold(0.0, (sum, semester) => sum + semester.totalGradePoints);
  }
} 