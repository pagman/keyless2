import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
class myDevices extends StatefulWidget {
  @override
  _myDevicesState createState() => _myDevicesState();
}


class _myDevicesState extends State<myDevices> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;
  List<String> deviceName;
  Future<List<String>> deviceName2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("my Devices"),
        backgroundColor: Color(0xffB8141F),
      ),
          body: StreamBuilder<List<ScanResult>>(
            stream: FlutterBlue.instance.scanResults,
            initialData: [],
            builder: (c, snapshot) => Column(
              children: snapshot.data
                  .map(
                    (r) => Card(
                      child: ListTile(
                        title: new Center(
                            child: new Text(
                              r.device.name,
                              style: new TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15.0),
                            )),
                        onTap: () {
                          print("skata");
                        },
                      ),
                    ),
              )
                  .toList(),
            ),
          ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Color(0xffB8141F),
            );
          } else {
            return Container(

                child: Visibility(
                  visible: true,
                  child: FloatingActionButton(
                      backgroundColor: Color(0xffB8141F),
                      child: Icon(Icons.search,
                        color: Color(0xffE7F7D4),
                      ),
                      onPressed: () => FlutterBlue.instance
                          .startScan(timeout: Duration(seconds: 4))),
                ),
            );
          }
        },
      ),
          );
  }
}
