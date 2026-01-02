import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:buildbuddy/widgets/section_card.dart';
import 'package:buildbuddy/widgets/primary_button.dart';
import 'package:buildbuddy/services/ai_service.dart';
import 'package:buildbuddy/sample_data.dart';
import 'package:buildbuddy/widgets/home_nav_button.dart';
import 'package:buildbuddy/widgets/copyable_text_block.dart';

class TechStackPage extends StatefulWidget {
  const TechStackPage({super.key});

  @override
  State<TechStackPage> createState() => _TechStackPageState();
}

class _TechStackPageState extends State<TechStackPage> {
  final _platform = ValueNotifier<String>('Web + Mobile');
  final _constraintsCtrl = TextEditingController(text: '24h hack, 3 teammates, prefer open-source');
  final _ai = AiService();
  String? _stack; String? _error; bool _loading = false;

  Future<void> _generate() async {
    _loading = true; _error = null; setState((){});
    try { final r = await _ai.recommendTech(platform: _platform.value, constraints: _constraintsCtrl.text.trim()); _stack = r; }
    catch (e) { _error = '$e'; }
    finally { _loading = false; setState((){}); }
  }

   Future<void> _loadExample() async {
     _loading = true; _error = null; setState((){});
     try {
       final r = await _ai.recommendTechExample(platform: _platform.value, constraints: _constraintsCtrl.text.trim());
       _stack = r;
     } catch (e) {
       debugPrint('Load Example (Stack) fallback: $e');
       _stack = SampleData.techStackExample(platform: _platform.value, constraints: _constraintsCtrl.text.trim());
     } finally { _loading = false; setState((){}); }
   }

  @override
  void dispose() { _constraintsCtrl.dispose(); _platform.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tech Stack Recommender'), actions: const [HomeNavButton()]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        SectionCard(title: 'Context', actions: [TextButton.icon(onPressed: _loading ? null : _loadExample, icon: const Icon(Icons.dataset), label: const Text('Load Example'))], child: Column(children: [
          Row(children: [
            Expanded(child: _DropdownField(valueListenable: _platform, items: const ['Web', 'Mobile', 'Web + Mobile', 'Hardware + App']))
          ]),
          const SizedBox(height: 8),
          TextField(controller: _constraintsCtrl, minLines: 1, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Constraints & preferences')),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: PrimaryButton(onPressed: _loading?(){}:_generate, label: _loading? 'Recommending…':'Recommend', icon: Icons.layers)),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: cs.error))),
        ])),
        const SizedBox(height: 16),
        SectionCard(title: 'Recommendation', child: _stack == null ? const Text('Recommendation will appear here.') : CopyableTextBlock(text: _stack!)),
      ])),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.valueListenable, required this.items});
  final ValueListenable<String> valueListenable; final List<String> items;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: valueListenable,
      builder: (context, value, _) => InputDecorator(
        decoration: const InputDecoration(labelText: 'Target Platform', border: OutlineInputBorder()),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(isExpanded: true, value: value, items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))], onChanged: (v) { if (v != null) (valueListenable as ValueNotifier<String>).value = v; }),
        ),
      ),
    );
  }
}
