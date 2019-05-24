import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';
void main() => runApp(new MaterialApp(
    home:MainPage(),
    ));

class MainPage extends StatefulWidget {
@override
  State createState() => new MainPageState();
  }

class MainPageState  extends State<MainPage> {
 Iterable<CallLogEntry> _callLogEntries = [];
 @override
  void initState() {
    super.initState();
    requestPermission();
  }

  requestPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.contacts,PermissionGroup.sms,PermissionGroup.locationAlways,PermissionGroup.phone]);
  }
  Future check() async{
      Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
GeolocationStatus geolocationStatus  = await geolocator.checkGeolocationPermissionStatus();
    try{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  } on PlatformException {
 AppSettings.openLocationSettings();
}
  }
  Future update() async{
var geolocator = Geolocator();
var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 100);

  var now = DateTime.now();
int from = now.subtract(Duration(days: 2)).millisecondsSinceEpoch;
int to = now.subtract(Duration(days: 0)).millisecondsSinceEpoch;
    _callLogEntries = await CallLog.query(dateFrom: from,
      dateTo: to,
      durationFrom: 0,
      durationTo: 60,
      type: CallType.outgoing,);
StreamSubscription<Position> positionStream = geolocator.getPositionStream(locationOptions).listen(
    (Position position) {
             SmsSender sender = new SmsSender();
      _callLogEntries.forEach((entry) {
      var address = '${entry.formattedNumber}';
 SmsMessage message = new SmsMessage(address, 'SOS Alert!'+'current location: '+position.toString());
  sender.sendSms(message);
    });
 });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
       appBar: new AppBar(
        title: new Text('Locate'),
        backgroundColor: Color(0xFF915FB5),
       ),
 body: new Stack(
        children: <Widget>[
          new Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(colors: [const Color(0xFF915FB5),const Color(0xFFCA436B)],
           begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomRight,
                stops: [0.0,1.0],
                tileMode: TileMode.clamp,
        ),
      ),
          ),
          new Container(
            alignment: new FractionalOffset(0.5, 0.5),
            margin: new EdgeInsets.only(bottom: 20.0),
            child: new MaterialButton(
            height: 40.0, 
            minWidth: 100.0,
            child: new Text("send alert",style: new TextStyle(color: Colors.white,fontSize: 20.0,fontFamily: 'RobotoMono-BoldItalic')),
            color:Colors.greenAccent,
            textColor: Colors.white,
            highlightColor: Colors.blue,
            highlightElevation: 30.0,
          onPressed: () {
            check();
            update();
            
          },
),
),
],
),);
}
}

