import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:buildbuddy/widgets/section_card.dart';
import 'package:buildbuddy/widgets/primary_button.dart';
import 'package:buildbuddy/services/ai_service.dart';
import 'package:buildbuddy/sample_data.dart';
import 'package:buildbuddy/widgets/home_nav_button.dart';
import 'package:buildbuddy/widgets/copyable_text_block.dart';

class DesignAssistantPage extends StatefulWidget {
  const DesignAssistantPage({super.key});

  @override
  State<DesignAssistantPage> createState() => _DesignAssistantPageState();
}

class _DesignAssistantPageState extends State<DesignAssistantPage> {
  final _vibeCtrl = TextEditingController(text: 'Playful but professional, minimal, student-friendly');
  final _audienceCtrl = TextEditingController(text: 'Hackathon judges and student developers');
  final _ai = AiService();
  String? _tips; String? _error; bool _loading = false;

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try { final r = await _ai.designAssist(vibe: _vibeCtrl.text.trim(), audience: _audienceCtrl.text.trim()); setState(() => _tips = r); }
    catch (e) { setState(() => _error = '$e'); }
    finally { setState(() => _loading = false); }
  }

  Future<void> _loadExample() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await _ai.designAssistExample(vibe: _vibeCtrl.text.trim(), audience: _audienceCtrl.text.trim());
      setState(() => _tips = r);
    } catch (e) {
      debugPrint('Load Example (Design) fallback: $e');
      final fallback = SampleData.designTipsExample(vibe: _vibeCtrl.text.trim(), audience: _audienceCtrl.text.trim());
      setState(() => _tips = fallback);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _vibeCtrl.dispose(); _audienceCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('UI/UX Assistant'), actions: const [HomeNavButton()]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        SectionCard(title: 'Brief', actions: [TextButton.icon(onPressed: _loading ? null : _loadExample, icon: const Icon(Icons.dataset), label: const Text('Load Example'))], child: Column(children: [
          TextField(controller: _vibeCtrl, decoration: const InputDecoration(labelText: 'Vibe', border: OutlineInputBorder(), prefixIcon: Icon(Icons.mood))),
          const SizedBox(height: 8),
          TextField(controller: _audienceCtrl, decoration: const InputDecoration(labelText: 'Audience', border: OutlineInputBorder(), prefixIcon: Icon(Icons.people))),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: PrimaryButton(onPressed: _loading?(){}:_generate, label: _loading? 'Generating…':'Suggest', icon: Icons.palette)),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: cs.error))),
        ])),
        const SizedBox(height: 16),
        SectionCard(title: 'Design Suggestions', child: _tips == null ? const Text('Suggestions will appear here.') : CopyableTextBlock(text: _tips!)),
      ])),
    );
  }
}
