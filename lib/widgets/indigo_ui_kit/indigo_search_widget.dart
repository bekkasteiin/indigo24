import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'indigo_text_field_widget.dart';

class IndigoSearchWidget extends StatelessWidget {
  final Function callback;
  final Function onChangeCallback;
  final TextEditingController _searchController;

  const IndigoSearchWidget({
    Key key,
    @required TextEditingController searchController,
    this.callback,
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
      child: IndigoTextField(
        onChangeCallback: onChangeCallback,
        textEditingController: _searchController,
        suffixIcon: GestureDetector(
          child: Icon(
            Icons.search,
            size: 26,
          ),
          onTap: callback,
        ),
        hintText: localization.search,
      ),
    );
  }
}
