import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../../invoices/providers/invoice_list_providers.dart';
import '../data/invoice_excel_parser.dart';
import '../data/invoice_import_service.dart';
import '../data/invoice_import_template_service.dart';
import '../models/invoice_import_models.dart';
import '../providers/import_providers.dart';

class ImportExcelScreen extends ConsumerStatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  ConsumerState<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends ConsumerState<ImportExcelScreen> {
  InvoiceImportPreview? _preview;

  bool _reading = false;
  bool _importing = false;
  bool _templateBusy = false;

  bool _overwriteDuplicates = false;

  String? _selectedFileName;

  Future<void> _pickFile() async {
    if (_reading || _importing) {
      return;
    }

    setState(() {
      _reading = true;
    });

    try {
      final selected = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
      );

      if (selected == null) {
        return;
      }

      Uint8List? bytes;

      try {
        bytes = await selected.readAsBytes();
      } catch (_) {
        if (selected.path != null) {
          bytes = await File(selected.path!).readAsBytes();
        }
      }

      if (bytes == null) {
        _message('Unable to read the selected Excel file.');
        return;
      }

      final company = await ref.read(primaryCompanyProvider.future);

      if (company == null) {
        _message('Please configure My Company first.');
        return;
      }

      final parser = InvoiceExcelParser(ref.read(appDatabaseProvider));

      final preview = await parser.parse(
        bytes: bytes,
        fileName: selected.name,
        companyId: company.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedFileName = selected.name;

        _preview = preview;

        _overwriteDuplicates = false;
      });
    } catch (error) {
      if (mounted) {
        _message('Unable to read Excel file.\n$error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _reading = false;
        });
      }
    }
  }

  Future<void> _import() async {
    final preview = _preview;

    if (preview == null || _importing) {
      return;
    }

    if (preview.hasFileErrors) {
      _message('Fix the Excel template errors before importing.');
      return;
    }

    final importable = preview.invoices.where(
      (invoice) =>
          !invoice.hasErrors && (!invoice.duplicate || _overwriteDuplicates),
    );

    if (importable.isEmpty) {
      _message('There are no valid invoices available to import.');
      return;
    }

    if (_overwriteDuplicates && preview.duplicateCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Overwrite duplicates?'),
          content: Text(
            '${preview.duplicateCount} invoice(s) already exist. '
            'Their saved header and line items will be replaced by the Excel data.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Overwrite'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }
    }

    setState(() {
      _importing = true;
    });

    try {
      final company = await ref.read(primaryCompanyProvider.future);

      if (company == null) {
        throw StateError('Company profile not found.');
      }

      final service = InvoiceImportService(ref.read(appDatabaseProvider));

      final result = await service.importPreview(
        preview: preview,
        company: company,
        overwriteDuplicates: _overwriteDuplicates,
      );

      ref.invalidate(allInvoicesProvider);

      ref.invalidate(importHistoryProvider);

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            result.failed == 0
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            size: 48,
          ),
          title: const Text('Import Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultLine(label: 'Imported', value: result.imported),
              _ResultLine(label: 'Overwritten', value: result.overwritten),
              _ResultLine(label: 'Skipped', value: result.skipped),
              _ResultLine(label: 'Failed', value: result.failed),
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Errors',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                ...result.errors.take(5).map((error) => Text('\u2022 $error')),
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _preview = null;
        _selectedFileName = null;
        _overwriteDuplicates = false;
      });
    } catch (error) {
      if (mounted) {
        _message('Import failed.\n$error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _importing = false;
        });
      }
    }
  }

  Future<void> _downloadTemplate() async {
    if (_templateBusy) {
      return;
    }

    setState(() {
      _templateBusy = true;
    });

    try {
      await InvoiceImportTemplateService.createAndShare();
    } catch (error) {
      if (mounted) {
        _message('Unable to create template.\n$error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _templateBusy = false;
        });
      }
    }
  }

  void _clearPreview() {
    setState(() {
      _preview = null;
      _selectedFileName = null;
      _overwriteDuplicates = false;
    });
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;

    return Scaffold(
      appBar: AppBar(title: const Text('Import Excel')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _IntroCard(
            reading: _reading,
            templateBusy: _templateBusy,
            fileName: _selectedFileName,
            onPick: _pickFile,
            onTemplate: _downloadTemplate,
          ),

          if (preview != null) ...[
            const SizedBox(height: 16),

            _PreviewSummary(preview: preview),

            if (preview.fileIssues.isNotEmpty) ...[
              const SizedBox(height: 16),
              _FileIssuesCard(issues: preview.fileIssues),
            ],

            const SizedBox(height: 16),

            _DuplicateOptions(
              duplicateCount: preview.duplicateCount,
              overwrite: _overwriteDuplicates,
              onChanged: (value) {
                setState(() {
                  _overwriteDuplicates = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _InvoicePreviewList(preview: preview),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importing ? null : _clearPreview,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _importing || preview.hasFileErrors
                        ? null
                        : _import,
                    icon: _importing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_done_rounded),
                    label: Text(
                      _importing ? 'Importing...' : 'Import Valid Records',
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          const _HistoryHeading(),

          const SizedBox(height: 12),

          const _ImportHistory(),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final bool reading;
  final bool templateBusy;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onTemplate;

  const _IntroCard({
    required this.reading,
    required this.templateBusy,
    required this.fileName,
    required this.onPick,
    required this.onTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.table_view_outlined,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historical Invoice Import',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Upload an .xlsx file using the VInvoice 24-column format.',
                        style: TextStyle(color: AppTheme.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (fileName != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(fileName!, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: reading ? null : onPick,
              icon: reading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_rounded),
              label: Text(reading ? 'Reading Excel...' : 'Select Excel File'),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: templateBusy ? null : onTemplate,
              icon: const Icon(Icons.download_outlined),
              label: Text(
                templateBusy
                    ? 'Preparing Template...'
                    : 'Download Import Template',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSummary extends StatelessWidget {
  final InvoiceImportPreview preview;

  const _PreviewSummary({required this.preview});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Validation Summary',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.25,
              children: [
                _CountTile(title: 'Invoices', value: preview.totalInvoices),
                _CountTile(title: 'Rows', value: preview.totalRows),
                _CountTile(title: 'Ready', value: preview.readyCount),
                _CountTile(title: 'Duplicates', value: preview.duplicateCount),
                _CountTile(
                  title: 'Missing Party',
                  value: preview.missingPartyCount,
                ),
                _CountTile(title: 'Invalid', value: preview.invalidCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  final String title;
  final int value;

  const _CountTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileIssuesCard extends StatelessWidget {
  final List<ImportIssue> issues;

  const _FileIssuesCard({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.report_problem_outlined),
                SizedBox(width: 8),
                Text(
                  'File Issues',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final issue in issues)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${issue.severity == ImportIssueSeverity.error ? 'ERROR' : 'WARNING'}'
                  '${issue.excelRow == null ? '' : ' \u2022 Row ${issue.excelRow}'}'
                  ': ${issue.message}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DuplicateOptions extends StatelessWidget {
  final int duplicateCount;
  final bool overwrite;
  final ValueChanged<bool> onChanged;

  const _DuplicateOptions({
    required this.duplicateCount,
    required this.overwrite,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (duplicateCount == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$duplicateCount duplicate invoice(s) detected',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Duplicates are detected using Company + Invoice Number.',
              style: TextStyle(color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: overwrite,
              onChanged: onChanged,
              title: Text(
                overwrite ? 'Overwrite duplicates' : 'Skip duplicates',
              ),
              subtitle: Text(
                overwrite
                    ? 'Existing invoice header and items will be replaced.'
                    : 'Existing invoices will remain unchanged.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoicePreviewList extends StatelessWidget {
  final InvoiceImportPreview preview;

  const _InvoicePreviewList({required this.preview});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Preview',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            if (preview.invoices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No invoices available for preview.'),
                ),
              )
            else
              for (final invoice in preview.invoices)
                _PreviewInvoiceTile(invoice: invoice),
          ],
        ),
      ),
    );
  }
}

class _PreviewInvoiceTile extends StatelessWidget {
  final ImportInvoiceGroup invoice;

  const _PreviewInvoiceTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final first = invoice.first;

    String status;

    if (invoice.hasErrors) {
      status = 'INVALID';
    } else if (invoice.duplicate) {
      status = 'DUPLICATE';
    } else if (invoice.missingParty) {
      status = 'READY \u2022 NEW PARTY';
    } else {
      status = 'READY';
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      title: Text(
        invoice.invoiceNumber,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${first.partyName} \u2022 ${invoice.rows.length} item(s)',
      ),
      trailing: Text(
        status,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: invoice.hasErrors ? Theme.of(context).colorScheme.error : null,
        ),
      ),
      children: [
        _PreviewLine(
          label: 'Invoice Date',
          value: DateFormat('dd-MM-yyyy').format(first.invoiceDate),
        ),
        _PreviewLine(label: 'Party', value: first.partyName),
        _PreviewLine(label: 'Items', value: '${invoice.rows.length}'),
        if (first.vendorCode.isNotEmpty)
          _PreviewLine(label: 'Vendor Code', value: first.vendorCode),
        if (first.sitePlant.isNotEmpty)
          _PreviewLine(label: 'Site / Plant', value: first.sitePlant),

        if (invoice.issues.isNotEmpty) ...[
          const Divider(height: 22),
          for (final issue in invoice.issues)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    issue.severity == ImportIssueSeverity.error
                        ? Icons.error_outline
                        : Icons.warning_amber_rounded,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${issue.excelRow == null ? '' : 'Row ${issue.excelRow}: '}${issue.message}',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _PreviewLine extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _HistoryHeading extends StatelessWidget {
  const _HistoryHeading();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.history_rounded, color: AppTheme.primary),
        SizedBox(width: 9),
        Text(
          'Import History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _ImportHistory extends ConsumerWidget {
  const _ImportHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(importHistoryProvider);

    return history.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text('Unable to load import history.\n$error'),
      data: (records) {
        if (records.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Text('No Excel imports yet.', textAlign: TextAlign.center),
            ),
          );
        }

        return Column(
          children: [
            for (final record in records)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.table_view_outlined),
                  ),
                  title: Text(record.fileName, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${DateFormat('dd-MM-yyyy HH:mm').format(record.importedAt)}\n'
                    'Rows ${record.totalRows} \u2022 Imported ${record.importedCount} \u2022 '
                    'Skipped ${record.skippedCount} \u2022 Failed ${record.failedCount}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    record.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ResultLine extends StatelessWidget {
  final String label;
  final int value;

  const _ResultLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
