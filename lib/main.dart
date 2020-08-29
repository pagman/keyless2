import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert';

import 'package:control_pad/control_pad.dart';
import 'package:control_pad/models/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';


final FlutterBlue flutterBlue = FlutterBlue.instance;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

BluetoothDevice targetDevice;
BluetoothCharacteristic targetCharacteristic;

String connectionText = "";

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
    }
  }, onDone: () => stopScan());
}

stopScan() {
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
          writeData("on3");
          setState(() {
            connectionText = "All Ready with ${targetDevice.name}";
          });
        }
      });
    }
  });
}

writeData(String data) {
  if (targetCharacteristic == null) return;
  List<int> bytes = utf8.encode(data);
  targetCharacteristic.write(bytes);
}

@override
Widget build(BuildContext context) {
  JoystickDirectionCallback onDirectionChanged(
      double degrees, double distance) {
    String data =
        "Degree : ${degrees.toStringAsFixed(2)}, distance : ${distance.toStringAsFixed(2)}";
    print(data);
    writeData(data);
  }

  PadButtonPressedCallback padBUttonPressedCallback(
      int buttonIndex, Gestures gesture) {
    String data = "buttonIndex : ${buttonIndex}";
    print(data);
    writeData(data);
  }

  return Scaffold(
    appBar: AppBar(
      title: Text(connectionText),
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
          JoystickView(
            onDirectionChanged: onDirectionChanged,
          ),
          PadButtonsView(
            padButtonPressedCallback: padBUttonPressedCallback,
          ),
        ],
      ),
    ),
  );
}
}
