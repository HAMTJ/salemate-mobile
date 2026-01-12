import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/floating_circles_background.dart';
import '../widgets/glass_container.dart';
import '../utils/constants.dart';
import '../models/user.dart';
import '../models/employee_data.dart';

// หน้าย่อยต่างๆ
import 'home_information.dart';
import 'calendar_work_widgets.dart';
import 'camera_page_widget.dart';
import 'work_main_screen.dart';  // เพิ่มบรรทัดนี้

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final User? user;
  final EmployeeData? employeeData;

  const HomeScreen({
    super.key, 
    required this.onLogout,
    this.user,
    this.employeeData,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Default เริ่มที่ Home

  // รายการหน้าต่างๆ (ไม่รวม Work เพราะจะไป navigate แยก)
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      const CalendarPageWidget(),
      HomeInformationWidget(
        user: widget.user,
        employeeData: widget.employeeData,
      ),
      Container(), // placeholder สำหรับ Work (ไม่ได้ใช้)
      CameraPageWidget(
        user: widget.user,
        employeeData: widget.employeeData,
      ),
    ];
  }

  void _onItemTapped(int index) {
    // ถ้ากดแท็บ "งาน" (index 2) ให้ไปหน้าใหม่
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkMainScreen(
            user: widget.user,
            employeeData: widget.employeeData,
          ),
        ),
      );
      return; // ออกจาก function ทันที
    }
    
    // สำหรับแท็บอื่นๆ ให้ทำงานปกติ
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 48,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(height: 16),
                Text(
                  'ออกจากระบบ',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ต้องการออกจากระบบ ใช่หรือไม่?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: AppButtonStyles.dangerButton,
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onLogout();
                        },
                        child: const Text('ออกจากระบบ'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background floating shapes
            const FloatingCirclesBackground(),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header Section - ข้อมูลทั่วไป
                  _buildHeaderSection(),

                  // Main Content Area - หน้าต่างๆ
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _widgetOptions[_selectedIndex],
                    ),
                  ),

                  // Bottom Navigation
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top row - Logo & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business_center,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SALEMATE',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Implement notification
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('แจ้งเตือน')),
                      );
                    },
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: Colors.black87,
                          size: 24,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: const Text(
                              '10',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showLogoutDialog,
                    icon: Icon(
                      Icons.logout_rounded,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User Info Row
          Row(
            children: [
              // Profile Picture
              _buildProfilePicture(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _getDisplayInfo(),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.calendar_month,
            label: 'ปฏิทิน',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.home_outlined,
            label: 'หน้าหลัก',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.work,
            label: 'งาน',
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.add_a_photo_outlined,
            label: 'ถ่ายภาพ',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.orange.shade100.withOpacity(0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.orange.shade700 
                  : Colors.black54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? Colors.orange.shade700 
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year + 543}';
  }

  // Helper methods for user display
  String _getDisplayName() {
    if (widget.employeeData?.fullName != null) {
      return '${widget.employeeData!.fullName}';
    } else if (widget.user?.fullName != null) {
      return '${widget.user!.fullName}';
    }
    return 'สวัสดี, ผู้ใช้งาน';
  }

  String _getDisplayInfo() {
    final department = widget.employeeData?.departmentName ?? 
                     widget.user?.department ?? 
                     'แผนก';
    return '$department • วันนี้: ${_getCurrentDate()}';
  }

  Widget _buildProfilePicture() {
    final profilePicture = widget.employeeData?.profilePicture;
    
    if (profilePicture != null && profilePicture.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.orange.shade100,
        child: ClipOval(
          child: Image.network(
            profilePicture,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // ถ้าโหลดรูปไม่ได้ ให้แสดง Icon แทน
              return Icon(
                Icons.person,
                color: Colors.orange.shade700,
                size: 28,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.orange.shade700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // ถ้าไม่มีรูป ให้แสดง Icon
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.orange.shade100,
        child: Icon(
          Icons.person,
          color: Colors.orange.shade700,
          size: 28,
        ),
      );
    }
  }
}