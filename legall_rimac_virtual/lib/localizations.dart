import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale _locale;
  Map<String, dynamic> _localizedMessages = Map();

  AppLocalizations(this._locale);

  static const String _defaultLangCode = "es";

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
  }

  static LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  Future<void> load() async {
    String jsonString;
    try {
      jsonString = await rootBundle
          .loadString("assets/i18n/${_locale.languageCode}.json");
    } catch (_) {
      jsonString =
      await rootBundle.loadString("assets/i18n/$_defaultLangCode.json");
    }
    _localizedMessages = json.decode(jsonString);
  }

  String translate(String key, {Map<String, dynamic> arguments, dynamic segment}) {
    if (_localizedMessages.containsKey(key)) {
      if (_localizedMessages[key] is Map) {
        if (segment == null) {
          return "Missing \"$key:$segment\"";
        } else {
          if ((_localizedMessages[key] as Map).containsKey(segment)) {
            return processMessage(_localizedMessages[key][segment], arguments);
          } else {
            return "Missing \"$key:$segment\"";
          }
        }
      } else {
        return processMessage(_localizedMessages[key], arguments);
      }
    } else {
      return "Missing \"$key\"";
    }
  }

  String processMessage(String message, Map<String, dynamic> arguments) {
    if (arguments != null) {
      arguments.forEach((key, value) {
        message = message.replaceAll("\$$key", value);
      });
    }

    return message;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations appLocalizations = AppLocalizations(locale);
    await appLocalizations.load();

    return appLocalizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) {
    return ["es"].contains(locale.languageCode);
  }
}