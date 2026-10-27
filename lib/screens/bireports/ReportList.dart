import 'dart:io';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/screens/bireports/BoldReportViewerScreenwithparam.dart';
import 'package:erpflutter/screens/bireports/WorkmaemSheduleWindows.dart';
import 'package:erpflutter/screens/bireports/WorkmanDashboardReportViewerScreen.dart';
import 'package:erpflutter/screens/bireports/WorkmenDashboardWindows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/SizeConfig.dart';


class Reportlist extends StatefulWidget {
  Reportlist({Key? key,})
      : super(key: key);

  @override
  _Reportlist createState() => _Reportlist();
}

class _Reportlist extends State<Reportlist> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;



  _Reportlist() {

  }

  final List<Map<String, String>> items = [
    {'image': 'assets/report.png', 'text': 'Project Wise Skill'},
    {'image': 'assets/report.png', 'text': 'Workmen Dashboard'},
    {'image': 'assets/report.png', 'text': 'Employee Wise Skill'},
    {'image': 'assets/report.png', 'text': 'Workmen Schedule'},
    {'image': 'assets/report.png', 'text': 'Employee Allotment'},
    {'image': 'assets/report.png', 'text': 'Employee Allotment Daywise'},
    {'image': 'assets/report.png', 'text': 'Employee Non Availibility'},


    // Add more items as needed
  ];

  @override
  void initState() {
    super.initState();
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);*/
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    int crossAxisCount = screenSize.width > 600 ? 6 : 3; // Adjust columns based on screen width
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report List',
          style: TextStyle(color: Colors.white,fontFamily: 'Roboto',),
        ),
        backgroundColor: AppColors.APPCOLOR,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(0),
              sliver: SliverGrid.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                childAspectRatio: (screenSize.width / crossAxisCount) / 140, // Adjust item height
                children: items.map((item) {
                  return GestureDetector(
                      onTap: () {
                         String reportServiceUrl, reportPath,xmlPayload,htmlpath,label;
                         reportServiceUrl ="http://10.0.0.223:8442"+"/api/ReportViewer";
                        if(item['text'] !=null && item['text'] =='Project Wise Skill')
                        {
                           reportPath ="~/BiReports/Product_Wise_Skill.rdl";
                             xmlPayload = '''
                            <XMLFILE>
                                 <SPXML>
                                 <SPDETAILS FLAG="1" ORGSTRUCID="0" RULEID="601" USERID="335" />
                                 </SPXML>
                            </XMLFILE>
                              ''';
                            htmlpath ='assets/js/bold_reportwithparameters.html';
                             label="Project Wise Skill";
                            if (Platform.isWindows) {

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),
                              );
                            }
                            else if(Platform.isAndroid){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),

                              );
                            }

                             }
                        else  if(item['text'] !=null && item['text'] =='Employee Wise Skill')
                        {

                           reportPath ="~/BiReports/Employee_Wise_Skill.rdl";
                           xmlPayload = '''
                             <XMLFILE>
                              <SPXML>
                                <SPDETAILS FLAG="1" ORGSTRUCID="0" RULEID="583" USERID="3242" />
                              </SPXML>
                             </XMLFILE>
                                ''';
                          htmlpath ='assets/js/bold_reportwithparameters.html';
                           label= "Employee Wise Skill";
                          if(Platform.isWindows){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                reportPath: reportPath,
                                xmlPayload: xmlPayload,
                                htmlPath: htmlpath,
                                label: label,)),
                            );
                          }
                          else if(Platform.isAndroid){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                reportPath: reportPath,
                                xmlPayload: xmlPayload,
                                htmlPath: htmlpath,
                                label: label,)),

                            );
                          }
                        }
                        else if(item['text'] !=null && item['text'] =='Workmen Schedule')
                        {

                        reportPath ="~/BiReports/Workman_Schedule.rdl";
                          xmlPayload = '''
                           <XMLFILE>
                            <SPXML>
                             <SPDETAILS FLAG="2" PRODNLINEID="0" ITEMID="0" SHIFTID="0" PAGENO="1" MACHINEID="0" ORGSTRUCID="0" Ruleid="590" ALLOCATIONDATE="2025-06-03T00:00:00" TODATE="2025-06-03T00:00:00" USERID="3242" />
                             </SPXML>
                           </XMLFILE>
                          ''';
                           label= "Workmen Schedule";
                          htmlpath ='assets/js/bold_reportwithparameters.html';
                          if(Platform.isWindows){

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                reportPath: reportPath,
                                xmlPayload: xmlPayload,
                                htmlPath: htmlpath,
                                label: label,)),
                            );
                          }else if(Platform.isAndroid){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                reportPath: reportPath,
                                xmlPayload: xmlPayload,
                                htmlPath: htmlpath,
                                label: label,)),

                            );
                          }
                        }
                        else if(item['text'] !=null && item['text'] =='Employee Allotment')
                        {

                            reportPath ="~/BiReports/Employee_Allotment.rdl";
                             xmlPayload = '''
                           <XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="1" ORGSTRUCID="0" Ruleid="590" StartDate="2025-06-03T00:00:00" EndDate="2025-06-03T00:00:00" RULEBASEDAVL="0" ISXML="0" IsDefaultRule="1" USERID="3242" SHOWSUMMARY="0" />
    <COLUMNS>
      <COLDETAILS COLUMN_NAME="PRODLINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SCHDATE" ISSELECTED="1" FILTER_VALS="1" />
      <COLDETAILS COLUMN_NAME="MACHINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATION" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PLANT" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="ITEMCODE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCLASS" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCATEGORY" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="WONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="CUSTOMER" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATOR" ISSELECTED="1" FILTER_VALS="" />
    </COLUMNS>
  </SPXML>
</XMLFILE>
                          ''';
                             label= "Employee Allotment";
                             htmlpath ='assets/js/bold_reportwithparameters.html';
                            if(Platform.isWindows){

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),
                              );
                            }
                            else if(Platform.isAndroid){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),

                              );
                            }
                          }
                        else if(item['text'] !=null && item['text'] =='Employee Allotment Daywise')
                        {

                         reportPath ="~/BiReports/Employee_Allotment_DayWise.rdl";
                         xmlPayload = '''
                           <XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="1" ORGSTRUCID="0" Ruleid="583" StartDate="2025-05-27T00:00:00" EndDate="2025-05-27T00:00:00" RULEBASEDAVL="0" ISXML="0" IsDefaultRule="1" USERID="3242" SHOWSUMMARY="0" />
    <COLUMNS>
      <COLDETAILS COLUMN_NAME="PRODLINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SCHDATE" ISSELECTED="1" FILTER_VALS="1" />
      <COLDETAILS COLUMN_NAME="MACHINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATION" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PLANT" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="ITEMCODE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCLASS" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCATEGORY" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="WONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="CUSTOMER" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATOR" ISSELECTED="1" FILTER_VALS="" />
    </COLUMNS>
  </SPXML>
</XMLFILE>
                          ''';
                          label= "Employee Allotment Daywise";
                          htmlpath ='assets/js/bold_reportwithparameters.html';
                          if(Platform.isWindows){

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                reportPath: reportPath,
                                xmlPayload: xmlPayload,
                                htmlPath: htmlpath,
                                label: label,)),
                            );

                          }else if(Platform.isAndroid){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                reportPath: reportPath,
                                xmlPayload: xmlPayload,
                                htmlPath: htmlpath,
                                label: label,)),

                            );
                          }
                        }
                        else if(item['text'] !=null && item['text'] =='Employee Allotment Daywise')
                          {
                             reportPath ="~/BiReports/Employee_Non_Availibility.rdl";
                            xmlPayload = '''
                          <XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="3" ORGSTRUCID="0" Ruleid="583" StartDate="2025-05-27T00:00:00" EndDate="2025-12-30T00:00:00" RULEBASEDAVL="0" ISXML="0" IsDefaultRule="1" USERID="3242" SHOWSUMMARY="0" />
    <COLUMNS>
      <COLDETAILS COLUMN_NAME="PRODLINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SCHDATE" ISSELECTED="1" FILTER_VALS="1" />
      <COLDETAILS COLUMN_NAME="MACHINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATION" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PLANT" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="ITEMCODE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCLASS" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCATEGORY" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="WONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="CUSTOMER" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATOR" ISSELECTED="1" FILTER_VALS="" />
    </COLUMNS>
  </SPXML>
</XMLFILE>
                          ''';
                            label= "Employee Non Availibility";
                            htmlpath ='assets/js/bold_reportwithparameters.html';
                            if(Platform.isWindows){


                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),
                              );
                            }else if(Platform.isAndroid){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),

                              );
                            }
                          }
                        else if(item['text'] !=null && item['text'] =='Workmen Dashboard'){
                          if(Platform.isWindows){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WorkmenDashboardWindowsScreen()),
                            );
                          }else if(Platform.isAndroid){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Workmandashboardreportviewerscreen()),
                            );
                          }
                        }
                      },
                      child:Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: double.infinity, // Ensure the container takes full width
                            height: screenHeight * 0.07, // Set height to 30% of screen height

                            child:  Image.asset(
                            item['image']!,
                            color: AppColors.APPCOLOR,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['text']!,
                            style:  TextStyle(
                              color: Colors.blue,
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.normal,),
                          ),
                        ),
                      ],
                    ),
                  ));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
