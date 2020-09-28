import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_picker/Picker.dart';
import 'package:hive/hive.dart';
import 'package:keyless2/PickerData.dart';
import 'package:keyless2/model/Device.dart';
import 'package:keyless2/pickervalue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../PickerMeterData.dart';

class myDevices extends StatefulWidget {
  @override
  _myDevicesState createState() => _myDevicesState();
}

class _myDevicesState extends State<myDevices> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;
  List<String> deviceName;
  bool _visible = true;
  Future<List<String>> deviceName2;
  var monVal = true;
  var tuVal = true;
  int meters = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey1 = GlobalKey<ScaffoldState>();

  void addDevice(int index, Device device){
    final deviceBox = Hive.box('devices');
    deviceBox.put(device.name,device);
    print('Name: ${deviceBox.get(index).name} Meters: ${deviceBox.get(index).meters} Approaching: ${deviceBox.get(index).approaching} Auto: ${deviceBox.get(index).auto} ');
    //print('Name: ${device.name},Meters: ${device.meters} Approaching: ${device.approaching} Auto: ${device.auto} ');
  }

  @override
  Widget build(BuildContext context) {
    var checkedValue = false;
    return Scaffold(
      key: _scaffoldKey1,
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
                (r) => Container(
                  height: 100,
                  child: Card(
                    child: ListTile(
                      title: new Center(
                          child: new Text(
                        r.device.name,
                        style: new TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15.0),
                      )),
                      onTap: () {
                        var index = snapshot.data.indexOf(r);
                        print(index);
                        print("skata");
                        //showPicker(context);
                        setState(() {
                          _visible = false;
                        });
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Column(
                            children: [
                              Flexible(
                                  child: Text("Add")),
                              Flexible(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    size: 30.0,
                                    color: Colors.brown[900],
                                  ),
                                  onPressed: () {
                                    var index = snapshot.data.indexOf(r);
                                    print(index);
                                    final newDevice = Device(r.device.name, meters, tuVal,monVal);
                                    addDevice(index, newDevice);
                                    //print("add");
                                    //   _onDeleteItemPressed(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Flexible(child: Text("Delete")),
                              Flexible(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 30.0,
                                    color: Colors.brown[900],
                                  ),
                                  onPressed: () {
                                    var index = snapshot.data.indexOf(r);
                                    print(index);
                                    showPicker(context);
                                    print("delete");
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Flexible(child: Text("Approaching")),
                              SizedBox(
                                height: 10,
                              ),
                              Flexible(
                                child: Checkbox(
                                  value: monVal,
                                  onChanged: (bool value) {
                                    var index = snapshot.data.indexOf(r);
                                    print(index);
                                    setState(() {
                                      monVal = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Flexible(child: Text("Auto")),
                              SizedBox(
                                height: 10,
                              ),
                              Flexible(
                                child: Checkbox(
                                  value: tuVal,
                                  onChanged: (bool value) {
                                    var index = snapshot.data.indexOf(r);
                                    print(index);
                                    setState(() {
                                      tuVal = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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
                visible: _visible,
                child: FloatingActionButton(
                    backgroundColor: Color(0xffB8141F),
                    child: Icon(
                      Icons.search,
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

  showPicker(BuildContext context) {
    Picker picker = Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: JsonDecoder().convert(PickerMeterData)),
        changeToFirst: false,
        textAlign: TextAlign.left,
        textStyle: const TextStyle(color: Colors.blue, fontSize: 17.0),
        selectedTextStyle: TextStyle(color: Colors.red, fontSize: 17.0),
        columnPadding: const EdgeInsets.all(0.0),
        onConfirm: (Picker picker, List value) {
          setState(() {
            _visible = true;
          });
          print(value[1].toString());
          meters = value[1];
        });
    picker.show(_scaffoldKey1.currentState);
  }
}
