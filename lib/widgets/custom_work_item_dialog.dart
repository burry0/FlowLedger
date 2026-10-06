import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/widgets/draft_share_field.dart';
import 'package:flutter/material.dart';

class CustomWorkItemInput {
  const CustomWorkItemInput({
    required this.title,
    required this.price,
    required this.quantity,
    required this.createAsCompleted,
    this.notes,
    this.draftShare,
  });

  final String title;
  final double price;
  final double quantity;
  final bool createAsCompleted;
  final String? notes;

  /// Part of the price billed now when the work is a draft; null otherwise.
  final double? draftShare;
}

class CustomWorkItemDialog extends StatefulWidget {
  const CustomWorkItemDialog({super.key});

  @override
  State<CustomWorkItemDialog> createState() => _CustomWorkItemDialogState();
}

class _CustomWorkItemDialogState extends State<CustomWorkItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  var _createAsCompleted = false;
  var _isDraft = false;
  var _draftShare = DraftShareField.defaultShare;

  double? get _fullPrice {
    final price = AppFormatter.parseNumber(_priceController.text);
    final quantity = AppFormatter.parseNumber(_quantityController.text);
    if (price == null || price < 0 || quantity == null || quantity <= 0) {
      return null;
    }
    return price * quantity;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final notes = _notesController.text.trim();
    Navigator.of(context).pop(
      CustomWorkItemInput(
        title: _titleController.text.trim(),
        price: AppFormatter.parseNumber(_priceController.text)!,
        quantity: AppFormatter.parseNumber(_quantityController.text)!,
        createAsCompleted: _createAsCompleted,
        notes: notes.isEmpty ? null : notes,
        draftShare: _isDraft ? _draftShare : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.oneOffWorkTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration:
                      InputDecoration(labelText: context.l10n.workTitle),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? context.l10n.workTitleRequiredShort
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: context.l10n.price),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: _validateNonNegative,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: context.l10n.quantity),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: _validatePositive,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: context.l10n.note),
                  minLines: 2,
                  maxLines: 4,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _createAsCompleted,
                  onChanged: (value) {
                    setState(() => _createAsCompleted = value ?? false);
                  },
                  title: Text(context.l10n.createAsCompleted),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                DraftShareField(
                  isDraft: _isDraft,
                  share: _draftShare,
                  fullPrice: _fullPrice,
                  onDraftChanged: (value) => setState(() => _isDraft = value),
                  onShareChanged: (value) =>
                      setState(() => _draftShare = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
            onPressed: _submit, child: Text(context.l10n.addWorkAction)),
      ],
    );
  }

  String? _validateNonNegative(String? value) {
    final parsed = AppFormatter.parseNumber(value ?? '');
    return parsed == null || parsed < 0
        ? context.l10n.validAmountRequired
        : null;
  }

  String? _validatePositive(String? value) {
    final parsed = AppFormatter.parseNumber(value ?? '');
    return parsed == null || parsed <= 0
        ? context.l10n.validQuantityRequired
        : null;
  }
}
