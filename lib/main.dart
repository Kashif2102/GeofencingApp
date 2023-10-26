import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './location_selection_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Geofence Alarm Application",
      theme: ThemeData(
          primarySwatch: Colors.brown,
          hintColor: Colors.greenAccent,
          errorColor: Colors.red,
          textTheme: ThemeData.dark().textTheme.copyWith(
                headline6:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
          appBarTheme: AppBarTheme(
            toolbarTextStyle: ThemeData.dark()
                .textTheme
                .copyWith(
                  headline6: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .bodyText2,
            titleTextStyle: ThemeData.dark()
                .textTheme
                .copyWith(
                  headline6: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .headline6,
          )),
      home: startscreen(),
    );
  }
}

class startscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geofence Alarm Application"),
        backgroundColor: Colors.red,
      ),
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          child: const Text("Press to get started",
              style: TextStyle(fontSize: 20.0)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LocationSelectionScreen()),
            );
          },
        ),
      ),
    );
  }
}
