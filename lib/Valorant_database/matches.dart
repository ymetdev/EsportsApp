import 'package:flutter/material.dart';

class MatchesPage extends StatelessWidget {
  final List<dynamic> matches;

  MatchesPage({required this.matches});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Matches')),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          var match = matches[index];
          var teams = match['teams'];
          var team1 = teams[0];
          var team2 = teams[1];

          return Card(
            margin: EdgeInsets.all(10),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // แสดงชื่อ Tournament และ Event
                  Text(
                    '${match['tournament']} - ${match['event']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              ),
                            ),
                            Text('Country: ${team1['country']}'),
                            Text('Score: ${team1['score']}'),
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
                              ),
                            ),
                            Text('Country: ${team2['country']}'),
                            Text('Score: ${team2['score']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // แสดงสถานะของการแข่งขัน
                  Text('Status: ${match['status']}'),
                  SizedBox(height: 8),

                  // แสดงรูปภาพของการแข่งขัน
                  Image.network(
                    'https://cors-anywhere.herokuapp.com/' + match['img'],
                    height: 50,

                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 8),

                  // แสดงวันที่และเวลา
                  Text('Date: ${match['utcDate']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
