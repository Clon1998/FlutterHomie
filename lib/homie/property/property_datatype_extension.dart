import 'package:flutter_homie/homie/property/property_model.dart';

extension PropertyDataTypeDecorated on PropertyDataType {
  String get displayName {
    switch (this) {
      case PropertyDataType.float:
        return 'Float';
      case PropertyDataType.boolean:
        return 'Boolean';
      case PropertyDataType.string:
        return 'String';
      case PropertyDataType.enumeration:
        return 'Enumeration';
      case PropertyDataType.color:
        return 'Color';
      case PropertyDataType.integer:
      default:
        return 'Integer';
    }
  }

  static PropertyDataType fromString(String s) {
    return PropertyDataType.values
        .firstWhere((element) => element.toString().endsWith('.$s'), orElse: () => PropertyDataType.string);
  }
}
