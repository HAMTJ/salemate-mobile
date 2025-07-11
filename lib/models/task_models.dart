// Task API Response Models
// File location: lib/models/task_models.dart
class TaskApiResponse {
  final String status;
  final int statusCode;
  final TaskData? data;
  final String? message;

  bool get isSuccess => status == 'success';

  TaskApiResponse({
    required this.status,
    required this.statusCode,
    this.data,
    this.message,
  });

  factory TaskApiResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return TaskApiResponse(
      status: result['status'] ?? '',
      statusCode: result['statuscode'] ?? 0,
      data: result['data'] != null ? TaskData.fromJson(result['data']) : null,
      message: result['message'],
    );
  }
}

// Main Task Data
class TaskData {
  final String employeeCode;
  final String outsourceFullName;
  final List<WorkType> workTypes;

  TaskData({
    required this.employeeCode,
    required this.outsourceFullName,
    required this.workTypes,
  });

  factory TaskData.fromJson(Map<String, dynamic> json) {
    return TaskData(
      employeeCode: json['employeeCode'] ?? '',
      outsourceFullName: json['outsourceFullName'] ?? '',
      workTypes: (json['workTypes'] as List? ?? [])
          .map((workType) => WorkType.fromJson(workType))
          .toList(),
    );
  }

  // Helper method: Flatten all dates from all workTypes
  List<WorkingDate> getAllDates() {
    List<WorkingDate> allDates = [];
    for (var workType in workTypes) {
      allDates.addAll(workType.dates);
    }
    return allDates;
  }

