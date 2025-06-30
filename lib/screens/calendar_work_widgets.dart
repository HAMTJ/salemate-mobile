import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';

// Calendar Screen Widget
class CalendarPageWidget extends StatelessWidget {
  const CalendarPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ปฏิทินงาน',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mini Calendar
          _buildMiniCalendar(),
          
          const SizedBox(height: 16),
          
          // Today's Events
          _buildTodayEvents(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMiniCalendar() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                'มิถุนายน 2568',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Days of week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส']
                .map((day) => Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Calendar Grid (Sample)
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: List.generate(5, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final day = weekIndex * 7 + dayIndex - 5; // Sample calculation
              final isToday = day == 30;
              final hasEvent = [3, 7, 15, 22, 28].contains(day);
              
              if (day < 1 || day > 30) {
                return const SizedBox(width: 32, height: 32);
              }
              
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isToday 
                      ? Colors.orange.shade600
                      : hasEvent 
                          ? Colors.orange.shade100
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday 
                          ? Colors.white
                          : hasEvent 
                              ? Colors.orange.shade700
                              : Colors.black87,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildTodayEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'นัดหมายวันนี้',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildEventCard(
          time: '09:00',
          title: 'ประชุมทีมขาย',
          subtitle: 'ห้องประชุมใหญ่',
          color: Colors.blue,
        ),
        
        const SizedBox(height: 8),
        
        _buildEventCard(
          time: '14:00',
          title: 'พบลูกค้า ABC Company',
          subtitle: 'ออฟฟิศลูกค้า',
          color: Colors.green,
        ),
        
        const SizedBox(height: 8),
        
        _buildEventCard(
          time: '16:30',
          title: 'ติดตามโครงการ',
          subtitle: 'โทรศัพท์',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String time,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.black54,
            size: 18,
          ),
        ],
      ),
    );
  }
}

// Work Screen Widget
class WorkPageWidget extends StatelessWidget {
  const WorkPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'งานของฉัน',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Work Status Summary
          _buildWorkStatusSummary(),
          
          const SizedBox(height: 16),
          
          // Active Tasks
          _buildActiveTasks(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWorkStatusSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            title: 'งานทั้งหมด',
            count: '24',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            title: 'กำลังดำเนินการ',
            count: '8',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            title: 'เสร็จแล้ว',
            count: '16',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String count,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'งานที่ต้องทำ',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildTaskCard(
          title: 'ติดตามลูกค้า ABC Company',
          description: 'โทรสอบถามความคืบหน้าการสั่งซื้อ',
          priority: 'สูง',
          dueDate: 'วันนี้',
          status: 'กำลังดำเนินการ',
          priorityColor: Colors.red,
        ),
        
        const SizedBox(height: 8),
        
        _buildTaskCard(
          title: 'เตรียมเอกสารเสนอราคา',
          description: 'สำหรับลูกค้า XYZ Corporation',
          priority: 'ปานกลาง',
          dueDate: 'พรุ่งนี้',
          status: 'รอดำเนินการ',
          priorityColor: Colors.orange,
        ),
        
        const SizedBox(height: 8),
        
        _buildTaskCard(
          title: 'ประชุมทบทวนยอดขาย Q2',
          description: 'สรุปผลการขายไตรมาส 2',
          priority: 'ต่ำ',
          dueDate: '3 วัน',
          status: 'รอดำเนินการ',
          priorityColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String description,
    required String priority,
    required String dueDate,
    required String status,
    required Color priorityColor,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  priority,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 14,
                color: Colors.black45,
              ),
              const SizedBox(width: 4),
              Text(
                'ครบกำหนด: $dueDate',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'กำลังดำเนินการ' 
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: status == 'กำลังดำเนินการ' 
                        ? Colors.blue.shade700
                        : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}