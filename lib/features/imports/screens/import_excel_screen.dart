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
    if (_reading || _importing) return;

    setState(() {
      _reading = true;
    });

    try {
      final selected = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
      );

      if (selected == null) return;

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

      if (!mounted) return;

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

    if (preview == null || _importing) return;

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
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warning,
          ),
          title: const Text('Overwrite duplicates?'),
          content: Text(
            '${preview.duplicateCount} invoice(s) already exist. '
            'Their saved header and line items will be replaced by the Excel data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Overwrite'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
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

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            result.failed == 0
                ? Icons.check_circle_outline_rounded
                : Icons.warning_amber_rounded,
            size: 48,
            color: result.failed == 0 ? AppTheme.success : AppTheme.warning,
          ),
          title: const Text('Import Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ResultLine(label: 'Imported', value: result.imported),
              _ResultLine(label: 'Overwritten', value: result.overwritten),
              _ResultLine(label: 'Skipped', value: result.skipped),
              _ResultLine(label: 'Failed', value: result.failed),
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                for (final error in result.errors.take(5))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('\u2022 '),
                        Expanded(
                          child: Text(
                            error,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );

      if (!mounted) return;

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
    if (_templateBusy) return;

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

    final canImport =
        preview != null &&
        !preview.hasFileErrors &&
        preview.invoices.any(
          (invoice) =>
              !invoice.hasErrors &&
              (!invoice.duplicate || _overwriteDuplicates),
        );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Import Excel')),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          _ImportHero(
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
              const SizedBox(height: 14),
              _FileIssuesCard(issues: preview.fileIssues),
            ],

            if (preview.duplicateCount > 0) ...[
              const SizedBox(height: 14),
              _DuplicateOptions(
                duplicateCount: preview.duplicateCount,
                overwrite: _overwriteDuplicates,
                onChanged: (value) {
                  setState(() {
                    _overwriteDuplicates = value;
                  });
                },
              ),
            ],

            const SizedBox(height: 14),

            _InvoicePreviewList(preview: preview),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importing ? null : _clearPreview,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _importing || !canImport ? null : _import,
                    icon: _importing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
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

          const SizedBox(height: 26),

          const _HistoryHeading(),

          const SizedBox(height: 10),

          const _ImportHistory(),
        ],
      ),
    );
  }
}

class _ImportHero extends StatelessWidget {
  const _ImportHero({
    required this.reading,
    required this.templateBusy,
    required this.fileName,
    required this.onPick,
    required this.onTemplate,
  });

  final bool reading;
  final bool templateBusy;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onTemplate;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.table_view_outlined, color: Colors.white, size: 26),
              SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historical Invoice Import',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'VInvoice 24-column Excel format',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (fileName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
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

          const SizedBox(height: 9),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: .45)),
            ),
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
    );
  }
}

class _PreviewSummary extends StatelessWidget {
  const _PreviewSummary({required this.preview});

  final InvoiceImportPreview preview;

  @override
  Widget build(BuildContext context) {
    return _ImportSection(
      title: 'Validation Summary',
      icon: Icons.fact_check_outlined,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 9,
        crossAxisSpacing: 9,
        childAspectRatio: 2.15,
        children: [
          _CountTile(title: 'Invoices', value: preview.totalInvoices),
          _CountTile(title: 'Rows', value: preview.totalRows),
          _CountTile(
            title: 'Ready',
            value: preview.readyCount,
            semantic: preview.readyCount > 0
                ? _CountSemantic.success
                : _CountSemantic.normal,
          ),
          _CountTile(
            title: 'Duplicates',
            value: preview.duplicateCount,
            semantic: preview.duplicateCount > 0
                ? _CountSemantic.warning
                : _CountSemantic.normal,
          ),
          _CountTile(
            title: 'Missing Party',
            value: preview.missingPartyCount,
            semantic: preview.missingPartyCount > 0
                ? _CountSemantic.warning
                : _CountSemantic.normal,
          ),
          _CountTile(
            title: 'Invalid',
            value: preview.invalidCount,
            semantic: preview.invalidCount > 0
                ? _CountSemantic.danger
                : _CountSemantic.normal,
          ),
        ],
      ),
    );
  }
}

