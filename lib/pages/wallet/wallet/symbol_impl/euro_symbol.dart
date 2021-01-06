import 'package:indigo24/pages/wallet/wallet/symbol/symbol_interface.dart';
import 'package:indigo24/pages/wallet/wallet/symbol/symbol_enum.dart';

class EuroSymbol implements SymbolInterface {
  @override
  String symbolTitle = "euro";
  @override
  double coef;

  EuroSymbol({
    this.coef = 1,
  });
  @override
  Symbol type = Symbol.euro;
}
