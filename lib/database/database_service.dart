import 'dart:io';
import 'package:erpflutter/barcodescanner/models/barcode_registration_flagone.dart';
import 'package:erpflutter/barcodescanner/models/barcode_registration_lookup.dart';
import 'package:erpflutter/barcodescanner/models/transactiondetailsresponse_model.dart';
import 'package:erpflutter/models/fill_user_list_model.dart';
import 'package:erpflutter/models/get_item_balance_model.dart';
import 'package:erpflutter/models/get_so_list_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

import 'package:http/http.dart' as http;

import '../models/LoginResponseModel.dart';
import '../models/add_so_request_model.dart';
import '../models/add_so_response_model.dart';
import '../models/business_partners_list_model.dart';
import '../models/bussiness_partners_list_model.dart';
import '../models/customer_name_spinner_model.dart';
import '../models/get_document_type_model.dart';
import '../models/getproductcode_model.dart';
import '../models/inventory_list_model.dart';
import '../models/item_balance_model.dart';
import '../models/lineinformationlist_model.dart';
import '../models/priceList_Model.dart';
import '../models/sales_executive_model.dart';
import '../models/sales_order_list_model.dart';
import '../models/sync_i_ledger_model.dart';
import '../models/sync_price_master_model.dart';
import '../models/sync_s_ledger_model.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();

  factory DatabaseService() => _databaseService;

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    try {
      String dbPath;

      if (Platform.isAndroid || Platform.isIOS) {
        // Use Android database path
        dbPath = await getDatabasesPath();
      } else if (Platform.isWindows) {
        // Use application documents directory for Windows
        Directory documentsDir = await getApplicationDocumentsDirectory();
        dbPath = documentsDir.path;
      } else {
        throw UnsupportedError('This platform is not supported');
      }

      // Ensure directory exists
      await Directory(dbPath).create(recursive: true);

      final path = join(dbPath, 'erp_db.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
    } catch (e) {
      debugPrint('Database initialization error: $e');
      rethrow;
    }
  }
  /*Future<Database> _initDatabase() async {
    try {
      final databasePath = await getDatabasesPath();

      // Ensure database directory exists
      await Directory(databasePath).create(recursive: true);

      final path = join(databasePath, 'erp_db.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onConfigure: (db) async {
          // Enable foreign keys
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
    } catch (e) {
      debugPrint('Database initialization error: $e');
      rethrow; // Let the caller handle it if needed
    }
  }*/

 /* Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    final path = join(databasePath, 'erp_db.db');

    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }*/

  // When the database is first created, create a table to store breeds
  // and a table to store dogs.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE [ITEMS] ([ITEMID] integer, [ITEMCODE] nvarchar(50), [ITEMDESC] nvarchar(254), [MRP] numeric(10, 3), [UOMCODE] nvarchar(50), [UOMDESC] nvarchar(100), [SUBGROUP] nvarchar(150), [MAINGROUP] nvarchar(150), [PLANT] nvarchar(150), [ITEMTYPE] nvarchar(150), [CURRENCY] nvarchar(100), [INSTOCKQTY] nvarchar(200), [UNITPRICE] nvarchar(200))',
    );

    await db.execute(
      'CREATE TABLE [SLEDGER] ([SLID] integer,[SLCODE] nvarchar(50),[SLDESC] nvarchar(254),[ADDRESS] nvarchar(300),[EMAIL] nvarchar(50),[PHONE] nvarchar(50),[MOBILE] nvarchar(50),[VENDORCODE] nvarchar(100),[CITY] nvarchar(150),[CONTACTPERSON] nvarchar(300),[UOM] nvarchar(100),[CREDITACCOUNTDETAIL] nvarchar(200),[FAX] nvarchar(100),[CONTACTPERSON_NAME] nvarchar(250),[CONTACTPERSON_DESIGNATION] nvarchar(200),[CONTACTPERSON_MOBILE] nvarchar(50),[CONTACTPERSON_FAX] nvarchar(100),[CONTACTPERSON_EMAIL] nvarchar(100),[SALESPERSONNAME] nvarchar(250),[SLTYPE] nvarchar(50))',
    );

    await db.execute(
      'CREATE TABLE [SOTRANS] ([SOID] integer, [TID] integer, [ITEMID] integer, [QTY] numeric(10, 3) DEFAULT 0.00, [MRP] numeric(10, 3) DEFAULT 0.00, [DELDATE] date, [SOTID] integer NOT NULL DEFAULT 0 PRIMARY KEY AUTOINCREMENT, [SYNCDONE] char(10) NULL, [LASTUPDATEDDATE] datetime NULL, [LASTSYNCDATE] datetime NULL, [FLAG] char(10) NULL, [UNITRATE] numeric(10, 3) NULL, [MID] integer NULL)',
    );

    await db.execute(
      'CREATE TABLE [PRICEMAST] ([PID] integer, [ITEMID] integer, [ITEMCODE] nvarchar(254), [ITEMDESC] nvarchar(254), [FROMDATE] date, [UNITRATE] decimal(18, 6))',
    );

    await db.execute(
      'CREATE TABLE [ERP_USERMAST] ([USERID] int NOT NULL,[LOGINID] varchar NOT NULL,[USERNAME] varchar,[UTYPEID] varchar,[TMZONEID] varchar,[ISACTIVE] varchar)',
    );
