import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Displays selectable text content with a small "📋 Copy" action button
/// shown directly after the content. Copies the full content to the clipboard
/// and shows a confirmation snackbar.
class CopyableTextBlock extends StatelessWidget {
  const CopyableTextBlock({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SelectableText(text),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: text));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            }
          },
          child: const Text('📋 Copy'),
        ),
      ),
    ]);
  }
}
