import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';

class ApiService {
  // 10.0.2.2 points directly to localhost of your PC from Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000/api';

// Login with Email + Password
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return response.statusCode == 200;
  }

  // Register full Employee
  static Future<Map<String, dynamic>> register(Employee employee) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(employee.toJson()),
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 201,
      'message': data['message'] ?? 'Registration error',
    };
  }
  // Get All Employees (Supports Search Query)
  static Future<List<Employee>> getEmployees({String search = ''}) async {
    final url = search.isEmpty
        ? '$baseUrl/employee'
        : '$baseUrl/employee?search=$search';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  // Create Employee
  static Future<bool> createEmployee(Employee employee) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(employee.toJson()),
    );
    return response.statusCode == 201;
  }

  // Update Employee
  static Future<bool> updateEmployee(String id, Employee employee) async {
    final response = await http.put(
      Uri.parse('$baseUrl/employee/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(employee.toJson()),
    );
    return response.statusCode == 200;
  }

  // Delete Employee
  static Future<bool> deleteEmployee(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/employee/$id'));
    return response.statusCode == 200;
  }
}