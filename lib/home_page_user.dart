import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:location/location.dart';
import 'package:userlocation/main.dart';

import 'get_address_location.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({
    Key? key,
    // required this.title,
    // required this.email,
    required this.user,
  }) : super(key: key);

  // final String title, email;
  final User? user;

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser>
    with WidgetsBindingObserver {
  Location location = Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  double? lat, lng;
  AppLifecycleState appLifecycleState = AppLifecycleState.detached;

  String address = '';

  // final databaseReference = FirebaseDatabase.instance.ref("users/123");
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Future<void> askLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    try {
      location.enableBackgroundMode(enable: true);
    } catch (error) {
      print("Can't set background mode");
    }
    location.onLocationChanged.listen(
      (LocationData locationData) async {
        lat = _locationData!.latitude;
        lng = _locationData!.longitude;
        address = await getPlace(lat, lng);
        setState(() {});
        // try {
        //   await location.enableBackgroundMode(enable: true);
        // } catch (error) {
        //   print("Can't set background mode");
        // }
        // }
        print(lat);
        print(lng);

        createData(widget.user!.displayName, widget.user!.email,
            _locationData!.latitude, _locationData!.longitude);
      },
    );
  }

  // Future<void> askLocation() async {
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled!) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled!) {
  //       return;
  //     }
  //   }
  //   // if (appLifecycleState == AppLifecycleState.paused) {
  //   // in background

  //   // try {
  //   //   await location.enableBackgroundMode(enable: true);
  //   // } catch (error) {
  //   //   print("Can't set background mode");
  //   // }
  //   // }
  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }

  //   _locationData = await location.getLocation();
  //   setState(() {
  //     lat = _locationData!.latitude;
  //     lng = _locationData!.longitude;
  //   });
  //   // print(lat);
  //   // print(lng);
  //   location.onLocationChanged.listen(
  //     (LocationData locationData) {
  //       setState(() {
  //         lat = _locationData!.latitude;
  //         lng = _locationData!.longitude;
  //       });
  //       print(lat);
  //       print(lng);
  //       createData(widget.user!.displayName, widget.user!.email,
  //           _locationData!.latitude, _locationData!.longitude);
  //     },
  //   );
  // }

  @override
  void initState() {
    askLocation();

    super.initState();
    // WidgetsBinding.instance.addObserver(this);
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   appLifecycleState = state;
  // }

  @override
  void dispose() {
    // TODO: implement dispose

    // askLocation();
    // lat;
    // lng;

    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void createData(name, email, lat, long) async {
    await databaseReference
        .child("Users/${widget.user!.uid}")
        .set({"name": name, "email": email, "lat": lat, "long": long});
    print("written");
    // await ref.set({
    //   "name": "John",
    //   "lat": 18,
    //   "long": 18,
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user!.displayName!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Name : "),
                Text(widget.user!.displayName!.split("|").first),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Email : "),
                Text(widget.user!.email!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Location : "),
                // Text(lat ?? ' ' " " + lng ?? ' '),
                Text(address),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          EasyLoading.show(status: 'loading...');
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sign out Successfully"),
            backgroundColor: Colors.blueAccent,
          ));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
          EasyLoading.dismiss();
        },
        tooltip: 'Sign out',
        child: const Icon(Icons.logout),
      ),
    );
  }
}
