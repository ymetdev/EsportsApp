import 'package:flutter/material.dart';

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  CustomPageRoute({required this.page})
    : super(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut; // ให้ลื่นไหลขึ้น
          var tween = Tween<Offset>(
            begin: Offset(1.0, 0.0), // เริ่มจากด้านขวา
            end: Offset.zero, // ไปที่ตำแหน่งปกติ
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
}
