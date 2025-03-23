import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'topic_details.dart'; // นำเข้าหน้ารายละเอียด

class ForumPage extends StatefulWidget {
  final dynamic user; // User data

  ForumPage({required this.user});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<dynamic> topics = [];
  List<dynamic> users = []; // List to store users

  @override
  void initState() {
    super.initState();
    fetchTopics();
    fetchUsers(); // Fetch users data
  }

  Future<void> fetchTopics() async {
    final response = await http.get(Uri.parse('http://localhost:3000/topics'));

    if (response.statusCode == 200) {
      setState(() {
        topics = json.decode(response.body);
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
    final response = await http.delete(
      Uri.parse('http://localhost:3000/topics/$topicId'),
    );

    if (response.statusCode == 200) {
      fetchTopics(); // รีเฟรชโพสต์
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Successfully deleted!")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Deletion failed!")));
    }
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
            ),
            ElevatedButton(
              onPressed: () {
                createTopic(titleController.text, contentController.text);
                Navigator.pop(context);
              },
              child: Text("Create"),
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
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showCreateTopicDialog, // เพิ่มปุ่มสร้างโพสต์ใหม่
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          final username = getUsernameById(
            topic['userId'],
          ); // Get username from userId

          return Card(
            child: Container(
              height: 100, // กำหนดความสูงที่ต้องการให้แต่ละรายการใน ListView
              child: ListTile(
                title: Text(topic['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic['content']),
                    Text(
                      'Posted by: $username', // Show username
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to topic details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TopicDetailsPage(
                            topic: topic,
                            users: users,
                            loggedInUser:
                                widget.user, // ส่งข้อมูลผู้ใช้ที่ล็อกอินไปด้วย
                          ),
                    ),
                  );
                },
                trailing:
                    widget.user['_id'] == topic['userId']
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed:
                                  () => showEditDialog(
                                    topic['_id'],
                                    topic['title'],
                                    topic['content'],
                                  ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteTopic(topic['_id']); // Delete topic
                              },
                            ),
                          ],
                        )
                        : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
