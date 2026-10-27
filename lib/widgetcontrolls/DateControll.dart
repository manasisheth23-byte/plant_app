


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DateControll extends StatefulWidget {


  var value;
  var textStyle = TextStyle();
  var label;
  var IsRequire;
  TextEditingController dateInput ;
  DateControll({Key? key,  required this.textStyle,required this.value,required this.label,required this.IsRequire,required this.dateInput}) : super(key: key){
    if(value != null && value != "null") {
      dateInput.text = value;
    }
  }

  @override
  _DateControllState createState() => _DateControllState();
}

class _DateControllState extends State<DateControll> {


  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
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
    Container(
    padding: EdgeInsets.all(15),
    height: MediaQuery.of(context).size.width / 3,
    child: Center(
    child: TextField(
    controller: widget.dateInput,
    //editing controller of this TextField
    decoration: InputDecoration(
    icon: Icon(Icons.calendar_today), //icon of text field
    labelText: "" //label text of field
    ),
    readOnly: true,
    //set it true, so that user will not able to edit text
    onTap: () async {
    DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1950),
    //DateTime.now() - not to allow to choose before today.
    lastDate: DateTime(2100));

    if (pickedDate != null) {
    print(
    pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
    String formattedDate =
    DateFormat('yyyy-MM-dd').format(pickedDate);
    print(
    formattedDate); //formatted date output using intl package =>  2021-03-16
    setState(() {
    widget.dateInput.text =
    formattedDate; //set output date to TextField value.
    });
    } else {}
    },
    )))]);


  }


}