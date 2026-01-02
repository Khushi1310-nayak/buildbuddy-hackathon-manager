import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:buildbuddy/widgets/section_card.dart';
import 'package:buildbuddy/widgets/tag_chip.dart';
import 'package:buildbuddy/widgets/primary_button.dart';
import 'package:buildbuddy/services/ai_service.dart';
import 'package:buildbuddy/sample_data.dart';
import 'package:buildbuddy/widgets/home_nav_button.dart';
import 'package:buildbuddy/widgets/copyable_text_block.dart';

class TeamBuilderPage extends StatefulWidget {
  const TeamBuilderPage({super.key});

  @override
  State<TeamBuilderPage> createState() => _TeamBuilderPageState();
}

class _TeamBuilderPageState extends State<TeamBuilderPage> {
  final _roleCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();
  final _roles = <String>['Frontend'];
  final _skills = <String>['Flutter', 'Figma'];
  final _ai = AiService();
  String? _advice; bool _loading = false; String? _error;

  void _addRole() { final v = _roleCtrl.text.trim(); if (v.isNotEmpty) setState(() { _roles.add(v); _roleCtrl.clear(); }); }
  void _addSkill() { final v = _skillCtrl.text.trim(); if (v.isNotEmpty) setState(() { _skills.add(v); _skillCtrl.clear(); }); }

  Future<void> _match() async {
    setState(() { _loading = true; _error = null; });
    try { final r = await _ai.teamMatch(roles: _roles, skills: _skills); setState(() => _advice = r); }
    catch (e) { setState(() => _error = '$e'); }
    finally { setState(() => _loading = false); }
  }

  Future<void> _loadExample() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await _ai.teamMatchExample(roles: _roles, skills: _skills);
      setState(() => _advice = r);
    } catch (e) {
      debugPrint('Load Example (Team) fallback: $e');
      final fallback = SampleData.teamAdviceExample(roles: _roles, skills: _skills);
      setState(() => _advice = fallback);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Team Builder'), actions: const [HomeNavButton()]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        SectionCard(title: 'Roles', actions: [TextButton.icon(onPressed: _loading ? null : _loadExample, icon: const Icon(Icons.dataset), label: const Text('Load Example'))], child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: _roleCtrl, decoration: const InputDecoration(labelText: 'Add role', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)))),
            const SizedBox(width: 8),
            PrimaryButton(onPressed: _addRole, label: 'Add', icon: Icons.add),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _roles.map((r) => TagChip(label: r, onDeleted: () => setState(() => _roles.remove(r)))).toList()),
        ])),
        const SizedBox(height: 16),
        SectionCard(title: 'Skills', child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: _skillCtrl, decoration: const InputDecoration(labelText: 'Add skill', border: OutlineInputBorder(), prefixIcon: Icon(Icons.build))),),
            const SizedBox(width: 8),
            PrimaryButton(onPressed: _addSkill, label: 'Add', icon: Icons.add),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _skills.map((s) => TagChip(label: s, onDeleted: () => setState(() => _skills.remove(s)))).toList()),
        ])),
        const SizedBox(height: 16),
        Align(alignment: Alignment.centerLeft, child: PrimaryButton(onPressed: _loading ? (){} : _match, label: _loading ? 'Matching…' : 'Suggest Team Setup', icon: Icons.group)),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: cs.error))),
        const SizedBox(height: 16),
        SectionCard(title: 'Suggestions', child: _advice == null ? const Text('Suggestions will appear here.') : CopyableTextBlock(text: _advice!)),
      ])),
    );
  }
}
