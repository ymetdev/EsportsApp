import 'package:flutter/material.dart';

class MatchesPage extends StatelessWidget {
  final List<dynamic> matches;

  const MatchesPage({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101010), // เปลี่ยนสีพื้นหลัง
      appBar: AppBar(
        title: Text('Matches'),
        backgroundColor: Color(0xFFA12C2C),
        foregroundColor: Colors.white, // สีของ AppBar
      ),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          var match = matches[index];
          var teams = match['teams'];
          var team1 = teams[0];
          var team2 = teams[1];

          return Card(
            margin: EdgeInsets.all(10),
            elevation: 3, // เพิ่มเงาของ Card
            color: Color(0xFF202020), // เปลี่ยนสีของ Card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // เพิ่มมุมมนให้กับ Card
            ),
            shadowColor: Colors.black.withOpacity(0.5), // ปรับสีเงาของ Card
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // แสดงชื่อ Tournament และ Event
                  Text(
                    '${match['tournament']} - ${match['event']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),

                  // แสดงทีมที่แข่งขัน
                  Row(
                    children: [
                      // แสดงทีมแรก
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team1['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Country: ${team1['country']}',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            // แสดง Score และใช้เครื่องหมายลบถ้าไม่มีค่า
                            Text(
                              'Score: ${team1['score'] ?? "-"}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber, // ใช้สีที่ทำให้ชัดขึ้น
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16), // ระยะห่างระหว่างทีม
                      // แสดงทีมที่สอง
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team2['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Country: ${team2['country']}',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            // แสดง Score และใช้เครื่องหมายลบถ้าไม่มีค่า
                            Text(
                              'Score: ${team2['score'] ?? "-"}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber, // ใช้สีที่ทำให้ชัดขึ้น
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // แสดงสถานะของการแข่งขัน
                  Text(
                    'Status: ${match['status']}',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),

                  // แสดงรูปภาพของการแข่งขัน
                  Image.network(
                    'https://cors-anywhere.herokuapp.com/' + match['img'],
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 8),

                  // แสดงวันที่และเวลา
                  Text(
                    'Date: ${match['utcDate']}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
