import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/floating_circles_background.dart';
import '../widgets/glass_container.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/employee_data.dart';

class LoginScreen extends StatefulWidget {
  final Function(User?, EmployeeData?) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  final AuthService _authService = AuthService();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Track if fields have been touched for validation
  bool _usernameHasBeenFocused = false;
  bool _passwordHasBeenFocused = false;

  @override
  void initState() {
    super.initState();
    
    // Add listeners to track when fields lose focus
    _usernameFocusNode.addListener(() {
      if (!_usernameFocusNode.hasFocus && !_usernameHasBeenFocused) {
        setState(() {
          _usernameHasBeenFocused = true;
        });
      }
    });
    
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus && !_passwordHasBeenFocused) {
        setState(() {
          _passwordHasBeenFocused = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear any previous error message
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call actual API
        final response = await _authService.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );
        
        if (response.success) {
          // Save token if needed
          // await SecureStorage.saveToken(response.token);
          
          // สร้าง User object จาก EmployeeData
          User? user;
          if (response.data != null) {
            user = User.fromEmployee(response.data!);
          }
          
          // Navigate to home with user data
          widget.onLogin(user, response.data);
        } else {
          setState(() {
            _errorMessage = response.message ?? 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
          });
        }
      } on AuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
        });
        print('Login error: $e'); // For debugging
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background floating shapes
            const FloatingCirclesBackground(),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: GlassContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SALEMATE',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Error message display
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 12),
                        
                        // Username field
                        TextFormField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-Z0-9._@]+$'),
                            ),
                          ],
                          validator: (value) => _usernameHasBeenFocused 
                              ? Validators.validateUsername(value) 
                              : null,
                          onChanged: (value) {
                            if (_usernameHasBeenFocused) {
                              _formKey.currentState!.validate();
                            }
                          },
                          style: const TextStyle(color: Colors.black87),
                          decoration: AppInputDecorations.textFieldDecoration(
                            hintText: 'Username',
                            prefixIcon: Icons.person,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscurePassword,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-Z0-9@#_\-!*]+$'),
                            ),
                          ],
                          validator: (value) => _passwordHasBeenFocused 
                              ? Validators.validatePassword(value) 
                              : null,
                          onChanged: (value) {
                            if (_passwordHasBeenFocused) {
                              _formKey.currentState!.validate();
                            }
                          },
                          style: const TextStyle(color: Colors.black87),
                          decoration: AppInputDecorations.textFieldDecoration(
                            hintText: 'Password',
                            prefixIcon: Icons.lock,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Password hint - ลบออกหรือแสดงเฉพาะใน debug mode
                        if (const bool.fromEnvironment('dart.vm.product') == false)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Test: sittiporn.w / Mca@2025',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 24),
                        
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: AppButtonStyles.primaryButton,
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      letterSpacing: 1.1,
                                      color: Colors.black87,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}