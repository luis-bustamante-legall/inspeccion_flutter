import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final Function() onTap;
  final ImageProvider image;
  final Widget child;
  final double height;
  final IconData icon;
  final Widget title;
  final Color color;

  ImageCard({
    this.onTap,
    this.image,
    this.child,
    @required this.height,
    @required this.icon,
    this.color,
    @required this.title
  });

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    return Card(
        margin: EdgeInsets.all(10),
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              child ??
              Container(
                height: height,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  image: image != null ?
                      DecorationImage(
                        image: image,
                        fit: BoxFit.cover
                      ): null,
                  color:Colors.grey
                ),
              ),
              Container(
                child: Align(
                  alignment: Alignment(0.0, 1.0),
                  heightFactor: 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color??_t.accentColor
                    ),
                    padding: EdgeInsets.all(10),
                    child: Icon(icon,
                      color: _t.accentIconTheme.color,
                      size: _t.accentIconTheme.size,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: title,
                )
              )
            ],
          )
        )
    );
  }
}
