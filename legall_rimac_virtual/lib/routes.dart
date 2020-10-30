import 'package:legall_rimac_virtual/screens/screens.dart';
import 'package:legall_rimac_virtual/screens/video_recording_screen.dart';

var routes = {
  AppRoutes.home: (context) => HomeScreen(),
  AppRoutes.inspection: (context) => InspectionScreen(),
  AppRoutes.chat: (context) => ChatScreen(),
  AppRoutes.videoRecording: (context) => VideoRecordingScreen(),
  AppRoutes.inspectionStep1: (context) => InspectionStep1Screen(),
  AppRoutes.inspectionStep2: (context) => InspectionStep2Screen(),
  AppRoutes.inspectionStep3: (context) => InspectionStep3Screen(),
  AppRoutes.inspectionStep4: (context) => InspectionStep4Screen()
};

class AppRoutes {
  static final String home = '/home';
  static final String inspection = '/inspection';
  static final String chat = '/chat';
  static final String videoRecording = '/video_recording';
  static final String inspectionStep1 = '$inspection/step1';
  static final String inspectionStep2 = '$inspection/step2';
  static final String inspectionStep3 = '$inspection/step3';
  static final String inspectionStep4 = '$inspection/step4';

}