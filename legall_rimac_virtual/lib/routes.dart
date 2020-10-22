import 'package:legall_rimac_virtual/screens/screens.dart';

var routes = {
  AppRoutes.home: (context) => HomeScreen(),
  AppRoutes.inspection: (context) => InspectionScreen()
};

class AppRoutes {
  static final String home = '/home';
  static final String inspection = '/inspection';

}