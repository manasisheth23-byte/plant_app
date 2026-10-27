import 'package:flutter/material.dart';

import 'models/LoginResponseModel.dart';






class HomePage extends StatefulWidget {
  final LoginResponseModel? loginResponseModel;
  HomePage({Key? key, required this.loginResponseModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState(loginResponseModel);
  }
}

class _HomePageState extends State<HomePage> {

  final LoginResponseModel? loginResponseModel;

  var getdisplaylist;
  _HomePageState(this.loginResponseModel);



@override
  void initState() {
    // TODO: implement initState
    super.initState();

    print(loginResponseModel!.data!.menulist!.data!.length);
for(int i=0;i<loginResponseModel!.data!.menulist!.data!.length;i++)
  {


    for(int j=0;j<loginResponseModel!.data!.menulist!.data[i].list.length;j++)
      {
        print(loginResponseModel!.data!.menulist!.data[i].list[j].name);
      }
  }


  }


  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashbored'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(''),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(''),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [

          ],
        ),

      ),
    );
  }

 /* Widget _buildMenuCard( BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              alignment: Alignment.center,
              child: Text(
                '',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }*/
}
