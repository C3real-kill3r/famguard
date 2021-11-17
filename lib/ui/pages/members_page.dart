import 'dart:async';
import 'package:famguard/data/values.dart';
import 'package:famguard/ui/components/member_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MembersPage extends StatefulWidget {
  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
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

  final name = TextEditingController();

  final phone = TextEditingController();

  setListData(String key, List value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setStringList(key, value);
  }

  @override
  initState() {
    super.initState();
    getListData('members');
    getListData('membersNumbers');
  }

  _enterPhoneNumber(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter phone number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter name',
                ),
                controller: name,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                ),
                controller: phone,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                // add name as key and phone number as value in shared_preferences
                // add name to list
                members.add(name.text.toString());
                membersNumbers.add(phone.text.toString());
                // update members list to sharedprefernce to key 'members'
                setListData('members', members);
                setListData('membersNumbers', membersNumbers);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // remove member from list
  _removeMember(BuildContext context, String member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove member'),
          content: Text('Are you sure you want to remove $member?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Remove'),
              onPressed: () {
                // remove member from list
                members.remove(member);
                // update members list to sharedprefernce to key 'members'
                setListData('members', members);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // empty card, grey background with empty gif from codepen and text and a TextButton
  Widget _emptyCard() {
    return Flex(
      direction: Axis.vertical,
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width / 1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(
                'https://cdn.dribbble.com/users/185409/screenshots/2669918/yell-empty-states-800.gif',
                fit: BoxFit.fitHeight,
              ),
              Text(
                'No members yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 3,
              width: double.maxFinite,
              color: colorGradientTop,
              child: Container(
                margin:
                    EdgeInsets.only(top: 25, bottom: 20, left: 40, right: 40),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/qr_code.png'))),
              ),
            ),
            (membersNumbers.isEmpty || membersNumbers == null)
                ? _emptyCard()
                : GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    shrinkWrap: true,
                    children: members.map((name) {
                      return MemberCard(name);
                    }).toList(),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
          ),
          backgroundColor: colorGradientTop,
          onPressed: () {
            _enterPhoneNumber(context);
          }),
    );
  }
}
