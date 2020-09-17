import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../widgets/verse.dart';
import '../providers/providers.dart';
import '../util/variables.dart';
import '../controllers/database-helper.dart';
import '../util/strings.dart';
import '../widgets/drawer.dart';
import '../widgets/title.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime currentBackPressTime;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _messaging = FirebaseMessaging();
  final String title = 'श्रीमद्भगवद् गीता';
  final int chapter = 18;

  @override
  void initState() {
    super.initState();
    _messaging.subscribeToTopic('all');
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('mesage received');
        print("onMessage: $message");
        var notification = message["notification"];
        // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Hi"),));
        showDialog(
          context: _scaffoldKey.currentState.context,
          builder: (context) {
            return AlertDialog(
              title: Text(notification["title"]),
              content: Text(notification["body"]),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            );
          },
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {},
    );
  }

  @override
  void dispose() {
    DatabaseHelper.disposeDatabase();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(AssetImage('assets/banner.png'), context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final gita = Provider.of<Gita>(context);
    final selectionProvider = Provider.of<Selection>(context);
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          _scaffoldKey.currentState
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('Press back again to exit'),
            ));
          return Future.value(false);
        }
        return Provider.of<MyAudio>(context, listen: false).disposeAudio();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: !selectionProvider.verses.contains(true)
            ? AppBar(
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      flex: 4,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: (gita.chapter > 1)
                            ? () {
                                gita.previousPage();
                              }
                            : null,
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 20,
                      child: BookTitle(title: title),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 4,
                      child: ChapterNumber(
                        currentPage: gita.chapter,
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: (gita.chapter < chapter)
                            ? () {
                                gita.nextPage();
                              }
                            : null,
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/search');
                          }),
                    )
                  ],
                ),
              )
            : PreferredSize(
                preferredSize: const Size(double.infinity, kToolbarHeight),
                child: Builder(
                  builder: (ctx) => AppBar(
                    centerTitle: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            selectionProvider.clear();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            Share.share(selectionProvider.selection
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]]'), '')
                                    .replaceAll(',', '')
                                    .trim() +
                                appUrl);
                            selectionProvider.clear();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.bookmark),
                          onPressed: () async {
                            await Provider.of<BookmarkManager>(context,
                                    listen: false)
                                .setBookmark(
                                    gita.chapter, selectionProvider.list);
                            Scaffold.of(ctx).showSnackBar(SnackBar(
                              content: Text(
                                  selectionProvider.list.length.toString() +
                                      addedToBookmarks),
                              behavior: SnackBarBehavior.floating,
                            ));
                            selectionProvider.clear();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            Clipboard.setData(new ClipboardData(
                                text: selectionProvider.selection
                                        .toString()
                                        .replaceAll(RegExp(r'[\[\]]'), '')
                                        .replaceAll(',', '')
                                        .trim() +
                                    appUrl));
                            Scaffold.of(ctx).showSnackBar(SnackBar(
                              content: const Text(copiedToClipboard),
                              behavior: SnackBarBehavior.floating,
                            ));
                            selectionProvider.clear();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
        drawer: drawer(context),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Builder(
              builder: (context) {
                if (gita.items.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                selectionProvider.add(gita.items.length);
                return Consumer<FontManager>(
                    builder: (context, fontManager, _) {
                  return ListView.builder(
                    key: ValueKey(gita.chapter),
                    itemCount: gita.items.length,
                    itemBuilder: (context, index) {
                      final item = gita.items[index];
                      // final String langData = langManager.language == 0
                      //     ? item.nepali
                      //     : item.english;
                      final String langData = item.data;
                      return InkWell(
                        child: Verse(
                          geeta: item,
                          translation: langData,
                          fontSize: fontManager.fontSize,
                          textColor: selectionProvider.textColor[index],
                          // download: gita.audio[gita.chapter - 1].download,
                          scaffoldKey: _scaffoldKey,
                        ),
                        onTap: () {
                          selectionProvider.selectVerse(
                              index, item.data, langData);
                        },
                      );
                    },
                  );
                });
              },
            ),
            selectionProvider.verses.contains(true)
                ? Container(
                    color: Colors.blue,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: color.map((c) {
                        return InkWell(
                          onTap: () async {
                            final int col =
                                color.indexWhere((test) => test == c);
                            await gita.setColor(
                                col, gita.chapter, selectionProvider.list);
                            selectionProvider.clear();
                          },
                          child: Container(
                            child: SizedBox(
                              height: mediaquery.size.width / 10,
                              width: mediaquery.size.width / 10,
                            ),
                            color: c,
                          ),
                        );
                      }).toList(),
                    ))
                : Container()
          ],
        ),
      ),
    );
  }
}
