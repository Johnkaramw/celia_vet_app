// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_Product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      name: fields[0] as String,
      buyPrice: fields[1] as double,
      sellPrice: fields[2] as double,
      quantityBought: fields[3] as int,
      quantitySold: fields[4] as int,
      soldQuantity: fields[5] as int,
      createdAt: fields[6] as DateTime,
      description: fields[7] as String?,
      expiryDate: fields[8] as DateTime?,
      authority: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.buyPrice)
      ..writeByte(2)
      ..write(obj.sellPrice)
      ..writeByte(3)
      ..write(obj.quantityBought)
      ..writeByte(4)
      ..write(obj.quantitySold)
      ..writeByte(5)
      ..write(obj.soldQuantity)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.expiryDate)
      ..writeByte(9)
      ..write(obj.authority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
