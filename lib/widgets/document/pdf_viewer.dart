import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

class PDFViewer extends StatefulWidget {
  final file;
  final String text;
  PDFViewer(this.file, {@required this.text});

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  int _actualPageNumber = 1;
  int _allPagesCount = 0;
  PdfController _pdfController;

  @override
  void initState() {
    _pdfController =
        PdfController(document: PdfDocument.openAsset(widget.file));
    super.initState();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(primaryColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(10),
                child: Image(
                  image: AssetImage(
                    'assets/images/back.png',
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            centerTitle: true,
            title: Text(
              "${widget.text}",
              style: TextStyle(
                color: blackPurpleColor,
                fontWeight: FontWeight.w400,
                fontSize: 22,
              ),
              maxLines: 2,
              textAlign: TextAlign.justify,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: PdfView(
                    documentLoader: Center(child: CircularProgressIndicator()),
                    pageLoader: Center(child: CircularProgressIndicator()),
                    controller: _pdfController,
                    onDocumentLoaded: (document) {
                      setState(() {
                        _allPagesCount = document.pagesCount;
                      });
                    },
                    onPageChanged: (page) {
                      setState(() {
                        _actualPageNumber = page;
                      });
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        width: 1,
                        color: blackPurpleColor,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.navigate_before,
                        color: blackPurpleColor,
                      ),
                      onPressed: () {
                        _pdfController.previousPage(
                          curve: Curves.ease,
                          duration: Duration(milliseconds: 100),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: Text(
                      ' $_actualPageNumber / $_allPagesCount',
                      style: TextStyle(
                        fontSize: 22,
                        color: blackPurpleColor,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: blackPurpleColor,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        width: 1,
                        color: blackPurpleColor,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.navigate_next,
                        color: whiteColor,
                      ),
                      onPressed: () {
                        _pdfController.nextPage(
                          curve: Curves.ease,
                          duration: Duration(milliseconds: 100),
                        );
                      },
                    ),
                  ),
                  Container(height: 100),
                ],
              ),
            ],
          ),
        ),
      );
}
