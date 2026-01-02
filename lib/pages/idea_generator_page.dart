import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:buildbuddy/services/ai_service.dart';
import 'package:buildbuddy/sample_data.dart';
import 'package:buildbuddy/widgets/primary_button.dart';
import 'package:buildbuddy/widgets/home_nav_button.dart';
import 'package:buildbuddy/widgets/section_card.dart';
import 'package:buildbuddy/widgets/copyable_text_block.dart';

class IdeaGeneratorPage extends StatefulWidget {
  const IdeaGeneratorPage({super.key});

  @override
  State<IdeaGeneratorPage> createState() => _IdeaGeneratorPageState();
}

class _IdeaGeneratorPageState extends State<IdeaGeneratorPage> {
  final _ai = AiService();
  String _domain = 'AI/ML';
  String _level = 'Beginner';
  final _themeCtrl = TextEditingController(text: 'Education, accessibility, sustainability');
  String? _result;
  bool _loading = false;
  String? _error;

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await _ai.generateIdeas(domain: _domain, level: _level, theme: _themeCtrl.text.trim());
      setState(() => _result = r);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadExample() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await _ai.generateIdeaExample(domain: _domain, level: _level, theme: _themeCtrl.text.trim());
      setState(() => _result = r);
    } catch (e) {
      // Fallback to local dynamic example if OpenAI isn't configured or fails
      debugPrint('Load Example fallback due to error: $e');
      final fallback = SampleData.ideaExample(domain: _domain, level: _level, theme: _themeCtrl.text.trim());
      setState(() => _result = fallback);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _themeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Idea Generator'), actions: const [HomeNavButton()]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          SectionCard(
            title: 'Input',
            actions: [
              TextButton.icon(onPressed: _loading ? null : _loadExample, icon: const Icon(Icons.dataset), label: const Text('Load Example')),
            ],
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: _DropdownField(label: 'Domain', value: _domain, items: const ['AI/ML', 'Web', 'Mobile', 'Hardware', 'Data'], onChanged: (v) => setState(() => _domain = v))),
                const SizedBox(width: 12),
                Expanded(child: _DropdownField(label: 'Skill Level', value: _level, items: const ['Beginner', 'Intermediate', 'Advanced'], onChanged: (v) => setState(() => _level = v))),
              ]),
              const SizedBox(height: 12),
              TextField(controller: _themeCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Hackathon Theme / Constraints', prefixIcon: Icon(Icons.topic)), minLines: 1, maxLines: 3),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: PrimaryButton(onPressed: _loading ? (){} : _generate, label: _loading ? 'Generating…' : 'Generate', icon: Icons.bolt)),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: cs.error))),
            ]),
          ),
          const SizedBox(height: 16),
          SectionCard(title: 'Ideas (Markdown)', child: _result == null ? const Text('Results will appear here.') : CopyableTextBlock(text: _result!)),
        ]),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged});
  final String label; final String value; final List<String> items; final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(isExpanded: true, value: value, items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))], onChanged: (v) { if (v != null) onChanged(v); }),
    ),
  );
}