//
    await db.execute(
      'CREATE TABLE [SOMAST] ([SOID] integer NOT NULL PRIMARY KEY AUTOINCREMENT,[DOCTYPE] nvarchar(100),[SLID] integer,[CONTROLNO] integer,[FCAMOUNT] integer,[SLDESC] nvarchar(200),[DATE] date,[POREFNO] nvarchar(100),[POREFDATE] date,[DUEDATE] date,[MID] integer,[INVCNUMB] nvarchar(200),[SONO] nvarchar(100),[SODATE] date,[CREATEDBY] integer,[CREATEDBYRNAME] nvarchar(200),[SALESPERSON] nvarchar(200),[STATUS] nvarchar(200),[CREATEDON] datetime,[DOCID] int,[LASTUPDATEDDATE] datetime,[LASTSYNCDATE] datetime,[SYNCDONE] char(10),[FLAG] char(10),[ISAUTH] integer,[ISRELEASE] integer,[DOCSTATUS] integer,[ISCOMPLETE] integer,[ORGSTRUCTID] integer,[POSID] integer)',
    );

    await db.execute(
      'CREATE TABLE [STOCKBALANCE] ([ITEMID] integer NOT NULL,[LOCID] integer,[LOCCODE]nvarchar(250),[LOCDESC] nvarchar(250),[ITEMCODE] integer,[CLOSEBAL] nvarchar(250),[ORGSTRUCID] integer)',
    );

    await db.execute(
      'CREATE TABLE [DOCMAST] ([MENUID] integer,[DOCID] integer,[ORGSTRUCID] integer,[DOCDESC] nvarchar(254))',
    );
    await db.execute(
      'CREATE TABLE [BARCODEISSUETRANSACTION] ('
          '[SRID] INTEGER PRIMARY KEY AUTOINCREMENT,'
          '[ORGSTRUCID] TEXT,'
          '[USERID] TEXT,'
          '[TRANSACTIONS] TEXT,'
          '[MID] TEXT,'
          '[DOCID] TEXT,'
          '[TID] TEXT,'
          '[INVCNUMB] TEXT,'
          '[INVCDATE] TEXT,'
          '[INVCTYPE] TEXT,'
          '[ITEMID] TEXT,'
          '[ITEMCODE] TEXT,'
          '[ITEMDESC] TEXT,'
          '[UOMID] TEXT,'
          '[UOM] TEXT,'
          '[LOCID] TEXT,'
          '[LOCATION] TEXT,'
          '[PROJID] TEXT,'
          '[PROJNO] TEXT,'
          '[NOU] TEXT,'
          '[DIMENSION] TEXT,'
          '[QTY] TEXT,'
          '[LINENUMB] TEXT,'
          '[BARCODEQTY] TEXT,'
          '[BARCODE_VERIFY] INTEGER'
          ')',
    );

    await db.execute(
      'CREATE TABLE [BARCODETRANSACTION] ('
          '[SRID] INTEGER PRIMARY KEY AUTOINCREMENT,'
          '[ORGSTRUCID] TEXT,'
          '[USERID] TEXT,'
          '[TRANSACTIONS] TEXT,'
          '[MID] TEXT,'
          '[DOCID] TEXT,'
          '[TID] TEXT,'
          '[INVCNUMB] TEXT,'
          '[INVCDATE] TEXT,'
          '[INVCTYPE] TEXT,'
          '[ITEMID] TEXT,'
          '[ITEMCODE] TEXT,'
          '[ITEMDESC] TEXT,'
          '[UOMID] TEXT,'
          '[UOM] TEXT,'
          '[LOCID] TEXT,'
          '[LOCATION] TEXT,'
          '[PROJID] TEXT,'
          '[PROJNO] TEXT,'
          '[NOU] TEXT,'
          '[DIMENSION] TEXT,'
          '[QTY] TEXT,'
          '[LINENUMB] TEXT,'
          '[BARCODEQTY] TEXT,'
          '[BARCODE_VERIFY] INTEGER'
          ')',
    );



    await db.execute('''
  CREATE TABLE BARCODEISSUERECEIPT (
    BID INTEGER PRIMARY KEY,
    LOTID TEXT,
    MID TEXT,
    DOCID TEXT,
    INVCTYPE TEXT,
    INVCNUMB TEXT,
    INVCDATE TEXT,
    TID TEXT,
    NOU TEXT,
    DIMN TEXT,
    QTY TEXT,
    LOTDESC TEXT,
    VARIFIEDFLAG TEXT,
    ISSUEDQTY TEXT,
    BARCODEQTY TEXT,
    ORGSTRUCTID TEXT,
    BARCODE TEXT,
    BARCODE_VERIFY INTEGER,
    itemcode TEXT,
    itemdesc TEXT,
    CHK_VERIFY_BARCODE TEXT
  )
''');



    await db.execute('''
  CREATE TABLE BARCODERECIPIENT (
    BID INTEGER PRIMARY KEY,
    LOTID TEXT,
    MID TEXT,
    DOCID TEXT,
    INVCTYPE TEXT,
    INVCNUMB TEXT,
    INVCDATE TEXT,
    TID TEXT,
    NOU TEXT,
    DIMN TEXT,
    QTY TEXT,
    LOTDESC TEXT,
    VARIFIEDFLAG TEXT,
    ISSUEDQTY TEXT,
    BALANCEQTY TEXT,
    ORGSTRUCTID TEXT,
    BARCODE TEXT,
    BARCODE_VERIFY INTEGER
  )
''');


  }

  Future<void> insertOrUpdateILedger(SyncILedgerModel syncILedgerModel) async {

    if (syncILedgerModel!.dATA!.status != null &&
        syncILedgerModel!.dATA!.status == 'false') {
      return;
    }

    if (syncILedgerModel.dATA!.lIST == null) return;

    final db = await _databaseService.database;

    Batch batch = db.batch();

    int size = 500;
    int count = 0;

    while (count < syncILedgerModel.dATA!.lIST!.length) {
      int loopcount = (syncILedgerModel.dATA!.lIST!.length - count) >= size
          ? size
          : (syncILedgerModel.dATA!.lIST!.length - count);

      for (int p = 0; p < loopcount; p++) {
        final item = syncILedgerModel.dATA!.lIST![count + p];

        final List<Map<String, dynamic>> existingItems = await db.query(
          'ITEMS',
          where: 'ITEMID = ?',
          whereArgs: [item.iTEMID ?? ''],
        );

        if (existingItems.isNotEmpty) {
          Map<String, dynamic> values = {
            'ITEMID': item.iTEMID ?? '',
            'ITEMCODE': item.iTEMCODE ?? '',
            'ITEMDESC': item.iTEMDESC ?? '',
            'UOMCODE': item.bASEUOMCODE ?? '',
            'UOMDESC': item.bASEUOMID ?? '',
            'SubGroup': item.subGroup ?? '',
            'MainGroup': item.mainGroup ?? '',
            'Plant': item.plant ?? '',
            'ItemType': item.itemType ?? '',
            'Currency': item.currency ?? '',
            'InStockQty': item.inStockQty ?? '',
            'Unitprice': item.unitprice ?? '',
          };

          batch.update(
            'ITEMS',
            values,
            where: 'ITEMID = ?',
            whereArgs: [item.iTEMID ?? ''],
          );
        } else {
          Map<String, dynamic> values = {
            'ITEMID': item.iTEMID ?? '',
            'ITEMCODE': item.iTEMCODE ?? '',
            'ITEMDESC': item.iTEMDESC ?? '',
            'UOMCODE': item.bASEUOMCODE ?? '',
            'UOMDESC': item.bASEUOMID ?? '',
            'SubGroup': item.subGroup ?? '',
            'MainGroup': item.mainGroup ?? '',
            'Plant': item.plant ?? '',
            'ItemType': item.itemType ?? '',
            'Currency': item.currency ?? '',
            'InStockQty': item.inStockQty ?? '',
            'Unitprice': item.unitprice ?? '',
          };

          batch.insert('ITEMS', values);
        }
      }
      count += loopcount;
    }

    await batch.commit(noResult: true);
  }

  Future<void> insertOrUpdateSLedger(SyncSLedgerModel syncSLedgerModel) async {
    if (syncSLedgerModel.dATA?.status != null &&
        syncSLedgerModel.dATA?.status == 'false') {
     // print('calling syncSLedgerModel API status :'+syncSLedgerModel.dATA?.status!);
      return;
    }
    try {
      final db = await _databaseService.database;

      Batch batch = db.batch();

      // try {
      if (syncSLedgerModel.dATA!.lIST != null) {
        int size = 500;
        int count = 0;
        int i = syncSLedgerModel.dATA!.lIST!.length;

        while (i > 0) {
          int loopCount = i >= size ? size : i;

          for (int p = 0; p < loopCount; p++) {
            var currentRecord = syncSLedgerModel.dATA!.lIST![count];

            // Check if the record already exists
            List<Map<String, dynamic>> existingRecord = await db.query(
              'SLEDGER',
              where: 'SLID = ?',
              whereArgs: [currentRecord.sLID],
            );

            Map<String, dynamic> values = {
              'SLID': currentRecord.sLID ?? '',
              'SLDESC': currentRecord.cUSTOMERNAME ?? '',
              'SLTYPE': currentRecord.sLTYPE ?? '',
              'SLCODE': currentRecord.sLCODE ?? '',
              'ADDRESS': currentRecord.aDDRESS ?? '',
              'EMAIL': currentRecord.eMAIL ?? '',
              'PHONE': currentRecord.pHONE ?? '',
              'MOBILE': currentRecord.mOBILE ?? '',
              'VENDORCODE': currentRecord.vENDORCODE ?? '',
              'CITY': currentRecord.cITY ?? '',
              'SALESPERSONNAME': currentRecord.sALESPERSON ?? '',
              'CONTACTPERSON': currentRecord.cONTACTPERSON ?? '',
              'UOM': currentRecord.cURRENCY ?? '',
              'CREDITACCOUNTDETAIL': currentRecord.cREDITACCOUNTDETAIL ?? '',
              'FAX': currentRecord.fAX ?? '',
              'CONTACTPERSON_NAME':
              currentRecord.cONTACTPERSONDETAILS?.nAME ?? '',
              'CONTACTPERSON_DESIGNATION':
              currentRecord.cONTACTPERSONDETAILS?.dESIGNATION ?? '',
              'CONTACTPERSON_MOBILE':
              currentRecord.cONTACTPERSONDETAILS?.mOBILE ?? '',
              'CONTACTPERSON_FAX': currentRecord.cONTACTPERSONDETAILS?.fAX ??
                  '',
              'CONTACTPERSON_EMAIL':
              currentRecord.cONTACTPERSONDETAILS?.eMAIL ?? '',
            };

            if (existingRecord.isNotEmpty) {
              // Update existing record
              batch.update(
                'SLEDGER',
                values,
                where: 'SLID = ?',
                whereArgs: [currentRecord.sLID],
              );
            } else {
              // Insert new record
              batch.insert('SLEDGER', values);
            }

            count++;
          }

          // Commit after processing batch
          i -= loopCount;
        }
        await batch.commit(noResult: true);
      }
    //  print('calling syncSLedgerModel API status :'+syncSLedgerModel!.dATA?.status!);
    }catch(e){

      print("calling syncSLedgerModel API info error: $e");
    }
  }

  Future<void> insertOrUpdatePriseMaster(
      SyncPriceMasterModel syncPriceMasterModel) async {
    if (syncPriceMasterModel!.dATA!.status != null &&
        syncPriceMasterModel!.dATA!.status == 'false') {
      return;
    }

    final db = await _databaseService.database;

    Batch batch = db.batch();

    // try {
    if (syncPriceMasterModel != null) {
      if (syncPriceMasterModel!.dATA!.lIST != null) {
        int size = 500;
        int count = 0;
        int loopCount = 0;
        int i = syncPriceMasterModel!.dATA!.lIST!.length;

        while (i > 0) {
          loopCount = i;
          if (loopCount >= size) {
            loopCount = size;
          }

          for (int p = 0; p < loopCount; p++) {
            int index = count + p;
            var item = syncPriceMasterModel.dATA!.lIST![index];

            // Check if the record exists
            List<Map<String, dynamic>> existingRecords = await db
                .rawQuery("SELECT * FROM PRICEMAST WHERE PID = ?", [item.pID]);

            if (existingRecords.isNotEmpty) {
              // Update existing record
              batch.update(
                'PRICEMAST',
                {
                  'PID': item.pID,
                  'ITEMID': item.iTEMID,
                  'ITEMCODE': item.iTEMCODE,
                  'ITEMDESC': item.iTEMDESC,
                  'UNITRATE': item.iTEMRATE,
                  'FROMDATE': item.effectiveDate,
                },
                where: 'PID = ?',
                whereArgs: [item.pID],
              );
            } else {
              // Insert new record
              batch.insert(
                'PRICEMAST',
                {
                  'PID': item.pID,
                  'ITEMID': item.iTEMID,
                  'ITEMCODE': item.iTEMCODE,
                  'ITEMDESC': item.iTEMDESC,
                  'UNITRATE': item.iTEMRATE,
                  'FROMDATE': item.effectiveDate,
                },
              );
            }
          }

          count += loopCount;
          i -= loopCount;
        }

        // Execute batch operations
        await batch.commit(noResult: true);
      }
    }
    // } catch (e) {
    //   print(e);
    // }
  }

  Future<void> insertOrUpdateUserMast(
      FillUserListModel fillUserListModel) async {
    if (fillUserListModel!.dATA!.status != null &&
        fillUserListModel!.dATA!.status == 'false') {
      return;
    }

    final db = await _databaseService.database;

    Batch batch = db.batch();

    // try {

    // Uncomment this line if you want to clear the table before insertion
    // batch.delete('ERP_USERMAST');

    if (fillUserListModel!.dATA!.status != null &&
        fillUserListModel!.dATA!.status == 'false') {
      return;
    }

    for (var user in fillUserListModel!.dATA!.lIST!) {
      Map<String, dynamic> values = {
        'USERID': user.uSERID ?? '',
        'LOGINID': user.lOGINID ?? '',
        'USERNAME': user.uSERNAME ?? '',
        'UTYPEID': user.uTYPEID ?? '',
        'TMZONEID': user.tMZONEID ?? '',
        'ISACTIVE': user.iSACTIVE ?? '',
      };

      // Insert or replace the user data in the ERP_USERMAST table
      batch.insert(
        'ERP_USERMAST',
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Execute batch operations
    await batch.commit(noResult: true);
    // } catch (e) {
    //   print('Error: $e');
    // }
  }

  Future<void> insertOrUpdateSO(GetSOListModel salesOrder) async {
    // Ensure salesOrder and its nested properties are not null
    if (
    salesOrder.dATA?.status == 'false') {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String orgStructID = prefs.getString('ORGSTRUCTID') ?? '';
    String posID = prefs.getString('POSID') ?? '';

    final db = await _databaseService.database;
    Batch batch = db.batch();


    if (salesOrder.dATA?.lIST == null) {
      print('No sales order data available.');
      return;
    }
    String baseQuery =
        "INSERT INTO SOMAST(SLID, POREFNO, SALESPERSON, STATUS, POREFDATE, MID, DOCTYPE, FCAMOUNT, SLDESC, DUEDATE, CREATEDBYRNAME, INVCNUMB, SODATE, CREATEDBY, CREATEDON, FLAG, SYNCDONE, DOCID, ISAUTH, ISRELEASE, DOCSTATUS, ISCOMPLETE, ORGSTRUCTID, POSID) VALUES ";

    int size = 500;
    int count = 0;
    int k = salesOrder.dATA!.lIST!.length;
    List<String> queries = [];

    while (k > 0) {
      int loopCount = k >= size ? size : k;

      List<Map<String, dynamic>> batchUpdates = [];
      for (int p = 0; p < loopCount; p++) {
        var currentItem = salesOrder.dATA!.lIST![count];
        String mid = currentItem.mID ?? "";
        List<Map> existingRecords = await db.query('SOMAST',
            where: 'MID = ? AND FLAG = ?', whereArgs: [mid, '0']);

        if (existingRecords.isNotEmpty) {
          Map<String, dynamic> values = {
            "SLID": currentItem.sLID ?? "",
            "SALESPERSON": currentItem.sALESPERSON ?? "",
            "STATUS": currentItem.sTATUS ?? "",
            "POREFNO": currentItem.pORDERNO ?? "",
            "POREFDATE": currentItem.pORDERDATE ?? "",
            "MID": currentItem.mID ?? "",
            "DOCTYPE": currentItem.dOCTYPE ?? "",
            "FCAMOUNT": currentItem.fCAMOUNT ?? "",
            "SLDESC": currentItem.sLDESC ?? "",
            "DUEDATE": currentItem.dUEDATE ?? "",
            "CREATEDBYRNAME":
            currentItem.cREATEDBYNAME ?? "",
            "INVCNUMB": currentItem.iNVCNUMB ?? "",
            "SODATE": currentItem.iNVCDATE ?? "",
            "CREATEDBY": currentItem.cREATEDBY ?? "",
            "CREATEDON": currentItem.cREATEDON ?? "",
            "DOCID": currentItem.dOCID ?? "",
            "ISAUTH": currentItem.iSAUTH ?? "",
            "ISRELEASE": currentItem.iSRELEASE ?? "",
            "DOCSTATUS": currentItem.dOCSTATUS ?? "",
            "ISCOMPLETE": currentItem.iSCOMPLETE ?? "",
            "ORGSTRUCTID": orgStructID,
            "POSID": posID
          };
          batchUpdates.add(values);

          // Update the record
          batch
              .update('SOMAST', values, where: 'MID = ?', whereArgs: [mid]);


          // Handle transaction list updates
          if (currentItem.tRANSLIST?.tRANS != null) {
            for (var trans
            in currentItem.tRANSLIST!.tRANS!) {
              List<Map> soIDRecords = await db.query('SOMAST',
                  columns: ['SOID'], where: 'MID = ?', whereArgs: [mid]);
            }
          }
        } else {
          String valuesString =
              "(${currentItem.sLID ?? 0}, "
              "'${currentItem.pORDERNO ?? ''}', "
              "'${currentItem.sALESPERSON ?? ''}', "
              "'${currentItem.sTATUS ?? ''}', "
              "'${currentItem.pORDERDATE ?? ''}', "
              "'${currentItem.mID ?? ''}', "
              "'${currentItem.dOCTYPE ?? ''}', "
              "'${currentItem.fCAMOUNT ?? ''}', "
              "'${currentItem.sLDESC ?? ''}', "
              "'${currentItem.dUEDATE ?? ''}', "
              "'${currentItem.cREATEDBYNAME ?? ''}', "
              "'${currentItem.iNVCNUMB ?? ''}', "
              "'${currentItem.iNVCDATE ?? ''}', "
              "'${currentItem.cREATEDBY ?? ''}', "
              "'${currentItem.cREATEDON ?? ''}', "
              "'0', "
              "'${currentItem.dOCID ?? ''}', "
              "'${currentItem.iSAUTH ?? ''}', "
              "'${currentItem.iSRELEASE ?? ''}', "
              "'${currentItem.dOCSTATUS ?? ''}', "
              "'${currentItem.iSCOMPLETE ?? ''}', "
              "'${currentItem.dOCSTATUS ?? ''}', "
              "'$orgStructID', '$posID')";

          queries.add(valuesString);
        }
        count++;
      }

      // Execute batch update
      if (batchUpdates.isNotEmpty) {
        batchUpdates.forEach((updateMap) {
          batch.update('SOMAST', updateMap,
              where: 'MID = ?', whereArgs: [updateMap['MID']]);
        });
        await batch.commit();
      }

      // Execute insert query in bulk
      if (queries.isNotEmpty) {
        String finalQuery = baseQuery + queries.join(', ');
        await db.execute(finalQuery);
        queries.clear();
      }

      k -= loopCount;
    }
  }

  Future<void> insertOrUpdateTransList(TRANS tran,
      String SOID,
      Database db,
      String mID,) async {
    // try {
    // Check if the record already exists
    final List<Map<String, dynamic>> existingRecords = await db.rawQuery(
      "SELECT * FROM SOTRANS WHERE TID = ?",
      [tran.tID],
    );

    // Prepare the values to be inserted/updated
    final Map<String, dynamic> values = {
      "TID": tran.tID,
      "ITEMID": tran.iTEMID,
      "QTY": tran.qTY,
      "DELDATE": tran.dELIVERYDATE,
      "SOID": SOID,
      "UNITRATE": tran.uNITRATE,
      "MID": mID,
      "FLAG": "0",
      "MRP": SOID,
    };

    // Execute a batch of operations
    final batch = db.batch();

    if (existingRecords.isNotEmpty) {
      // Update the existing record
      batch.update(
        'SOTRANS',
        values,
        where: "TID = ?",
        whereArgs: [tran.tID],
      );
    } else {
      // Insert the new record
      batch.insert('SOTRANS', values);
    }

    // Commit the batch of operations
    await batch.commit();
    // } catch (e) {
    //   print("Error: $e");
    // }
  }

  Future<void> insertOrUpdateItemStock(
      GetItemBalanceModel itemBalanceModel) async {
    final db = await _databaseService.database;
    Batch batch = db.batch();

    if (itemBalanceModel != null) {
      final int size = 500;
      int count = 0;

      if (itemBalanceModel.dATA != null && itemBalanceModel.dATA!.lIST != null) {
        while (count < itemBalanceModel.dATA!.lIST!.length) {
          int loopCount = itemBalanceModel.dATA!.lIST!.length - count > size
              ? size
              : itemBalanceModel.dATA!.lIST!.length - count;

          for (int p = 0; p < loopCount; p++) {
            final item = itemBalanceModel.dATA!.lIST![count];

            // Check if item already exists
            List<Map<String, dynamic>> result = await db.query(
              'STOCKBALANCE',
              where: 'ITEMID = ?',
              whereArgs: [item.iTEMID],
            );

            Map<String, dynamic> values = {
              'ITEMID': item.iTEMID,
              'LOCID': item.lOCID,
              'LOCCODE': item.lOCCODE,
              'LOCDESC': item.lOCDESC,
              'ITEMCODE': item.iTEMCODE,
              'CLOSEBAL': item.cLOSEBAL,
              'ORGSTRUCID': item.oRGSTRUCID,
            };

            if (result.isNotEmpty) {
              // Update existing record
              batch.update(
                'STOCKBALANCE',
                values,
                where: 'ITEMID = ?',
                whereArgs: [item.iTEMID],
              );
            } else {
              // Insert new record
              batch.insert('STOCKBALANCE', values);
            }

            count++;
          }
        }
      } else {
        // Handle the case where dATA or lIST is null
        print("Error: DATA or LIST is null");
      }


      // Commit the batch operation
      await batch.commit(noResult: true);
    }
  }

  Future<List<InventoryListModel>> getinventoryPaginatelist(int count) async {


    List<InventoryListModel> productCodeSpinner_models = [];
    List<Map> result3 = [];

    final db = await _databaseService.database;
    String pageno = (count * 10).toString();
    List<Map> result = [];

    try{
    await db.transaction((txn) async {
      result = await txn.rawQuery(
          'select * FROM  ITEMS order by ITEMDESC ASC limit 10 offset ' +
              pageno);
    });
    print(
        'select * FROM  ITEMS order by ITEMDESC ASC limit 10 offset ' + pageno);
    await db.transaction((txn) async {
      for (int j = 0; j < result.length; j++) {
        InventoryListModel lookUpDropDownList1 = new InventoryListModel();

        lookUpDropDownList1.iTEMID =
            int.tryParse(result[j]["ITEMID"].toString());

        result3 = await txn.rawQuery(
            "select SUM(CLOSEBAL)as stockqty FROM STOCKBALANCE where  ITEMID='" +
                result[j]["ITEMID"].toString() +
                "'");

        for (int k = 0; k < result3.length; k++) {
          InventoryListModel lookUpDropDownList = new InventoryListModel();

          lookUpDropDownList.iTEMID =
              int.tryParse(result3[k]["ITEMID"].toString());
          lookUpDropDownList.cURRENCY = result[j]["CURRENCY"].toString();
          lookUpDropDownList.iTEMCODE = result[j]["ITEMCODE"].toString();
          lookUpDropDownList.iTEMDESC = result[j]["ITEMDESC"].toString();
          lookUpDropDownList.uOMCODE = result[j]["UOMCODE"].toString();
          lookUpDropDownList.uOMDESC = result[j]["UOMDESC"].toString();
          lookUpDropDownList.sUBGROUP = result[j]["SUBGROUP"].toString();
          lookUpDropDownList.mAINGROUP = result[j]["MAINGROUP"].toString();
          lookUpDropDownList.pLANT = result[j]["PLANT"].toString();
          lookUpDropDownList.iTEMTYPE = result[j]["ITEMTYPE"].toString();
          lookUpDropDownList.iNSTOCKQTY = result[j]["iNSTOCKQTY"].toString();
          lookUpDropDownList.uNITPRICE = result[j]["UNITPRICE"].toString();
          productCodeSpinner_models.add(lookUpDropDownList);
        }
      }
    });
    print("*****");
    print(productCodeSpinner_models.length);
    } catch (e) {
      print("Error fetching core activities: $e");
    }
    return productCodeSpinner_models;
  }

  Future<List<InventoryListModel>> getInventorySearchList(
      String searchString) async {
    List<InventoryListModel> productCodeSpinner_models = [];
    List<Map> result3 = [];

    final db = await _databaseService.database;
try{
    List<Map> result = [];
    await db.transaction((txn) async {
      result = await txn.rawQuery(
          "select * FROM  ITEMS where   ITEMCODE like '" +
              searchString +
              "%' or  ITEMDESC like '" +
              searchString +
              "%'");
    });
    await db.transaction((txn) async {
      for (int j = 0; j < result.length; j++) {
        InventoryListModel lookUpDropDownList1 = new InventoryListModel();

        lookUpDropDownList1.iTEMID =
            int.tryParse(result[j]["ITEMID"].toString());

        result3 = await txn.rawQuery(
            "select SUM(CLOSEBAL)as stockqty FROM STOCKBALANCE where  ITEMID='" +
                result[j]["ITEMID"].toString() +
                "'");

        for (int k = 0; k < result3.length; k++) {
          InventoryListModel lookUpDropDownList = new InventoryListModel();

          lookUpDropDownList.iTEMID =
              int.tryParse(result3[k]["ITEMID"].toString());
          lookUpDropDownList.cURRENCY = result[j]["CURRENCY"].toString();
          lookUpDropDownList.iTEMCODE = result[j]["ITEMCODE"].toString();
          lookUpDropDownList.iTEMDESC = result[j]["ITEMDESC"].toString();
          lookUpDropDownList.uOMCODE = result[j]["UOMCODE"].toString();
          lookUpDropDownList.uOMDESC = result[j]["UOMDESC"].toString();
          lookUpDropDownList.sUBGROUP = result[j]["SUBGROUP"].toString();
          lookUpDropDownList.mAINGROUP = result[j]["MAINGROUP"].toString();
          lookUpDropDownList.pLANT = result[j]["PLANT"].toString();
          lookUpDropDownList.iTEMTYPE = result[j]["ITEMTYPE"].toString();
          lookUpDropDownList.iNSTOCKQTY = result[j]["iNSTOCKQTY"].toString();
          lookUpDropDownList.uNITPRICE = result[j]["UNITPRICE"].toString();
          productCodeSpinner_models.add(lookUpDropDownList);
        }
      }
    });
    print("*****");
    print(productCodeSpinner_models.length);
} catch (e) {
  print("Error fetching core activities: $e");
}
    return productCodeSpinner_models;
  }

  Future<List<ItemBalanceModel>> getItemStockList(String strItemId) async {
    List<ItemBalanceModel> itemmaster_models = [];

    final db = await _databaseService.database;

    List<Map> result = [];

    try{
    await db.transaction((txn) async {
      result = await txn.rawQuery(
          "SELECT * from STOCKBALANCE where ITEMID='" + strItemId + "'");
    });
    await db.transaction((txn) async {
      for (int j = 0; j < result.length; j++) {
        ItemBalanceModel itemmasterList = new ItemBalanceModel();

        itemmasterList.iTEMID = result[j]["ITEMID"].toString();
        itemmasterList.iTEMCODE = result[j]["ITEMCODE"].toString();
        itemmasterList.lOCID = result[j]["LOCID"].toString();
        itemmasterList.lOCCODE = result[j]["LOCCODE"].toString();
        itemmasterList.lOCDESC = result[j]["LOCDESC"].toString();
        itemmasterList.CLOSEBAL = result[j]["CLOSEBAL"].toString();
        itemmasterList.ORGSTRUCID = result[j]["ORGSTRUCID"].toString();

        itemmaster_models.add(itemmasterList);
      }
    });
    } catch (e) {
      print("Error fetching core activities: $e");
    }
    print(itemmaster_models.length);
    return itemmaster_models;
  }

  Future<List<PriseListModel>> getPriseList() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT PID, ITEMID, ITEMCODE, ITEMDESC, FROMDATE, UNITRATE FROM PRICEMAST',
    );

    return List.generate(
      maps.length,
          (i) {
        return PriseListModel.fromMap(maps[i]);
      },
    ).toList();
  }

  Future<List<PriseListModel>> getPaginatedPriseList(int page,
      int pageSize) async {
    final db = await _databaseService.database;
    final offset = page * pageSize;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT PID, ITEMID, ITEMCODE, ITEMDESC, FROMDATE, UNITRATE FROM PRICEMAST LIMIT ? OFFSET ?',
      [pageSize, offset],
    );

    return List.generate(maps.length, (i) {
      return PriseListModel.fromMap(maps[i]);
    }).toList();
  }

  Future<List<SalesOrderList>> getSalesOrderList() async {
    List<SalesOrderList> sales_order_models = [];

    final db = await _databaseService.database;

    List<Map> result = [];
    try{
    await db.transaction((txn) async {
      result = await txn.rawQuery(
          "SELECT (SELECT SLDESC FROM SLEDGER AS SL WHERE SL.SLID=S.SLID)AS SsLDESC, (SELECT DOCDESC FROM DOCMAST AS D WHERE D.DOCID=S.DOCID)AS DOCDESC,S.POREFNO, S.SLID, S.SLDESC,S.SOID,S.POREFDATE,S.SODATE,S.MID,S.DOCID ,S.ISRELEASE,S.DUEDATE,S.FCAMOUNT,S.DOCTYPE,S.INVCNUMB ,S.CREATEDBYRNAME,S.SALESPERSON,S.STATUS,S.SLDESC FROM SOMAST AS S where S.FLAG!='D' order by S.DUEDATE ASC");
    });
    await db.transaction((txn) async {
      for (int j = 0; j < result.length; j++) {
        SalesOrderList salesOrderList = new SalesOrderList();

        salesOrderList.SLID = result[j]["SLID"].toString();
        salesOrderList.strSlDesc = result[j]["SLDESC"].toString();
        salesOrderList.strDueDate = result[j]["DUEDATE"].toString();
        salesOrderList.strSOID = result[j]["SOID"].toString();
        salesOrderList.strPORefNo = result[j]["POREFNO"].toString();
        salesOrderList.strMID = result[j]["MID"].toString();
        salesOrderList.strDOCID = result[j]["DOCID"].toString();
        salesOrderList.strDOCDESC = result[j]["DOCDESC"].toString();
        salesOrderList.strISRELEASE = result[j]["ISRELEASE"].toString();
        salesOrderList.strSoDate = result[j]["SODATE"].toString();
        salesOrderList.strAmount = result[j]["FCAMOUNT"].toString();
        salesOrderList.strDocType = result[j]["DOCTYPE"].toString();
        salesOrderList.strINVCNUMB = result[j]["INVCNUMB"].toString();
        salesOrderList.srtCreatedByName =
            result[j]["CREATEDBYRNAME"].toString();
        salesOrderList.strSalesPerson = result[j]["SALESPERSON"].toString();
        salesOrderList.strStatus = result[j]["STATUS"].toString();
        salesOrderList.strSlDesc = result[j]["SLDESC"].toString();
        salesOrderList.strCustomerNAme = result[j]["SsDESC"].toString();
        sales_order_models.add(salesOrderList);
      }
    });

    print(sales_order_models.length);
    } catch (e) {
      print("Error fetching core activities: $e");
    }
    return sales_order_models;
  }

  Future<List<SalesOrderList>> getSalesOrderSearchList(
      String searchString) async {
    List<SalesOrderList> sales_order_models = [];

    final db = await _databaseService.database;
try{
    List<Map> result = [];
    await db.transaction((txn) async {
      result = await txn.rawQuery(
          "SELECT (SELECT SLDESC FROM SLEDGER AS SL WHERE SL.SLID=S.SLID)AS SsLDESC, (SELECT DOCDESC FROM DOCMAST AS D " +
              "WHERE D.DOCID=S.DOCID)AS DOCDESC,S.POREFNO, S.SLID, S.SLDESC,S.SOID,S.POREFDATE,S.SODATE,S.MID,S.DOCID ," +
              "S.ISRELEASE,S.DUEDATE,S.FCAMOUNT,S.DOCTYPE,S.INVCNUMB ,S.CREATEDBYRNAME,S.SALESPERSON,S.STATUS,S.SLDESC FROM SOMAST AS S where S.FLAG!='D' " +
              "and S.SALESPERSON like '" +
              searchString +
              "%' or S.DUEDATE like '" +
              searchString +
              "%' or S.INVCNUMB like '" +
              searchString +
              "%'");
    });
    await db.transaction((txn) async {
      for (int j = 0; j < result.length; j++) {
        SalesOrderList salesOrderList = new SalesOrderList();

        salesOrderList.SLID = result[j]["SLID"].toString();
        salesOrderList.strSlDesc = result[j]["SLDESC"].toString();
        salesOrderList.strDueDate = result[j]["DUEDATE"].toString();
        salesOrderList.strSOID = result[j]["SOID"].toString();
        salesOrderList.strPORefNo = result[j]["POREFNO"].toString();
        salesOrderList.strMID = result[j]["MID"].toString();
        salesOrderList.strDOCID = result[j]["DOCID"].toString();
        salesOrderList.strDOCDESC = result[j]["DOCDESC"].toString();
        salesOrderList.strISRELEASE = result[j]["ISRELEASE"].toString();
        salesOrderList.strSoDate = result[j]["SODATE"].toString();
        salesOrderList.strAmount = result[j]["FCAMOUNT"].toString();
        salesOrderList.strDocType = result[j]["DOCTYPE"].toString();
        salesOrderList.strINVCNUMB = result[j]["INVCNUMB"].toString();
        salesOrderList.srtCreatedByName =
            result[j]["CREATEDBYRNAME"].toString();
        salesOrderList.strSalesPerson = result[j]["SALESPERSON"].toString();
        salesOrderList.strStatus = result[j]["STATUS"].toString();
        salesOrderList.strSlDesc = result[j]["SLDESC"].toString();

        sales_order_models.add(salesOrderList);
      }
    });

    print(sales_order_models.length);
} catch (e) {
  print("Error fetching core activities: $e");
}
    return sales_order_models;
  }

  Future<List<BusinessPartnersListModel>> getBusinessPartnersPaginateList(
      String slType, int count) async {
    int pgCount = count - 1;
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * FROM SLEDGER WHERE SLTYPE LIKE ? ORDER BY SLDESC ASC LIMIT 10 OFFSET ? * 10",
        ['%$slType%', pgCount]);
    print("select * FROM  SLEDGER where SLTYPE like'" +
        slType +
        "%' order by SLDESC ASC limit 10 offset 0");
    return List.generate(maps.length, (i) {
      return BusinessPartnersListModel.fromMap(maps[i]);
    });
  }

  Future<List<BussinessPartnersListModel>> getBusinessPartnersPaginateList1(
      String slType, int count) async {
    int pgCount = count - 1;
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * FROM SLEDGER ORDER BY SLDESC ASC LIMIT 25 OFFSET ? * 25",
        [pgCount]);

    print('data size----> ${maps.length}');
    return List.generate(maps.length, (i) {
      return BussinessPartnersListModel.fromMap(maps[i]);
    });
  }

  Future<List<BusinessPartnersListModel>> getBusinessPartnersList1(
      String slType, int count) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery("select * FROM  SLEDGER order by SLDESC ASC");

    return List.generate(maps.length, (i) {
      return BusinessPartnersListModel.fromMap(maps[i]);
    });
  }

  Future<void> insertDocMast(LoginResponseModel login) async {
    final db = await _databaseService.database;

     try {
    // Begin the transaction
    await db.transaction((txn) async {
      // Clear the DOCMAST table
      await txn.execute("DELETE FROM DOCMAST");

      if (login.data!.sodetails != null &&
          login.data!.sodetails!.data.list.isNotEmpty) {
        // Create a batch
        Batch batch = txn.batch();

        for (var item in login.data!.sodetails!.data.list) {
          if (item != null) {
            print('item inserted to docmast');
            Map<String, dynamic> values = {
              "DOCID": item!.docid,
              "ORGSTRUCID": item.orgstrucid,
              "DOCDESC": item.description,
            };
            batch.insert('DOCMAST', values);
          }
        }

        // Commit the batch
        await batch.commit(noResult: true);
      }
    });
     } catch (e) {
     print("Error: $e");
    }
  }

  Future<List<BusinessPartnersListModel>> getBussinessPartnersSearchList(
      String slType, String searchString) async {
    final db = await _databaseService.database;

    // Query with parameterized search to avoid SQL injection
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM SLEDGER 
      WHERE SLTYPE = ? AND 
      (CONTACTPERSON_NAME LIKE ? OR 
       MOBILE LIKE ? OR 
       EMAIL LIKE ? OR 
       SLDESC LIKE ?)
      ''', [
      slType,
      '$searchString%',
      '$searchString%',
      '$searchString%',
      '$searchString%'
    ]);

    return List.generate(maps.length, (i) {
      return BusinessPartnersListModel.fromMap(maps[i]);
    });
  }

  Future<List<BusinessPartnersListModel>> getBusinessPartnersSearchList(
      String slType, String searchString) async {

    final db = await _databaseService.database;

    // Query with parameterized search to avoid SQL injection
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
  SELECT * FROM SLEDGER 
  WHERE SLTYPE = ? AND 
  (CONTACTPERSON_NAME LIKE ? OR 
   MOBILE LIKE ? OR 
   EMAIL LIKE ? OR 
   SLDESC LIKE ?)
  ''', [
      slType,
      '%$searchString%', // These are correctly formatted
      '%$searchString%',
      '%$searchString%',
      '%$searchString%'
    ]);

    return List.generate(maps.length, (i) {
      return BusinessPartnersListModel.fromMap(maps[i]);
    });
  }

  Future<List<BussinessPartnersListModel>> getBusinessPartnersSearchList1(
      String slType, String searchString) async {

    final db = await _databaseService.database;

    // Query with parameterized search to avoid SQL injection
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
  SELECT * FROM SLEDGER 
  WHERE SLTYPE = ? AND 
  (CONTACTPERSON_NAME LIKE ? OR 
   MOBILE LIKE ? OR 
   EMAIL LIKE ? OR 
   SLDESC LIKE ?)
  ''', [
      slType,
      '%$searchString%', // These are correctly formatted
      '%$searchString%',
      '%$searchString%',
      '%$searchString%'
    ]);

    return List.generate(maps.length, (i) {
      return BussinessPartnersListModel.fromMap(maps[i]);
    });
  }

  Future<List<SalesExicutiveUserMast>> getSalesExicutiveUserMast(
      {int limit = 10, int offset = 0}) async {
    List<SalesExicutiveUserMast> itemmaster_models = [];

    final db = await _databaseService.database;

    List<Map> result = await db.rawQuery(
        "SELECT * FROM ERP_USERMAST LIMIT ? OFFSET ?", [limit, offset]);

    for (var item in result) {
      SalesExicutiveUserMast salesexecutiveList = SalesExicutiveUserMast();
      salesexecutiveList.USERID = int.tryParse(item["USERID"].toString());
      salesexecutiveList.USERNAME = item["USERNAME"].toString();
      itemmaster_models.add(salesexecutiveList);
    }
    print("Fetched ${itemmaster_models.length} records");

    return itemmaster_models;
  }

  Future<List<CustomerNameModel>> getCustomerNames({
    int limit = 10,
    int offset = 0,
  }) async {
    List<CustomerNameModel> itemmaster_models = [];

    final db = await _databaseService.database;
try{
    List<Map> result = await db.rawQuery(
        "SELECT SLID, SLCODE, SLDESC FROM SLEDGER LIMIT ? OFFSET ?",
        [limit, offset]);

    for (var item in result) {
      CustomerNameModel custNameList = CustomerNameModel();
      custNameList.sLID = int.tryParse(item["SLID"].toString());
      custNameList.sLCODE = item["SLCODE"].toString();
      custNameList.sLDESC = item["SLDESC"].toString();
      itemmaster_models.add(custNameList);
    }
    // slid = int.tryParse(custNameList.sLID.toString());
} catch (e) {
  print("Error fetching core activities: $e");
}
    return itemmaster_models;
  }

  Future<List<DocumentTypeModel>> getDocumentsType({
    required String strOrgstructId,
  }) async {
    List<DocumentTypeModel> itemmaster_models = [];
try{
    final db = await _databaseService.database;

    List<Map> result = await db.rawQuery(
      "SELECT DOCDESC, DOCID FROM DOCMAST WHERE ORGSTRUCID = ?",
      [strOrgstructId],
    );

    for (var row in result) {
      DocumentTypeModel doctypeList = DocumentTypeModel();
      doctypeList.dOCID = int.tryParse(row["DOCID"].toString());
      doctypeList.dOCDESC = row["DOCDESC"].toString();
      itemmaster_models.add(doctypeList);
    }
} catch (e) {
  print("Error fetching core activities: $e");
}
    print("===========>>>>> Document Typee ${itemmaster_models}");
    return itemmaster_models;
  }


  // Function to get the product codes from the database
  Future<List<ProductCodeSpinnerModel>> getProductCode() async {
    final db = await _databaseService.database;

    List<ProductCodeSpinnerModel> getProductCodeList = [];

    List<Map<String, dynamic>> result = [];
try{
    // Execute the query within a transaction
    await db.transaction((txn) async {
      result = await txn.rawQuery(
          'SELECT ITEMID, ITEMCODE, ITEMDESC, MRP, UOMCODE, UOMDESC FROM ITEMS');
    });

    print(result.toString());

    // Iterate over the result and populate the list
    await db.transaction((txn) async {
      for (int i = 0; i < result.length; i++) {
        print(result[i]['ITEMCODE'].toString());
        ProductCodeSpinnerModel productCode = ProductCodeSpinnerModel(
          itemId: int.parse(result[i]['ITEMID'].toString()),
          itemCode: result[i]['ITEMCODE'].toString(),
          itemDesc: result[i]['ITEMDESC'].toString(),
          mrp: 0,
          // Hardcoded to 0 as per the original logic
          uomCode: result[i]['UOMCODE'].toString(),
          uomDesc: result[i]['UOMDESC'].toString(),
        );
        getProductCodeList.add(productCode);
      }
    });
} catch (e) {
  print("Error fetching core activities: $e");
}
    print("**************************** ${getProductCodeList.length}");
    return getProductCodeList;
  }

//   Add Sales Order

  Future<int> addSalesOrder({
    required int soID,
    required int slID,
    required String SLDESC,
    required String strPORef,
    required String strPORefDate,
    required String strSONO,
    required String strduedate,
    required int strCreatedBY,
    required String strCreatedOn,
    required String lastUpdatedDate,
    required String flag,
    required int docID,
    required String createdByName,
    required String salesPerson,
  }) async {
    int id = 0;
    String formattedDate = DateFormat('dd-MMM-yyyy').format(
      DateTime.now(),
    );

    final db = await _databaseService.database;

    try {
      // Check if the record already exists
      List<Map<String, dynamic>> cursor = await db.rawQuery(
        "SELECT * FROM SOMAST WHERE SOID = ?",
        [soID],
      );

      print("Cursor Value $cursor");

      if (cursor.isNotEmpty) {
        // Update the existing record
        Map<String, dynamic> contentValues = {
          'SOID': soID,
          'SLID': slID,
          'SLDESC': SLDESC,
          'POREFNO': strPORef,
          'POREFDATE': strPORefDate,
          'SONO': strSONO,
          'DUEDATE': strduedate,
          'CREATEDBY': strCreatedBY,
          'FLAG': flag,
          'LASTUPDATEDDATE': lastUpdatedDate,
          'DOCID': docID,
          'SALESPERSON': salesPerson,
        };

        print("contemtValues Value If NotEmpty $contentValues");

        if (flag == "I") {
          contentValues['STATUS'] = "Draft";
        }

        id = await db.update(
          'SOMAST',
          contentValues,
          where: 'SOID = ?',
          whereArgs: [soID],
        );
        id = soID;
      } else {
        // Insert a new record
        Map<String, dynamic> contentValues = {
          'SLID': slID,
          'SLDESC': SLDESC,
          'POREFNO': strPORef,
          'POREFDATE': strPORefDate,
          'SONO': strSONO,
          // 'INVCNUMB': '',
          'CREATEDBY': strCreatedBY,
          'DUEDATE': strduedate,
          'FLAG': flag,
          'LASTUPDATEDDATE': lastUpdatedDate,
          'DOCID': docID,
          'ISAUTH': "0",
          'ISRELEASE': "0",
          'DOCSTATUS': "0",
          'ISCOMPLETE': "0",
          'SALESPERSON': salesPerson,
        };

        print("Insert New Content Value If NotEmpty $contentValues");

        if (flag == "I") {
          contentValues['STATUS'] = "Draft";
          contentValues['CREATEDON'] = strCreatedOn;
          contentValues['SODATE'] = strCreatedOn.split(" ")[0];
        }

        contentValues['CREATEDBYRNAME'] = createdByName;

        id = await db.insert('SOMAST', contentValues);
      }
    } catch (e) {
      print(e.toString());
    }
    print("Return $id");
    return id;
  }

  // Future<void> getSalesOrder() async {
  //   final db = await _databaseService.database;
  //   String soID = 'your_soID';
  //   String slID = 'your_slID';
  //   String dOCID = 'your_dOCID';
  //   String flag = 'AddNew';
  //
  //   // Fetch sales order data from table
  //   List<Map<String, dynamic>> result = await db.rawQuery(
  //       'SELECT A.POREFNO, A.SLID, A.DOCTYPE, A.SOID, B.SLDESC, POREFDATE, SODATE, A.DOCID, A.SALESPERSON '
  //       'FROM SOMAST AS A '
  //       'JOIN SLEDGER AS B ON A.SLID=B.SLID '
  //       'WHERE SOID = ?',
  //       [soID]);
  //
  //   print("&&&&&&%%%%%%%%%%%%%% ${result.toString()}");
  //
  //   String strSOID = '',
  //       strSLID = '',
  //       strDocType = '',
  //       strPOREFNO = '',
  //       strPOREFDATE = '',
  //       strSLDESC = '',
  //       strSODATE = '',
  //       strDOCID = '',
  //       strSalesPerson = '';
  //
  //   if (result.isNotEmpty) {
  //     var row = result.first;
  //     strSOID = row['SOID'] ?? '';
  //     strSLID = row['SLID'] ?? '';
  //     strDOCID = row['DOCID'] ?? '';
  //     strPOREFNO = row['POREFNO'] ?? '';
  //     strPOREFDATE = row['POREFDATE'] ?? '';
  //     strSLDESC = row['SLDESC'] ?? '';
  //     strDocType = row['DOCTYPE'] ?? '';
  //     strSODATE = row['SODATE'] ?? '';
  //     strSalesPerson = row['SALESPERSON'] ?? '';
  //   }
  //
  //   int fcAmount = 0;
  //
  //   // Get FCAmount value from SOTRANS table
  //   List<Map<String, dynamic>> transResult = await db
  //       .rawQuery('SELECT QTY, UNITRATE FROM SOTRANS WHERE SOID = ?', [soID]);
  //
  //   for (var row in transResult) {
  //     String? transQty = row['QTY']?.toString();
  //     String? transUnitRate = row['UNITRATE']?.toString();
  //     if (transQty != null && transUnitRate != null) {
  //       int qty = int.tryParse(transQty) ?? 0;
  //       int unitRate = int.tryParse(transUnitRate) ?? 0;
  //       fcAmount += qty * unitRate;
  //     }
  //   }
  //
  //   if (soID.isNotEmpty && strSOID == soID) {
  //     if (strSLID != slID) {
  //       strSLID = slID;
  //     }
  //     if (strPOREFNO != 'your_edporef') {
  //       // Replace 'your_edporef' with your actual value
  //       strPOREFNO = 'your_edporef';
  //     }
  //     if (strPOREFDATE != 'your_edporefdate') {
  //       // Replace 'your_edporefdate' with your actual value
  //       strPOREFDATE = 'your_edporefdate';
  //     }
  //     if (strDOCID != dOCID) {
  //       if (dOCID.isNotEmpty) {
  //         strDOCID = dOCID;
  //       }
  //     }
  //
  //     if (strDOCID.isEmpty) {
  //       print('Please select document type');
  //       return;
  //     }
  //     if (strSLID.isEmpty) {
  //       print('Please select customer name');
  //       return;
  //     }
  //     if (strPOREFNO.isEmpty) {
  //       print('Please enter PO/Ref No');
  //       return;
  //     }
  //     if (strPOREFDATE.isEmpty) {
  //       print('Please enter PO/Ref Date');
  //       return;
  //     }
  //
  //     String syncDate =
  //         DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now());
  //
  //     Map<String, dynamic> values = {
  //       'SLID': strSLID,
  //       'SLDESC': strSLDESC,
  //       'DOCTYPE': strDocType,
  //       'DOCID': strDOCID,
  //       'POREFNO': strPOREFNO,
  //       'POREFDATE': strPOREFDATE,
  //       'SODATE': strSODATE,
  //       'FCAMOUNT': fcAmount,
  //       'SALESPERSON': strSalesPerson,
  //       'FLAG': flag == 'AddNew' ? 'I' : 'E',
  //       'LASTUPDATEDDATE': syncDate,
  //       'SYNCDONE': '0',
  //     };
  //
  //     await db
  //         .update('SOMAST', values, where: 'SOID = ?', whereArgs: [strSOID]);
  //   } else {
  //     print('Sales Order ID is not valid.');
  //     // Handle case when soID is null or doesn't match
  //   }
  // }



  Future<List<LineInformationList>> getLineinfoList(String sOID) async {
    List<LineInformationList> lineInformationLists = [];
    final db = await _databaseService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT S.SOTID, S.ITEMID, ITEMDESC, DELDATE, QTY, S.MRP, S.UNITRATE "
        "FROM SOTRANS AS S "
        "JOIN ITEMS AS I ON S.ITEMID = I.ITEMID "
        "WHERE SOID = ?",
        [sOID],
      );

      if (maps.isNotEmpty) {
        lineInformationLists = List.generate(maps.length, (i) {
          return LineInformationList(
            itemId: maps[i]['ITEMID'],
            itemDesc: maps[i]['ITEMDESC'],
            delDate: maps[i]['DELDATE'],
            qty: maps[i]['QTY'],
            mrp: maps[i]['MRP'],
            sotId: maps[i]['SOTID'],
            unitRate: maps[i]['UNITRATE'],
          );
        });
      }
    } catch (e) {
      print('Error: $e');
    }
    print("Line InformationModelllll $lineInformationLists");
    return lineInformationLists;
  }
// Function to get the product codes from the database
//   Future<List<ProductCodeSpinnerModel>> getProductCode() async {
//     final db = await _databaseService.database;


  // Future<List<PostSOModelRequest>> postSO() async {
  //   // Open the database (make sure to replace with your database path)
  //   final db = await _databaseService.database;
  //
  //   // List to hold the PostSOModelRequest objects
  //   List<PostSOModelRequest> postSOModelRequestsList = [];
  //
  //   // Query the SOMAST table
  //   final List<Map<String, dynamic>> somastResult = await db.rawQuery(
  //       "SELECT * FROM SOMAST WHERE SYNCDONE != '1' AND FLAG != '0'");
  //
  //   // Iterate through the SOMAST records
  //   for (var row in somastResult) {
  //     // Create a new PostSOModelRequest
  //     PostSOModelRequest postSOModelRequest = PostSOModelRequest(
  //       xMLFILE: XMLFILE(
  //         sOMAST: SOMAST(
  //           sLID: row['SLID'] as String?,
  //           sOID: row['SOID'] as String?,
  //           pOREFNO: row['POREFNO'] as String?,
  //           pOREFDATE: row['POREFDATE'] as String?,
  //           sONO: row['SONO'] as String?,
  //           sODATE: row['SODATE'] as String?,
  //           cREATEDBY: row['CREATEDBY'] as String?,
  //           cREATEDON: row['CREATEDON'] as String?,
  //           dUEDATE: row['DUEDATE'] as String?,
  //           dOCID: row['DOCID'] as String?,
  //           mID: row['MID'] ?? '0',
  //           lASTUPDATEDDATE: row['LASTUPDATEDDATE'] as String?,
  //           fLAG: row['FLAG'] as String?,
  //         ),
  //       ),
  //     );
  //
  //     // Retrieve SharedPreferences for ORGSTRUCTID and POSID
  //     final prefs = await SharedPreferences.getInstance();
  //     postSOModelRequest.xMLFILE.sOMAST.oRGSTRUCTID =
  //         prefs.getInt('ORGSTRUCTID')?.toString();
  //     postSOModelRequest.xMLFILE.sOMAST.pOSID =
  //         prefs.getInt('POSID')?.toString();
  //
  //     // Query the SOTRANS table
  //     final List<Map<String, dynamic>> sotranResult = await db.rawQuery(
  //         "SELECT * FROM SOTRANS WHERE SOID = '${postSOModelRequest.xMLFILE.sOMAST.sOID}'");
  //
  //     // Create a list of SOTRAN objects
  //     List<SOTRAN> sotransList = [];
  //     for (var transRow in sotranResult) {
  //       SOTRAN sotran = SOTRAN(
  //         sOTID: transRow['SOTID'] as String?,
  //         iTEMID: transRow['ITEMID'] as String?,
  //         tID: transRow['TID'] ?? '0',
  //         mRP: transRow['MRP'] as String?,
  //         qTY: transRow['QTY'] as String?,
  //         dELDATE: transRow['DELDATE'] as String?,
  //         fLAG: transRow['FLAG'] as String?,
  //         uNITRATE: transRow['UNITRATE'] as String?,
  //         lASTUPDATEDDATE: transRow['LASTUPDATEDDATE'] as String?,
  //       );
  //       sotransList.add(sotran);
  //     }
  //
  //     // Add the SOTRANS list to the SOMAST object
  //     postSOModelRequest.xMLFILE.sOMAST.sOTRANS = sotransList;
  //
  //     // Add the PostSOModelRequest to the list
  //     postSOModelRequestsList.add(postSOModelRequest);
  //   }
  //
  //   // Return the list of PostSOModelRequest objects
  //   return postSOModelRequestsList;
  // }

  Future<List<AddSORequestModel>> postSO() async {
    final db = await _databaseService.database;
    List<AddSORequestModel> postSOModelRequestslist = [];

    // Fetch data from SOMAST table
    final List<Map<String, dynamic>> masterRows = await db.rawQuery(
        "SELECT * FROM SOMAST WHERE SYNCDONE != '1' AND FLAG != '0'");

    if (masterRows.isNotEmpty) {
      for (var masterRow in masterRows) {
        AddSORequestModel postSOModelRequest = AddSORequestModel();
        postSOModelRequest.xMLFILE = XMLFILE(
          sOID: masterRow['SOID'],
          sLID: masterRow['SLID'],
          pOREFNO: masterRow['POREFNO'],
          pOREFDATE: masterRow['POREFDATE'],
          mID: masterRow['MID'] ?? '0',
          dOCID: masterRow['DOCID'],
          cREATEDBY: masterRow['CREATEDBY'],
          sODATE: masterRow['SODATE'],
          cREATEDON: masterRow['CREATEDON'],
          dUEDATE: masterRow['DUEDATE'],
          fLAG: masterRow['FLAG'],
          lASTUPDATEDDATE: masterRow['LASTUPDATEDDATE'],
        );

        // Fetch data from SOTRANS table
        List<Map<String, dynamic>> transRows = await db.rawQuery(
            "SELECT * FROM SOTRANS WHERE SOID = ?", [masterRow['SOID']]);

        List<SOTRANS> sOTRANSList = [];
        if (transRows.isNotEmpty) {
          for (var transRow in transRows) {
            SOTRANS sotran = SOTRANS(
              tID: transRow['TID'] ?? '0',
              iTEMID: transRow['ITEMID'],
              uNITRATE: transRow['UNITRATE'],
              qTY: transRow['QTY'],
              mRP: transRow['MRP'],
              dELDATE: transRow['DELDATE'],
              fLAG: transRow['FLAG'],
              lASTUPDATEDDATE: transRow['LASTUPDATEDDATE'],
            );
            sOTRANSList.add(sotran);
          }
        }

        postSOModelRequest.xMLFILE?.sOTRANS = sOTRANSList;

        // Adding user-specific data (assuming shared preferences)
        final prefs = await SharedPreferences.getInstance();
        postSOModelRequest.xMLFILE?.oRGSTRUCTID =
            prefs.getInt('ORGSTRUCTID')?.toString() ?? '0';
        postSOModelRequest.xMLFILE?.pOSID =
            prefs.getInt('POSID')?.toString() ?? '0';

        // Add the request model to the list
        postSOModelRequestslist.add(postSOModelRequest);
      }
    }

    return postSOModelRequestslist;
  }


//   {
//   required String sOTID,
//   required String soID,
//   required String tID,
//   required String itemID,
//   required String qty,
//   required String mrp,
//   required String delDate,
//   required String strUnitRate,
// }

  Future<int> addLineInformation(List<Map<String, dynamic>> lineInformation, int sOTID) async {
    final db = await _databaseService.database;

    Batch batch = db.batch();

    final DateTime lastUpdatedDate = DateTime.now();

    for(Map<String, dynamic> item in lineInformation){
      final List<Map<String, dynamic>> existingRecord = await db.query(
        'SOTRANS',
        where: 'SOTID = ?',
        whereArgs: [sOTID],
      );

      Map<String, dynamic> contentValues = {
        'SOID': 0,
        // 'SOTID': sOTID,
        'ITEMID': item['ITEMID'],
        'QTY': item['QTY'],
        'MRP': item['MRP'],
        'DELDATE': item['DELDATE'].toString(),
        'LASTUPDATEDDATE': lastUpdatedDate.toString(),
        'UNITRATE': item['UNITRATE']
      };

      if (existingRecord.isNotEmpty) {
        // Update the existing record
        contentValues['FLAG'] = 'E';
        batch.update(
          'SOTRANS',
          contentValues,
          where: 'SOTID = ?',
          whereArgs: [sOTID],
        );
      } else {
        // Insert a new record
        contentValues['FLAG'] = 'I';
        contentValues['SYNCDONE'] = '0';
        contentValues['TID'] = sOTID; // Add SOTID for new insert
        batch.insert('SOTRANS', contentValues);
      }
    }

    List<dynamic> results = await batch.commit();
    int id = results.isNotEmpty ? results.first : 0;
    return id;
  }
  Future<List<BussinessPartnersListModel>> getBusinessPartnersList() async {
    List<BussinessPartnersListModel> sales_order_models = [];

    final db = await _databaseService.database;

    List<Map> result = [];
    try{
      await db.transaction((txn) async {
        result = await txn.rawQuery(
            "select * FROM  SLEDGER order by SLDESC ASC");
      });
      await db.transaction((txn) async {
        for (int j = 0; j < result.length; j++) {
          BussinessPartnersListModel salesOrderList = BussinessPartnersListModel();

          salesOrderList.sLID = result[j]["SLID"].toString();
          salesOrderList.sLCODE = result[j]["SLCODE"].toString();
          salesOrderList.sLDESC = result[j]["SLDESC"].toString();
          salesOrderList.sLTYPE = result[j]["SLTYPE"].toString();
          salesOrderList.aDDRESS = result[j]["ADDRESS"].toString();
          salesOrderList.eMAIL = result[j]["EMAIL"].toString();
          salesOrderList.pHONE = result[j]["PHONE"].toString();
          salesOrderList.mBOILE = result[j]["MBOILE"].toString();
          salesOrderList.vENDORCODE = result[j]["VENDORCODE"].toString();
          salesOrderList.cITY = result[j]["CITY"].toString();
          salesOrderList.sALESPERSON = result[j]["SALESPERSON"].toString();
          salesOrderList.cONTACTPERSON = result[j]["CONTACTPERSON"].toString();
          salesOrderList.cURRENCY = result[j]["CURRENCY"].toString();
          salesOrderList.cREDITACCOUNTDETAIL =
              result[j]["CREDITACCOUNTDETAIL"].toString();
          salesOrderList.fAX = result[j]["FAX"].toString();
          salesOrderList.CONTACTPERSON_MOBILE = result[j]["CONTACTPERSON_MOBILE"].toString();
          salesOrderList.CONTACTPERSON_NAME = result[j]["CONTACTPERSON_NAME"].toString();
          salesOrderList.CONTACTPERSON_DESIGNATION = result[j]["CONTACTPERSON_DESIGNATION"].toString();
          salesOrderList.CONTACTPERSON_FAX = result[j]["CONTACTPERSON_FAX"].toString();
          salesOrderList.CONTACTPERSON_EMAIL = result[j]["CONTACTPERSON_EMAIL"].toString();

          sales_order_models.add(salesOrderList);
        }
      });

      print(sales_order_models.length);
    } catch (e) {
      print("Error fetching core activities: $e");
    }
    return sales_order_models;
  }
//insert transaction data
  Future<void> insertTransactions(List<Transactionl> transactions) async {
    try {
      final db = await _databaseService.database;
      await db.delete('BARCODEISSUETRANSACTION');
      // Start batch
      Batch batch = db.batch();

      for (var transaction in transactions) {
        batch.insert(
          'BARCODEISSUETRANSACTION',
          transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Commit batch
      await batch.commit(noResult: true); // noResult=true avoids returning results for speed
      print('All transactions inserted successfully!');
    } catch (e) {
      print('DB Insert Error: $e');
      // Optionally log to Crashlytics/Sentry here
    }
  }

  Future<void> insertLotDetails(List<LotDetail> lotDetails) async {
    final db = await _databaseService.database; // your SQLite database instance
    await db.delete('BARCODEISSUERECEIPT');
    Batch batch = db.batch();

    for (var lotMap in LotDetail.listToMap(lotDetails)) {
      batch.insert(
        'BARCODEISSUERECEIPT', // replace with your table name
        lotMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('All lot details inserted successfully!');
  }
  Future<void> insertLotRegisterDetails(List<BarcodeLotDetail> lotDetails) async {
    final db = await _databaseService.database;
    // Clear the table first
    await db.delete('BARCODERECIPIENT');// your SQLite database instance
    Batch batch = db.batch();

    for (var lotMap in BarcodeLotDetail.listToMap(lotDetails)) {
      batch.insert(
        'BARCODERECIPIENT', // replace with your table name
        lotMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('All lot details inserted successfully!');
  }
 Future<List<Transactionl>> getAllTransactions() async {
    try {
      final db = await _databaseService.database;

      final List<Map<String, dynamic>> result =
      await db.query('BARCODEISSUETRANSACTION');

      // Convert List<Map> to List<Transactionl>
      return result.map((map) => Transactionl.fromMap(map)).toList();
    } catch (e) {
      print('DB Read Error: $e');
      return [];
    }
  }
  Future<List<Transactionl>> getAllTransactionsRegistration({int limit = 10, int offset = 0}) async {
    try {
      final db = await _databaseService.database;

      final List<Map<String, dynamic>> result = await db.query(
        'BARCODEISSUETRANSACTION',
        limit: limit,
        offset: offset,
        orderBy: 'SRID DESC', // ✅ use SRID instead of id
      );

      return result.map((map) => Transactionl.fromMap(map)).toList();
    } catch (e) {
      print('DB Read Error: $e');
      return [];
    }
  }
  Future<List<LotDetail>> getAllBarcodeTransactionsRegistration({int limit = 10, int offset = 0,String? barcode}) async {
    try {
      final db = await _databaseService.database;

   /*   final List<Map<String, dynamic>> result = await db.query(
        'BARCODEISSUETRANSACTION',
        limit: limit,
        offset: offset,
        orderBy: 'SRID DESC', // ✅ use SRID instead of id
      );*/
      final List<Map<String, dynamic>> result = await db.query(
        'BARCODERECIPIENT',
        where: 'BARCODE = ?',         // 👈 condition
        whereArgs: [barcode],         // 👈 value passed safely
        limit: limit,
        offset: offset,
        orderBy: 'SRID DESC',
      );
      return result.map((map) => LotDetail.fromMap(map)).toList();
    } catch (e) {
      print('DB Read Error: $e');
      return [];
    }
  }

/*  Future<List<BarcodeRegistrationLookup>> getBarcodeRegistrationLookup({
    required String barcode,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final db = await _databaseService.database;

      final String query = '''
      SELECT 
        b.INVCTYPE,
        b.INVCNUMB,
        b.ITEMCODE,
        b.ITEMDESC,
        a.QTY,
        a.LOTID
      FROM BARCODERECIPIENT AS a
      INNER JOIN BARCODETRANSACTION AS b
        ON a.MID = b.MID
        AND a.RTID = b.TID
        AND a.DOCID = b.DOCID
      WHERE a.BARCODE = ?
      ORDER BY b.INVCNUMB DESC
      LIMIT ? OFFSET ?
    ''';

      final List<Map<String, dynamic>> result =
      await db.rawQuery(query, [barcode, limit, offset]);

      return result.map((map) => BarcodeRegistrationLookup.fromMap(map)).toList();
    } catch (e) {
      print('DB Join Read Error: $e');
      return [];
    }
  }*/
/*  Future<List<BarcodeRegistrationLookup>> getBarcodeRegistrationLookup({
    required String barcode,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final db = await _databaseService.database;

      final String query = '''
      SELECT 
        b.INVCTYPE,
        b.INVCNUMB,
        b.ITEMCODE,
        b.ITEMDESC,
        a.QTY,
        a.LOTID
      FROM BARCODERECIPIENT AS a
      INNER JOIN BARCODETRANSACTION AS b
        ON a.MID = b.MID
        AND a.RTID = b.TID
        AND a.DOCID = b.DOCID
      WHERE a.BARCODE = ?
      ORDER BY b.INVCNUMB DESC
      LIMIT ? OFFSET ?
    ''';
      print("➡️ Running Query:");
      print(query);
      print("➡️ Params: barcode=$barcode, limit=$limit, offset=$offset");

      final List<Map<String, dynamic>> result =
      await db.rawQuery(query, [barcode, limit, offset]);

      return result.map((map) {
        final lotId = map['LOTID'] as String?;
        return BarcodeRegistrationLookup(
          invcType: map['INVCTYPE'] as String?,
          invcNumb: map['INVCNUMB'] as String?,
          itemCode: map['ITEMCODE'] as String?,
          itemDesc: map['ITEMDESC'] as String?,
          qty: map['QTY'] as String?,
          lotId: lotId,
          postBarcodes: lotId != null
              ? [PostRegisterBarcode(lotId: lotId, barcodeVerify: '1')]
              : [], // ✅ initialize with a default PostRegisterBarcode if LOTID exists
        );
      }).toList();
    } catch (e) {
      print('DB Join Read Error: $e');
      return [];
    }
  }*/
  Future<List<BarcodeRegistrationLookup>> getBarcodeRegistrationLookup({
    required String barcode,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final db = await _databaseService.database;

      // ---------------------------------------------------------
      // 🧹 1. FULL BARCODE CLEANING (Scanner fixes)
      // ---------------------------------------------------------
      barcode = barcode
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll('\t', '')
          .trim();

      print("🔍 Clean barcode = '$barcode'");
      print("🔍 Clean barcode length = ${barcode.length}");


      // ---------------------------------------------------------
      // 📌 3. Actual Join Query
      // ---------------------------------------------------------
      final String query = '''
      SELECT 
        *
      FROM BARCODERECIPIENT AS a
      INNER JOIN BARCODETRANSACTION AS b
        ON a.MID = b.MID
        AND a.TID = b.TID
        AND a.DOCID = b.DOCID
      WHERE a.BARCODE = ?
      ORDER BY b.INVCNUMB DESC
      LIMIT ? OFFSET ?
    ''';

      final params = [barcode, limit, offset];
      print("📌 Query Params: $params");

      final List<Map<String, dynamic>> result =
      await db.rawQuery(query, params);

      print("📌 Query returned ${result.length} rows");
      print("📌 Query returned ${result} ");

      // ---------------------------------------------------------
      // 🔄 4. Convert to Model
      // ---------------------------------------------------------
      return result.map((map) {
        final lotId = map['LOTID'] as String?;
        return BarcodeRegistrationLookup(
          invcType: map['INVCTYPE'] as String?,
          invcNumb: map['INVCNUMB'] as String?,
          itemCode: map['ITEMCODE'] as String?,
          itemDesc: map['ITEMDESC'] as String?,
          qty: map['QTY'] as String?,
          lotId: lotId,
          tid:map['TID'] as String?,
          mid:map['MID'] as String?,
          docid:map['DOCID'] as String?,
          barcode:map['BARCODE'] as String?,
          postBarcodes: lotId != null
              ? [PostRegisterBarcode(lotId: lotId, barcodeVerify: '1', tid: '', mid: '', docid: '', qty: '', barcode: '')]
              : [],
        );
      }).toList();

    } catch (e) {
      print('❌ DB Join Read Error: $e');
      return [];
    }
  }



  Future<List<Transactionl>> getAllTransactionsSelected(String invcNumb) async {
    try {
      final db = await _databaseService.database;

      final List<Map<String, dynamic>> result = await db.query(
        'BARCODEISSUETRANSACTION',
        where: 'INVCNUMB = ?',
        whereArgs: [invcNumb],
      );

      // Convert List<Map> to List<Transactionl
      return result.map((map) => Transactionl.fromMap(map)).toList();
    } catch (e) {
      print('DB Read Error: $e');
      return [];
    }
  }

  Future<List<String>> getDistinctDocumentNumbers() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT INVCNUMB FROM BARCODEISSUETRANSACTION');

    return result
        .map((row) => row['INVCNUMB']?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }
  Future<List<String>> getDistinctDocumentNumbersSort(String value) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT INVCNUMB FROM BARCODEISSUETRANSACTION where INVCNUMB = $value');

    return result
        .map((row) => row['INVCNUMB']?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }

  //insert transaction data
  Future<void> insertTransactionsRegistration(List<Transactionl> transactions) async {
    try {
      final db = await _databaseService.database;
// Clear the table first
      await db.delete('BARCODETRANSACTION');
      // Start batch
      Batch batch = db.batch();

      for (var transaction in transactions) {
        batch.insert(
          'BARCODETRANSACTION',
          transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Commit batch
      await batch.commit(noResult: true); // noResult=true avoids returning results for speed
      print('All transactions inserted successfully!');
    } catch (e) {
      print('DB Insert Error: $e');
      // Optionally log to Crashlytics/Sentry here
    }
  }

}
