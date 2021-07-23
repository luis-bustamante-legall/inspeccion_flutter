import 'package:flutter/material.dart';

class ProgressDialog {
  final context;
  bool isVisibleProgress = false;

  BuildContext _contextProgress;

  ProgressDialog(this.context);

  void show() {
    if (!isVisibleProgress) {
      isVisibleProgress = true;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            _contextProgress = context;
            return Center(
                child: Container(
                  alignment: Alignment.center,
                  width: 180,
                  height: 90,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 10),
                      Text("Cargando...",style: TextStyle(color: Colors.blue,fontSize: 14,decoration: TextDecoration.none),)
                    ],
                  ),
                ),
            );
          });
    }
  }

  void hide() {
    if (isVisibleProgress) {
      isVisibleProgress = false;
      Navigator.pop(_contextProgress);
    }
  }
}
