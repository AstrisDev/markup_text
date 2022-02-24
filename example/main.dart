import 'package:flutter/material.dart';
import 'package:markup_text/markup_text.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: MarkupText("(b)Markup(/b) (c yellow)(i)Example(/i)(/c)"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MarkupText(
                "This is a (b)bold(/b) text (a http://flutter.dev)with a link(/a),"
                " an (u)underlined(/u) word (a http://pub.dev)with"
                " a second link containing a word in (i)italics(/i)(/a) and (c #ff0000)colored(/c) words"
                " (c deepPurpleAccent)here(/c) and (c green)there(/c).",
                style: TextStyle(fontSize: 18),
              ),
              Container(margin: EdgeInsets.all(8)),
              MarkupText(
                "(c purple)(icon flight_takeoff) Departures(/c)\n"
                "(c teal)(icon flight_land) Arrivals(/c)",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
