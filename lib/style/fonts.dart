import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

TextStyle fS14({c}) {
  return TextStyle(
    color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
    fontSize: 14,
  );
}

TextStyle fS18({c}) {
  return TextStyle(
    color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
    fontSize: 18,
  );
}

TextStyle fS16({c}) {
  return TextStyle(
    color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
    fontSize: 16,
  );
}

TextStyle fS20({c}) {
  return TextStyle(
    color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
    fontSize: 20,
  );
}

TextStyle fS18w200({c}) {
  return TextStyle(
      color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
      fontSize: 18,
      fontWeight: FontWeight.w200);
}

TextStyle fS20w300({c}) {
  return TextStyle(
      color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
      fontSize: 20,
      fontWeight: FontWeight.w300);
}

TextStyle fS20w400({c}) {
  return TextStyle(
      color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
      fontSize: 20,
      fontWeight: FontWeight.w400);
}

TextStyle fS26({c}) {
  return TextStyle(
    color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
    fontSize: 26,
  );
}

TextStyle fS26w200({c}) {
  return TextStyle(
      color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
      fontSize: 26,
      fontWeight: FontWeight.w200);
}

TextStyle fS26w300({c}) {
  return TextStyle(
      color: c == null ? blackColor : Color(int.parse('FF$c', radix: 16)),
      fontSize: 26,
      fontWeight: FontWeight.w300);
}
