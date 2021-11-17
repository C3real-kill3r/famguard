import 'dart:async';
import 'package:famguard/data/values.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // assign empty list to members key in shared preferences
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  // function to assign empty list to members key in shared preferences
  void assignEmptyList() async {
    // alert
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to reset all the members?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                // assign empty list to members key in shared preferences
                (await prefs).setStringList('members', []);
                // assign empty list to membersNumbers key in shared preferences
                (await prefs).setStringList('membersNumbers', []);
                // alert
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Success'),
                      content: Text('All members have been reset.'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // TODO: remove location permission of the application from the phone permissions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: colorGradientTop,
        title: Text("Settings"),
      ),
      body: Container(
        // color: colorGradientTop,
        child: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Notification",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Switch(
                  value: true,
                  onChanged: (value) {},
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Location",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Switch(
                  value: true,
                  onChanged: (value) {},
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Clear Data",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                // red button with rounded corners "reset"
                GestureDetector(
                  onTap: () {
                    assignEmptyList();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Reset",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
