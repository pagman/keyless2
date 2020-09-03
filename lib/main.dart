import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert';
import 'package:slider_button/slider_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'PickerData.dart';
import 'pickervalue.dart';
final FlutterBlue flutterBlue = FlutterBlue.instance;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hellas Digital Keyless Access',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
final String TARGET_DEVICE_NAME = "myESP32";

FlutterBlue flutterBlue = FlutterBlue.instance;
StreamSubscription<ScanResult> scanSubScription;
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
BluetoothDevice targetDevice;
BluetoothCharacteristic targetCharacteristic;
String _slidetext = "Slide to Disable";
int _stateflag = 0;
String connectionText = "";

Stream<String> numberStream() async* {
  var random = Random();
  var rssii = "0";

  //print("saaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
  while(true){
    await Future.delayed(Duration(seconds: 5));
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

// Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        rssii = r.rssi.toString();
      }
    });

// Stop scanning
    flutterBlue.stopScan();
    yield rssii;
  }
}


@override
void initState() {
  super.initState();
  startScan();
}

startScan() {
  setState(() {
    connectionText = "Start Scanning";
  });
   scanSubScription = flutterBlue.scan().listen((scanResult) {
    if (scanResult.device.name == TARGET_DEVICE_NAME) {
      print('DEVICE found');
      stopScan();
      setState(() {
        connectionText = "Found Target Device";
      });
      targetDevice = scanResult.device;
      connectToDevice();
      print(scanResult.rssi);
    }
  }, onDone: () => stopScan());
}

stopScan() {
  print("scan stoped");
  scanSubScription?.cancel();
  scanSubScription = null;
}

connectToDevice() async {
  if (targetDevice == null) return;

  setState(() {
    connectionText = "Device Connecting";
  });

  await targetDevice.connect();
  print('DEVICE CONNECTED');
  setState(() {

    connectionText = "Device Connected";
  });

  discoverServices();
}

disconnectFromDevice() {
  if (targetDevice == null) return;

  targetDevice.disconnect();

  setState(() {
    connectionText = "Device Disconnected";
  });
}

discoverServices() async {
  if (targetDevice == null) return;

  List<BluetoothService> services = await targetDevice.discoverServices();
  services.forEach((service) {
    print("-------------- service");
    print(service.uuid.toString());
    print("--------------");
    // do something with service
    if (service.uuid.toString() == SERVICE_UUID) {
      service.characteristics.forEach((characteristic) {
        print("-------------- mpike karakteristik");
        print(characteristic.uuid.toString());
        print("--------------");
        if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
          targetCharacteristic = characteristic;
          //writeData("on3");
          setState(() {
            connectionText = "All Ready with ${targetDevice.name}";
          });
        }
      });
    }
  });
  disconnectFromDevice();
}

writeData(String data) {
  if (targetCharacteristic == null) return;
  List<int> bytes = utf8.encode(data);
  targetCharacteristic.write(bytes);
}

@override
Widget build(BuildContext context) {

  return Scaffold(
    key: _scaffoldKey,
    appBar: AppBar(
      title: Text(connectionText),
      backgroundColor: Color(0xffB8141F),
    ),
    drawer: Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: new Center(
                child: new Text(
                  "Settings",
                  style: new TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15.0, color: Colors.white),
                )),
            decoration: new BoxDecoration(color: Color(0xffB8141F)),
          ),
          Card(
            child: ListTile(
              title: new Center(
                  child: new Text(
                    "Set Time",
                    style: new TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 15.0),
                  )),
              onTap: () {
                showPicker(context);
              },
            ),
          ),
          Card(
            child: ListTile(
              title: new Center(
                  child: new Text(
                    "Set Distance",
                    style: new TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 15.0),
                  )),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ),
          Card(
            child: ListTile(
              title: new Center(
                  child: new Text(
                    "Sign Out",
                    style: new TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 15.0),
                  )),
              onTap: () {
              },
            ),
          ),
        ],
      ),
    ),
    body: Container(
      child: targetCharacteristic == null
          ? Center(
        child: Text(
          "Waiting...",
          style: TextStyle(fontSize: 24, color: Colors.red),
        ),
      )
          : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Center(
                  child: StreamBuilder(
                      stream: numberStream(),
                      builder: (context, snapshot){
                        if(snapshot.hasError)
                          return Text("Error");
                        else if (snapshot.connectionState == ConnectionState.waiting)
                          return CircularProgressIndicator();
                        return Text("${snapshot.data}", style: Theme.of(context).textTheme.display1,);
                      }
                  )
                ),
                Center(
                  child: SliderButton(
                    dismissible: false,
                    vibrationFlag: false,
                    action: () {
                      print(_stateflag);
                      if(_stateflag == 0) {
                        writeData("off0");
                        setState(() {
                          _slidetext = "Slide to Enable";
                        });
                        _stateflag = 1;
                      }
                      else if(_stateflag == 1) {
                        writeData("on0");
                        setState(() {
                          _slidetext = "Slide to Disable";
                        });
                        _stateflag = 0;
                      }
                    },
                    label: Text(
                      _slidetext,
                      style: TextStyle(
                          color: Color(0xff4a4a4a), fontWeight: FontWeight.w500, fontSize: 17),
                    ),
                    icon: Text(
                      "x",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 44,
                      ),
                    ),
                  )
                ),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: FittedBox(
                      child: FloatingActionButton(
                        child: Icon(Icons.add),
                        onPressed: () {
                          print(pickervalue.s);
                          writeData(pickervalue.s);
                        },
                        backgroundColor: Color(0xffB8141F),
                      ),
                    ),
                  ),
                ),
              ],
            ),],
          ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        startScan();
      },
      child: Icon(Icons.navigation),
      backgroundColor: Colors.green,
    ),
  );
}

showPicker(BuildContext context) {

  Picker picker = Picker(
      adapter: PickerDataAdapter<String>(pickerdata: JsonDecoder().convert(PickerData)),
      changeToFirst: false,
      textAlign: TextAlign.left,
      textStyle: const TextStyle(color: Colors.blue , fontSize: 17.0),
      selectedTextStyle: TextStyle(color: Colors.red, fontSize: 17.0),
      columnPadding: const EdgeInsets.all(0.0),
      onConfirm: (Picker picker, List value) {
        print(value[0].toString());
        if(value[0]==0){
          //seconds
          pickervalue.s = 'on'+(value[1]).toString();
          print((value[1]+1).toString());
          print(pickervalue.s);
          print(picker.getSelectedValues());
        }
        else{
          //minutes
          print('minutes');
          print(((value[1]+1)*60).toString());
          pickervalue.s = 'on'+((value[1]+1)*60).toString();
          print(((value[1]+1)*60).toString());
          print(pickervalue.s);
          print(picker.getSelectedValues());
        }
      }
  );
  picker.show(_scaffoldKey.currentState);
}
}
