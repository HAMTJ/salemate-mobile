import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';

// Brand Model
class Brand {
  final int id;
  final String name;
  final String code;
  final String status;
  final bool isCompleted;

  Brand({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.isCompleted,
  });
}

// Branch Info Model
class BranchInfo {
  final int id;
  final String name;
  final String code;
  final DateTime selectedDate;

  BranchInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.selectedDate,
  });
}

// Brand Detail Screen
class BrandDetailScreen extends StatefulWidget {
  final BranchInfo branchInfo;
  
  const BrandDetailScreen({
    super.key,
    required this.branchInfo,
  });

  @override
  State<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends State<BrandDetailScreen> {
  // Mock data สำหรับแบรนด์ในสาขา
  List<Brand> get _mockBrands => [
    Brand(
      id: 1,
      name: 'SMOOTH E',
      code: 'MR2T',
      status: 'pending',
      isCompleted: false,
    ),
    Brand(
      id: 2,
      name: 'THAIWAH',
      code: 'MSME',
      status: 'completed',
      isCompleted: true,
    ),
    Brand(
      id: 3,
      name: 'CHAOSUA',
      code: 'BRC',
      status: 'pending',
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFEFEFE),
              Color(0xFFF3F4F6),
              Color.fromARGB(255, 231, 188, 255),
            ],
            stops: [0.0, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branch Info
                      _buildBranchInfo(),
                      
                      const SizedBox(height: 20),
                      
                      // Brand List
                      _buildBrandList(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'คีย์ข้อมูลแบรนด์',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.white),
                      SizedBox(width: 8),
                      Text('รีเฟรชข้อมูลแล้ว'),
                    ],
                  ),
                  backgroundColor: Colors.blue.shade600,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchInfo() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.branchInfo.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'รหัส: ${widget.branchInfo.code}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'วันที่: ${_formatDateThai(widget.branchInfo.selectedDate)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandList() {
    final completedCount = _mockBrands.where((b) => b.isCompleted).length;
    final totalCount = _mockBrands.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'แบรนด์ที่ต้องคีย์ข้อมูล',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$completedCount/$totalCount',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Brand Cards แทนที่ Table
        ...List.generate(_mockBrands.length, (index) {
          final brand = _mockBrands[index];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      brand.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: brand.isCompleted 
                            ? Colors.green.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        brand.isCompleted ? '✓ สำเร็จแล้ว' : 'รอดำเนินการ',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: brand.isCompleted 
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: brand.isCompleted 
                        ? null 
                        : () => _startBrandInput(brand),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand.isCompleted 
                          ? Colors.green
                          : const Color.fromARGB(255, 255, 69, 69),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      brand.isCompleted ? 'คีย์แล้ว' : 'คีย์ข้อมูล',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _startBrandInput(Brand brand) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เริ่มคีย์ข้อมูล',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'คุณต้องการเริ่มคีย์ข้อมูลสำหรับ:',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 245, 227, 253),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.branding_watermark,
                          size: 16,
                          color: const Color.fromARGB(255, 183, 0, 255),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'แบรนด์: ${brand.name}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 183, 0, 255),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 16,
                          color: const Color.fromARGB(255, 183, 0, 255),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'สาขา: ${widget.branchInfo.name}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 183, 0, 255),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: const Color.fromARGB(255, 183, 0, 255),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'วันที่: ${_formatDateThai(widget.branchInfo.selectedDate)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 183, 0, 255),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'ยกเลิก',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToInputForm(brand);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 145, 62, 255),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'เริ่มคีย์',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToInputForm(Brand brand) {
    // TODO: Navigate to Brand Input Form Screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: Colors.white),
                SizedBox(width: 8),
                Text('ไปหน้าคีย์ข้อมูล'),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'แบรนด์: ${brand.name} | วันที่: ${_formatDateThai(widget.branchInfo.selectedDate)}',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _formatDateThai(DateTime date) {
    final months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }
}