class Employee {
  final String? id;
  final int empId;
  final String name;
  final String email;
  final String? password;
  final String department;
  final String designation;
  final String? city;
  final String? gender;
  final String? image;

  Employee({
    this.id,
    required this.empId,
    required this.name,
    required this.email,
    this.password,
    required this.department,
    required this.designation,
    this.city,
    this.gender,
    this.image,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'],
      empId: json['emp_id'] is int ? json['emp_id'] : int.parse(json['emp_id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      city: json['city'],
      gender: json['gender'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emp_id': empId,
      'name': name,
      'email': email,
      if (password != null && password!.isNotEmpty) 'password': password,
      'department': department,
      'designation': designation,
      'city': city,
      'gender': gender,
      'image': image,
    };
  }
}