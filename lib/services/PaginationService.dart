import 'package:flutter/material.dart';
import 'package:gutenberg_reader/models/Text_Layout.dart';

class PaginationService {
  // This function now uses the TextLayout enum directly for type safety
  static TextAlign getAlign(TextLayout layout) {
    switch (layout) {
      case TextLayout.justify:
        return TextAlign.justify;
      case TextLayout.center:
        return TextAlign.center;
      case TextLayout.right:
        return TextAlign.end;
      default:
        return TextAlign.start;
    }
  }
}
