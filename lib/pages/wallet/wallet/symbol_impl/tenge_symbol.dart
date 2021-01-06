import 'package:indigo24/pages/wallet/wallet/symbol/symbol_interface.dart';
import 'package:indigo24/pages/wallet/wallet/symbol/symbol_enum.dart';

class TengeSymbol implements SymbolInterface {
  @override
  String symbolTitle = "tenge";
  @override
  double coef;

  TengeSymbol({
    this.coef = 1,
  });

  @override
  Symbol type = Symbol.tenge;
}
