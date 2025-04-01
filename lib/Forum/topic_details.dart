import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:timeago/timeago.dart' as timeago;

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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(widget.topic['content'], style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: 'Posted by ', // ข้อความแรกที่เป็นสีเทา
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            '@$username', // ข้อความ username ที่เป็นสี Deep Purple
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${timeago.format(DateTime.parse(widget.topic['createdAt']), locale: 'en')}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 16),

                // แสดงจำนวนคอมเมนต์
                Text(
                  '${comments.length} Comments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                comments.isEmpty
                    ? Center(child: Text('No comments yet.'))
                    : Container(
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
                            elevation: 2, // เพิ่มเงา (4 คือระดับความเข้มของเงา)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // ทำให้มุมโค้งมน
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ), // เพิ่มระยะห่างข้างใน
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 4.0,
                                  ), // เพิ่ม padding ด้านล่าง
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '@$commenterUsername ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
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
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                subtitle: Text(comment['content']),
                                trailing:
                                    widget.loggedInUser['_id'] ==
                                            comment['userId']
                                        ? PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert),
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
                                                    title: Text('Edit Comment'),
                                                    content: TextField(
                                                      controller:
                                                          contentController,
                                                      decoration:
                                                          InputDecoration(
                                                            labelText:
                                                                "Content",
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
                                                            contentController
                                                                .text,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: Text("Save"),
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
                                                    ),
                                                    content: Text(
                                                      'Do you really want to delete this comment?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: Text('Cancel'),
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
                                                  child: Text('Edit'),
                                                ),
                                                PopupMenuItem<String>(
                                                  value: 'delete',
                                                  child: Text('Delete'),
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
