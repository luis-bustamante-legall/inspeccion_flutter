import 'package:flutter/material.dart';
import 'package:legall_rimac_virtual/localizations.dart';

class ImageCard extends StatelessWidget {
  final Function() onTap;
  final Function() onHelp;
  final ImageProvider image;
  final Widget child;
  final IconData emptyIcon;
  final IconData icon;
  final Widget title;
  final Color color;
  final bool working;

  ImageCard({
    this.onTap,
    this.onHelp,
    this.emptyIcon,
    this.image,
    this.child,
    this.working,
    @required this.icon,
    this.color,
    @required this.title
  });

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);
    return Card(
        margin: EdgeInsets.all(10),
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              child ??
              Expanded(
                child: Container(
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
                    child: image == null && child == null ? Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(emptyIcon??Icons.photo,
                                color: Colors.white,
                              )
                          ),
                          Visibility(
                            visible: onHelp != null,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: InkWell(
                                onTap: onHelp,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child:Text(_l.translate('help'),
                                        style: TextStyle(
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.help,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              )
                            )
                          ),
                        ],
                      ),
                    ): null
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
                    child: (working??false) ?
                    SizedBox(
                      height: _t.accentIconTheme.size,
                      width: _t.accentIconTheme.size,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ):
                    Icon(icon,
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
