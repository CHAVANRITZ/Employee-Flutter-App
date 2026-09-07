import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'add_edit_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Employee> _employees = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _initLiveAlerts();
  }

  void _initLiveAlerts() {
    SocketService.initSocket(
      onNotification: (data) {
        if (!mounted) return;

        final message = data['message'] ?? 'Employee list updated';
        final type = data['type'] ?? 'UPDATED';

        // 1. Instantly refresh directory with active search query preserved
        _fetchEmployees(query: _searchController.text.trim());

        // 2. Customize banner color & icon based on event
        Color bannerColor = const Color(0xFF2563EB); // Blue for UPDATED
        IconData bannerIcon = Icons.update_rounded;

        if (type == 'CREATED') {
          bannerColor = const Color(0xFF059669); // Green for CREATED
          bannerIcon = Icons.person_add_alt_1_rounded;
        } else if (type == 'DELETED') {
          bannerColor = const Color(0xFFDC2626); // Red for DELETED
          bannerIcon = Icons.delete_outline_rounded;
        }

        // 3. Show floating live alert banner
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: bannerColor,
            content: Row(
              children: [
                Icon(bannerIcon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    SocketService.disconnect();
    super.dispose();
  }

  Widget _buildAvatar(String? image) {
    const defaultUrl = 'https://clipart-library.com/new_gallery/301-3016414_headshot-silhouette.png';
    final resolvedImage = (image != null && image.trim().isNotEmpty && !image.contains('-png.png'))
        ? image
        : defaultUrl;

    // 1. Base64
    if (resolvedImage.startsWith('data:image')) {
      try {
        final bytes = base64Decode(resolvedImage.split(',').last);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }

    // 2. Network image with User-Agent
    if (resolvedImage.startsWith('http')) {
      return Image.network(
        resolvedImage,
        fit: BoxFit.cover,
        headers: const {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image load failed for $resolvedImage: $error');
          return Icon(Icons.person_rounded, color: Colors.blue.shade300, size: 32);
        },
      );
    }

    return Icon(Icons.person_rounded, color: Colors.blue.shade300, size: 32);
  }

  Future<void> _fetchEmployees({String query = ''}) async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getEmployees(search: query);
      if (!mounted) return;
      setState(() {
        _employees = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _deleteEmployee(String? id) async {
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Employee', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone. Do you want to continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteEmployee(id);
      if (success) _fetchEmployees(query: _searchController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5AE49),
      appBar: AppBar(
        title: const Text(
          'Employees',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, role, department...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () {
                      _searchController.clear();
                      _fetchEmployees();
                      setState(() {});
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onChanged: (val) {
                  setState(() {});
                  _fetchEmployees(query: val.trim());
                },
              ),
            ),
          ),

          // Content List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _employees.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('No records found', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () => _fetchEmployees(query: _searchController.text.trim()),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _employees.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final emp = _employees[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.blue.shade50,
                          child: _buildAvatar(emp.image),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              emp.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1E293B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${emp.empId}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            emp.designation,
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF475569)),
                          ),
                          Text(
                            emp.department,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF3B82F6)),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddEditScreen(employee: emp)),
                              );
                              if (updated == true) _fetchEmployees();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
                            onPressed: () => _deleteEmployee(emp.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditScreen()),
          );
          if (created == true) _fetchEmployees();
        },
      ),
    );
  }
}