import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data.dart';
import 'util.dart';
import 'vaccine_locations.dart';

//Constants
enum Screen {
  HOME,
  APPOINTMENT,
}

Screen currentScreen = Screen.HOME;

const primaryColor = const MaterialColor(0xFF023E8A, const <int, Color>{
  50: const Color(0xFF03043E),
  100: const Color(0xFF03045E),
  200: const Color(0xFF023E8A),
  300: const Color(0xFF0077B6),
  400: const Color(0xFF0096C7),
  500: const Color(0xFF00B4D8),
  600: const Color(0xFF48CAE4),
  700: const Color(0xFF90E0EF),
  800: const Color(0xFFADE8F4),
  900: const Color(0xFFCAF0F8),
});

final TextStyle nStyle = TextStyle(
    fontSize: 50,
    fontStyle: FontStyle.italic,
    shadows: <Shadow>[
      Shadow(color: Colors.black54, offset: Offset.fromDirection(0.7854, 5))
    ],
    letterSpacing: -10,
    color: Colors.blue[100]);

final TextStyle jStyle = TextStyle(
    fontSize: 50,
    fontStyle: FontStyle.italic,
    shadows: <Shadow>[
      Shadow(color: Colors.black54, offset: Offset.fromDirection(0.7854, 5))
    ],
    letterSpacing: 5,
    color: Colors.red);

final ShaderMask mask = ShaderMask(
  shaderCallback: (rect) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[
        Colors.black.withOpacity(1.0),
        Colors.black.withOpacity(0.75),
        Colors.black.withOpacity(0.5),
        Colors.black.withOpacity(0.25),
        Colors.black.withOpacity(0), // <-- change this opacity
        // Colors.transparent // <-- you might need this if you want full transparency at the edge
      ],
      stops: [
        0.0,
        0.25,
        0.5,
        0.75,
        1.0
      ], //<-- the gradient is interpolated, and these are where the colors above go into effect (that's why there are two colors repeated)
    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
  },
  blendMode: BlendMode.dstIn,
  child: Image.asset('assets/nj.png'),
);

List<VaccineLocation> dataList = [];
bool connected = false;

//main method to run app
void main() async {
  runApp(RootWidget());
  dataList = await fetchNJ();
  connected = await isConnected();
}

//Root Widget (Houses all other Widgets)
class RootWidget extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NJVax',
      theme: ThemeData(
        primarySwatch: primaryColor,
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MainAppBar(), drawer: MainDrawer(), body: HomeBody());
  }
}

//---------- APPBAR ----------
@deprecated
AppBar getAppBar(BuildContext context) => AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      toolbarHeight: 80,
      centerTitle: true,
      backgroundColor: Color(0xFF004AAD),
      title: RichText(
        text: TextSpan(
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            children: <TextSpan>[
              TextSpan(text: "N", style: nStyle),
              TextSpan(text: "J", style: jStyle),
              TextSpan(text: "VAX")
            ]),
      ),
    );

//---------- APPBAR ----------
class MainAppBar extends AppBar {
  MainAppBar({Key? key, Widget? title})
      : super(
          iconTheme: IconThemeData(color: Colors.white),
          toolbarHeight: 80,
          centerTitle: true,
          backgroundColor: Color(0xFF004AAD),
          title: RichText(
            text: TextSpan(
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Raleway-Heavy"),
                children: <TextSpan>[
                  TextSpan(text: "N", style: nStyle),
                  TextSpan(text: "J", style: jStyle),
                  TextSpan(text: "VAX")
                ]),
          ),
          brightness: Brightness.dark,
        );
}

//---------- DRAWER ----------
class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment(-2, 0),
                  child: mask,
                ),
                Align(
                    alignment: Alignment(1.5, -0.3),
                    child: Transform.rotate(
                        angle: degreesToRad(30),
                        child: Text("Get Vaxxed!",
                            style: TextStyle(
                                fontSize: 40, fontFamily: "PermanentMarker"))))
              ],
            )),
        //Home Tile
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home', style: TextStyle(fontSize: 16)),
          onTap: () {
            Navigator.pop(context);
            if (currentScreen != Screen.HOME) {
              currentScreen = Screen.HOME;

              if (Platform.isIOS) {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => HomePage()));
              } else {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, Animation<double> a1, Animation<double> a2) =>
                            FadeTransition(
                      opacity: a1,
                      child: HomePage(),
                    ),
                  ),
                );
              }
            }
          },
        ),

        //Appointment Tile
        ListTile(
          leading: Icon(Icons.calendar_today_rounded),
          title:
              Text('Schedule Your Appointment', style: TextStyle(fontSize: 16)),
          onTap: () {
            Navigator.pop(context);
            if (currentScreen != Screen.APPOINTMENT) {
              currentScreen = Screen.APPOINTMENT;

              if (Platform.isIOS) {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => AppointmentPage()));
              } else {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, Animation<double> a1, Animation<double> a2) =>
                            FadeTransition(
                      opacity: a1,
                      child: AppointmentPage(),
                    ),
                  ),
                );
              }
            }
          },
        ),

        //Profile Tile
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Profile', style: TextStyle(fontSize: 16)),
        ),
        //Settings Tile
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings', style: TextStyle(fontSize: 16)),
        ),
      ],
    ));
  }
}

class HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(children: <Card>[
      Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              leading: Icon(Icons.album),
              title: Text('The Enchanted Nightingale'),
              subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('BUY TICKETS'),
                  onPressed: () {/* ... */},
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('LISTEN'),
                  onPressed: () {/* ... */},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
      Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              leading: Icon(Icons.location_pin),
              title: Text('The Enchanted Nightingale'),
              subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('BUY TICKETS'),
                  onPressed: () {/* ... */},
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('LISTEN'),
                  onPressed: () {/* ... */},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}

//---------- APPOINTMENT SCREEN ----------
class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MainAppBar(), drawer: MainDrawer(), body: AppointmentBody());
  }
}
