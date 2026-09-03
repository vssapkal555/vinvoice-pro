import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/note_providers.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: notesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _NotesError(
            error: error.toString(),
            onRetry: () {
              ref.invalidate(notesProvider);
            },
          ),
          data: (notes) {
            final query = _query.trim().toLowerCase();

            final filtered = notes.where((note) {
              if (query.isEmpty) return true;

              return note.title.toLowerCase().contains(query) ||
                  (note.content ?? '').toLowerCase().contains(query);
            }).toList();

            final pinnedCount = notes.where((note) => note.isPinned).length;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notesProvider);
                await ref.read(notesProvider.future);
              },
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  _NotesHero(
                    total: notes.length,
                    pinned: pinnedCount,
                    onAdd: () => _openNoteForm(context),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search notes',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();

                                setState(() {
                                  _query = '';
                                });
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _query.isEmpty ? 'Business Notes' : 'Search Results',
                          style: const TextStyle(
                            color: AppTheme.darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${filtered.length} ${filtered.length == 1 ? 'note' : 'notes'}',
                        style: const TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (notes.isEmpty)
                    _NotesEmpty(onAdd: () => _openNoteForm(context))
                  else if (filtered.isEmpty)
                    const _NoNotesFound()
                  else
                    ...filtered.map(
                      (note) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _NoteCard(
                          note: note,
                          onTap: () => _openNoteForm(context, note: note),
                          onPin: () => _togglePinned(note),
                          onDelete: () => _confirmDelete(note),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _togglePinned(Note note) async {
    await ref
        .read(appDatabaseProvider)
        .updateNoteRecord(
          NotesCompanion(
            id: Value(note.id),
            isPinned: Value(!note.isPinned),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.danger,
          ),
          title: const Text('Delete note?'),
          content: Text('"${note.title}" will be permanently removed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(appDatabaseProvider).deleteNoteRecord(note.id);
  }

  Future<void> _openNoteForm(BuildContext context, {Note? note}) async {
    final company = await ref.read(primaryCompanyProvider.future);

    if (company == null || !context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      builder: (_) => _NoteFormSheet(companyId: company.id, note: note),
    );

    ref.invalidate(notesProvider);
  }
}

class _NotesHero extends StatelessWidget {
  const _NotesHero({
    required this.total,
    required this.pinned,
    required this.onAdd,
  });

  final int total;
  final int pinned;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .15),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.note_alt_outlined, color: Colors.white),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Notes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Keep reminders and business information handy',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),

              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New'),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _NoteMetric(label: 'Total Notes', value: '$total'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NoteMetric(label: 'Pinned', value: '$pinned'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteMetric extends StatelessWidget {
  const _NoteMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 9),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final content = (note.content ?? '').trim();

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: note.isPinned
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: .30)
                  : AppTheme.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: note.isPinned
                      ? Theme.of(context).colorScheme.primaryContainer
                      : AppTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  note.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.note_alt_outlined,
                  color: note.isPinned
                      ? Theme.of(context).colorScheme.primary
                      : AppTheme.secondaryText,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    if (content.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 10,
                          height: 1.45,
                        ),
                      ),
                    ],

                    const SizedBox(height: 9),

                    Text(
                      'Updated ${DateFormat('dd MMM yyyy, HH:mm').format(note.updatedAt)}',
                      style: const TextStyle(
                        color: AppTheme.tertiaryText,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                tooltip: 'Note actions',
                onSelected: (value) {
                  if (value == 'pin') {
                    onPin();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'pin',
                    child: Row(
                      children: [
                        Icon(
                          note.isPinned
                              ? Icons.push_pin_outlined
                              : Icons.push_pin_rounded,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Text(note.isPinned ? 'Unpin' : 'Pin note'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: AppTheme.danger,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppTheme.danger),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteFormSheet extends ConsumerStatefulWidget {
  const _NoteFormSheet({required this.companyId, this.note});

  final String companyId;
  final Note? note;

  @override
  ConsumerState<_NoteFormSheet> createState() => _NoteFormSheetState();
}

class _NoteFormSheetState extends ConsumerState<_NoteFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _content;

  late bool _pinned;

  bool _saving = false;

  bool get _editing => widget.note != null;

  @override
  void initState() {
    super.initState();

    _title = TextEditingController(text: widget.note?.title ?? '');

    _content = TextEditingController(text: widget.note?.content ?? '');

    _pinned = widget.note?.isPinned ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);

      if (!_editing) {
        await db.insertNoteRecord(
          NotesCompanion.insert(
            companyId: widget.companyId,
            title: _title.text.trim(),
            content: Value(_content.text.trim()),
            isPinned: Value(_pinned),
          ),
        );
      } else {
        await db.updateNoteRecord(
          NotesCompanion(
            id: Value(widget.note!.id),
            title: Value(_title.text.trim()),
            content: Value(_content.text.trim()),
            isPinned: Value(_pinned),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      ref.invalidate(notesProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to save note.\n$error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .82,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.borderStrong,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.note_alt_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _editing ? 'Edit Note' : 'New Note',
                              style: const TextStyle(
                                color: AppTheme.darkText,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Private business reminder',
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _title,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                prefixIcon: Icon(Icons.title_rounded),
                              ),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Note title is required';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _content,
                              minLines: 7,
                              maxLines: 12,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                labelText: 'Note',
                                alignLabelWithHint: true,
                                hintText:
                                    'Write your reminder or business note...',
                              ),
                            ),

                            const SizedBox(height: 10),

                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _pinned,
                              onChanged: (value) {
                                setState(() {
                                  _pinned = value;
                                });
                              },
                              secondary: Icon(
                                _pinned
                                    ? Icons.push_pin_rounded
                                    : Icons.push_pin_outlined,
                                color: _pinned
                                    ? Theme.of(context).colorScheme.primary
                                    : AppTheme.secondaryText,
                              ),
                              title: const Text(
                                'Pin this note',
                                style: TextStyle(
                                  color: AppTheme.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: const Text(
                                'Pinned notes stay at the top.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SafeArea(
                  top: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      border: Border(top: BorderSide(color: AppTheme.border)),
                    ),
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _saving
                            ? 'Saving...'
                            : _editing
                            ? 'Update Note'
                            : 'Save Note',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotesEmpty extends StatelessWidget {
  const _NotesEmpty({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.note_add_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 27,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No notes yet',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Keep reminders, customer information and important business details here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 11,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Note'),
          ),
        ],
      ),
    );
  }
}

class _NoNotesFound extends StatelessWidget {
  const _NoNotesFound();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 44),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppTheme.tertiaryText,
            size: 34,
          ),
          SizedBox(height: 9),
          Text(
            'No matching notes',
            style: TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesError extends StatelessWidget {
  const _NotesError({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.danger,
              size: 38,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load notes',
              style: TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
