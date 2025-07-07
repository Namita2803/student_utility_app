import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grades.dart';

class GradesService {
  static const String _gradesKey = 'grades';
  static const String _subjectsKey = 'subjects';
  
  static Future<List<Grade>> getGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final gradesJson = prefs.getStringList(_gradesKey) ?? [];
    
    return gradesJson
        .map((gradeJson) => Grade.fromJson(jsonDecode(gradeJson)))
        .toList();
  }

  static Future<void> addGrade(Grade grade) async {
    final prefs = await SharedPreferences.getInstance();
    final grades = await getGrades();
    grades.add(grade);
    
    final gradesJson = grades
        .map((grade) => jsonEncode(grade.toJson()))
        .toList();
    
    await prefs.setStringList(_gradesKey, gradesJson);
  }

  static Future<void> updateGrade(Grade updatedGrade) async {
    final prefs = await SharedPreferences.getInstance();
    final grades = await getGrades();
    
    final index = grades.indexWhere((grade) => grade.id == updatedGrade.id);
    if (index != -1) {
      grades[index] = updatedGrade;
      
      final gradesJson = grades
          .map((grade) => jsonEncode(grade.toJson()))
          .toList();
      
      await prefs.setStringList(_gradesKey, gradesJson);
    }
  }

  static Future<void> deleteGrade(String gradeId) async {
    final prefs = await SharedPreferences.getInstance();
    final grades = await getGrades();
    
    grades.removeWhere((grade) => grade.id == gradeId);
    
    final gradesJson = grades
        .map((grade) => jsonEncode(grade.toJson()))
        .toList();
    
    await prefs.setStringList(_gradesKey, gradesJson);
  }

  static Future<List<Subject>> getSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = prefs.getStringList(_subjectsKey) ?? [];
    
    return subjectsJson
        .map((subjectJson) => Subject.fromJson(jsonDecode(subjectJson)))
        .toList();
  }

  static Future<void> addSubject(Subject subject) async {
    final prefs = await SharedPreferences.getInstance();
    final subjects = await getSubjects();
    subjects.add(subject);
    
    final subjectsJson = subjects
        .map((subject) => jsonEncode(subject.toJson()))
        .toList();
    
    await prefs.setStringList(_subjectsKey, subjectsJson);
  }

  static List<Grade> getGradesBySemester(List<Grade> grades, String semester) {
    return grades.where((grade) => grade.semester == semester).toList();
  }

  static SemesterResult calculateSemesterResult(List<Grade> grades, String semester) {
    final semesterGrades = getGradesBySemester(grades, semester);
    
    if (semesterGrades.isEmpty) {
      return SemesterResult(
        semester: semester,
        grades: [],
        sgpa: 0.0,
        totalCredits: 0,
      );
    }

    final totalGradePoints = semesterGrades.fold(0.0, (sum, grade) => sum + (grade.gradePoints * grade.credits));
    final totalCredits = semesterGrades.fold(0, (sum, grade) => sum + grade.credits);
    final sgpa = totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;

    return SemesterResult(
      semester: semester,
      grades: semesterGrades,
      sgpa: sgpa,
      totalCredits: totalCredits,
    );
  }

  static AcademicRecord calculateAcademicRecord(List<Grade> grades) {
    final semesters = grades.map((grade) => grade.semester).toSet().toList();
    final semesterResults = semesters.map((semester) => calculateSemesterResult(grades, semester)).toList();
    
    final totalGradePoints = semesterResults.fold(0.0, (sum, semester) => sum + semester.totalGradePoints);
    final totalCredits = semesterResults.fold(0, (sum, semester) => sum + semester.totalCredits);
    final cgpa = totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;

    return AcademicRecord(
      semesterResults: semesterResults,
      cgpa: cgpa,
      totalCredits: totalCredits,
    );
  }

  static String calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C+';
    if (percentage >= 40) return 'C';
    return 'F';
  }

  static double calculateGradePoints(String grade) {
    switch (grade) {
      case 'A+': return 4.0;
      case 'A': return 3.7;
      case 'B+': return 3.3;
      case 'B': return 3.0;
      case 'C+': return 2.3;
      case 'C': return 2.0;
      case 'F': return 0.0;
      default: return 0.0;
    }
  }
} 