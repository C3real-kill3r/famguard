import 'dart:async';
import 'dart:convert';

import 'package:famguard/data/values.dart';
import 'package:famguard/ui/components/circular_image.dart';
import 'package:famguard/ui/components/option_card.dart';
import 'package:famguard/ui/components/panic_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var name = "";
  var loc;
  List<String> members = [];
  List<String> membersNumbers = [];

  Future<void> getListData(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    var myMembers = myPrefs.getStringList(key);
    setState(() {
      if (key == "membersNumbers" && myMembers != null) {
        membersNumbers = myMembers;
      } else if (key == "members" && myMembers != null) {
        members = myMembers;
      } else {
        members = [];
        membersNumbers = [];
      }
    });
  }

  // check if location permission and sms permission are granted
  Future<bool> checkPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse);
    PermissionStatus smsPermission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.sms);
    if (permission == PermissionStatus.granted &&
        smsPermission == PermissionStatus.granted) {
      return true;
    } else {
      // request permissions
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions(
              [PermissionGroup.locationWhenInUse, PermissionGroup.sms]);
      if (permissions[PermissionGroup.locationWhenInUse] ==
              PermissionStatus.granted &&
          permissions[PermissionGroup.sms] == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  // funtion to refresh current page
  Future<void> refresh() async {
    await getListData("members");
    await getListData("membersNumbers");
    setState(() {});
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // ignore: non_constant_identifier_names
  Future getAddress(lat, long) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'http://api.positionstack.com/v1/reverse?access_key=1174cf460f12bb08f6d36a126456ab5f&query=$lat,$long'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var resp = await response.stream.bytesToString();
      // convert response to json
      var jsonResponse = json.decode(resp);
      loc = jsonResponse['data'][0]['name'];
      print(loc);
    } else {
      print(response.reasonPhrase);
    }
  }

  // feature coming soon toast
  void featureComingSoon() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Feature Coming Soon"),
            content: Text("This feature is coming soon"),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
  // emergency message sending

  // ignore: non_constant_identifier_names
  Future<void> SendMessage() async {
    final name = _determinePosition();
    name.then((value) async {
      var lat = value.latitude;
      var long = value.longitude;
      await getAddress(lat, long);
      // loop through membersNumbers and send sms
      for (int i = 0; i < membersNumbers.length; i++) {
        SmsSender sender = new SmsSender();
        String message =
            "Hi ${members[i]}, This is a test. Please help me. My location is $loc. https://maps.google.com/?q=$lat,$long ";
        SmsMessage msg = new SmsMessage(membersNumbers[i], message);
        msg.onStateChanged.listen((state) {
          if (state == SmsMessageState.Sent) {
            print("SMS is sent!");
          } else if (state == SmsMessageState.Delivered) {
            print("SMS is delivered!");
          }
        });
        sender.sendSms(msg);
      }
    });
  }

  String imageUrl =
      "https://i.pinimg.com/originals/6b/aa/98/6baa98cc1c3f4d76e989701746e322dd.png";

  Widget buildCustomAppBar() {
    List<Widget> _navigationWidgetList = [
      IconButton(
        onPressed: () {
          featureComingSoon();
        },
        icon: Icon(
          Icons.add_alert,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(32),
      ),
      IconButton(
        onPressed: () {
          // toast request for donation and developed by Kimberly
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "Donate",
                  ),
                  content: Text(
                      "If you like this app and want to donate, please click the button below"),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        "Donate",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // add donation link
                      },
                      // green backround, rounded sides
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green[300],
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    FlatButton(
                      child: Text("Not Today"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        },
        icon: Hero(
            tag: 'app_icon',
            child: ImageIcon(
              AssetImage('images/app_icon.png'),
              color: Colors.white,
            )),
        padding: EdgeInsets.all(32),
      ),
      IconButton(
        onPressed: () => Navigator.of(context).pushNamed('/settings'),
        icon: Icon(
          Icons.settings,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(32),
      ),
    ];

    return Container(
      height: 190,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(80),
                  bottomLeft: Radius.circular(80)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CircularImage(
              NetworkImage(imageUrl),
              width: 90,
              height: 100,
              showBorder: true,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _navigationWidgetList,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        OptionCard('Track', Icons.track_changes, () {
          Navigator.of(context).pushNamed('/tracks');
        }),
        OptionCard('Members', Icons.people, () {
          Navigator.of(context).pushNamed('/members');
        }),
        OptionCard('Chats', Icons.question_answer, () {
          featureComingSoon();
        }),
      ],
    );
  }

  // alert user that there are no members
  void noMembers() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No Members"),
            content: Text("There are no members in your group"),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  initState() {
    super.initState();
    checkPermission();
    getListData('members');
    getListData('membersNumbers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          buildCustomAppBar(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Switch(
                  value: true,
                  onChanged: (v) {},
                  activeColor: colorGradientTop,
                ),
                Text(
                  'Active Track',
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[400],
            height: MediaQuery.of(context).size.height / 6.25,
            width: double.maxFinite,
            //TODO: place Google Maps here
            child: Image(
              image: AssetImage(
                'images/maps.jpg',
              ),
              fit: BoxFit.fitWidth,
            ),
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: <Widget>[
                  buildOptions(),
                  GestureDetector(
                    child: Hero(
                      tag: "panic",
                      child: PanicButton(),
                    ),
                    onTap: () async {
                      await refresh();
                      print(membersNumbers);
                      print(members);
                      if (membersNumbers.length > 0) {
                        await SendMessage();
                        Navigator.of(context).pushNamed('/panic');
                      } else {
                        noMembers();
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Click to send emergency message",
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

void launch(String s) {}
