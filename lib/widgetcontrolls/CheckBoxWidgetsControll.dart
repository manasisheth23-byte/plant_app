


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/SizeConfig.dart';

class CheckBoxWidgetsControll extends StatefulWidget {
  var label;
  var IsRequire;
  bool checkedValue = false;
  var value;
  var textStyle = TextStyle();
  TextEditingController inputController;
  CheckBoxWidgetsControll({Key? key,  required this.textStyle,required this.value,required this.inputController,required this.checkedValue,required this.label,required this.IsRequire}) : super(key: key){
    if(value != null && value != "null") {
      inputController.text = value;
    }
  }

  @override
  _CheckBoxWidgetsControllState createState() => _CheckBoxWidgetsControllState(checkedValue);
}

class _CheckBoxWidgetsControllState extends State<CheckBoxWidgetsControll> {
  bool checkedValue = false;

  _CheckBoxWidgetsControllState(this.checkedValue);


  @override
  Widget build(BuildContext context) {

    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[


        Container(
          padding: const EdgeInsets.all(8),
          width: SizeConfig.screenWidth! * 100 ,
          child: CheckboxListTile(
            title: Row(
                children: <Widget>[
                  Text(
                    widget.label,
                    style: TextStyle(color: Colors.blue),),
                  if(widget.IsRequire != null && widget.IsRequire == "1")...[
                    Text(
                      " *",

                      style: TextStyle(color: Colors.red),),
                  ]
                ]),
            value: checkedValue,
            onChanged: (newValue) {
              setState(() {


              });


            },
            controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
          ),

        ),

      ],
    );
  }


}