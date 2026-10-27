import '../utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class TextInputControll extends StatefulWidget {
  var label;
  var IsRequire;
  var value;
  var hint;
  var maxLinevalue;
  var getstrFieldType;
  var ID;
  var fieldCode;
  var textStyle = TextStyle();
  bool isEnabled;

  TextEditingController inputController;
  TextInputControll(
      {Key? key,
      required this.textStyle,
      required this.value,
      required this.inputController,
      required this.maxLinevalue,
      required this.getstrFieldType,
      required this.hint,
      required this.label,
      required this.IsRequire,
      required this.ID,
      required this.fieldCode,
      this.isEnabled = true})
      : super(key: key) {
    if (value != null && value != "null") {
      inputController.text = value;
    }
  }

  @override
  _TextInputControllState createState() => _TextInputControllState(hint);
}

class _TextInputControllState extends State<TextInputControll> {
  String hint;
  _TextInputControllState(this.hint);

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
          if (widget.getstrFieldType != null &&
              widget.getstrFieldType == "4") ...[
            if (widget.fieldCode == "F2_CUSTCODE ") ...[
              Container(
                //padding: const EdgeInsets.all(8),
                width: SizeConfig.screenWidth! * 100,
                child: TextField(
                    keyboardType: TextInputType.none,
                    maxLines: widget.maxLinevalue,
                    controller: widget.inputController,
                    enableInteractiveSelection: false,
                    focusNode: FocusNode(),
                    style: TextStyle(fontSize: 16),
                    enabled: widget.isEnabled,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      focusColor: Colors.blue,
                      hintStyle: TextStyle(fontSize: 20.0, color: Colors.black),
                    )),
              ),
            ] else ...[
              Container(
                //padding: const EdgeInsets.all(8),
                width: SizeConfig.screenWidth! * 100,
                child: TextField(
                    enabled: widget.isEnabled,
                    keyboardType: TextInputType.text,
                    maxLines: widget.maxLinevalue,
                    controller: widget.inputController,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      hintStyle: TextStyle(fontSize: 20.0, color: Colors.black),
                    )),
              ),
            ]

            // inputController.text=
          ] else ...[
            Container(
              //padding: const EdgeInsets.all(8),
              width: SizeConfig.screenWidth! * 100,
              child: TextField(
                  enabled: widget.isEnabled,
                  keyboardType: TextInputType.text,
                  controller: widget.inputController,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      hintStyle:
                          TextStyle(fontSize: 20.0, color: Colors.black))),
            ),
          ]
        ],
      ),
    );
  }
}
