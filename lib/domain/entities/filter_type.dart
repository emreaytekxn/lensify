enum FilterType {
  original,
  blackAndWhite,
  grayscale,
  magicColor
}

extension FilterTypeExtension on FilterType {
  String get name {
    switch (this) {
      case FilterType.original:
        return 'Original';
      case FilterType.blackAndWhite:
        return 'B&W';
      case FilterType.grayscale:
        return 'Grayscale';
      case FilterType.magicColor:
        return 'Magic Color';
    }
  }
}
