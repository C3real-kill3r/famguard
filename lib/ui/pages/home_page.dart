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
import 'package:http/http.dart' as http;

// import 'package:contacts_service/contacts_service.dart';
class HomePage extends StatefulWidget {
  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var name = "";
  var loc;
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

  // ignore: non_constant_identifier_names
  Future<void> SendMessage() async {
    final name = _determinePosition();
    name.then((value) async {
      var lat = value.latitude;
      var long = value.longitude;
      await getAddress(lat, long);
      // Timer.periodic(Duration(seconds: 20), (timer) {
      SmsSender sender = new SmsSender();
      String address = "+254751007698";
      SmsMessage message = new SmsMessage(
        address,
        'Hello, I need your help. Find me at $loc. http://maps.google.com/?ie=UTF8&hq=&ll=$lat,$long&z=13',
      );
      print(address);
      message.onStateChanged.listen((state) {
        if (state == SmsMessageState.Sent) {
          print("SMS is sent!");
        } else if (state == SmsMessageState.Delivered) {
          print("SMS is delivered!");
        }
      });
      sender.sendSms(message);
    });
    // });
  }

  String imageUrl =
      "https://i.pinimg.com/originals/6b/aa/98/6baa98cc1c3f4d76e989701746e322dd.png";

  Widget buildCustomAppBar() {
    List<Widget> _navigationWidgetList = [
      IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.add_alert,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(32),
      ),
      IconButton(
        onPressed: () {},
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
        OptionCard('Chats', Icons.question_answer, () {}),
      ],
    );
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
                    onTap: () {
                      SendMessage();
                      Navigator.of(context).pushNamed('/panic');
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
