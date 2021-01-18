import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/document/download_manager.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/constants.dart';
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
        theme: ThemeData(primaryColor: whiteColor),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(10),
                child: Image(
                  image: AssetImage(
                    '${assetsPath}back.png',
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
            actions: [
              IconButton(
                icon: Container(
                  height: 20,
                  width: 20,
                  child: Image.asset(
                    "${assetsPath}download_black.png",
                    width: 20,
                  ),
                ),
                iconSize: 30,
                color: blackPurpleColor,
                onPressed: () async {
                  Api _api = Api();

                  final url = "https://indigo24.com/terms/ru.pdf";

                  void showDownloadProgress(received, total) {
                    if (total != -1) {
                      print((received / total * 100).toStringAsFixed(0) + "%");
                    }
                  }

                  DownloadManager downloadManager = DownloadManager(_api);
                  bool downloaded = await downloadManager.fileNetwork(
                    url: url,
                    onReceiveProgress: showDownloadProgress,
                    type: 'pdf',
                  );

                  downloaded
                      ? showIndigoDialog(
                          context: context,
                          builder: CustomDialog(
                            description: "${Localization.language.success}",
                            yesCallBack: () {
                              Navigator.pop(context);
                            },
                          ),
                        )
                      : showIndigoDialog(
                          context: context,
                          builder: CustomDialog(
                            description: "${Localization.language.error}",
                            yesCallBack: () {
                              Navigator.pop(context);
                            },
                          ),
                        );
                },
              )
            ],
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
