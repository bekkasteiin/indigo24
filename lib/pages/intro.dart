import 'package:flutter/material.dart';
import 'package:indigo24/pages/login.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
  
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: Colors.white, // status bar color
          brightness: Brightness.light, // status bar brightness
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_login.png"),
                fit: BoxFit.cover 
              ),
              
            )
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _space(size.height/2.5),
                  _signInButton(size),
                  _space(10),
                  _signUpButton(size),
                  _space(size.height/5),
                  
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  _space(double h){
    return Container(
      height: h,
    );
  }

  _signInButton(Size size){
    return ButtonTheme(
      minWidth: size.width * 0.75,
      height: 60,
      child: RaisedButton(
        onPressed: () {
          print('Login is pressed');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        child: const Text(
          'Вход',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
        ),
        color: Color(0xFFFFFFFF),
        textColor: Color(0xFF001D52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
      ),
    );
  }

  _signUpButton(Size size){
    return ButtonTheme(
      minWidth: size.width * 0.75,
      height: 60,
      child: RaisedButton(
        onPressed: () {
          print('Register is pressed');
        },
        child: const Text(
          'Регистрация',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
        ),
        color: Color(0xFFffffff).withOpacity(0.35),
        textColor: Color(0xFFffffff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
      ),
    );
  }
}

