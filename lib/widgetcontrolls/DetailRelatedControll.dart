import 'package:flutter/material.dart';
import '../utils/SizeConfig.dart';

class DetailRelatedControll extends StatefulWidget {
  var value;
  TextStyle textStyle = TextStyle();

  DetailRelatedControll({Key? key, required this.textStyle, this.value})
      : super(key: key);

  @override
  _DetailRelatedControllState createState() => _DetailRelatedControllState();
}

class _DetailRelatedControllState extends State<DetailRelatedControll> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blue,
        width: SizeConfig.screenWidth! * 90,
        child: Row(
          children: <Widget>[
            Text(
              widget.value,
              style: widget.textStyle.copyWith(color: Colors.white),
            ),
            new Spacer(),
            Icon(
              Icons.add,
              color: Colors.white,
              size: 30.0,
            ),
          ],
        ));
  }
}
