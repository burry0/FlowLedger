import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/models/work_item_version.dart';
import 'package:flowledger/widgets/revisions/revision_labels.dart';
import 'package:flutter/material.dart';

class FeedbackDialogResult {
  const FeedbackDialogResult({
    required this.body,
    required this.kind,
    this.timecode,
    this.versionId,
  });

  final String body;
  final WorkItemFeedbackKind kind;
  final String? timecode;
  final String? versionId;
}

/// Adds or edits feedback.
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({
    super.key,
    this.feedback,
    required this.versions,
    this.initialVersionId,
    this.linkedDeletedVersion,
  });

  /// Null to create new feedback.
  final WorkItemFeedback? feedback;

  /// Versions that can be selected, newest first.
  final List<WorkItemVersion> versions;
  final String? initialVersionId;

  /// Deleted version the edited feedback is linked to, offered so the link
  /// can be kept.
  final WorkItemVersion? linkedDeletedVersion;

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bodyController;
  late final TextEditingController _timecodeController;
  late WorkItemFeedbackKind _kind;
  String? _versionId;

  @override
  void initState() {
    super.initState();
    final feedback = widget.feedback;
    _bodyController = TextEditingController(text: feedback?.body);
    _timecodeController = TextEditingController(text: feedback?.timecode);
    _kind = feedback?.kind ?? WorkItemFeedbackKind.revision;
    _versionId =
        feedback == null ? widget.initialVersionId : feedback.versionId;
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _timecodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    Navigator.of(context).pop(
      FeedbackDialogResult(
        body: _bodyController.text,
        kind: _kind,
        timecode: _timecodeController.text,
        versionId: _versionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final deleted = widget.linkedDeletedVersion;
    final versionItems = <DropdownMenuItem<String?>>[
      DropdownMenuItem(value: null, child: Text(l10n.feedbackGeneral)),
      for (final version in widget.versions)
        DropdownMenuItem(value: version.id, child: Text(version.label)),
      if (deleted != null)
        DropdownMenuItem(
          value: deleted.id,
          child: Text(l10n.deletedVersionLabel(deleted.label)),
        ),
    ];
    final hasSelected = versionItems.any((item) => item.value == _versionId);

    return AlertDialog(
      title:
          Text(widget.feedback == null ? l10n.addFeedback : l10n.editFeedback),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<WorkItemFeedbackKind>(
                  segments: [
                    for (final kind in WorkItemFeedbackKind.values)
                      ButtonSegment(
                        value: kind,
                        label: Text(feedbackKindLabel(l10n, kind)),
                        icon: Icon(kind == WorkItemFeedbackKind.revision
                            ? Icons.rate_review_outlined
                            : Icons.add_box_outlined),
                      ),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (selection) =>
                      setState(() => _kind = selection.single),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bodyController,
                  autofocus: true,
                  minLines: 2,
                  maxLines: 6,
                  decoration: InputDecoration(labelText: l10n.feedbackBody),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.feedbackBody
                      : null,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 180,
                      child: TextFormField(
                        controller: _timecodeController,
                        decoration: InputDecoration(
                          labelText: l10n.feedbackTimecode,
                          hintText: l10n.feedbackTimecodeHint,
                          prefixIcon: const Icon(Icons.timer_outlined),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      child: DropdownButtonFormField<String?>(
                        initialValue: hasSelected ? _versionId : null,
                        isExpanded: true,
                        decoration:
                            InputDecoration(labelText: l10n.feedbackVersion),
                        items: versionItems,
                        onChanged: (value) =>
                            setState(() => _versionId = value),
                      ),
                    ),
                  ],
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
