
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:legall_rimac_virtual/widgets/message_widget.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  var _messageController = TextEditingController();
  var _scrollController = ScrollController( );

  var chats = [
    ['Hola Hilda, Soy Andrew,Yo seré tu inspector en este proceso.',false],
    ['Hola, ya subi el video del vehiculo.', true]
  ];

  void _scrollToEnd() {
    Timer(
      Duration(milliseconds: 200),
          () => _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          ),
    );
  }

  void _sendMessage(message) {
    _messageController.text = '';
    setState(() {
      chats.add([message,true]);
    });
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat de inspección')
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: _t.buttonColor,
              child:  ListView(
                padding: EdgeInsets.all(10),
                controller: _scrollController,
                children: chats.map((ls) =>
                  MessageWidget(
                    body: ls.first,
                    dateTime: DateTime.now(),
                    isOwn: ls.last
                  )
                ).toList(),
              ),
            )
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration.collapsed(
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (msg) {
                        _sendMessage(msg);
                      },
                    )
                  )
                ),
                Container(
                  decoration: BoxDecoration(
                    color: _t.accentColor,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  child: IconButton(
                    color: _t.accentIconTheme.color,
                    icon: Icon(Icons.send),
                    padding: EdgeInsets.all(0),
                    onPressed: (){
                      _sendMessage(_messageController.text);
                    }
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }

}