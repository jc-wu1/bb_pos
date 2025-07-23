import 'package:isar/isar.dart';

part 'receipt.g.dart';

@collection
@Name('ReceiptModel')
class Receipt {
  Receipt({this.txnId, this.createdAt});

  Id id = Isar.autoIncrement;

  String? txnId;

  @Index()
  DateTime? createdAt;

  final products = IsarLinks<Product>();
}

@collection
@Name('ProductModel')
class Product {
  Product({
    this.itemId,
    this.productName,
    this.productPrice,
    this.productDesc,
    this.createdAt,
    this.qty = 0,
    this.image,
  });

  Id id = Isar.autoIncrement;

  String? itemId;
  String? productName;
  String? productDesc;
  double? productPrice;
  int? qty;
  String? image;
  DateTime? createdAt;

  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get productNameWords => productName!.split(' ');
}
