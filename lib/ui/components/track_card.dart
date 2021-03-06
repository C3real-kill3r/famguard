import 'package:famguard/data/values.dart';
import 'package:famguard/ui/components/circular_image.dart';
import 'package:flutter/material.dart';

class TrackCard extends StatelessWidget {
  final String member;
  final String number;

  TrackCard(this.member, this.number);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 4, right: 4),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: CircularImage(NetworkImage(
                        'https://i.pinimg.com/originals/6b/aa/98/6baa98cc1c3f4d76e989701746e322dd.png')),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        member,
                      ),
                      Text(
                        number,
                        style: TextStyle(fontSize: 12, color: colorGradientTop),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Switch(
                    value: true,
                    activeColor: colorGradientTop,
                    onChanged: (currentValue) {},
                  ),
                  Text('Track')
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
