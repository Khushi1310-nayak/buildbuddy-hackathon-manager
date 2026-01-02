import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:buildbuddy/widgets/section_card.dart';
import 'package:buildbuddy/widgets/primary_button.dart';
import 'package:buildbuddy/services/ai_service.dart';
import 'package:buildbuddy/sample_data.dart';
import 'package:buildbuddy/widgets/home_nav_button.dart';
import 'package:buildbuddy/widgets/copyable_text_block.dart';

class ReadinessScorePage extends StatefulWidget {
  const ReadinessScorePage({super.key});

  @override
  State<ReadinessScorePage> createState() => _ReadinessScorePageState();
}

class _ReadinessScorePageState extends State<ReadinessScorePage> {
  final _planCtrl = TextEditingController(text: 'MVP features done, pitch pending, needs demo data and backup plan.');
  final _teamCtrl = TextEditingController(text: '3 teammates: frontend, backend, designer.');
  final _ai = AiService();
  String? _score; bool _loading = false; String? _error;

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try { final r = await _ai.readiness(plan: _planCtrl.text.trim(), team: _teamCtrl.text.trim()); setState(() => _score = r); }
    catch (e) { setState(() => _error = '$e'); }
    finally { setState(() => _loading = false); }
  }

  Future<void> _loadExample() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await _ai.readinessExample(plan: _planCtrl.text.trim(), team: _teamCtrl.text.trim());
      setState(() => _score = r);
    } catch (e) {
      debugPrint('Load Example (Readiness) fallback: $e');
      final fallback = SampleData.readinessExample(plan: _planCtrl.text.trim(), team: _teamCtrl.text.trim());
      setState(() => _score = fallback);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _planCtrl.dispose(); _teamCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Hackathon Readiness Score'), actions: const [HomeNavButton()]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        SectionCard(title: 'Inputs', actions: [TextButton.icon(onPressed: _loading ? null : _loadExample, icon: const Icon(Icons.dataset), label: const Text('Load Example'))], child: Column(children: [
          TextField(controller: _planCtrl, minLines: 2, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Plan summary')),
          const SizedBox(height: 8),
          TextField(controller: _teamCtrl, minLines: 1, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Team summary')),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: PrimaryButton(onPressed: _loading?(){}:_generate, label: _loading? 'Scoring…':'Score', icon: Icons.verified)),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: cs.error))),
        ])),
        const SizedBox(height: 16),
        SectionCard(title: 'Readiness', child: _score == null ? const Text('Score and suggestions will appear here.') : CopyableTextBlock(text: _score!)),
      ])),
    );
  }
}
