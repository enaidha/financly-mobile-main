import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/constants.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  SharedPreferences? pref;
  String? uid = '';
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  int _filterBulan = 0;
  int _filterTahun = 0;
  String _selectedBulan = "0";
  String _selectedTahun = "0";
  String _filterLaporan = 'Semua';
  bool _filterPemasukan = true;
  bool _sort = true;
  final _arrYear = [2022, 2023, 2024, 2025];
  DateTime now = DateTime.now();

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    pref = preferences;
    print('user_id : ' + preferences.getString('user_id')!);
    print('name : ' + preferences.getString('name')!);
    setState(() {
      uid = preferences.getString('user_id')!;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  List<DropdownMenuItem<String>> get _dropdownYearItem {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Pilih Tahun"), value: "0"),
      DropdownMenuItem(child: Text("2022"), value: "2022"),
      DropdownMenuItem(child: Text("2023"), value: "2023"),
      DropdownMenuItem(child: Text("2024"), value: "2024"),
      DropdownMenuItem(child: Text("2025"), value: "2025"),
    ];
    return menuItems;
  }

  List<DropdownMenuItem<String>> get _dropdownMonthItem {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Pilih Bulan"), value: "0"),
      DropdownMenuItem(child: Text("Januari"), value: "1"),
      DropdownMenuItem(child: Text("Februari"), value: "2"),
      DropdownMenuItem(child: Text("Maret"), value: "3"),
      DropdownMenuItem(child: Text("April"), value: "4"),
      DropdownMenuItem(child: Text("Mei"), value: "5"),
      DropdownMenuItem(child: Text("Juni"), value: "6"),
      DropdownMenuItem(child: Text("Juli"), value: "7"),
      DropdownMenuItem(child: Text("Agustus"), value: "8"),
      DropdownMenuItem(child: Text("September"), value: "9"),
      DropdownMenuItem(child: Text("Oktober"), value: "10"),
      DropdownMenuItem(child: Text("November"), value: "11"),
      DropdownMenuItem(child: Text("Desember"), value: "12"),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);
    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IconButton(
                  //     onPressed: () {
                  //       _filterYear();
                  //     },
                  //     icon: const Icon(Icons.format_list_numbered)),
                  IconButton(
                      onPressed: () {
                        _filterYearMonth();
                      },
                      icon: const Icon(Icons.format_align_justify)),
                  InkWell(
                    onTap: () {
                      _filter();
                    },
                    child: Container(
                      width: _sizeConfig.blockHorizontal! * 50,
                      color: mPrimaryColor,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _filterLaporan,
                            style: mTitleStyle.copyWith(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _sort = !_sort;
                        });
                      },
                      icon: const Icon(Icons.format_line_spacing)),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: _filterTahun > 0 &&
                        _filterBulan == 0 &&
                        _filterLaporan.contains('Semua')
                    ? users
                        .doc(uid!)
                        .collection('laporan')
                        .where('year_created', isEqualTo: _filterTahun)
                        .orderBy('nominal', descending: _sort)
                        .snapshots()
                    : _filterTahun > 0 &&
                            _filterBulan > 0 &&
                            _filterLaporan.contains('Semua')
                        ? users
                            .doc(uid!)
                            .collection('laporan')
                            .where('year_created', isEqualTo: _filterTahun)
                            .where('month_created', isEqualTo: _filterBulan)
                            .orderBy('nominal', descending: _sort)
                            .snapshots()
                        : _filterTahun == 0 &&
                                _filterBulan > 0 &&
                                _filterLaporan.contains('Semua')
                            ? users
                                .doc(uid!)
                                .collection('laporan')
                                .where('month_created', isEqualTo: _filterBulan)
                                .orderBy('nominal', descending: _sort)
                                .snapshots()
                            : _filterTahun == 0 &&
                                    _filterBulan == 0 &&
                                    !_filterLaporan.contains('Semua')
                                ? users
                                    .doc(uid!)
                                    .collection('laporan')
                                    .where('is_pemasukan',
                                        isEqualTo: _filterPemasukan)
                                    .orderBy('nominal', descending: _sort)
                                    .snapshots()
                                : _filterTahun > 0 &&
                                        _filterBulan == 0 &&
                                        !_filterLaporan.contains('Semua')
                                    ? users
                                        .doc(uid!)
                                        .collection('laporan')
                                        .where('year_created',
                                            isEqualTo: _filterTahun)
                                        .where('is_pemasukan',
                                            isEqualTo: _filterPemasukan)
                                        .orderBy('nominal', descending: _sort)
                                        .snapshots()
                                    : _filterTahun > 0 &&
                                            _filterBulan > 0 &&
                                            !_filterLaporan.contains('Semua')
                                        ? users
                                            .doc(uid!)
                                            .collection('laporan')
                                            .where('year_created',
                                                isEqualTo: _filterTahun)
                                            .where('month_created',
                                                isEqualTo: _filterBulan)
                                            .where('is_pemasukan',
                                                isEqualTo: _filterPemasukan)
                                            .orderBy('nominal',
                                                descending: _sort)
                                            .snapshots()
                                        : _filterTahun == 0 &&
                                                _filterBulan > 0 &&
                                                !_filterLaporan
                                                    .contains('Semua')
                                            ? users
                                                .doc(uid!)
                                                .collection('laporan')
                                                .where('month_created',
                                                    isEqualTo: _filterBulan)
                                                .where('is_pemasukan',
                                                    isEqualTo: _filterPemasukan)
                                                .orderBy('nominal',
                                                    descending: _sort)
                                                .snapshots()
                                            : users
                                                .doc(uid!)
                                                .collection('laporan')
                                                .orderBy('nominal',
                                                    descending: _sort)
                                                .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.size > 0) {
                    if (_filterTahun == 0 &&
                        _filterBulan == 0 &&
                        _filterLaporan.contains('Semua')) {
                      var date = DateTime.now();
                      String now = date.toString().split('.')[0];

                      num totalPemasukan = 0;
                      num totalPengeluaran = 0;

                      for (var i = 0; i < snapshot.data!.size; i++) {
                        if (snapshot.data!.docs[i].get('is_pemasukan')) {
                          totalPemasukan +=
                              snapshot.data!.docs[i].get('nominal');
                        } else {
                          totalPengeluaran +=
                              snapshot.data!.docs[i].get('nominal');
                        }
                      }

                      return Column(
                        children: [
                          _card(
                              nominal: totalPemasukan.toString(),
                              judul: "Total Pemasukan",
                              isPemasukan: true,
                              waktu: now),
                          _card(
                              nominal: totalPengeluaran.toString(),
                              judul: "Total Pengeluaran",
                              isPemasukan: false,
                              waktu: now),
                        ],
                      );
                    } else {
                      return Column(
                        children: snapshot.data!.docs
                            .map((e) => _card(
                                nominal: e['nominal'].toString(),
                                judul: e['judul'],
                                isPemasukan: e['is_pemasukan'],
                                waktu: e['created_at']))
                            .toList(),
                      );
                    }
                  } else {
                    return Container(
                      child: Center(
                        child: Text(
                          'Data tidak ada.',
                          style: mRowTextStyle,
                        ),
                      ),
                    );
                  }
                })
          ],
        ),
      ),
      bottomNavigationBar: _myBottomBar(),
      floatingActionButton: _myFloat(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: mPrimaryColor,
      leading: Container(),
      title: Text(
        'Rekap Bulanan',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 6,
        ),
      ),
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

  Container _card(
      {required String nominal,
      required String judul,
      required String waktu,
      required bool isPemasukan}) {
    return Container(
      width: _sizeConfig.screenWidth,
      height: _sizeConfig.blockVertical! * 8,
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
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Icon(
          Icons.label,
          color: isPemasukan == true ? Colors.greenAccent : Colors.red,
        ),
        const SizedBox(
          width: 14,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
              text: TextSpan(
                  text: 'Rp. ${currencyFormat.format(int.parse(nominal))}\n',
                  style: mRowTextStyle.copyWith(
                    fontSize: _sizeConfig.blockHorizontal! * 4.4,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  children: [
                const WidgetSpan(
                  child: SizedBox(height: 20),
                ),
                TextSpan(
                  text: judul.toLowerCase(),
                  style: mWarningTextStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 3.4,
                      fontWeight: FontWeight.w400),
                )
              ])),
        ),
      ]),
    );
  }

  _filter() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: _sizeConfig.blockHorizontal! * 70,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    print('Semua');
                    setState(() {
                      _filterLaporan = 'Semua';
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterLaporan == 'Semua' ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Semua',
                      style: mTitleStyle.copyWith(
                        color: _filterLaporan == 'Semua'
                            ? mPrimaryColor
                            : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Pemasukan');
                    setState(() {
                      _filterLaporan = 'Pemasukan';
                      _filterPemasukan = true;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterLaporan == 'Pemasukan' ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Pemasukan',
                      style: mTitleStyle.copyWith(
                        color: _filterLaporan == 'Pemasukan'
                            ? mPrimaryColor
                            : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Pengeluaran');
                    setState(() {
                      _filterLaporan = 'Pengeluaran';
                      _filterPemasukan = false;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterLaporan == 'Pengeluaran' ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Pengeluaran',
                      style: mTitleStyle.copyWith(
                        color: _filterLaporan == 'Pengeluaran'
                            ? mPrimaryColor
                            : Colors.black,
                        fontSize: 14,
                      )),
                ),
              ],
            ),
          );
        });
  }

  _filterYearMonth() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: _sizeConfig.blockHorizontal! * 70,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(children: [
                DropdownButton(
                    items: _dropdownYearItem,
                    value: _selectedTahun,
                    onChanged: (String? value) {
                      print('selected year : $value');
                      setState(() {
                        _selectedTahun = value!;
                        _filterTahun = int.parse(value);
                      });
                    }),
                DropdownButton(
                    items: _dropdownMonthItem,
                    value: _selectedBulan,
                    onChanged: (String? value) {
                      print('selected month : $value');
                      setState(() {
                        _selectedBulan = value!;
                        _filterBulan = int.parse(value);
                      });
                    }),
                const SizedBox(
                  height: 12,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: mPrimaryColor,
                    ),
                    child: Text('Filter',
                        style: mInputStyle.copyWith(
                            fontSize: _sizeConfig.blockVertical! * 2.6,
                            fontWeight: FontWeight.w400,
                            color: Colors.white)))
              ]),
            ),
          );
        });
  }

  _filterYear() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: _sizeConfig.blockHorizontal! * 70,
            child: ListView(
              children: [
                ListTile(
                  onTap: () {
                    print('Semua');
                    setState(() {
                      _filterTahun = 0;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterTahun == 0 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Semua',
                      style: mTitleStyle.copyWith(
                        color: _filterTahun == 0 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                for (var i = 0; i < _arrYear.length; i++) _filterYearCard(i)
              ],
            ),
          );
        });
  }

  Column _filterYearCard(int i) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            print(_arrYear[i]);
            setState(() {
              _filterTahun = _arrYear[i];
            });
            Navigator.pop(context);
          },
          selected: _filterTahun == _arrYear[i] ? true : false,
          selectedColor: mPrimaryColor,
          title: Text(_arrYear[i].toString(),
              style: mTitleStyle.copyWith(
                color:
                    _filterTahun == _arrYear[i] ? mPrimaryColor : Colors.black,
                fontSize: 14,
              )),
        ),
        i < (_arrYear.length - 1)
            ? const Divider(
                color: Colors.black,
              )
            : Container(),
      ],
    );
  }

  _filterMonth() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: _sizeConfig.blockVertical! * 70,
          color: Colors.white,
          child: Center(
            child: ListView(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    print('Semua');
                    setState(() {
                      _filterBulan = 0;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 0 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Semua',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 0 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Januari');
                    setState(() {
                      _filterBulan = 1;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 1 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Januari',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 1 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Februari');
                    setState(() {
                      _filterBulan = 2;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 2 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Februari',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 2 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Maret');
                    setState(() {
                      _filterBulan = 3;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 3 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Maret',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 3 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('April');
                    setState(() {
                      _filterBulan = 4;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 4 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('April',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 4 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Mei');
                    setState(() {
                      _filterBulan = 5;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 5 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Mei',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 5 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Juni');
                    setState(() {
                      _filterBulan = 6;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 6 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Juni',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 6 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Juli');
                    setState(() {
                      _filterBulan = 7;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 7 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Juli',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 7 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Agustus');
                    setState(() {
                      _filterBulan = 8;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 8 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Agustus',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 8 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('September');
                    setState(() {
                      _filterBulan = 9;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 9 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('September',
                      style: mTitleStyle.copyWith(
                        color: _filterBulan == 9 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Oktober');
                    setState(() {
                      _filterBulan = 10;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 10 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Oktober',
                      style: mTitleStyle.copyWith(
                        color:
                            _filterBulan == 10 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('November');
                    setState(() {
                      _filterBulan = 11;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 11 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('November',
                      style: mTitleStyle.copyWith(
                        color:
                            _filterBulan == 11 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Desember');
                    setState(() {
                      _filterBulan = 12;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterBulan == 12 ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Desember',
                      style: mTitleStyle.copyWith(
                        color:
                            _filterBulan == 12 ? mPrimaryColor : Colors.black,
                        fontSize: 14,
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
