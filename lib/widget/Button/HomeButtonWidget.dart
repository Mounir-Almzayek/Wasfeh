import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const HomeButtonWidget({
    Key? key,

    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Align(
        child: GestureDetector(
          onTap: onTap,
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
