import 'package:finance_plan/pages/base_screen.dart';
import 'package:finance_plan/pages/detail_goals_page.dart';
import 'package:finance_plan/pages/edit_goals_page.dart';
import 'package:finance_plan/pages/edit_profile_page.dart';
import 'package:finance_plan/pages/goals_page.dart';
import 'package:finance_plan/pages/guest_page.dart';
import 'package:finance_plan/pages/laporan_page.dart';
import 'package:finance_plan/pages/list_berita.dart';
import 'package:finance_plan/pages/list_goals_page.dart';
import 'package:finance_plan/pages/loading_page.dart';
import 'package:finance_plan/pages/login_page.dart';
import 'package:finance_plan/pages/option_page.dart';
import 'package:finance_plan/pages/pemasukan_page.dart';
import 'package:finance_plan/pages/pengeluaran_page.dart';
import 'package:finance_plan/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'configs/local_notification.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

/* void callbackDispatcher() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
    print('user id : '+preferences.getString('user_id')!);
  Workmanager().executeTask((taskName, inputData) async {
    // show the notification
    print('show notification');
    LocalNotification.Initializer();

    /* Get Notification data from firestore */
    
    await getDocs();
    
    /* End */

    LocalNotification.ShowNotification();
    LocalNotification.ShowOneTimeNotification(
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)));
    return Future.value(true);
  });
}

Future getDocs() async {
  CollectionReference user = FirebaseFirestore.instance.collection('users');
  List<QueryDocumentSnapshot> docSnap = await user
    .doc(user.id)
    .firestore
    .collection('goals').get().then((value) {
      // print('goalsss : '+value.)
      return value.docs;
    });

    for (var i = 0; i < docSnap.length; i++) {
      print('goals $i');
    }
} */

void main() async {
  tz.initializeTimeZones();
  var jakarta = tz.getLocation('Asia/Jakarta');
  tz.setLocalLocation(jakarta);

  ErrorWidget.builder = (FlutterErrorDetails details) => const LoadingPage();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  // Workmanager().registerOneOffTask('1', 'notification task');
  // Workmanager().registerPeriodicTask("test_workertask", "test_workertask",
  //     inputData: {"data1": "value1", "data2": "value2"},
  //     frequency: Duration(minutes: 15));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Plan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/guest': (context) => const GuestPage(),
        '/login': (context) => const LoginPage(),
        // '/register': (context) => const RegisterPage(),
        '/home': (context) => const BaseScreen(),
        '/pemasukan': (context) => const PemasukanPage(),
        '/pengeluaran': (context) => const PengeluaranPage(),
        '/option': (context) => const OptionPage(),
        '/editProfile': (context) => const EditProfilePage(),
        '/goals': (context) => const GoalsPage(),
        '/list_goals': (context) => const ListGoalsPage(),
        '/detail_goals': (context) => const DetailGoalsPage(),
        '/edit_goals': (context) => const EditGoalsPage(),
        '/laporan': (context) => const LaporanPage(),
        // '/list_berita': (context) => const ListBerita(),
      },
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}
