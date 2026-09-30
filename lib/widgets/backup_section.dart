import 'package:file_selector/file_selector.dart';
import 'package:flowledger/core/app_refresh_notifier.dart';
import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flutter/material.dart';

/// Backup and restore section of the settings screen.
class BackupSection extends StatefulWidget {
  const BackupSection({super.key, this.databaseHelper});

  /// Overridable for tests.
  final DatabaseHelper? databaseHelper;

  @override
  State<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<BackupSection> {
  static const _extension = 'db';
  var _busy = false;

  DatabaseHelper get _helper =>
      widget.databaseHelper ?? DatabaseHelper.instance;

  XTypeGroup _typeGroup(AppLocalizations l10n) =>
      XTypeGroup(label: l10n.backupFileType, extensions: const [_extension]);

  Future<void> _createBackup() async {
    final l10n = context.l10n;
    final location = await getSaveLocation(
      suggestedName: 'FlowLedger-backup-${_dateStamp()}.$_extension',
      acceptedTypeGroups: [_typeGroup(l10n)],
    );
    if (location == null || !mounted) return;
    final target = location.path.toLowerCase().endsWith('.$_extension')
        ? location.path
        : '${location.path}.$_extension';
    await _run(() async {
      await _helper.backupTo(target);
      _show(l10n.backupSaved(target));
    }, l10n.backupFailed);
  }

  Future<void> _restoreBackup() async {
    final l10n = context.l10n;
    final file = await openFile(acceptedTypeGroups: [_typeGroup(l10n)]);
    if (file == null || !mounted) return;

    final BackupInfo info;
    try {
      info = await _helper.inspectBackup(file.path);
    } on BackupValidationException catch (error) {
      _show(_problemMessage(l10n, error.problem));
      return;
    }
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreConfirmTitle),
        content: Text(
            l10n.restoreConfirmMessage(info.clientCount, info.workItemCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.restoreAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _run(() async {
      final safetyPath = await _helper.restoreFrom(file.path);
      AppRefreshNotifier.notifyChanged();
      _show(l10n.restoreSucceeded(safetyPath));
    }, l10n.restoreFailed);
  }

  Future<void> _run(Future<void> Function() action, String failure) async {
    setState(() => _busy = true);
    try {
      await action();
    } on BackupValidationException catch (error) {
      if (mounted) _show(_problemMessage(context.l10n, error.problem));
    } on Object {
      _show(failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 6)),
    );
  }

  static String _problemMessage(AppLocalizations l10n, BackupProblem problem) =>
      switch (problem) {
        BackupProblem.notFound => l10n.backupNotFound,
        BackupProblem.notABackup => l10n.backupInvalid,
        BackupProblem.newerVersion => l10n.backupNewer,
        BackupProblem.corrupted => l10n.backupCorrupted,
      };

  static String _dateStamp() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.backupTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(l10n.backupDescription, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _busy ? null : _createBackup,
              icon: const Icon(Icons.save_alt_outlined),
              label: Text(l10n.createBackup),
            ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _restoreBackup,
              icon: const Icon(Icons.settings_backup_restore_outlined),
              label: Text(l10n.restoreBackup),
            ),
          ],
        ),
        if (_busy) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}
