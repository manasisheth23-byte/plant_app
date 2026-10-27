import '../utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class TitleControll extends StatefulWidget {
  var value;
  TextStyle textStyle;

  TitleControll({Key? key, required this.textStyle, this.value})
      : super(key: key);

  @override
  _TitleControllState createState() => _TitleControllState();
}

class _TitleControllState extends State<TitleControll> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50.0,
        width: SizeConfig.screenWidth! * 90,
        padding: const EdgeInsets.all(12),
        color: Colors.blue,
        child: Center(
          child: Text(
            widget.value,
            style: widget.textStyle
                .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ));
  }
}
