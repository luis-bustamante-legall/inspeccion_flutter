import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/chat_model.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import '../routes.dart';

class PhoneCallButton extends StatelessWidget {
  Widget build(BuildContext context) {
    final ThemeData _t = Theme.of(context);
    final AppLocalizations _l = AppLocalizations.of(context);
    return IconButton(
        onPressed: () async {
          ChatsBloc chatsBloc = BlocProvider.of<ChatsBloc>(context);
          SettingsRepository settingsRepository = 
            RepositoryProvider.of<SettingsRepository>(context);
          chatsBloc.add(SendChat(settingsRepository.getInspectionId(),
            source: ChatSource.system,
            body: _l.translate('a call was requested')
          ));
        },
        icon: Icon(Icons.phone_callback,
            color: _t.accentIconTheme.color
        ),
        tooltip: 'Solicitar una llamada',
    );
  }
}

