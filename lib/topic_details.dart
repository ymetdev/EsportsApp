import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TopicDetailsPage extends StatefulWidget {
  final dynamic topic; // รับข้อมูลหัวข้อ
  final List<dynamic> users; // รับข้อมูล users
  final dynamic loggedInUser; // รับข้อมูลผู้ใช้ที่ล็อกอิน

  TopicDetailsPage({
    required this.topic,
    required this.users,
    required this.loggedInUser,
  });

  @override
  _TopicDetailsPageState createState() => _TopicDetailsPageState();
}

class _TopicDetailsPageState extends State<TopicDetailsPage> {
  late List<dynamic> comments = [];
  final TextEditingController contentController =
      TextEditingController(); // สร้าง TextEditingController

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  // ฟังก์ชันดึงความคิดเห็นจาก API
  Future<void> fetchComments() async {
    final response = await http.get(
      Uri.parse(
        'http://localhost:3000/comments?topicId=${widget.topic['_id']}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        comments = data;
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  // ฟังก์ชันเพิ่มความคิดเห็นใหม่
  Future<void> addComment(String content) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/comments'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "topicId": widget.topic['_id'],
        "userId": widget.loggedInUser['_id'],
        "content": content,
        "createdAt": DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      // เมื่อเพิ่มความคิดเห็นเสร็จแล้ว รีเฟรชความคิดเห็น
      fetchComments();
      contentController.clear();
      print("Comment successfully added!");
    } else {
      print("Failed to add comment.");
    }
  }

  // ฟังก์ชันแก้ไขความคิดเห็น
  Future<void> editComment(int commentId, String newContent) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/comments/$commentId'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"content": newContent}),
    );

    if (response.statusCode == 200) {
      fetchComments();
      print("Comment successfully updated!");
    } else {
      print("Failed to update comment.");
    }
  }

  // ฟังก์ชันลบความคิดเห็น
  Future<void> deleteComment(int commentId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/comments/$commentId'),
    );

    if (response.statusCode == 200) {
      fetchComments();
      print("Comment successfully deleted!");
    } else {
      print("Failed to delete comment.");
    }
  }

  String getUsernameById(int userId) {
    final user = widget.users.firstWhere(
      (user) => user['_id'] == userId,
      orElse: () => {},
    );
    return user.isNotEmpty ? user['username'] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    String username = getUsernameById(widget.topic['userId']);

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic['title'])),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic['title'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(widget.topic['content'], style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                Text(
                  'Posted by: $username',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Posted on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.topic['createdAt']))}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 16),
                comments.isEmpty
                    ? Center(child: Text('No comments yet.'))
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        var comment = comments[index];
                        String commenterUsername = getUsernameById(
                          comment['userId'],
                        );
                        String formattedDate = DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).format(DateTime.parse(comment['createdAt']));

                        return ListTile(
                          title: Text(commenterUsername),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment['content']),
                              SizedBox(height: 5),
                              Text(
                                'Posted on: $formattedDate',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing:
                              widget.loggedInUser['_id'] == comment['userId']
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          TextEditingController
                                          contentController =
                                              TextEditingController(
                                                text: comment['content'],
                                              );

                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text('Edit Comment'),
                                                content: TextField(
                                                  controller: contentController,
                                                  decoration: InputDecoration(
                                                    labelText: "Content",
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: Text("Cancel"),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      editComment(
                                                        comment['_id'],
                                                        contentController.text,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Save"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          // แสดงกล่องโต้ตอบเพื่อยืนยันการลบ
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text('Are you sure?'),
                                                content: Text(
                                                  'Do you really want to delete this comment?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop(); // ปิดกล่องโต้ตอบ
                                                    },
                                                    child: Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      deleteComment(
                                                        comment['_id'],
                                                      ); // ลบความคิดเห็น
                                                      Navigator.of(
                                                        context,
                                                      ).pop(); // ปิดกล่องโต้ตอบหลังจากลบ
                                                    },
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                  : null,
                        );
                      },
                    ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: contentController, // ใส่ controller สำหรับช่องกรอก
                decoration: InputDecoration(
                  labelText: 'Add a comment',
                  filled: true, // เปิดใช้งานการเติมสีพื้นหลัง
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    addComment(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
