import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/configs.dart' as configs;

class RefillPage extends StatefulWidget {
  @override
  _RefillPageState createState() => _RefillPageState();
}

class _RefillPageState extends State<RefillPage> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  @override
  void dispose() {
    api.getBalance();
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
  var commission = '0';
  final amountController = TextEditingController();
  Api api = Api();
  WillPopScope buildWebviewScaffold(url) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
          brightness: Brightness.light,
          title: Text(
            "${localization.refill}",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: WebviewScaffold(
            url: '$url',
            withZoom: true,
            withLocalStorage: true,
            hidden: false,
            initialChild: Center(child: CircularProgressIndicator())
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
          brightness: Brightness.light,
          title: Text(
            "${localization.refill}",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              Center(
                child: Text('${localization.commission} ${configs.refillCommission}%'),
              ),
              Center(
                child: Text('${localization.minAmount} ${configs.refillMin} KZT'),
              ),
              Center(
                child: Text('${localization.minCommission} ${configs.refillMinCommission} KZT'),
              ),
              Center(
                child: Text('${localization.maxAmount} ${configs.refillMax} KZT'),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration.collapsed(
                    hintText: '${localization.amount}',
                  ),
                  style: TextStyle(fontSize: 20),
                  controller: amountController,
                  onChanged: (String text) async {
                    if(amountController.text[0] == '0'){
                      amountController.clear();
                    }
                    if(amountController.text.isNotEmpty){
                      // if(amountController.text[0] == '0'){
                      //   amountController.text = '';
                      // }
                      if(int.parse(amountController.text) < int.parse(configs.refillMax))
                        setState(() {
                          commission = (int.parse(text) * 2.2 / 100).toStringAsFixed(2);
                          if(double.parse(commission) < 350.00 )
                            commission = '350';
                        });
                      // if(amountController.text[0] == '0'){
                      //   amountController.text = '';
                      // } else{
                      //   if(int.parse(amountController.text) < int.parse(configs.refillMax))
                      //     setState(() {
                      //       commission = (int.parse(text) * 2.2 / 100).toStringAsFixed(2);
                      //       if(double.parse(commission) < 350.00 )
                      //         commission = '350';
                      //     });
                      // }
                     
                    } else{
                      setState(() {
                        commission = '0';
                      });
                    }
                  },
                ),
              ),
              Center(child: Text('${localization.commission} $commission KZT')),
              Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          spreadRadius: -2,
                          offset: Offset(0.0, 0.0))
                    ]),
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 20, bottom: 10),
                child: ButtonTheme(
                  minWidth: double.infinity,
                  height: 100.0,
                  child: FlatButton(
                    onPressed: () async {
                      if(amountController.text.isNotEmpty){
                        api.refill(amountController.text).then((refillResult){
                          if(refillResult['success'].toString() == 'true'){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => buildWebviewScaffold(refillResult['redirectURL'])));
                          } else{
                            Widget okButton = CupertinoDialogAction(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            );
                            CupertinoAlertDialog alert = CupertinoAlertDialog(
                              title: Text("${localization.alert}"),
                              content: Text('${refillResult['message']}'),
                              actions: [
                                okButton,
                              ],
                            );
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          }
                          print(refillResult);
                        });
                      }
                    },

                    child: Text(
                      '${localization.refill}',
                      style: TextStyle(
                          color: Color(0xFF0543B8), fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
                  SizedBox(height: 10,),

            ],
          ),
        ),
      ),
    );
  }
}
