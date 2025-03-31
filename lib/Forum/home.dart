import 'package:flutter/material.dart';
import 'dart:math';
import 'login.dart';
import 'forum.dart';
import '../Valorant_database/valorant_database.dart';
import '../custom_page_route.dart';

List<String> emojis = [
  '✿',
  '♠',
  '♡',
  '☕︎',
  '🕷',
  '🗿',
  '🌟',
  '💎',
  '🔥',
  '🌸',
  '⚡',
  '💖',
  '🎉',
  '💀',
];
String getRandomEmoji() {
  final random = Random();
  return emojis[random.nextInt(emojis.length)];
}

class HomePage extends StatelessWidget {
  final dynamic user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
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
          mainAxisAlignment: MainAxisAlignment.start, // ให้เนื้อหาอยู่ด้านบน
          crossAxisAlignment: CrossAxisAlignment.start, // ทำให้ข้อความชิดซ้าย
          children: [
            SizedBox(height: 40), // ดันขึ้นไปให้สูงขึ้น
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ), // เพิ่ม Padding ซ้าย-ขวา
              child: Text(
                'Welcome, ${user['username']} ${getRandomEmoji()}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.left, // (ไม่จำเป็นแต่ใส่เพื่อความชัดเจน)
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Press "Forum" to see what others are talking about, and press "Database" to view information about Valorant.',
                style: TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 15), // เว้นระยะห่างก่อนปุ่ม
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ), // Padding ด้านซ้าย-ขวา และบน-ล่าง
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // จัดให้ข้อความชิดซ้าย
                children: [
                  Text(
                    "Tap to explore",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 0), // ระยะห่างระหว่าง Heading กับ Subheading
                  Padding(
                    padding: EdgeInsets.only(bottom: 15), // Margin bottom 20
                    child: Text(
                      "Choose a page to continue", // Subheading
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ), // เพิ่ม padding ด้านข้าง
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // จัดตำแหน่งให้อยู่กลาง
                children: [
                  _buildSquareButton(
                    context,
                    'Forum',
                    ForumPage(user: user),
                    Icons.forum,
                  ),
                  SizedBox(height: 20), // ระยะห่างระหว่างปุ่ม
                  _buildSquareButton(
                    context,
                    'Database',
                    ValorantDatabasePage(),
                    Icons.storage, // ใช้ไอคอนสำหรับ Database
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างปุ่มสี่เหลี่ยมจตุรัส
  Widget _buildSquareButton(
    BuildContext context,
    String text,
    Widget page,
    IconData icon,
  ) {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width, // กำหนดให้ปุ่มเป็นสี่เหลี่ยมจตุรัส
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            CustomPageRoute(page: page), // ใช้ CustomPageRoute ที่เราสร้างไว้
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // ทำให้มุมโค้งเล็กน้อย
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // จัดข้อความและไอคอนให้อยู่กลาง
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10), // ระยะห่างระหว่างข้อความและไอคอน
            Icon(
              icon, // ไอคอนที่ส่งมาจากการเรียกใช้
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }

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
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  CustomPageRoute(
                    page: LoginPage(),
                  ), // ใช้ CustomPageRoute ที่เราแก้ไขแล้ว
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
