import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widget/InfoWidget.dart';
import '../../widget/MedicineNameWidget.dart';

class MedicineDetails extends StatefulWidget {
  final String name;
  final List<Map<String, String>> details;

  const MedicineDetails({Key? key, required this.name, required this.details}) : super(key: key);

  @override
  _MedicineDetailsState createState() => _MedicineDetailsState();
}

class _MedicineDetailsState extends State<MedicineDetails> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0.h),
          child: MedicineNameWidget(
            name: widget.name,
            isExpanded: _isExpanded,
            onToggle: _toggleExpanded,
          ),
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Column(
            children: widget.details.map((detail) {
              return Container(
                margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0.h),
                child: InfoWidget(
                  title: detail['title']!,
                  subtitle: detail['subtitle']!,
                ),
              );
            }).toList(),
          )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
