import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumberdash/lumberdash.dart';

class AppBlocDelegate extends BlocDelegate {

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    logMessage('${transition.event}: ${transition.currentState} -> ${transition.nextState}');
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    //FirebaseCrashlytics.instance.recordError(error, stacktrace);
    logError(error, stacktrace: stacktrace);
  }
}
