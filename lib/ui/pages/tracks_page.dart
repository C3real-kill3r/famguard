import 'dart:async';
import 'package:famguard/data/values.dart';
import 'package:famguard/ui/components/track_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/generated/i18n.dart';

class TracksPage extends StatefulWidget {
  @override
  _TracksPageState createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
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
    // return [membersNumbers, members];
  }

  @override
  void initState() {
    super.initState();
    getListData("members");
    getListData("membersNumbers");
  }

  // empty TrackCard with an icon
  Widget emptyTrackCard() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.network(
            'https://cdn.dribbble.com/users/185409/screenshots/2669918/yell-empty-states-800.gif',
            fit: BoxFit.fitHeight,
          ),
          Text(
            'No members added yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 40,
          ),
          RaisedButton(
            color: Colors.green,
            child: Text(
              'Add members',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/members');
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorGradientTop,
        title: Text("Track"),
      ),
      body: (membersNumbers.isEmpty || membersNumbers == null)
          ? emptyTrackCard()
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return TrackCard(members[index], membersNumbers[index]);
              },
            ),
    );
  }
}
