import 'package:flutter/material.dart';
import 'package:indigo24/services/localization/localization.dart';
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
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
          hintText: Localization.language.search,
        ),
      ),
    );
  }
}
