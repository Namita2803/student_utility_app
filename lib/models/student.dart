class Student {
  final String id;
  final String name;
  final String email;
  final String rollNumber;
  final String department;
  final String semester;
  final String academicYear;
  final String profileImageUrl;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.academicYear,
    this.profileImageUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'rollNumber': rollNumber,
      'department': department,
      'semester': semester,
      'academicYear': academicYear,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      rollNumber: json['rollNumber'],
      department: json['department'],
      semester: json['semester'],
      academicYear: json['academicYear'],
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
} 