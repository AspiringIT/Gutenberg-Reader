
import 'package:gutenberg_reader/models/Text_Layout.dart';
import 'package:gutenberg_reader/screens/Reader_Screen.dart' hide TextLayout;

class PaginationParams {
  final List<String> paragraphs;
  final double maxWidth;
  final double maxHeight;
  final double fontSize;
  final TextLayout layout;

  PaginationParams({
    required this.paragraphs,
    required this.maxWidth,
    required this.maxHeight,
    required this.fontSize,
    required this.layout,
  });
}