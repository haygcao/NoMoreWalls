import 'package:flutter/material.dart';

class FolderPathView extends StatelessWidget {
  final List<String> segments;

  const FolderPathView({
    super.key,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: [
        for (final MapEntry(key: index, value: segment) in segments.asMap().entries)
          Text.rich(
            TextSpan(
              children: [
                if (index != 0)
                  TextSpan(
                    text: "/ ",
                    style: TextStyle(color: colorScheme.primary),
                  ),
                TextSpan(text: segment),
              ],
            ),
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.tertiary,
            ),
          ),
      ],
    );
  }
}