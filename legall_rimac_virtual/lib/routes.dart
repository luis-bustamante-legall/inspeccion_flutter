import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/blocs/inspection_bloc.dart';
import 'package:legall_rimac_virtual/blocs/photo_bloc.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:legall_rimac_virtual/screens/screens.dart';

var routes = {
  AppRoutes.splash: (context) => SplashScreen(),
  AppRoutes.home: (context) =>  MultiBlocProvider(
    providers: [
      BlocProvider(
          create: (context) => InspectionBloc(
              repository: RepositoryProvider.of<InspectionsRepository>(context),
              settings: RepositoryProvider.of<SettingsRepository>(context))
      )
    ],
    child: HomeScreen(),
  ),
  AppRoutes.inspection: (context) => MultiBlocProvider(
    providers: [
      BlocProvider(
          create: (context) => InspectionBloc(
              repository: RepositoryProvider.of<InspectionsRepository>(context),
              settings: RepositoryProvider.of<SettingsRepository>(context))
      )
    ],
    child: InspectionScreen(),
  ),
  AppRoutes.chat: (context) =>  MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ChatsBloc(
            repository: RepositoryProvider.of<ChatsRepository>(context)),
      )
    ],
    child: ChatScreen(),
  ),
  AppRoutes.inspectionStep1: (context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ChatsBloc(
            repository: RepositoryProvider.of<ChatsRepository>(context)),
      ),
      BlocProvider(
          create: (context) => VideoBloc(
              repository: RepositoryProvider.of<VideosRepository>(context))
      )
    ],
    child: InspectionStep1Screen(),
  ),
  AppRoutes.inspectionStep2: (context) =>  MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ChatsBloc(
            repository: RepositoryProvider.of<ChatsRepository>(context))
      ),
      BlocProvider(
        create: (context) => PhotoBloc(
            repository: RepositoryProvider.of<PhotosRepository>(context))
      )
    ],
    child: InspectionStep2Screen(),
  ),
  AppRoutes.inspectionStep3: (context) =>  MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ChatsBloc(
            repository: RepositoryProvider.of<ChatsRepository>(context))
      ),
      BlocProvider(
          create: (context) => PhotoBloc(
              repository: RepositoryProvider.of<PhotosRepository>(context))
      )
    ],
    child: InspectionStep3Screen(),
  ),
  AppRoutes.inspectionStep4: (context) =>  MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ChatsBloc(
            repository: RepositoryProvider.of<ChatsRepository>(context))
      ),
      BlocProvider(
          create: (context) => InspectionBloc(
              repository: RepositoryProvider.of<InspectionsRepository>(context),
              settings: RepositoryProvider.of<SettingsRepository>(context))
      )
    ],
    child: InspectionStep4Screen(),
  ),
  AppRoutes.inspectionComplete: (context) =>  MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ChatsBloc(
            repository: RepositoryProvider.of<ChatsRepository>(context))
      )
    ],
    child: InspectionCompleteScreen(),
  ),
  AppRoutes.scheduleInspectionStep1: (context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => BrandBloc(repository: RepositoryProvider.of<BrandsRepository>(context)),
      ),
      BlocProvider(
        create: (context) => InspectionBloc(
            repository: RepositoryProvider.of<InspectionsRepository>(context),
            settings: RepositoryProvider.of<SettingsRepository>(context))
      )
    ],
    child: ScheduleInspectionStep1(),
  ),
  AppRoutes.scheduleInspectionStep2: (context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => PhotoBloc(repository: RepositoryProvider.of<PhotosRepository>(context)),
      ),
      BlocProvider(
          create: (context) => InspectionBloc(
              repository: RepositoryProvider.of<InspectionsRepository>(context),
              settings: RepositoryProvider.of<SettingsRepository>(context))
      )
    ],
    child: ScheduleInspectionStep2(),
  ),
};

class AppRoutes {
  static final String splash = '/';
  static final String home = '/home';
  static final String inspection = '/inspection';
  static final String chat = '/chat';
  static final String inspectionStep1 = '$inspection/step1';
  static final String inspectionStep2 = '$inspection/step2';
  static final String inspectionStep3 = '$inspection/step3';
  static final String inspectionStep4 = '$inspection/step4';
  static final String inspectionComplete = '$inspection/complete';
  static final String scheduleInspectionStep1 = '/schedule_inspection_step1';
  static final String scheduleInspectionStep2 = '/schedule_inspection_step2';
}