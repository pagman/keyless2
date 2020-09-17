import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hive/hive.dart';
import 'package:keyless2/model/Device.dart';
import 'screens/myHomePage.dart';
import 'screens/myDevices.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
final FlutterBlue flutterBlue = FlutterBlue.instance;

void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(DeviceAdapter());
  await Hive.openBox('devices');
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
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/myDevices': (context) => myDevices(),

      }
    );
  }
  @override
  void dispose() {
    Hive.close();
  }
}
