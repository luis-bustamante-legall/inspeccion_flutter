import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/models/chat_model.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';

class ChatButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatButtonState();
}

class ChatButtonState extends State<ChatButton> {
  int _chatPending = 0;
  bool _isShown = false;
  bool _firstMessage = true;
  String _inspectionId;
  ChatsBloc _chatsBloc;

  void _messageIncomming(String text) {
    var messenger = Scaffold.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      duration: Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(10),
      content: Text('Mensaje Nuevo:\n$text',
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }
  
  @override
  void initState() {
    super.initState();
    SettingsRepository _settingsRepository =
      RepositoryProvider.of<SettingsRepository>(context);
    _inspectionId = _settingsRepository.getInspectionId();
    _chatsBloc = BlocProvider.of<ChatsBloc>(context);
    _chatsBloc.add(LoadChats(_inspectionId));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    return BlocListener<ChatsBloc,ChatsState>(
      listener: (context,state) {
        if (state is ChatsLoaded) {
          if (state.success) {
            if (!_isShown) {
              var inspectorChats = state
                  .chats
                  .where((chat) =>
              (chat.source == ChatSource.inspector || chat.source == ChatSource.system) && !chat.read);
              setState(() {
                _chatPending = inspectorChats.length;
              });
              if (_firstMessage) {
                _firstMessage = false;
                return;
              }
              if (inspectorChats.isNotEmpty) {
                _messageIncomming(inspectorChats.last.body);
              }
            }
          }
        }
      },
      child: IconButton(
          onPressed: () async {
            _isShown = true;
            await Navigator.pushNamed(context, AppRoutes.chat);
            _isShown = false;
            _chatsBloc.add(ReadAllChats(_inspectionId));
          },
          icon: SizedBox(
            width: _t.accentIconTheme.size,
            height: _t.accentIconTheme.size,
            child:  Stack(
              children: [
                Center(
                    child: Icon(Icons.textsms,
                        color: _t.accentIconTheme.color,
                        size: _t.accentIconTheme.size
                    )
                ),
                Visibility(
                    visible: _chatPending > 0,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text('$_chatPending',
                            style: TextStyle(
                                color: Colors.white
                            )
                        ),
                      ),
                    )
                )
              ],
            ),
          )
      ),
    );
  }
}