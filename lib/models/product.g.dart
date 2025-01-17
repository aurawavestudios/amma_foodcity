// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

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
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as String,
      weight: fields[4] as int,
      salePrice: fields[3] as String?,
      isOnSale: fields[5] as bool,
      imagePath: fields[6] as String,
      imageUrls: (fields[7] as List).cast<String>(),
      description: fields[8] as String,
      category: fields[9] as String,
      categoryId: fields[10] as String,
      subCategory: fields[11] as String,
      origin: fields[12] as String,
      storage: fields[13] as String,
      vendor: fields[14] as String,
      tags: (fields[15] as List).cast<String>(),
      handle: fields[16] as String,
      quantityAvailable: fields[17] as int?,
      isAvailable: fields[18] as bool,
      variantId: fields[19] as String,
      metafields: (fields[20] as Map?)?.cast<String, String>(),
      publishedAt: fields[21] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.salePrice)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.isOnSale)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.imageUrls)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.categoryId)
      ..writeByte(11)
      ..write(obj.subCategory)
      ..writeByte(12)
      ..write(obj.origin)
      ..writeByte(13)
      ..write(obj.storage)
      ..writeByte(14)
      ..write(obj.vendor)
      ..writeByte(15)
      ..write(obj.tags)
      ..writeByte(16)
      ..write(obj.handle)
      ..writeByte(17)
      ..write(obj.quantityAvailable)
      ..writeByte(18)
      ..write(obj.isAvailable)
      ..writeByte(19)
      ..write(obj.variantId)
      ..writeByte(20)
      ..write(obj.metafields)
      ..writeByte(21)
      ..write(obj.publishedAt);
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
