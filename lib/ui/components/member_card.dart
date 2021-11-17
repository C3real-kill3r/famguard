import 'package:famguard/ui/components/circular_image.dart';
import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final String imageUrl =
      "https://i.pinimg.com/originals/6b/aa/98/6baa98cc1c3f4d76e989701746e322dd.png";
  final String memberName;

  MemberCard(this.memberName);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: <Widget>[
              CircularImage(NetworkImage(imageUrl)),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 3.56,
                  child: Text(
                    memberName,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Center(
                        child: GestureDetector(
                      onTap: () {
                        print('I was tapped $memberName');
                      },
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 14,
                      ),
                    )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
