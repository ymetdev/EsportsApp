import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'topic_details.dart'; // นำเข้าหน้ารายละเอียด
import '../custom_page_route.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumPage extends StatefulWidget {
  final dynamic user; // User data

  const ForumPage({super.key, required this.user});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<dynamic> topics = [];
  List<dynamic> users = []; // List to store users
  TextEditingController _searchController =
      TextEditingController(); // ควบคุมการพิมพ์ในช่องค้นหา
  List<dynamic> filteredTopics = []; // เก็บผลลัพธ์ที่ค้นหาจากข้อความ

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users data
    fetchTopics();
  }

  void _searchTopics(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredTopics = topics;
      });
    } else {
      setState(() {
        filteredTopics =
            topics.where((topic) {
              return topic['title'].toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  topic['content'].toLowerCase().contains(query.toLowerCase());
            }).toList();
      });
    }
  }

  String timeAgo(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return timeago.format(date, locale: 'en'); // แสดงเวลาแบบ 2 hours ago
  }

  Future<void> fetchTopics() async {
    final response = await http.get(Uri.parse('http://localhost:3000/topics'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        topics = data;
        filteredTopics = data; // ⭐ เพิ่มบรรทัดนี้
      });
    }
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:3000/users'));

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    }
  }

  String getUsernameById(int userId) {
    final user = users.firstWhere(
      (user) => user['_id'] == userId,
      orElse: () => {},
    );
    return user.isNotEmpty ? user['username'] : 'Unknown';
  }

  Future<void> createTopic(String title, String content) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/topics'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "title": title,
        "content": content,
        "userId": widget.user['_id'], // ส่ง userId ของผู้ใช้ที่ล็อกอิน
      }),
    );

    if (response.statusCode == 201) {
      fetchTopics(); // รีเฟรชโพสต์
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Topic created successfully!")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create topic!")));
    }
  }

  Future<void> updateTopic(
    int topicId,
    String newTitle,
    String newContent,
  ) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/topics/$topicId'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"title": newTitle, "content": newContent}),
    );

    if (response.statusCode == 200) {
      fetchTopics(); // รีเฟรชโพสต์
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Successfully updated!")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update failed!")));
    }
  }

  Future<void> deleteTopic(int topicId) async {
    // แสดง Dialog เพื่อยืนยันการลบ
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this topic?'),
          actions: [
            TextButton(
              onPressed: () {
                // ปิด Dialog และไม่ลบ
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // เปลี่ยนพื้นหลังเป็นสีดำ
              ),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                // ทำการลบโพสต์
                final response = await http.delete(
                  Uri.parse('http://localhost:3000/topics/$topicId'),
                );

                if (response.statusCode == 200) {
                  fetchTopics(); // รีเฟรชโพสต์
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Successfully deleted!")),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Deletion failed!")));
                }
                Navigator.pop(context); // ปิด Dialog หลังจากลบ
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA12C2C), // ใช้สีหลักจากธีมของแอป
                foregroundColor: Colors.white, // สีตัวอักษรให้เป็นขาว
              ),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(int topicId, String currentTitle, String currentContent) {
    TextEditingController titleController = TextEditingController(
      text: currentTitle,
    );
    TextEditingController contentController = TextEditingController(
      text: currentContent,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: "Content"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // พื้นหลังสีดำ
              ),
            ),
            ElevatedButton(
              onPressed: () {
                updateTopic(
                  topicId,
                  titleController.text,
                  contentController.text,
                );
                Navigator.pop(context);
              },
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA12C2C), // พื้นหลังสีแดง (สีหลัก)
                foregroundColor: Colors.white, // ตัวอักษรเป็นสีขาว
              ),
            ),
          ],
        );
      },
    );
  }

  void showCreateTopicDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Topic'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: "Content"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF101010), // ตัวอักษรเป็นสีขาว
              ),
            ),
            ElevatedButton(
              onPressed: () {
                createTopic(titleController.text, contentController.text);
                Navigator.pop(context);
              },
              child: Text("Create"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(
                  0xFFA12C2C,
                ), // พื้นหลังปุ่มเป็นสี primary
                foregroundColor: Colors.white, // ตัวอักษรเป็นสีขาว
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFFA12C2C), // สีหลัก (primary)
        actions: [
          IconButton(
            icon: Icon(Icons.add), // ใช้ไอคอน "+" สำหรับการเพิ่มโพสต์
            onPressed: () {
              // เรียกใช้ฟังก์ชันการแสดง dialog สร้างโพสต์ใหม่
              showCreateTopicDialog();
            },
          ),
        ],
      ),

      body: Container(
        color: Color(0xFF101010), // สีพื้นหลัง (background)
        child: Column(
          children: [
            // ช่องค้นหาที่อยู่ข้างบนก่อนการแสดงผลรายการ
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchTopics,
                  cursorColor: Color(0xFFA12C2C), // สีแดงของ cursor
                  decoration: InputDecoration(
                    hintText: 'Search Topics',
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(
                          0xFFA12C2C,
                        ), // สีแดงเข้มที่คุณใช้ใน username ก็ได้
                        width: 2.0,
                      ),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                  ),
                ),
              ),
            ),
            // แสดงรายการหัวข้อที่กรองตามข้อความค้นหา
            Expanded(
              child: ListView.builder(
                itemCount: filteredTopics.length,
                itemBuilder: (context, index) {
                  final topic = filteredTopics[index];
                  final username = getUsernameById(
                    topic['userId'],
                  ); // Get username from userId

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3.0,
                    ), // กำหนด margin ด้านล่าง
                    child: Card(
                      color: Color(0xFF202020), // สีพื้นหลังของการ์ด
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          15,
                        ), // มุมโค้งของการ์ด
                      ),
                      elevation: 5, // เพิ่มเงาให้กับการ์ด
                      shadowColor: Colors.black.withOpacity(
                        0.5,
                      ), // ปรับสีของเงา
                      child: ListTile(
                        title: Text(
                          topic['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // ทำให้ข้อความตัวหนา
                            color: Colors.white, // สีข้อความ (text) เป็นสีขาว
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic['content'],
                              style: TextStyle(
                                color:
                                    Colors.white, // สีข้อความ (text) เป็นสีขาว
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                              ), // กำหนด margin ด้านบน
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'MyCustomFont',
                                    fontSize: 14,
                                    color:
                                        Colors
                                            .white70, // สีข้อความ (text) เป็นสีเทาอ่อน
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Posted by ',
                                    ), // ข้อความแรกที่เป็นสีเทา
                                    TextSpan(
                                      text: '@$username', // Username
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(
                                          0xFFA12C2C,
                                        ), // สีแดงเข้ม (primary)
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' • ${timeAgo(topic['createdAt'])}', // เวลาที่โพสต์
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(
                              page: TopicDetailsPage(
                                topic: topic,
                                users: users,
                                loggedInUser: widget.user,
                              ),
                            ),
                          );
                        },
                        trailing:
                            widget.user['_id'] == topic['userId']
                                ? PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      showEditDialog(
                                        topic['_id'],
                                        topic['title'],
                                        topic['content'],
                                      );
                                    } else if (value == 'delete') {
                                      deleteTopic(topic['_id']); // Delete topic
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ];
                                  },
                                )
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
