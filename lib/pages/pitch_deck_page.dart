import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:buildbuddy/widgets/section_card.dart';
import 'package:buildbuddy/widgets/primary_button.dart';
import 'package:buildbuddy/services/ai_service.dart';
import 'package:buildbuddy/sample_data.dart';
import 'package:buildbuddy/widgets/home_nav_button.dart';
import 'package:buildbuddy/widgets/copyable_text_block.dart';

class PitchDeckPage extends StatefulWidget {
  const PitchDeckPage({super.key});

  @override
  State<PitchDeckPage> createState() => _PitchDeckPageState();
}

class _PitchDeckPageState extends State<PitchDeckPage> {
  final _ideaCtrl = TextEditingController(text: 'Event Radar for Hackathons: live mentor queues and team visibility.');
  final _ai = AiService();
  String? _pitch; bool _loading = false; String? _error;

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try { final r = await _ai.pitch(ideaSummary: _ideaCtrl.text.trim()); setState(() => _pitch = r); }
    catch (e) { setState(() => _error = '$e'); }
    finally { setState(() => _loading = false); }
  }

  Future<void> _loadExample() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await _ai.pitchExample(ideaSummary: _ideaCtrl.text.trim());
      setState(() => _pitch = r);
    } catch (e) {
      debugPrint('Load Example (Pitch) fallback: $e');
      final fallback = SampleData.pitchExample(ideaSummary: _ideaCtrl.text.trim());
      setState(() => _pitch = fallback);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _ideaCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pitch Deck & Demo Flow'), actions: const [HomeNavButton()]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        SectionCard(title: 'Idea Summary', actions: [TextButton.icon(onPressed: _loading ? null : _loadExample, icon: const Icon(Icons.dataset), label: const Text('Load Example'))], child: Column(children: [
          TextField(controller: _ideaCtrl, minLines: 2, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Your idea in one or two sentences')), const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: PrimaryButton(onPressed: _loading?(){}:_generate, label: _loading? 'Generating…':'Generate Pitch', icon: Icons.slideshow)),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: cs.error))),
        ])),
        const SizedBox(height: 16),
        SectionCard(title: 'Pitch & Demo', child: _pitch == null ? const Text('Pitch outline will appear here.') : CopyableTextBlock(text: _pitch!)),
      ])),
    );
  }
}
