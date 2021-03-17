import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/chat_model.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';

class PhoneCallButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PhoneCallButtonState();
}

class PhoneCallButtonState extends State<PhoneCallButton> {
  Widget build(BuildContext context) {
    final ThemeData _t = Theme.of(context);
    final AppLocalizations _l = AppLocalizations.of(context);
    var _enableButton = false;

    return BlocBuilder<ChatsBloc,ChatsState>(
      builder: (context,state) {
        if (state is ChatsLoaded) {
          if (_enableButton == false) {
            if (state.chats == null || state.chats.isEmpty) {
              _enableButton = true;
            } else {
              var lastChat = state.chats.last;
              _enableButton = lastChat.source != ChatSource.system;
            }
          }
        }

        return IconButton(
          onPressed:() {
            if (_enableButton) {
              _enableButton = false;
              SettingsRepository settingsRepository =
              RepositoryProvider.of<SettingsRepository>(context);
              BlocProvider.of<ChatsBloc>(context)
                  .add(SendChat(settingsRepository.getInspectionId(),
                  source: ChatSource.system,
                  body: _l.translate('a call was requested'),
                  read: false
              ));
            }
          },
          icon: Icon(Icons.phone_callback,
              color: _t.accentIconTheme.color
          ),
          tooltip: 'Solicitar una llamada',
        );
      },
    );
  }
}

