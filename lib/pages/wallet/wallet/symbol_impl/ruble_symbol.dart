import 'package:indigo24/pages/wallet/wallet/symbol/symbol_interface.dart';
import 'package:indigo24/pages/wallet/wallet/symbol/symbol_enum.dart';

class RubleSymbol implements SymbolInterface {
  @override
  String symbolTitle = "ruble";
  @override
  double coef;

  RubleSymbol({
    this.coef = 1,
  });
  @override
  Symbol type = Symbol.ruble;
}
