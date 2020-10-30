import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class MessageWidget extends StatelessWidget {
  final isOwn;
  final String body;
  final DateTime dateTime;
  final _dateFormat = DateFormat('dd MMM, yyyy hh:mm a');

  MessageWidget({
    this.isOwn,
    this.dateTime,
    this.body
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData _t = Theme.of(context);
    return Align(
      alignment: (isOwn??false) ? Alignment.centerRight: Alignment.centerLeft,
      child: ClipPath(
        child: Card(
          margin: EdgeInsets.only(left: (isOwn??false) ? 100: 0,right: (isOwn??false) ? 0: 100, top: 7, bottom: 7),
          color: (isOwn??false) ? Colors.white: Color.fromARGB(255,220, 238, 255),
          child: Padding(
            padding: EdgeInsets.only(
                left: (isOwn??false) ? 10: 30,
                top: 10,
                right: !(isOwn??false) ? 10: 30,
                bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(body,
                  style: _t.textTheme.bodyText2,
                ),
                SizedBox(height: 5,),
                Align(
                  alignment: (isOwn??false) ? Alignment.bottomLeft: Alignment.bottomRight,
                  child: Text(_dateFormat.format(dateTime),
                    style: _t.textTheme.caption,
                  )
                )
              ],
            ),
          )
        ),
        clipper: (isOwn??false) ? MessageClipRight(): MessageClipLeft(),
      ),
    );
  }

}