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
  bool isLoading = true; // เพิ่มตัวแปรนี้

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  // ฟังก์ชันดึงความคิดเห็นจาก API
  Future<void> fetchComments() async {
    setState(() {
      isLoading = true; // เริ่มโหลดข้อมูล
    });
    final response = await http.get(
      Uri.parse(
        'http://localhost:3000/comments?topicId=${widget.topic['_id']}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        comments = data;
        isLoading = false; // โหลดเสร็จแล้ว
      });
    } else {
      isLoading = false; // โหลดไม่สำเร็จ แต่ให้จบการโหลด
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

  void _showEditCommentDialog(dynamic comment) {
    TextEditingController editController = TextEditingController(
      text: comment['content'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Comment'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Enter new comment'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                editComment(comment['_id'], editController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Comment successfully updated!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update comment."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
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
                    text: 'Posted by ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '@$username',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  timeago.format(
                    DateTime.parse(widget.topic['createdAt']),
                    locale: 'en',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // โหลดเสร็จก่อนค่อยแสดงคอมเมนต์
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${comments.length} Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        comments.isEmpty
                            ? Center(child: Text('No comments yet.'))
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

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10.0,
                                    ), // เพิ่มช่องว่างด้านล่าง
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '@$commenterUsername ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.deepPurple,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            timeago.format(
                                                                      DateTime.parse(
                                                                        comment['createdAt'],
                                                                      ),
                                                                      locale:
                                                                          'en_short',
                                                                    ) ==
                                                                    'now'
                                                                ? 'Now'
                                                                : '${timeago.format(DateTime.parse(comment['createdAt']), locale: 'en_short')} ago',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (comment['userId'] ==
                                                    widget.loggedInUser['_id'])
                                                  PopupMenuButton<String>(
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _showEditCommentDialog(
                                                          comment,
                                                        );
                                                      } else if (value ==
                                                          'delete') {
                                                        deleteComment(
                                                          comment['_id'],
                                                        );
                                                      }
                                                    },
                                                    itemBuilder:
                                                        (context) => [
                                                          PopupMenuItem(
                                                            value: 'edit',
                                                            child: Text('Edit'),
                                                          ),
                                                          PopupMenuItem(
                                                            value: 'delete',
                                                            child: Text(
                                                              'Delete',
                                                            ),
                                                          ),
                                                        ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                          subtitle: Text(comment['content']),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      ],
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
                  filled: true,
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