  // Helper method: Get dates grouped by date string
  Map<String, List<TaskLocation>> getGroupedByDate() {
    Map<String, List<TaskLocation>> grouped = {};
    
    for (var workType in workTypes) {
      for (var date in workType.dates) {
        final dateKey = _formatDateKey(date.workingDate);
        
        if (grouped[dateKey] == null) {
          grouped[dateKey] = [];
        }
        
        // Add all locations from this date
        grouped[dateKey]!.addAll(date.locations.map((loc) => 
          TaskLocation(
            accountNameEnglish: loc.accountNameEnglish,
            storeNameThai: loc.storeNameThai,
            tasks: loc.tasks,
            workType: workType.workType, // เพิ่ม workType เพื่อ reference
            originalDate: date.workingDate,
          )
        ));
      }
    }
    
    return grouped;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Work Type (Key Account, Share, PC)
class WorkType {
  final String workType;
  final List<WorkingDate> dates;

  WorkType({
    required this.workType,
    required this.dates,
  });

  factory WorkType.fromJson(Map<String, dynamic> json) {
    return WorkType(
      workType: json['workType'] ?? '',
      dates: (json['dates'] as List? ?? [])
          .map((date) => WorkingDate.fromJson(date))
          .toList(),
    );
  }
}

// Working Date
class WorkingDate {
  final DateTime workingDate;
  final List<Location> locations;

  WorkingDate({
    required this.workingDate,
    required this.locations,
  });

  factory WorkingDate.fromJson(Map<String, dynamic> json) {
    return WorkingDate(
      workingDate: DateTime.parse(json['workingDate']),
      locations: (json['locations'] as List? ?? [])
          .map((location) => Location.fromJson(location))
          .toList(),
    );
  }
}

// Location (Store)
class Location {
  final String accountNameEnglish;
  final String storeNameThai;
  final List<Task> tasks;

  Location({
    required this.accountNameEnglish,
    required this.storeNameThai,
    required this.tasks,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      accountNameEnglish: json['accountNameEnglish'] ?? '',
      storeNameThai: json['storeNameThai'] ?? '',
      tasks: (json['tasks'] as List? ?? [])
          .map((task) => Task.fromJson(task))
          .toList(),
    );
  }

  // Helper methods for UI
  int get totalTasks => tasks.length;
  
  int get completedTasks => tasks.where((task) => 
    task.keyDataStatus == 'completed' || 
    task.keyDataStatus == 'done'
  ).length;
  
  int get pendingTasks => totalTasks - completedTasks;
  
  double get completionRate => totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  
  String get overallStatus {
    if (completedTasks == totalTasks) return 'completed';
    if (completedTasks > 0) return 'in_progress';
    return 'pending';
  }
}

// Task (Brand work)
class Task {
  final String brandName;
  final String quotationShareSubNo;
  final String visitStatusCode;
  final String visitStatusDescription;
  final String visitStatusColor;
  final dynamic keyDataStatus; // เปลี่ยนเป็น dynamic เพื่อรองรับ null และ int
  final String keyDataStatusWording;

  Task({
    required this.brandName,
    required this.quotationShareSubNo,
    required this.visitStatusCode,
    required this.visitStatusDescription,
    required this.visitStatusColor,
    this.keyDataStatus,
    required this.keyDataStatusWording,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      brandName: json['brandName'] ?? '',
      quotationShareSubNo: json['quotationShareSubNo'] ?? '',
      visitStatusCode: json['visitStatusCode'] ?? '',
      visitStatusDescription: json['visitStatusDescription'] ?? '',
      visitStatusColor: json['visitStatusColor'] ?? '',
      keyDataStatus: json['keyDataStatus'], // รับค่าเป็น dynamic
      keyDataStatusWording: json['keyDataStatusWording'] ?? '',
    );
  }

  // Helper methods for UI
  bool get isCompleted => keyDataStatus == 1; // เช็คว่าเป็น 1 (int)
  
  bool get isPending => keyDataStatus == null; // เช็คว่าเป็น null
  
  bool get canKeyData => visitStatusCode != 'Y'; // ตาม logic ที่ตกลงกัน
  
  String get statusForUI {
    if (isCompleted) return 'คีย์ยอดแล้ว';
    if (isPending) return 'รอคีย์ยอด';
    return keyDataStatusWording;
  }
}

// Extended TaskLocation for flattened data (helper class)
class TaskLocation extends Location {
  final String workType;
  final DateTime originalDate;

  TaskLocation({
    required String accountNameEnglish,
    required String storeNameThai,
    required List<Task> tasks,
    required this.workType,
    required this.originalDate,
  }) : super(
    accountNameEnglish: accountNameEnglish,
    storeNameThai: storeNameThai,
    tasks: tasks,
  );

  // Generate unique key for this location+date combination
  String get uniqueKey => '${accountNameEnglish}_${storeNameThai}_${_formatDateKey(originalDate)}';
  
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// For backward compatibility with existing UI models
class Branch {
  final int id;
  final String name;
  final String code;
  final String address;
  final String status;
  final int totalBrands;
  final int completedBrands;
  final DateTime? lastVisit;
  final DateTime selectedDate;

  Branch({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.status,
    required this.totalBrands,
    required this.completedBrands,
    this.lastVisit,
    required this.selectedDate,
  });

  double get completionRate => totalBrands > 0 ? (completedBrands / totalBrands) * 100 : 0;

  // Convert from TaskLocation to Branch for existing UI
  factory Branch.fromTaskLocation(TaskLocation location, int index, DateTime selectedDate) {
    return Branch(
      id: index,
      name: location.storeNameThai,
      code: location.accountNameEnglish,
      address: '', // ไม่มีข้อมูลใน API
      status: location.overallStatus,
      totalBrands: location.totalTasks,
      completedBrands: location.completedTasks,
      lastVisit: location.originalDate,
      selectedDate: selectedDate,
    );
  }
}

// For brand detail screen
class BranchInfo {
  final int id;
  final String name;
  final String code;
  final DateTime selectedDate;
  final List<Task> tasks; // เพิ่ม tasks เพื่อส่งไปหน้าถัดไป

  BranchInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.selectedDate,
    required this.tasks,
  });
}