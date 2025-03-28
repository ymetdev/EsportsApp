import 'package:flutter/material.dart';
import 'dart:math';
import 'login.dart';
import 'forum.dart';
import '../Valorant_database/valorant_database.dart';

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
          children: [
            SizedBox(height: 100), // ดันขึ้นไปให้สูงขึ้น
            Text(
              'Welcome, ${user['username']} ${getRandomEmoji()}',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Press "Forum" to see what others are talking about, and press "Database" to view information about Valorant.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40), // เว้นระยะห่างก่อนปุ่ม
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSquareButton(context, 'Forum', ForumPage(user: user)),
                SizedBox(width: 20),
                _buildSquareButton(context, 'Database', ValorantDatabasePage()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างปุ่มสี่เหลี่ยมจตุรัส
  Widget _buildSquareButton(BuildContext context, String text, Widget page) {
    return SizedBox(
      width: 150, // กำหนดให้ปุ่มเป็นสี่เหลี่ยมจตุรัส
      height: 150,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // ทำให้มุมโค้งเล็กน้อย
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
