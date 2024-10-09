import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/config/toc.dart';
import 'package:markdown_widget/widget/all.dart';

class NoteScreen extends StatefulWidget {
  NoteScreen({super.key, required this.assetsPath});

  String assetsPath;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  String? data;
  final TocController tocController = TocController();
  bool isLoaded = false;

  @override
  void initState() {
    loadData(widget.assetsPath);
    super.initState();
  }

  void loadData(String assetsPath) {
    rootBundle.loadString(assetsPath).then((data) {
      this.data = data;
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: !isLoaded
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: height,
                  color: Colors.transparent,
                  child: Icon(Icons.arrow_back_ios_new),
                ),
              ),
              Expanded(child: buildTocWidget(), flex: 1),
              Expanded(child: buildMarkdown(), flex: 2)
            ],
          ),
        ));
  }

  Widget buildTocWidget() => TocWidget(controller: tocController);

  Widget buildMarkdown() => MarkdownWidget(data: data!, tocController: tocController);
}
