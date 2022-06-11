import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/configs/local_notification.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/constants.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/pages/base_screen.dart';
import 'package:finance_plan/pages/login_page.dart';
import 'package:finance_plan/widgtes/header_start.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  bool _isLogin = false;

  _initialPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('user_id') != null) {
      // Sudah pernah login
      setState(() => _isLogin = true);
    }

    if (_isLogin) {
      _loadWidget(_gohomepage);
    } else {
      _loadWidget(_gologinpage);
    }
  }

  @override
  void initState() {
    super.initState();
    _initialPref();
    loadData();
  }

  _loadWidget(goto) async {
    var _duration = const Duration(seconds: 5);
    return Timer(_duration, goto);
  }

  void _gologinpage() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _gohomepage() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  int _counterValue = 0;

  void loadData() async {
    _counterValue = await BackGroundWork.instance._getBackGroundCounterValue();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);

    return Scaffold(
      body: Container(
        width: _sizeConfig.screenWidth,
        height: _sizeConfig.screenHeight,
        margin: EdgeInsets.only(
          left: _sizeConfig.marginHorizontalSize!,
          right: _sizeConfig.marginHorizontalSize!,
        ),
        color: mBackgroundColor,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: _sizeConfig.blockHorizontal! * 60,
                  height: _sizeConfig.blockHorizontal! * 60,
                  child: Image.asset(
                    'assets/images/logo.png',
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print(TAG + "callbackDispatcher");
    int value = await BackGroundWork.instance._getBackGroundCounterValue();
    BackGroundWork.instance._loadCounterValue(value + 1);
    return Future.value(true);
  });
}

class BackGroundWork {
  BackGroundWork._privateConstructor();

  static final BackGroundWork _instance = BackGroundWork._privateConstructor();

  static BackGroundWork get instance => _instance;

  _loadCounterValue(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('BackGroundCounterValue', value);
  }

  Future getDocs(String userid) async {
    CollectionReference user = FirebaseFirestore.instance.collection('users');
    List<QueryDocumentSnapshot> docSnap = await user
        .doc(userid)
        .firestore
        .collection('goals')
        .get()
        .then((value) {
      // print('goalsss : '+value.)
      return value.docs;
    });

    for (var i = 0; i < docSnap.length; i++) {
      print('goals $i');
    }
  }

  Future<int> _getBackGroundCounterValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint(TAG + '_getBackGroundCounterValue');
    String userId = prefs.getString('user_id')!;
    // await getDocs(userId);
    CollectionReference user = FirebaseFirestore.instance.collection('users');
    // List<QueryDocumentSnapshot> docSnap = await user
    //     .doc(userId)
    //     .firestore
    //     .collection('goals')
    //     .get()
    //     .then((value) {
    //   // print('goalsss : '+value.)
    //   return value.docs;
    // });

    QuerySnapshot query = await user.doc(userId).collection('goals').get();
    final data = query.docs.map((doc) => doc.data()).toList();
    // final docc = await user.doc(userId).collection('goals').doc();
    var idGoals = [];
    for (var i = 0; i < data.length; i++) {
      debugPrint('doc id :' + query.docs.elementAt(i).id);
      idGoals.add(query.docs.elementAt(i).id);
    }

    // loop goals
    for (var i = 0; i < idGoals.length; i++) {
      QuerySnapshot checklists = await user
          .doc(userId)
          .collection('goals')
          .doc(idGoals[i])
          .collection('checklistgoals')
          .where('status_pembayaran', isEqualTo: 'undone')
          .get();

      // loop checklist
      for (var j = 0; j < checklists.size; j++) {
        List<QueryDocumentSnapshot> checklistDocs = checklists.docs;
        debugPrint('checklistgoals deadline_bulanan : ' +
            checklistDocs.elementAt(j).get('deadline_bulanan'));

        String judul = query.docs.elementAt(i).get('nama');
        String deadline = checklistDocs.elementAt(j).get('deadline_bulanan');

        var date = DateTime.now();
        String now = date.toString().split('.')[0];
        now = now.split(' ')[0];

        DateTime current = DateTime.parse(now);
        DateTime dl = DateTime.parse(deadline);

        // LocalNotification.ShowOneTimeNotification(
        //     scheduledDate: tz.TZDateTime.parse(tz.local, deadline)
        //         .add(const Duration(minutes: 1)),
        //     title: 'Scheduler Goal $judul',
        //     body: 'Ayo segera penuhi target mu pada $deadline');

        // Hari H-3
        if (current.compareTo(dl.subtract(const Duration(days: 3))) == 0) {
          LocalNotification.ShowNotification(
              title: 'Goal $judul',
              body: 'Ayo segera penuhi target mu pada $deadline');
        }

        // Hari H-2
        if (current.compareTo(dl.subtract(const Duration(days: 2))) == 0) {
          LocalNotification.ShowNotification(
              title: 'Goal $judul',
              body: 'Ayo segera penuhi target mu pada $deadline');
        }

        // Hari H-1
        if (current.compareTo(dl.subtract(const Duration(days: 1))) == 0) {
          LocalNotification.ShowNotification(
              title: 'Goal $judul',
              body: 'Ayo segera penuhi target mu pada $deadline');
        }

        // Hari H
        if (current.compareTo(dl) == 0) {
          LocalNotification.ShowNotification(
              title: 'Goal $judul',
              body: 'Ayo segera penuhi target mu pada $deadline');
        }
      }
    }

    // for (var item in data) {
    //   debugPrint(item.toString());
    // }
    // for (var i = 0; i < docSnap.length; i++) {
    //   print('goals $i');
    // }
    debugPrint(TAG + "-USER=" + userId);

    //Return bool
    int counterValue = prefs.getInt('BackGroundCounterValue') ?? 0;
    return counterValue;
  }
}
