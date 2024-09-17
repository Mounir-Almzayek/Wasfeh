import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackButtonWidget extends StatelessWidget {
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;

  const BackButtonWidget({
    Key? key,
    this.marginTop = 0,
    this.marginBottom = 10,
    this.marginLeft = 0,
    this.marginRight = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom),
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE8ECF4)),
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFFFFFFFF),
            ),
            child: Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.fromLTRB(14.9, 13.1, 17.6, 13.1),
              child: SizedBox(
                width: 19,
                height: 19,
                child: SvgPicture.asset(
                  'assets/svgs/go_back.svg',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
