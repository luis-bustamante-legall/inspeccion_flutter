
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/chat_model.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:legall_rimac_virtual/widgets/chat_widget.dart';
import 'package:legall_rimac_virtual/widgets/phone_call_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  var _messageController = TextEditingController();
  var _scrollController = ScrollController();
  String _inspectionId;
  ChatsBloc _chatsBloc;

  void _scrollToEnd() {
    Timer(
      Duration(milliseconds: 10),
          () => _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          ),
    );
  }

  void _sendMessage(message) async {
    _messageController.text = '';
    _chatsBloc.add(SendChat(_inspectionId,
      body: message,
      source: ChatSource.insured,
    ));
  }

  @override
  void initState() {
    super.initState();
    _chatsBloc = BlocProvider.of<ChatsBloc>(context);
    SettingsRepository _settingsRepository =
      RepositoryProvider.of<SettingsRepository>(context);
    _inspectionId = _settingsRepository.getInspectionId();
    _chatsBloc.add(LoadChats(_inspectionId));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat de inspección'),
        actions: [
          PhoneCallButton()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: _t.buttonColor,
              child:  BlocBuilder<ChatsBloc,ChatsState>(
                builder: (context,state) {
                  if (state is ChatsLoading)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  else if (state is ChatsLoaded) {
                    if (state.success) {
                      Future.delayed(Duration(milliseconds: 10),() {
                        _scrollToEnd();
                      });
                      return ListView(
                        padding: EdgeInsets.all(10),
                        controller: _scrollController,
                        children: state.chats.map((chat) =>
                            ChatWidget(
                                body: chat.body,
                                dateTime: chat.dateTime,
                                source: chat.source,
                            )
                        ).toList(),
                      );
                    } else {
                      var messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(SnackBar(
                        duration: Duration(seconds: 4),
                        backgroundColor: Colors.red,
                        content: ListTile(
                          leading: Icon(Icons.announcement_rounded),
                          title: Text(_l.translate('problems loading chats'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ));
                    }
                  }
                  return Container();
                },
              )
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
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
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