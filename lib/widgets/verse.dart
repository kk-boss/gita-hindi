import 'package:flutter/material.dart';

import '../util/variables.dart';
import '../models/geeta.dart';
// import './player.dart';

class Verse extends StatelessWidget {
  Verse(
      {Key key,
      @required this.geeta,
      this.translation,
      this.fontSize,
      this.textColor,
      // this.download,
      this.scaffoldKey,
      this.showAudio = true})
      : super(key: key);
  final Geeta geeta;
  final String translation;
  final double fontSize;
  final Color textColor;
  // final int download;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool showAudio;
  @override
  Widget build(BuildContext context) {
    final List<String> data = geeta.data.split('\n\n');
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: textColor == Colors.grey[400] ? textColor : color[geeta.color],
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Text(
                  data[0],
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                ),
                Text(
                  data[1],
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
