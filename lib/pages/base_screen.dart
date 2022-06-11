import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:finance_plan/Network/api.dart';
import 'package:finance_plan/configs/auth_service.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/constants.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/cubit/user_cubit.dart';
import 'package:finance_plan/models/berita.dart';
import 'package:finance_plan/pages/detail_berita.dart';
import 'package:finance_plan/pages/detail_berita_webview.dart';
import 'package:finance_plan/pages/list_berita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:progress_indicator/progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final SizeConfig _sizeConfig = SizeConfig();
  CollectionReference user = FirebaseFirestore.instance.collection('users');
  SharedPreferences? pref;
  CollectionReference? goals;
  int _currentSaldo = 0;
  String? uid = '';
  String? name = '';
  String? email = '';
  String? photoUrl = '';
  int? length;
  bool _isGoogle = false;
  Berita? berita;

  _initBerita() {
    Network.getBerita().then((response) {
      setState(() {
        berita = response;
        length = berita!.data!.posts!.length;
        print('panjang : $length');
        // print(mitigasi);
      });
    });
  }

  var _banners = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg'
  ];

  Future<String> getPref() async {
    print('Load preferences');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    pref = preferences;
    print('user_id : ' + preferences.getString('user_id')!);
    print('name : ' + preferences.getString('name')!);
    String userId = preferences.getString('user_id')!;

    print('us $userId');
    name = preferences.getString('name')!;
    email = preferences.getString('email')!;
    photoUrl = preferences.containsKey('photo_url')
        ? preferences.getString('photo_url')
        : '-';
    _isGoogle = preferences.containsKey('is_google')
        ? preferences.getBool('is_google')!
        : false;
    print('Completed preferences');

    return userId;
  }

  // Future<String> _currentSaldo(uid) async {
  //   String saldo = '0';
  //   await user.doc(uid).get().then((value) {
  //     setState(() {
  //       saldo = value.get('current_saldo');
  //     });
  //     print('saldoss : ${value.get('current_saldo')}');
  //   });
  //   return saldo;
  // }

  Future<void> _refresh() {
    return Future.delayed(Duration(seconds: 1));
  }

  @override
  void initState() {
    super.initState();
    _initBerita();
  }

  _logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (_isGoogle) {
      AuthServices services = AuthServices();

      try {
        await services.signOutFromGoogle();
        pref.clear();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } catch (e) {
        if (e is FirebaseAuthException) {
          var snackbar = SnackBar(
            content: Text(
              e.message!,
              style: mCardTitleStyle.copyWith(
                fontSize: _sizeConfig.blockHorizontal! * 4,
                fontWeight: FontWeight.w400,
              ),
            ),
            backgroundColor: mDangerColor,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      }
    } else {
      await FirebaseAuth.instance.signOut();
      pref.clear();

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);

    print('Build');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: getPref(),
          builder: (context, snap) {
            return BlocProvider(
              create: (context) => UserCubit(),
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  print('user id: ${snap.data}');
                  return SingleChildScrollView(
                    child: SizedBox(
                      width: _sizeConfig.screenWidth,
                      height: _sizeConfig.screenHeight,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[_header(), body(snap)]),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _myBottomBar(),
      floatingActionButton: _myFloat(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget body(snap) {
    var saldo;
    user.doc(snap.data.toString()).get().then((value) {
      setState(() {
        _currentSaldo = value.get('current_saldo');
      });
      print('saldos $_currentSaldo');
    });
    return Expanded(
      child: Stack(
        children: [
          _saldoLayout(_currentSaldo),
          Positioned(
            top: _sizeConfig.blockVertical! * 12,
            child: Container(
              width: _sizeConfig.screenWidth,
              // margin: EdgeInsets.only(
              //   top: _sizeConfig.blockVertical! * 4,
              // ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: _sizeConfig.blockVertical! * 4,
                        left: _sizeConfig.marginHorizontalSize!,
                        right: _sizeConfig.marginHorizontalSize!),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Artikel',
                          style: mCardTitleStyle.copyWith(
                              color: Colors.black, fontWeight: FontWeight.w800),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ListBerita()));
                          },
                          child: Text(
                            'Selengkapnya',
                            style: mCardTitleStyle.copyWith(
                                color: mYellowColor,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _bannerLayout(),
                  Padding(
                    padding: EdgeInsets.only(
                        top: _sizeConfig.blockVertical! * 4,
                        left: _sizeConfig.marginHorizontalSize!,
                        right: _sizeConfig.marginHorizontalSize!),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Goals',
                            style: mCardTitleStyle.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/list_goals');
                            },
                            child: Text(
                              'Selengkapnya',
                              style: mCardTitleStyle.copyWith(
                                  color: mYellowColor,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ]),
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: user
                          .doc(snap.data.toString())
                          .collection('goals')
                          // .orderBy('created_at', descending: false)
                          .snapshots(),
                      builder: (context, snapGoals) {
                        if (snapGoals.hasData && snapGoals.data! != null) {
                          if (snapGoals.data!.size > 0) {
                            return Column(
                              children: snapGoals.data!.docs
                                  .take(3)
                                  .map((e) => _goalsLayout(
                                      title: e['nama'],
                                      target: e['target'].toString(),
                                      status: e['status'],
                                      deadline: e['deadline'],
                                      deadlineBulan: e['deadline_bulan'],
                                      createdAt: e['created_at']))
                                  .toList(),
                            );
                          } else {
                            return InkWell(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/goals'),
                              child: Container(
                                  width: _sizeConfig.screenWidth,
                                  height: _sizeConfig.blockVertical! * 10,
                                  margin: EdgeInsets.only(
                                    top: _sizeConfig.blockVertical! * 4,
                                    left: _sizeConfig.marginHorizontalSize!,
                                    right: _sizeConfig.marginHorizontalSize!,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    // vertical: _sizeConfig.marginHorizontalSize!,
                                    horizontal:
                                        _sizeConfig.marginHorizontalSize!,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mPrimaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                      child: Text(
                                    'Ayo segera buat tujuanmu menabung !!!',
                                    style: mTitleStyle.copyWith(
                                        color: Colors.white, fontSize: 18),
                                  ))),
                            );
                          }
                        } else {
                          return InkWell(
                            onTap: () => Navigator.pushNamed(context, '/goals'),
                            child: Container(
                                width: _sizeConfig.screenWidth,
                                height: _sizeConfig.blockVertical! * 10,
                                margin: EdgeInsets.only(
                                  top: _sizeConfig.blockVertical! * 4,
                                  left: _sizeConfig.marginHorizontalSize!,
                                  right: _sizeConfig.marginHorizontalSize!,
                                ),
                                padding: EdgeInsets.symmetric(
                                  // vertical: _sizeConfig.marginHorizontalSize!,
                                  horizontal: _sizeConfig.marginHorizontalSize!,
                                ),
                                decoration: BoxDecoration(
                                  color: mPrimaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                    child: Text(
                                  'Ayo segera buat tujuanmu menabung !!!',
                                  style: mTitleStyle.copyWith(
                                      color: Colors.white, fontSize: 18),
                                ))),
                          );
                        }
                      }),

                  // _goalsLayout(),
                  // _goalsLayout(),
                  // _goalsLayout(),
                  SizedBox(height: _sizeConfig.blockVertical! * 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _saldoLayout(saldo) {
    return Container(
        width: _sizeConfig.screenWidth,
        height: _sizeConfig.blockVertical! * 12,
        margin: EdgeInsets.only(
          top: _sizeConfig.blockVertical! * 2,
          // left: _sizeConfig.marginHorizontalSize!,
          // right: _sizeConfig.marginHorizontalSize!,
        ),
        padding: EdgeInsets.all(_sizeConfig.marginHorizontalSize!),
        decoration: const BoxDecoration(
          color: mPrimaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Row(
              children: [
                RichText(
                  text: TextSpan(
                      text: 'Saldo Tabungan\n',
                      style: mRowTextStyle.copyWith(
                          fontSize: _sizeConfig.blockHorizontal! * 4,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      children: [
                        WidgetSpan(
                            child: Icon(
                          FontAwesomeIcons.wallet,
                          size: _sizeConfig.blockHorizontal! * 3,
                        )),
                        WidgetSpan(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(' Rp. ${currencyFormat.format(saldo)}',
                              style: mRowTextStyle.copyWith(
                                  fontSize: _sizeConfig.blockHorizontal! * 3.4,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ))
                      ]),
                ),
                SizedBox(
                  width: _sizeConfig.blockHorizontal! * 2,
                ),
                Center(
                  child: SizedBox(
                    width: _sizeConfig.blockHorizontal! * 4.4,
                    height: _sizeConfig.blockHorizontal! * 4.4,
                    child: Material(
                      type: MaterialType.circle,
                      color: mYellowColor,
                      child: IconButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () {
                            Navigator.pushNamed(context, '/pemasukan');
                          },
                          color: Colors.white,
                          icon: Icon(
                            FontAwesomeIcons.plus,
                            size: _sizeConfig.blockHorizontal! * 3,
                          )),
                    ),
                  ),
                )
              ],
            )),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: _sizeConfig.blockHorizontal! * 2),
              width: 2,
              height: 100,
              color: Colors.black,
            ),
            Expanded(
                child: Row(
              children: [
                RichText(
                  text: TextSpan(
                      text: 'Rekap Bulanan\n',
                      style: mRowTextStyle.copyWith(
                          fontSize: _sizeConfig.blockHorizontal! * 4,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      children: [
                        WidgetSpan(
                            child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/laporan');
                          },
                          child: Text('Klik disini',
                              style: mRowTextStyle.copyWith(
                                  fontSize: _sizeConfig.blockHorizontal! * 3.4,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  color: Colors.white)),
                        ))
                      ]),
                ),
                SizedBox(
                  width: _sizeConfig.blockHorizontal! * 2,
                ),
              ],
            ))
          ],
        ));
  }

  Container _bannerLayout() {
    return Container(
      margin: EdgeInsets.only(
        top: _sizeConfig.blockVertical! * 5,
      ),
      child: Center(
          child: berita != null
              ? CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 140.0,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  itemCount: length,
                  itemBuilder:
                      (BuildContext context, int itemIndex, int pageIndexView) {
                    return Stack(
                      children: [
                        Center(
                          child: Container(
                            width: _sizeConfig.blockHorizontal! * 80,
                            height: _sizeConfig.blockVertical! * 30,
                            child: Image.network(
                              berita!.data!.posts![itemIndex].thumbnail
                                  .toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailBeritaWebview(
                                      link:
                                          berita!.data!.posts![itemIndex].link),
                                ));
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => DetailBerita(
                            //               link: berita!
                            //                   .data!.posts![itemIndex].link,
                            //               title: berita!
                            //                   .data!.posts![itemIndex].title,
                            //               pubDate: berita!
                            //                   .data!.posts![itemIndex].pubDate,
                            //               description: berita!.data!
                            //                   .posts![itemIndex].description,
                            //               thumbnail: berita!.data!
                            //                   .posts![itemIndex].thumbnail,
                            //             )));
                          },
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: _sizeConfig.blockVertical! * 8,
                              color: Colors.black.withOpacity(0.7),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    berita!.data!.posts![itemIndex].title
                                        .toString(),
                                    style: mSubtitleStyle.copyWith(
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  // [0, 1, 2].map((i) {
                  //   return Builder(
                  //     builder: (BuildContext context) {
                  //       return InkWell(
                  //         onTap: () {
                  //           print('click banner $i');
                  //         },
                  //         child: Container(
                  //           width: MediaQuery.of(context).size.width,
                  //           margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  //           child: ClipRRect(
                  //             borderRadius: BorderRadius.circular(12),
                  //             child: Image.asset(_banners[i], fit: BoxFit.cover),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   );
                  // }).toList(),
                )
              : SizedBox(
                  height: _sizeConfig.blockVertical! * 15,
                  child: const Center(child: CircularProgressIndicator()),
                )),
    );
  }

  Container _goalsLayout(
      {required String title,
      required String target,
      required String status,
      required String deadline,
      required String createdAt,
      required num deadlineBulan}) {
    deadline = deadline.split('-')[1];
    createdAt = createdAt.split('-')[1];

    var month = int.parse(deadline) - int.parse(createdAt);
    var perbulan = (int.parse(target) / deadlineBulan).toStringAsFixed(0);

    return Container(
        width: _sizeConfig.screenWidth,
        height: _sizeConfig.blockVertical! * 10,
        margin: EdgeInsets.only(
          top: _sizeConfig.blockVertical! * 4,
          left: _sizeConfig.marginHorizontalSize!,
          right: _sizeConfig.marginHorizontalSize!,
        ),
        padding: EdgeInsets.symmetric(
          // vertical: _sizeConfig.marginHorizontalSize!,
          horizontal: _sizeConfig.marginHorizontalSize!,
        ),
        decoration: BoxDecoration(
          color: mPrimaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: mRowTextStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 4,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                Text(
                  'Rp. ${currencyFormat.format(int.parse(target))}',
                  style: mRowTextStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 4,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ],
            ),
            SizedBox(
              height: _sizeConfig.blockVertical! * 0.6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                    text: TextSpan(
                        text: status,
                        style: mWarningTextStyle.copyWith(
                          fontSize: _sizeConfig.blockHorizontal! * 3.4,
                          fontWeight: FontWeight.w400,
                        ),
                        children: <TextSpan>[
                      TextSpan(
                        text: ' - $deadlineBulan Bulan',
                        style: mRowTextStyle.copyWith(
                            fontSize: _sizeConfig.blockHorizontal! * 3.4,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      )
                    ])),
                Text(
                  'Rp. ${currencyFormat.format(int.parse(perbulan))}/Bulan',
                  style: mRowTextStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 3.4,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ],
            ),
          ],
        ));
  }

  Row _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: _sizeConfig.marginHorizontalSize! * 2,
          height: _sizeConfig.marginHorizontalSize! * 2,
          margin: EdgeInsets.only(
              top: _sizeConfig.marginHorizontalSize! / 2,
              left: _sizeConfig.marginHorizontalSize!,
              right: _sizeConfig.blockHorizontal! * 3),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              image: photoUrl!.isNotEmpty && photoUrl != '-'
                  ? DecorationImage(
                      image: NetworkImage(
                        photoUrl!,
                      ),
                      fit: BoxFit.cover)
                  : const DecorationImage(
                      image: AssetImage(
                        'assets/images/ic-profile.png',
                      ),
                      fit: BoxFit.cover)),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: _sizeConfig.blockVertical! * 2,
              left: _sizeConfig.blockVertical! * 1),
          child: Text(
            name != null ? '$name\n' : 'User\n',
            style: mRowTextStyle.copyWith(
                fontSize: _sizeConfig.blockHorizontal! * 4,
                fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, '/option');
            },
            icon: const Icon(
              FontAwesomeIcons.bell,
              size: 18,
              color: Colors.black,
            )),
        Padding(
          padding:
              EdgeInsets.only(right: _sizeConfig.marginHorizontalSize! / 1.4),
          child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/option');
              },
              icon: const Icon(
                FontAwesomeIcons.cog,
                size: 18,
                color: Colors.black,
              )),
        )
      ],
    );
  }

  Widget _myBottomBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        // sets the background color of the `BottomNavigationBar`
        canvasColor: mPrimaryColor,
        // sets the active color of the `BottomNavigationBar` if `Brightness` is light
        primaryColor: Colors.red,
      ),
      child: BottomAppBar(
        color: mPrimaryColor,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: _sizeConfig.blockVertical! * 8,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/list_goals');
                  },
                  splashColor: Colors.white,
                  child: const Icon(
                    Icons.add_reaction,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/laporan');
                  },
                  splashColor: Colors.white,
                  child: const Icon(
                    Icons.restore_page_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 26,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/pemasukan');
                  },
                  splashColor: Colors.white,
                  child: const Icon(
                    Icons.arrow_circle_down_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/pengeluaran');
                  },
                  splashColor: Colors.white,
                  child: const Icon(
                    Icons.arrow_circle_up_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton _myFloat() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/home');
      },
      backgroundColor: mYellowColor,
      child: const Icon(Icons.home),
      tooltip: 'Home',
    );
  }
}
