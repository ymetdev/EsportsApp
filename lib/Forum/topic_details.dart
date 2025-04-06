import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:timeago/timeago.dart' as timeago;

class TopicDetailsPage extends StatefulWidget {
  final dynamic topic; // รับข้อมูลหัวข้อ
  final List<dynamic> users; // รับข้อมูล users
  final dynamic loggedInUser; // รับข้อมูลผู้ใช้ที่ล็อกอิน

  const TopicDetailsPage({
    super.key,
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
      backgroundColor: Color(0xFF101010), // พื้นหลัง
      appBar: AppBar(
        title: Text(
          widget.topic['title'],
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFA12C2C), // สีหลักของแถบแอพ
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic['title'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.topic['content'],
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    text: 'Posted by ',
                    style: TextStyle(
                      fontFamily: 'MyCustomFont',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '@$username',
                        style: TextStyle(
                          fontFamily: 'MyCustomFont',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA12C2C), // สีหลักสำหรับ username
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 0),
                Text(
                  timeago.format(
                    DateTime.parse(widget.topic['createdAt']),
                    locale: 'en',
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 16),
                Text(
                  '${comments.length} Comments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                comments.isEmpty
                    ? Center(
                      child: Text(
                        'No comments yet.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          var comment = comments[index];
                          String commenterUsername = getUsernameById(
                            comment['userId'],
                          );

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '@$commenterUsername ',
                                          style: TextStyle(
                                            fontFamily: 'MyCustomFont',
                                            fontWeight: FontWeight.bold,
                                            color: Color(
                                              0xFFA12C2C,
                                            ), // สีหลักสำหรับ username
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              timeago.format(
                                                        DateTime.parse(
                                                          comment['createdAt'],
                                                        ),
                                                        locale: 'en_short',
                                                      ) ==
                                                      'now'
                                                  ? 'Now'
                                                  : '${timeago.format(DateTime.parse(comment['createdAt']), locale: 'en_short')} ago',
                                          style: TextStyle(
                                            fontFamily: "MyCustomFont",
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF101010), // สีข้อคว
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  comment['content'],
                                  style: TextStyle(
                                    color: Color(
                                      0xFF101010,
                                    ), // สีข้อความเป็นสีพื้นหลัง
                                    fontWeight:
                                        FontWeight
                                            .bold, // ทำให้ข้อความเป็นตัวหนา
                                  ),
                                ), // สีข้อความในคอมเมนต์เป็นสีพื้นหลัง
                                trailing:
                                    widget.loggedInUser['_id'] ==
                                            comment['userId']
                                        ? PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: Color(0xFF101010),
                                          ),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              TextEditingController
                                              contentController =
                                                  TextEditingController(
                                                    text: comment['content'],
                                                  );
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Edit Comment',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF101010,
                                                        ),
                                                      ),
                                                    ),
                                                    content: TextField(
                                                      controller:
                                                          contentController,
                                                      decoration:
                                                          InputDecoration(
                                                            labelText:
                                                                "Content",
                                                            labelStyle:
                                                                TextStyle(
                                                                  color: Color(
                                                                    0xFF101010,
                                                                  ),
                                                                ),
                                                          ),
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF101010,
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFF101010,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          editComment(
                                                            comment['_id'],
                                                            contentController
                                                                .text,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: Text("Save"),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  Color(
                                                                    0xFFA12C2C,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else if (value == 'delete') {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Are you sure?',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF101010,
                                                        ),
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'Do you really want to delete this comment?',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF101010,
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFF101010,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          deleteComment(
                                                            comment['_id'],
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: Text('Delete'),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Color(
                                                                    0xFFA12C2C,
                                                                  ),
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          itemBuilder:
                                              (context) => [
                                                PopupMenuItem<String>(
                                                  value: 'edit',
                                                  child: Text(
                                                    'Edit',
                                                    style: TextStyle(
                                                      color: Color(0xFF101010),
                                                    ),
                                                  ),
                                                ),
                                                PopupMenuItem<String>(
                                                  value: 'delete',
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Color(0xFF101010),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Add a comment',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF101010),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFA12C2C),
                      width: 2,
                    ), // เปลี่ยนสีเส้นขอบเป็นสีแดง
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ), // สีเส้นขอบปกติ
                  ),
                ),
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white, // ตั้งสีของ cursor เป็นสีแดง
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
