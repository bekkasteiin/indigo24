import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String _fullName = "Иван Иванов";
  final String _status = "Software Developer";
  final String _bio =
      "\"Hi, I am a Freelance developer working for hourly basis. If you wants to contact me to build your product leave a message.\"";
  final String _followers = "173";
  final String _posts = "24";
  final String _scores = "450";

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/cover.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSBWXyk_J29zFOujj_OVI9etvoysAWbLD-wdJeuRk6gnOERR98e&usqp=CAU'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Color(0xFF001D52),
            width: 5.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
    );

    return Text(
      _fullName,
      style: _nameTextStyle,
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        _status,
        style: TextStyle(
          fontFamily: 'Spectral',
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    TextStyle _statLabelTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.black54,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count,
          style: _statCountTextStyle,
        ),
        Text(
          label,
          style: _statLabelTextStyle,
        ),
      ],
    );
  }

  Widget _buildStatContainer() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Followers", _followers),
          _buildStatItem("Posts", _posts),
          _buildStatItem("Scores", _scores),
        ],
      ),
    );
  }

  Widget _buildBio(BuildContext context) {
    TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        _bio,
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }

  TextEditingController emailController = new TextEditingController(text: "example1234567890@gmail.com");

  Widget _buildEmailSection(Size screenSize){
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Email"),
          SizedBox(height: 5),
          TextField(
            decoration: null,
            controller: emailController,
          ),
          SizedBox(height: 5)
        ],
      ),
    );
  }

  Widget _buildPhoneSection(Size screenSize){
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("НОМЕР ТЕЛЕФОНА"),
          SizedBox(height: 5),
          Text("+7 700 000 0000", textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildCountySection(Size screenSize){
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("СТРАНА"),
          SizedBox(height: 5),
          Text("Казахстан", textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildCitySection(Size screenSize){
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("ГОРОД"),
          SizedBox(height: 5),
          Text("Алматы", textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildWhateverSection(Size screenSize){
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("WHATEVER", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 5),
          Text("Whatever", textAlign: TextAlign.left, style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      height: 0.5,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  Widget _buildGetInTouch(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        "Get in Touch with ${_fullName.split(" ")[0]},",
        style: TextStyle(fontFamily: 'Roboto', fontSize: 16.0),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () => print("followed"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: Color(0xFF404A5C),
                ),
                child: Center(
                  child: Text(
                    "FOLLOW",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: InkWell(
              onTap: () => print("Message"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "MESSAGE",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            
            
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 120),
                  // _buildFullName(),
                  // _buildStatus(context),
                  // _buildStatContainer(),
                  // _buildBio(context),
                  // _buildSeparator(screenSize),
                  // SizedBox(height: 10.0),
                  // _buildGetInTouch(context),
                  // SizedBox(height: 8.0),
                  // _buildButtons(),
                  
                  SizedBox(height: 10),
                  _buildPhoneSection(screenSize),
                  _buildSeparator(screenSize),
                  SizedBox(height: 10),
                  _buildEmailSection(screenSize),
                  _buildSeparator(screenSize),
                  SizedBox(height: 10),
                  _buildCountySection(screenSize),
                  _buildSeparator(screenSize),
                  SizedBox(height: 10),
                  _buildCitySection(screenSize),
                  _buildSeparator(screenSize),


    
                  SizedBox(height: 10),
                  _buildWhateverSection(screenSize),
                  _buildSeparator(screenSize),
                  SizedBox(height: 10),
                  _buildWhateverSection(screenSize),
                  _buildSeparator(screenSize),


                    
                  SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (){
                            print("lol 12");
                          },
                          child: Ink(
                            child: Text("Служба поддержки", style: TextStyle(color: Colors.grey)),
                          )
                        ),
                      ),
                      
                      SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),

            _buildCoverImage(screenSize),
            Column(
              children: <Widget>[
                SizedBox(height:5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (){
                            print("lol");
                          },
                          child: Ink(
                            child: Text("Выйти", style: TextStyle(color: Colors.white)),
                          )
                        ),
                      ),
                      
                      SizedBox(width: 10),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 10),
                      _buildProfileImage(),
                      SizedBox(width: 10),
                      _buildFullName(),
                    ],
                  ),
              ],
            ),



          ],
        ),
      ),
    );
  }
}