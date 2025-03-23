import 'package:flutter/material.dart';
import 'login.dart'; // นำเข้า LoginPage สำหรับกลับไปที่หน้า Login
import 'forum.dart'; // นำเข้า ForumPage

class HomePage extends StatelessWidget {
  final dynamic user; // รับข้อมูลผู้ใช้จากหน้า Login

  HomePage({required this.user}); // Constructor เพื่อรับข้อมูลผู้ใช้

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          // ปุ่ม Logout ใน AppBar
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user['username']}!'), // แสดงชื่อผู้ใช้ที่ login
            SizedBox(height: 20),
            // ปุ่มไปที่หน้า Forum
            ElevatedButton(
              onPressed: () {
                // ส่ง user ไปที่ ForumPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForumPage(user: user),
                  ),
                );
              },
              child: Text('Go to Forum'),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันแสดงกล่องยืนยันการออกจากระบบ
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่อง
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // กลับไปที่หน้า Login
                Navigator.of(context).pop(); // ปิดกล่อง
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
