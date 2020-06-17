enum PropertyValidationError {
  empty,
  notNumeric,
  notFloating,
  noBool,
  sizeExceeded,
  toSmall,
  toBig,
  general,
  wrongRGBFormat,
  wrongHSVFormat
}

extension PropertyValidationErrorDecoraded on PropertyValidationError {
  String get description {
    switch (this) {
      case PropertyValidationError.empty:
        return 'Empty value';
      case PropertyValidationError.toSmall:
        return 'Smaller than Format range';
      case PropertyValidationError.toBig:
        return 'Bigger than format range';
      case PropertyValidationError.notNumeric:
        return 'Non numeric value';
      case PropertyValidationError.notFloating:
        return 'Non floating numeric value. Make sure to use "." instead of ","';
      case PropertyValidationError.wrongRGBFormat:
        return 'Not matching RGB-Color format';
      case PropertyValidationError.wrongHSVFormat:
        return 'Not matching HSV-Color format';
      default:
        return 'General';
    }
  }
}
