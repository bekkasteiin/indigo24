import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;

class IndigoSearchWidget extends StatelessWidget {
  final Function callback;
  final Function onChangeCallback;
  final TextEditingController _searchController;

  const IndigoSearchWidget({
    Key key,
    @required TextEditingController searchController,
    @required this.callback,
    @required this.onChangeCallback,
  })  : _searchController = searchController,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(55),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            spreadRadius: -5,
            offset: Offset(0.0, 6.0),
          )
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
              child: Icon(
                Icons.search,
                size: 26,
              ),
              onTap: callback),
          isDense: true,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: const BorderRadius.all(
              const Radius.circular(20.0),
            ),
          ),
          contentPadding: EdgeInsets.only(
            left: 15,
            bottom: 10,
            top: 10,
            right: 15,
          ),
          hintText: "${localization.search}",
          hintStyle: TextStyle(
            color: darkPrimaryColor,
          ),
          fillColor: whiteColor,
        ),
        onChanged: onChangeCallback,
        controller: _searchController,
      ),
    );
  }
}
