import '../utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class NumberTextControll extends StatefulWidget {
  var value;
  var label;
  var IsRequire;
  var ID;
  var textStyle = TextStyle();
  bool isEnabled;
  TextEditingController inputController;
  NumberTextControll(
      {Key? key,
      required this.textStyle,
      required this.value,
      required this.inputController,
      required this.label,
      required this.IsRequire,
      required this.ID,
      this.isEnabled = true})
      : super(key: key) {
    if (value != null && value != "null") {
      inputController.text = value;
    }
  }

  @override
  _NumberTextControllState createState() => _NumberTextControllState();
}

class _NumberTextControllState extends State<NumberTextControll> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Text(
              widget.label,
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            if (widget.IsRequire != null && widget.IsRequire == "1") ...[
              Text(
                " *",
                style: TextStyle(color: Colors.red),
              ),
            ]
          ]),
          SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(0),
            width: SizeConfig.screenWidth! * 100,
            child: TextField(
                enabled: widget.isEnabled,
                keyboardType: TextInputType.number,
                controller: widget.inputController,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    hintStyle: TextStyle(fontSize: 20.0, color: Colors.black))),
          ),
        ],
      ),
    );
  }
}