enum _CountSemantic { normal, success, warning, danger }

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.title,
    required this.value,
    this.semantic = _CountSemantic.normal,
  });

  final String title;
  final int value;
  final _CountSemantic semantic;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (semantic) {
      case _CountSemantic.success:
        background = AppTheme.successSoft;
        foreground = AppTheme.success;
        break;
      case _CountSemantic.warning:
        background = AppTheme.warningSoft;
        foreground = AppTheme.warning;
        break;
      case _CountSemantic.danger:
        background = AppTheme.danger.withValues(alpha: .08);
        foreground = AppTheme.danger;
        break;
      case _CountSemantic.normal:
        background = AppTheme.surfaceMuted;
        foreground = AppTheme.darkText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: foreground,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileIssuesCard extends StatelessWidget {
  const _FileIssuesCard({required this.issues});

  final List<ImportIssue> issues;

  @override
  Widget build(BuildContext context) {
    return _ImportSection(
      title: 'File Issues',
      icon: Icons.report_problem_outlined,
      child: Column(
        children: [
          for (final issue in issues)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: issue.severity == ImportIssueSeverity.error
                    ? AppTheme.danger.withValues(alpha: .06)
                    : AppTheme.warningSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${issue.severity == ImportIssueSeverity.error ? 'ERROR' : 'WARNING'}'
                '${issue.excelRow == null ? '' : ' \u2022 Row ${issue.excelRow}'}'
                ': ${issue.message}',
                style: TextStyle(
                  color: issue.severity == ImportIssueSeverity.error
                      ? AppTheme.danger
                      : AppTheme.warning,
                  fontSize: 10,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DuplicateOptions extends StatelessWidget {
  const _DuplicateOptions({
    required this.duplicateCount,
    required this.overwrite,
    required this.onChanged,
  });

  final int duplicateCount;
  final bool overwrite;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _ImportSection(
      title: 'Duplicate Handling',
      icon: Icons.copy_all_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppTheme.warningSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.warning,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$duplicateCount duplicate invoice(s) detected using Company + Invoice Number.',
                    style: const TextStyle(
                      color: AppTheme.warning,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: overwrite,
            onChanged: onChanged,
            title: Text(
              overwrite ? 'Overwrite duplicates' : 'Skip duplicates',
              style: const TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              overwrite
                  ? 'Existing invoice header and items will be replaced.'
                  : 'Existing invoices remain unchanged.',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoicePreviewList extends StatelessWidget {
  const _InvoicePreviewList({required this.preview});

  final InvoiceImportPreview preview;

  @override
  Widget build(BuildContext context) {
    return _ImportSection(
      title: 'Invoice Preview',
      icon: Icons.preview_outlined,
      child: preview.invoices.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No invoices available for preview.')),
            )
          : Column(
              children: [
                for (final invoice in preview.invoices)
                  _PreviewInvoiceTile(invoice: invoice),
              ],
            ),
    );
  }
}

class _PreviewInvoiceTile extends StatelessWidget {
  const _PreviewInvoiceTile({required this.invoice});

  final ImportInvoiceGroup invoice;

  @override
  Widget build(BuildContext context) {
    final first = invoice.first;

    String status;
    Color statusColor;
    Color statusBackground;

    if (invoice.hasErrors) {
      status = 'INVALID';
      statusColor = AppTheme.danger;
      statusBackground = AppTheme.danger.withValues(alpha: .07);
    } else if (invoice.duplicate) {
      status = 'DUPLICATE';
      statusColor = AppTheme.warning;
      statusBackground = AppTheme.warningSoft;
    } else if (invoice.missingParty) {
      status = 'READY + PARTY';
      statusColor = AppTheme.primary;
      statusBackground = AppTheme.primarySoft;
    } else {
      status = 'READY';
      statusColor = AppTheme.success;
      statusBackground = AppTheme.successSoft;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
        title: Text(
          invoice.invoiceNumber,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${first.partyName} \u2022 ${invoice.rows.length} item(s)',
          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 9),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: statusBackground,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
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
                          ? Icons.error_outline_rounded
                          : Icons.warning_amber_rounded,
                      size: 16,
                      color: issue.severity == ImportIssueSeverity.error
                          ? AppTheme.danger
                          : AppTheme.warning,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${issue.excelRow == null ? '' : 'Row ${issue.excelRow}: '}${issue.message}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 10,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 10))),
        ],
      ),
    );
  }
}

class _ImportSection extends StatelessWidget {
  const _ImportSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
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
          style: TextStyle(
            color: AppTheme.darkText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
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
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          'Unable to load import history.\n$error',
          textAlign: TextAlign.center,
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.table_view_outlined, color: AppTheme.tertiaryText),
                SizedBox(height: 8),
                Text(
                  'No Excel imports yet.',
                  style: TextStyle(color: AppTheme.secondaryText),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (final record in records)
              Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.table_view_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.darkText,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(record.importedAt),
                            style: const TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Rows ${record.totalRows}  \u2022  Imported ${record.importedCount}  \u2022  Skipped ${record.skippedCount}  \u2022  Failed ${record.failedCount}',
                            style: const TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successSoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        record.status.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.success,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
