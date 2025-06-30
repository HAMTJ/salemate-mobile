import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../models/user.dart';
import '../models/employee_data.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isLoggedIn = false;
  User? currentUser;
  EmployeeData? currentEmployeeData;

  void toggleAuth({User? user, EmployeeData? employeeData}) {
    setState(() {
      isLoggedIn = !isLoggedIn;
      if (user != null) currentUser = user;
      if (employeeData != null) currentEmployeeData = employeeData;
      
      // ถ้า logout ให้ clear ข้อมูล
      if (!isLoggedIn) {
        currentUser = null;
        currentEmployeeData = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        )),
        child: child,
      ),
      child: isLoggedIn
          ? HomeScreen(
              key: const ValueKey('home'), 
              onLogout: () => toggleAuth(),
              user: currentUser,
              employeeData: currentEmployeeData,
            )
          : LoginScreen(
              key: const ValueKey('login'), 
              onLogin: (user, employeeData) => toggleAuth(
                user: user, 
                employeeData: employeeData,
              ),
            ),
    );
  }
}