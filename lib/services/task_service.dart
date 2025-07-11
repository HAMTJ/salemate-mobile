import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../api/task_api.dart';
import '../models/task_models.dart';

// File location: lib/services/task_service.dart

class TaskService {
  
  // Get tasks for current employee
  static Future<TaskServiceResult<TaskData>> getTasks({
    required String employeeCode,
    String? authToken,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Validate employee code
      if (!TaskApi.isValidEmployeeCode(employeeCode)) {
        return TaskServiceResult.error('Employee code format ไม่ถูกต้อง: $employeeCode');
      }
      
      print('🔄 TaskService: Getting tasks for $employeeCode');
      
      // Call API
      final response = await TaskApi.getTasks(
        employeeCode: employeeCode,
        authToken: authToken,
        startDate: startDate,
        endDate: endDate,
      );

      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = TaskApiResponse.fromJson(responseData);
        
        if (apiResponse.isSuccess && apiResponse.data != null) {
          print('✅ TaskService: Successfully got ${apiResponse.data!.workTypes.length} work types');
          
          // Log summary
          _logTaskSummary(apiResponse.data!);
          
          return TaskServiceResult.success(apiResponse.data!);
        } else {
          return TaskServiceResult.error(
            apiResponse.message ?? 'ไม่สามารถดึงข้อมูล task ได้'
          );
        }
      } else if (response.statusCode == 401) {
        return TaskServiceResult.error('ไม่มีสิทธิ์เข้าถึงข้อมูล กรุณาเข้าสู่ระบบใหม่');
      } else if (response.statusCode == 404) {
        return TaskServiceResult.error('ไม่พบข้อมูล task สำหรับพนักงานนี้');
      } else {
        return TaskServiceResult.error('เกิดข้อผิดพลาด (${response.statusCode})');
      }
    } on SocketException {
      return TaskServiceResult.error('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } on http.ClientException {
      return TaskServiceResult.error('เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } catch (e) {
      print('❌ TaskService Error: $e');
      return TaskServiceResult.error('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }
  
  // Get tasks for specific date
  static Future<TaskServiceResult<Map<String, List<TaskLocation>>>> getTasksForDate({
    required String employeeCode,
    required DateTime selectedDate,
    String? authToken,
  }) async {
    try {
      // Get all tasks first
      final result = await getTasks(
        employeeCode: employeeCode,
        authToken: authToken,
      );
      
      if (!result.isSuccess) {
        return TaskServiceResult.error(result.message);
      }
      
      final taskData = result.data!;
      final groupedData = taskData.getGroupedByDate();
      
      // Filter for selected date
      final selectedDateKey = _formatDateKey(selectedDate);
      final tasksForDate = groupedData[selectedDateKey] ?? [];
      
      print('📅 TaskService: Found ${tasksForDate.length} locations for ${_formatDateThai(selectedDate)}');
      
      return TaskServiceResult.success({selectedDateKey: tasksForDate});
      
    } catch (e) {
      print('❌ TaskService Error in getTasksForDate: $e');
      return TaskServiceResult.error('เกิดข้อผิดพลาดในการดึงข้อมูลงานวันที่เลือก');
    }
  }
  
  // Convert TaskLocation to Branch for backward compatibility
  static List<Branch> convertToBranchList(List<TaskLocation> locations, DateTime selectedDate) {
    return locations.asMap().entries.map((entry) {
      final index = entry.key;
      final location = entry.value;
      
      return Branch.fromTaskLocation(location, index + 1, selectedDate);
    }).toList();
  }
  
  // Get summary statistics
  static TaskSummary getSummary(TaskData taskData) {
    final allDates = taskData.getAllDates();
    
    int totalLocations = 0;
    int totalTasks = 0;
    int completedTasks = 0;
    int pendingTasks = 0;
    
    for (var date in allDates) {
      for (var location in date.locations) {
        totalLocations++;
        totalTasks += location.totalTasks;
        completedTasks += location.completedTasks;
        pendingTasks += location.pendingTasks;
      }
    }
    
    return TaskSummary(
      totalDays: allDates.length,
      totalLocations: totalLocations,
      totalTasks: totalTasks,
      pendingTasks: pendingTasks,
      completedTasks: completedTasks,
    );
  }
  
  // Update key data status (API ใหม่)
  static Future<TaskServiceResult<bool>> updateKeyDataStatus({
    required String employeeCode,
    required String quotationShareSubNo,
    required String brandName,
    String? authToken,
  }) async {
    try {
      print('🔄 TaskService: Updating key data status for $brandName');
      
      final response = await TaskApi.updateKeyDataStatus(
        employeeCode: employeeCode,
        quotationShareSubNo: quotationShareSubNo,
        brandName: brandName,
        authToken: authToken,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Check ตาม format ใหม่: {"result": {"status": "success"}}
        if (responseData['result']['status'] == 'success') {
          print('✅ TaskService: Key data status updated successfully');
          return TaskServiceResult.success(true);
        } else {
          return TaskServiceResult.error(
            responseData['result']['message'] ?? 'อัพเดทสถานะไม่สำเร็จ'
          );
        }
      } else {
        return TaskServiceResult.error('เกิดข้อผิดพลาดในการอัพเดทสถานะ (${response.statusCode})');
      }
    } catch (e) {
      print('❌ TaskService Error in updateKeyDataStatus: $e');
      return TaskServiceResult.error('เกิดข้อผิดพลาดในการอัพเดทสถานะ');
    }
  }
  
  // Submit key data (สำหรับเมื่อเสร็จสิ้นการคีย์ยอด)
  static Future<TaskServiceResult<bool>> submitKeyData({
    required String employeeCode,
    required String quotationShareSubNo,
    required String brandName,
    required Map<String, dynamic> keyDataPayload,
    String? authToken,
  }) async {
    try {
      print('🔄 TaskService: Submitting key data for $brandName');
      print('📊 Key data keys: ${keyDataPayload.keys.toList()}');
      
      final response = await TaskApi.submitKeyData(
        employeeCode: employeeCode,
        quotationShareSubNo: quotationShareSubNo,
        brandName: brandName,
        keyDataPayload: keyDataPayload,
        authToken: authToken,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['result']['status'] == 'success') {
          print('✅ TaskService: Key data submitted successfully');
          return TaskServiceResult.success(true);
        } else {
          return TaskServiceResult.error(
            responseData['result']['message'] ?? 'ส่งข้อมูลยอดไม่สำเร็จ'
          );
        }
      } else {
        return TaskServiceResult.error('เกิดข้อผิดพลาดในการส่งข้อมูลยอด (${response.statusCode})');
      }
    } catch (e) {
      print('❌ TaskService Error in submitKeyData: $e');
      return TaskServiceResult.error('เกิดข้อผิดพลาดในการส่งข้อมูลยอด');
    }
  }
  
  // Helper methods
  static void _logTaskSummary(TaskData taskData) {
    final summary = getSummary(taskData);
    print('📊 Task Summary:');
    print('   - Total Days: ${summary.totalDays}');
    print('   - Total Locations: ${summary.totalLocations}');
    print('   - Total Tasks: ${summary.totalTasks}');
    print('   - Completed: ${summary.completedTasks}');
    print('   - Pending: ${summary.pendingTasks}');
    
    // Log work types
    print('🏷️ Work Types:');
    for (var workType in taskData.workTypes) {
      print('   - ${workType.workType}: ${workType.dates.length} dates');
    }
  }
  
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  static String _formatDateThai(DateTime date) {
    final months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }
  
  // Cache management (สำหรับอนาคต)
  static TaskData? _cachedTaskData;
  static DateTime? _cacheTimestamp;
  static const int _cacheValidityMinutes = 5;
  
  static bool get _isCacheValid {
    if (_cachedTaskData == null || _cacheTimestamp == null) return false;
    
    final now = DateTime.now();
    final diff = now.difference(_cacheTimestamp!).inMinutes;
    return diff < _cacheValidityMinutes;
  }
  
  static void _updateCache(TaskData taskData) {
    _cachedTaskData = taskData;
    _cacheTimestamp = DateTime.now();
    print('💾 TaskService: Cache updated');
  }
  
  static void clearCache() {
    _cachedTaskData = null;
    _cacheTimestamp = null;
    print('🗑️ TaskService: Cache cleared');
  }
  
  // Get cached data if available and valid
  static TaskData? getCachedData() {
    if (_isCacheValid) {
      print('⚡ TaskService: Using cached data');
      return _cachedTaskData;
    }
    return null;
  }
}

// Result wrapper class
class TaskServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final String message;
  final String? errorCode;

  TaskServiceResult({
    required this.isSuccess,
    this.data,
    required this.message,
    this.errorCode,
  });

  factory TaskServiceResult.success(T data) {
    return TaskServiceResult<T>(
      isSuccess: true,
      data: data,
      message: 'Success',
    );
  }

  factory TaskServiceResult.error(String message, {String? errorCode}) {
    return TaskServiceResult<T>(
      isSuccess: false,
      data: null,
      message: message,
      errorCode: errorCode,
    );
  }

  @override
  String toString() {
    return 'TaskServiceResult(isSuccess: $isSuccess, message: $message, errorCode: $errorCode)';
  }
}

// Summary model for dashboard
class TaskSummary {
  final int totalDays;
  final int totalLocations;
  final int totalTasks;
  final int pendingTasks;
  final int completedTasks;

  TaskSummary({
    required this.totalDays,
    required this.totalLocations,
    required this.totalTasks,
    required this.pendingTasks,
    required this.completedTasks,
  });

  double get completionRate => totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  
  @override
  String toString() {
    return 'TaskSummary(days: $totalDays, locations: $totalLocations, tasks: $totalTasks, completed: $completedTasks, pending: $pendingTasks)';
  }
}