import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item_version.dart';
import 'package:flutter/material.dart';

class VersionDialogResult {
  const VersionDialogResult({this.label, this.notes, this.link});

  final String? label;
  final String? notes;
  final String? link;
}

/// Creates or edits a version. Status is changed on the version card.
class VersionDialog extends StatefulWidget {
  const VersionDialog({super.key, this.version, required this.defaultLabel});

  /// Null to create a new version.
  final WorkItemVersion? version;

  /// Label the repository assigns when the name is left empty.
  final String defaultLabel;

  @override
  State<VersionDialog> createState() => _VersionDialogState();
}

class _VersionDialogState extends State<VersionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _notesController;
  late final TextEditingController _linkController;

  bool get _isEditing => widget.version != null;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.version?.label);
    _notesController = TextEditingController(text: widget.version?.notes);
    _linkController = TextEditingController(text: widget.version?.link);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _notesController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    Navigator.of(context).pop(
      VersionDialogResult(
        label: _labelController.text,
        notes: _notesController.text,
        link: _linkController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(_isEditing ? l10n.editVersion : l10n.newVersion),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _labelController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.versionLabel,
                    helperText: _isEditing
                        ? null
                        : l10n.versionLabelHint(widget.defaultLabel),
                  ),
                  validator: (value) =>
                      _isEditing && (value == null || value.trim().isEmpty)
                          ? l10n.versionLabel
                          : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(labelText: l10n.versionNotes),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _linkController,
                  decoration: InputDecoration(
                    labelText: l10n.versionLink,
                    prefixIcon: const Icon(Icons.link),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
