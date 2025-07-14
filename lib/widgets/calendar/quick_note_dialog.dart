// lib/widgets/calendar/quick_note_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../glass_container.dart';
import 'calendar_models.dart';

class QuickNoteDialog extends StatefulWidget {
  final DateTime date;
  final String? existingNote;
  final NoteSaveCallback? onSave;
  final VoidCallback? onDelete;

  const QuickNoteDialog({
    Key? key,
    required this.date,
    this.existingNote,
    this.onSave,
    this.onDelete,
  }) : super(key: key);

  @override
  State<QuickNoteDialog> createState() => _QuickNoteDialogState();
}

class _QuickNoteDialogState extends State<QuickNoteDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();

  // Quick note templates
  final List<String> _quickTemplates = [
    '✅ งานเสร็จเรียบร้อย',
    '⏰ ต้องติดตาม',
    '❗ สำคัญ',
    '📝 บันทึกเพิ่มเติม',
    '🚀 ทำได้ดีมาก',
    '⚠️ มีปัญหา',
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.existingNote ?? '');
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation
    _animationController.forward();
    
    // Auto focus after animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_textController.text.trim().isEmpty) {
      _handleDelete();
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate save delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    widget.onSave?.call(widget.date, _textController.text.trim());
    
    if (mounted) {
      _animateOut();
    }
  }

  void _handleDelete() async {
    setState(() => _isLoading = true);
    
    // Simulate delete delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    widget.onDelete?.call();
    
    if (mounted) {
      _animateOut();
    }
  }

  void _animateOut() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _insertTemplate(String template) {
    final currentText = _textController.text;
    final newText = currentText.isEmpty ? template : '$currentText\n$template';
    
    _textController.text = newText;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: GlassContainer(
                padding: const EdgeInsets.all(0),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    maxHeight: 500,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildContent(),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.note_add,
              color: Colors.orange.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'บันทึกส่วนตัว',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  ThaiCalendarUtils.formatThaiDate(widget.date),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _animateOut,
            icon: Icon(
              Icons.close,
              color: Colors.black54,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text input
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'เพิ่มบันทึกสำหรับวันนี้...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick templates
            Text(
              'เทมเพลตด่วน',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTemplates.map((template) {
                return GestureDetector(
                  onTap: () => _insertTemplate(template),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      template,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Delete button (only show if existing note)
          if (widget.existingNote != null && widget.existingNote!.isNotEmpty)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleDelete,
                icon: _isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.delete, size: 16),
                label: Text('ลบ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          
          if (widget.existingNote != null && widget.existingNote!.isNotEmpty)
            const SizedBox(width: 12),
          
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : _animateOut,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black54,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'ยกเลิก',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Save button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleSave,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.save, size: 16),
              label: Text(_isLoading ? 'กำลังบันทึก...' : 'บันทึก'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the dialog
Future<void> showQuickNoteDialog({
  required BuildContext context,
  required DateTime date,
  String? existingNote,
  NoteSaveCallback? onSave,
  VoidCallback? onDelete,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return QuickNoteDialog(
        date: date,
        existingNote: existingNote,
        onSave: onSave,
        onDelete: onDelete,
      );
    },
  );
}