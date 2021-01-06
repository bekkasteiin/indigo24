import 'package:indigo24/pages/wallet/wallet/symbol/symbol_interface.dart';
import 'package:indigo24/pages/wallet/wallet/symbol/symbol_enum.dart';

class DollarSymbol implements SymbolInterface {
  @override
  String symbolTitle = "dollar";
  @override
  double coef;

  DollarSymbol({
    this.coef = 1,
  });
  @override
  Symbol type = Symbol.dollar;
}
