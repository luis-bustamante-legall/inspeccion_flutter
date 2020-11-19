import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legall_rimac_virtual/models/chat_model.dart';

class MessageClipRight extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 10.0;
    final arrow = 20.0;
    path.moveTo(radius,0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width-arrow, arrow);
    path.lineTo(size.width-arrow, size.height-radius);
    path.quadraticBezierTo((size.width-arrow), size.height,
        size.width-arrow-(radius),size.height);
    path.lineTo(radius,size.height);
    path.quadraticBezierTo(0, size.height,
      0,size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0,
        radius,0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(MessageClipRight oldClipper) => false;
}

class MessageClipLeft extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 10.0;
    final arrow = 20.0;
    path.moveTo(0,0);
    path.lineTo(size.width-radius, 0);
    path.quadraticBezierTo(size.width, 0,
        size.width,radius);
    path.lineTo(size.width,size.height-radius);
    path.quadraticBezierTo(size.width, size.height,
        size.width-radius,size.height);
    path.lineTo(arrow+radius,size.height);
    path.quadraticBezierTo(arrow, size.height,
        arrow,size.height - radius);
    path.lineTo(arrow, arrow);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(MessageClipLeft oldClipper) => false;
}

class ChatWidget extends StatelessWidget {
  final ChatSource source;
  final String body;
  final DateTime dateTime;
  final _dateFormat = DateFormat('dd MMM, yyyy hh:mm a');

  ChatWidget({
    this.source,
    this.dateTime,
    this.body
  });

  Alignment _getAlignment() {
    switch(source) {
      case ChatSource.insured:
        return Alignment.centerRight;
      case ChatSource.inspector:
        return Alignment.centerLeft;
      case ChatSource.system:
        return Alignment.center;
    }
    return null;
  }

  Alignment _getDateAlignment() {
    switch(source) {
      case ChatSource.insured:
        return Alignment.centerLeft;
      case ChatSource.inspector:
        return Alignment.centerRight;
      case ChatSource.system:
        return Alignment.center;
    }
    return null;
  }

  EdgeInsets _getMargin() {
    switch(source) {
      case ChatSource.inspector:
        return EdgeInsets.only(left: 0,right: 100, top: 7, bottom: 7);
      case ChatSource.insured:
        return EdgeInsets.only(left: 100,right: 0, top: 7, bottom: 7);
      case ChatSource.system:
        return EdgeInsets.only(left: 100,right: 100, top: 7, bottom: 7);
    }
    return null;
  }

  EdgeInsets _getPadding() {
    switch(source) {
      case ChatSource.inspector:
        return EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10);
      case ChatSource.insured:
        return EdgeInsets.only(left: 10, right: 30, top: 10, bottom: 10);
      case ChatSource.system:
        return EdgeInsets.all(10);
    }
    return null;
  }

  Color _getColor() {
    switch(source) {
      case ChatSource.inspector:
        return Colors.white;
      case ChatSource.insured:
        return Color.fromARGB(255,220, 238, 255);
      case ChatSource.system:
        return Color.fromARGB(255,180, 255,180 );
    }
    return null;
  }

  CustomClipper<Path> _getClip() {
    switch(source) {
      case ChatSource.inspector:
        return MessageClipLeft();
      case ChatSource.insured:
        return  MessageClipRight();
      case ChatSource.system:
        return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _t = Theme.of(context);
    return Align(
      alignment: _getAlignment(),
      child: ClipPath(
        child: Card(
          margin: _getMargin(),
          color: _getColor(),
          child: Padding(
            padding: _getPadding(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(body,
                  style: _t.textTheme.bodyText2,
                ),
                SizedBox(height: 5,),
                Align(
                  alignment: _getDateAlignment(),
                  child: Text(_dateFormat.format(dateTime),
                    style: _t.textTheme.caption,
                  )
                )
              ],
            ),
          )
        ),
        clipper: _getClip(),
      ),
    );
  }

}