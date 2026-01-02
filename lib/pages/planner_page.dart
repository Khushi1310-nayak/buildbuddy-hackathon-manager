import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:buildbuddy/widgets/section_card.dart';
import 'package:buildbuddy/widgets/primary_button.dart';
import 'package:buildbuddy/services/ai_service.dart';
import 'package:buildbuddy/sample_data.dart';
import 'package:buildbuddy/widgets/home_nav_button.dart';
import 'package:buildbuddy/widgets/copyable_text_block.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final _ideaCtrl = TextEditingController(text: 'AI tutor for STEM students with step-by-step explanations.');
  final _ai = AiService();
  String? _plan; String? _error; bool _loading = false;

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try { final r = await _ai.plan(ideaSummary: _ideaCtrl.text.trim()); setState(() => _plan = r); }
    catch (e) { setState(() => _error = '$e'); }
    finally { setState(() => _loading = false); }
  }

  Future<void> _loadExample() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await _ai.planExample(ideaSummary: _ideaCtrl.text.trim());
      setState(() => _plan = r);
    } catch (e) {
      debugPrint('Load Example (Plan) fallback: $e');
      final fallback = SampleData.planExample(ideaSummary: _ideaCtrl.text.trim());
      setState(() => _plan = fallback);
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
      appBar: AppBar(title: const Text('Project Planner'), actions: const [HomeNavButton()]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        SectionCard(title: 'Idea Summary', actions: [TextButton.icon(onPressed: _loading ? null : _loadExample, icon: const Icon(Icons.dataset), label: const Text('Load Example'))], child: Column(children: [
          TextField(controller: _ideaCtrl, minLines: 2, maxLines: 6, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Describe your idea')), const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: PrimaryButton(onPressed: _loading?(){}:_generate, label: _loading? 'Generating…' : 'Generate Plan', icon: Icons.timeline)),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: cs.error))),
        ])),
        const SizedBox(height: 16),
        SectionCard(title: 'Plan (Markdown)', child: _plan == null ? const Text('Plan will appear here.') : CopyableTextBlock(text: _plan!)),
      ])),
    );
  }
}
