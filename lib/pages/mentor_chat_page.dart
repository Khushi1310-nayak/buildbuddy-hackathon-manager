import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
// Web-only fallback for picking files when the file_picker web plugin isn't registered.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:buildbuddy/services/ai_service.dart';
import 'package:buildbuddy/widgets/home_nav_button.dart';

class MentorChatPage extends StatefulWidget {
  const MentorChatPage({super.key});

  @override
  State<MentorChatPage> createState() => _MentorChatPageState();
}

class _MentorChatPageState extends State<MentorChatPage> {
  final _ai = AiService();
  final _inputCtrl = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final _messages = <Map<String, String>>[]; // keys: role, content, imageBase64?, imageMime?
  bool _loading = false;
  final _scroll = ScrollController();
  Uint8List? _attachedImageBytes;
  String? _attachedImageBase64;
  String _attachedImageMime = 'image/jpeg';

  Future<void> _pickImage() async {
    if (_loading) return;
    // Prefer a robust, plugin-free path on web first (works regardless of plugin registration),
    // then use FilePicker on other platforms.
    if (kIsWeb) {
      try {
        final input = html.FileUploadInputElement()
          ..accept = 'image/*'
          ..draggable = false;
        input.click();
        await input.onChange.first; // wait for user selection
        final files = input.files;
        if (files == null || files.isEmpty) return; // user canceled
        final file = files.first;

        // Try reading as Data URL to reliably get mime + base64
        final reader = html.FileReader();
        final completer = Completer<void>();
        reader.onLoadEnd.listen((_) => completer.complete());
        reader.readAsDataUrl(file);
        await completer.future;
        final result = reader.result;
        if (result is! String || !result.startsWith('data:')) {
          // Fallback to ArrayBuffer if Data URL failed
          final reader2 = html.FileReader();
          final completer2 = Completer<void>();
          reader2.onLoadEnd.listen((_) => completer2.complete());
          reader2.readAsArrayBuffer(file);
          await completer2.future;
          final data = reader2.result;
          if (data is! ByteBuffer) throw StateError('Unexpected reader result: ${data.runtimeType}');
          final bytes = data.asUint8List();
          String mime = file.type.isNotEmpty ? file.type : 'image/jpeg';
          final name = file.name.toLowerCase();
          if (mime == 'application/octet-stream' || mime.isEmpty) {
            if (name.endsWith('.png')) mime = 'image/png';
            else if (name.endsWith('.webp')) mime = 'image/webp';
            else if (name.endsWith('.gif')) mime = 'image/gif';
            else if (name.endsWith('.jpg') || name.endsWith('.jpeg')) mime = 'image/jpeg';
          }
          setState(() {
            _attachedImageBytes = bytes;
            _attachedImageBase64 = base64Encode(bytes);
            _attachedImageMime = mime;
          });
          return;
        }
        // Parse data URL: data:<mime>;base64,<payload>
        final dataUrl = result as String;
        final comma = dataUrl.indexOf(',');
        if (comma <= 5) throw StateError('Malformed data URL');
        final header = dataUrl.substring(5, comma); // e.g., image/png;base64
        final semiIdx = header.indexOf(';');
        final mime = semiIdx == -1 ? header : header.substring(0, semiIdx);
        final b64 = dataUrl.substring(comma + 1);
        final bytes = base64Decode(b64);
        setState(() {
          _attachedImageBytes = bytes;
          _attachedImageBase64 = b64; // already base64 without prefix
          _attachedImageMime = mime;
        });
        return;
      } catch (e, st) {
        debugPrint('Web image pick failed: $e\n$st');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to pick image. Please try again.")));
        return;
      }
    }

    // Non-web platforms: use FilePicker
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false, withData: true);
      final file = result?.files.single;
      if (file == null) return; // user canceled
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) throw StateError('No bytes from picked file');
      final name = (file.name).toLowerCase();
      String mime = 'image/jpeg';
      if (name.endsWith('.png')) mime = 'image/png';
      else if (name.endsWith('.webp')) mime = 'image/webp';
      else if (name.endsWith('.gif')) mime = 'image/gif';
      else if (name.endsWith('.jpg') || name.endsWith('.jpeg')) mime = 'image/jpeg';
      setState(() {
        _attachedImageBytes = bytes;
        _attachedImageBase64 = base64Encode(bytes!);
        _attachedImageMime = mime;
      });
    } catch (e, st) {
      debugPrint('FilePicker (non-web) failed: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to pick image. Please try again.")));
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if ((text.isEmpty && _attachedImageBase64 == null) || _loading) return;
    setState(() {
      _messages.add({
        'role': 'user',
        'content': text,
        if (_attachedImageBase64 != null) 'imageBase64': _attachedImageBase64!,
        if (_attachedImageBase64 != null) 'imageMime': _attachedImageMime,
      });
      _inputCtrl.clear();
      _loading = true;
    });
    try {
      final reply = await _ai.mentorChat(
        history: _messages,
        imageBase64: _attachedImageBase64,
        imageMime: _attachedImageMime,
      );
      setState(() { _messages.add({'role': 'assistant', 'content': reply}); });
      await Future.delayed(const Duration(milliseconds: 50));
      _scroll.animateTo(_scroll.position.maxScrollExtent + 200, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {
      setState(() { _messages.add({'role': 'assistant', 'content': 'Error: $e'}); });
    } finally {
      setState(() {
        _loading = false;
        _attachedImageBytes = null;
        _attachedImageBase64 = null;
      });
    }
  }

  @override
  void dispose() { _inputCtrl.dispose(); _inputFocus.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor Chat'), actions: const [HomeNavButton()]),
      body: Column(children: [
        Expanded(child: ListView.builder(controller: _scroll, padding: const EdgeInsets.all(16), itemCount: _messages.length, itemBuilder: (context, i) {
          final m = _messages[i]; final isUser = m['role'] == 'user';
          final imgB64 = m['imageBase64'];
          Uint8List? imgBytes;
          if (imgB64 != null && imgB64.isNotEmpty) {
            try { imgBytes = base64Decode(imgB64); } catch (_) {}
          }
          return Align(alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(color: isUser ? cs.primaryContainer : cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outline.withValues(alpha: 0.15))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (imgBytes != null) ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(imgBytes, width: 260, fit: BoxFit.cover)),
              if (imgBytes != null && (m['content']?.isNotEmpty ?? false)) const SizedBox(height: 8),
              if ((m['content']?.isNotEmpty ?? false)) SelectableText(m['content'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface)),
            ]),
          ));
        })),
        Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_attachedImageBytes != null) Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outline.withValues(alpha: 0.15))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(_attachedImageBytes!, width: 64, height: 64, fit: BoxFit.cover)),
              const SizedBox(width: 8),
              Text('Image attached', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurface)),
              const SizedBox(width: 8),
              IconButton(onPressed: _loading ? null : () => setState(() { _attachedImageBytes = null; _attachedImageBase64 = null; }), icon: const Icon(Icons.close))
            ]),
          ),
          Row(children: [
            IconButton(
              tooltip: 'Add image',
              onPressed: _loading ? null : _pickImage,
              icon: const Icon(Icons.image_outlined),
            ),
          Expanded(child: Focus(
            focusNode: _inputFocus,
            onKeyEvent: (node, event) {
              final isEnter = event.logicalKey == LogicalKeyboardKey.enter;
              final isKeyDown = event is KeyDownEvent;
              final shiftPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
                  HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);
              if (isKeyDown && isEnter && !shiftPressed) {
                if (!_loading) { _send(); }
                return KeyEventResult.handled; // Prevent newline insert on Enter
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: _inputCtrl,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                hintText: 'Ask about tech, design, or pitching…',
                border: OutlineInputBorder(),
              ),
            ),
          )),
          const SizedBox(width: 8),
          Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final foreground = isDark ? Colors.white : Colors.black;
            return ElevatedButton.icon(
              onPressed: _loading ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primaryContainer,
                foregroundColor: foreground,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            );
          })
          ])
        ]))
      ]),
    );
  }
}
