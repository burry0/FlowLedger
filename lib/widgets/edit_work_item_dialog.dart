import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flutter/material.dart';

class EditWorkItemResult {
  const EditWorkItemResult({
    required this.title,
    required this.quantity,
    required this.multiplier,
    this.notes,
  });

  final String title;
  final double quantity;
  final double multiplier;
  final String? notes;
}

/// Edits a work item's title, quantity, multiplier and notes. The unit price
/// is fixed; the preview shows unit price × quantity × multiplier.
class EditWorkItemDialog extends StatefulWidget {
  const EditWorkItemDialog({super.key, required this.workItem});

  final WorkItem workItem;

  static const presetMultipliers = <double>[1, 1.25, 1.5, 2, 3];

  @override
  State<EditWorkItemDialog> createState() => _EditWorkItemDialogState();
}

class _EditWorkItemDialogState extends State<EditWorkItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  late double _multiplier;

  @override
  void initState() {
    super.initState();
    final workItem = widget.workItem;
    _titleController = TextEditingController(text: workItem.title);
    _quantityController =
        TextEditingController(text: _plainNumber(workItem.quantity));
    _notesController = TextEditingController(text: workItem.notes ?? '');
    _multiplier = workItem.multiplier;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? get _quantity {
    final value = AppFormatter.parseNumber(_quantityController.text);
    return value == null || value <= 0 ? null : value;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final notes = _notesController.text.trim();
    Navigator.of(context).pop(
      EditWorkItemResult(
        title: _titleController.text.trim(),
        quantity: _quantity!,
        multiplier: _multiplier,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final price = widget.workItem.priceSnapshot;
    final quantity = _quantity;
    final multipliers = {
      ...EditWorkItemDialog.presetMultipliers,
      _multiplier,
    }.toList()
      ..sort();

    return AlertDialog(
      title: Text(l10n.editWorkItem),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l10n.workTitle),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.workTitleRequired
                      : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(labelText: l10n.quantity),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (_) => _quantity == null
                            ? l10n.validQuantityRequired
                            : null,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<double>(
                        initialValue: _multiplier,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: l10n.multiplier),
                        items: [
                          for (final value in multipliers)
                            DropdownMenuItem(
                              value: value,
                              child: Text(
                                '×${context.number(value)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _multiplier = value ?? 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  quantity == null
                      ? '${context.money(price)} × — × ${context.number(_multiplier)}'
                      : '${context.money(price)} × ${context.number(quantity)} × '
                          '${context.number(_multiplier)} = '
                          '${context.money(price * quantity * _multiplier)}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: l10n.notes),
                  minLines: 2,
                  maxLines: 4,
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

/// Number for an input field, without grouping: 2 → "2", 1.5 → "1.5".
String _plainNumber(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toString();
