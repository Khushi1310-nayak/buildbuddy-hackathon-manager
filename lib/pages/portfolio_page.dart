import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buildbuddy/widgets/section_card.dart';
import 'package:buildbuddy/widgets/primary_button.dart';
import 'package:buildbuddy/widgets/home_nav_button.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  // Start with an empty portfolio; user can add their own projects
  final _projects = <_Project>[];

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  String _exportMarkdown() {
    final b = StringBuffer('# BuildBuddy Portfolio\n');
    for (final p in _projects) {
      b.writeln('\n## ${p.title}');
      b.writeln('- Domain: ${p.domain}');
      b.writeln('- Updated: ${p.updated.toIso8601String()}');
      b.writeln('- Notes: ${p.notes}');
    }
    return b.toString();
  }

  Future<void> _copyExport() async {
    if (_projects.isEmpty) {
      // Do not copy when portfolio is empty; inform the user
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Your Portfolio is empty, can't copy to clipboard")));
      return;
    }
    final md = _exportMarkdown();
    await Clipboard.setData(ClipboardData(text: md));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portfolio copied to Clipboard')));
  }

  Future<void> _openProjectSheet({_Project? project, int? index}) async {
    final isEdit = project != null && index != null;
    final titleCtrl = TextEditingController(text: project?.title ?? '');
    final domainCtrl = TextEditingController(text: project?.domain ?? '');
    final notesCtrl = TextEditingController(text: project?.notes ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isEdit ? Icons.edit_note : Icons.add_circle, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(isEdit ? 'Edit Project' : 'Add Project', style: Theme.of(ctx).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Hackathon Planner'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: domainCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Domain', hintText: 'e.g., Education, Health, Fintech'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes', hintText: 'Short status or description'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        final domain = domainCtrl.text.trim();
                        final notes = notesCtrl.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
                          return;
                        }
                        final now = DateTime.now();
                        if (isEdit) {
                          debugPrint('Editing project at index $index');
                          setState(() => _projects[index!] = _Project(title, domain.isEmpty ? 'General' : domain, now, notes));
                        } else {
                          debugPrint('Adding new project');
                          setState(() => _projects.insert(0, _Project(title, domain.isEmpty ? 'General' : domain, now, notes)));
                        }
                        Navigator.of(ctx).pop();
                      },
                      label: isEdit ? 'Save Changes' : 'Add Project',
                      icon: isEdit ? Icons.save : Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(int index) async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final p = _projects[index];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(Icons.delete_forever, color: cs.error), const SizedBox(width: 8), Text('Delete Project', style: Theme.of(ctx).textTheme.titleLarge)]),
              const SizedBox(height: 8),
              Text('Are you sure you want to delete "${p.title}"? This action cannot be undone.'),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: PrimaryButton(
                    onPressed: () {
                      debugPrint('Deleting project at index $index');
                      setState(() => _projects.removeAt(index));
                      Navigator.of(ctx).pop();
                    },
                    label: 'Delete',
                    icon: Icons.delete,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Project History & Portfolio'), actions: const [HomeNavButton()]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProjectSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionCard(title: 'Your Projects', actions: [
              // Removed inline "Add Project" to avoid overflow; keep Export only
              PrimaryButton(onPressed: _copyExport, label: 'Export Markdown', icon: Icons.file_download),
            ], child: Column(children: [
              for (int i = 0; i < _projects.length; i++)
                Builder(builder: (context) {
                  final isCompact = MediaQuery.of(context).size.width < 480;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: CircleAvatar(backgroundColor: cs.primaryContainer, child: Icon(Icons.folder, color: cs.onPrimaryContainer)),
                    title: Text(_projects[i].title, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${_projects[i].domain} • Updated ${_fmtDate(_projects[i].updated)}'),
                    trailing: isCompact
                        ? Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _openProjectSheet(project: _projects[i], index: i),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => _confirmDelete(i),
                              icon: const Icon(Icons.delete),
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ])
                        : Wrap(spacing: 4, children: [
                            TextButton.icon(
                              onPressed: () => _openProjectSheet(project: _projects[i], index: i),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => _confirmDelete(i),
                              icon: const Icon(Icons.delete),
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ]),
                  );
                }),
              if (_projects.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Icon(Icons.inbox, color: cs.outline),
                    const SizedBox(width: 8),
                    Expanded(child: Text('No projects yet. Use "Add Project" to create your first entry.', style: Theme.of(context).textTheme.bodyMedium)),
                  ]),
                ),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _Project {
  final String title; final String domain; final DateTime updated; final String notes;
  _Project(this.title, this.domain, this.updated, this.notes);
}
