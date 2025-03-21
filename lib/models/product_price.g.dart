// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_price.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductPriceAdapter extends TypeAdapter<ProductPrice> {
  @override
  final int typeId = 2;

  @override
  ProductPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductPrice(
      name: fields[0] as String,
      price: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ProductPrice obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
