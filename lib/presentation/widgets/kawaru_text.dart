import 'package:flutter/material.dart';

class KawaruText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const KawaruText(this.text, {super.key, this.style, this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    if (!text.contains('Kawaru')) {
      return Text(text, style: style, textAlign: textAlign);
    }

    final parts = text.split('Kawaru');
    List<InlineSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: style));
      }
      if (i != parts.length - 1) {
        spans.add(
          TextSpan(
            text: 'K',
            style: (style ?? const TextStyle()).copyWith(color: Colors.blueAccent),
          ),
        );
        spans.add(
          TextSpan(
            text: 'awaru',
            style: style,
          ),
        );
      }
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}
