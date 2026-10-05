import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flutter/material.dart';

class PaymentDialogResult {
  const PaymentDialogResult({
    required this.amount,
    required this.paidAt,
    this.note,
    this.workItemIds = const [],
  });

  final double amount;
  final DateTime paidAt;
  final String? note;

  /// Work items this payment covers; empty when an amount was typed.
  final List<String> workItemIds;
}

enum _PaymentInputMode { amount, workItems }

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({
    super.key,
    required this.initialAmount,
    this.title,
    this.submitLabel,
    this.helperText,
    this.maxAmount,
    this.allowZero = true,
    this.selectableWorkItems,
  });

  final double initialAmount;

  /// Defaults to the "record payment" title and button text.
  final String? title;
  final String? submitLabel;
  final String? helperText;
  final double? maxAmount;
  final bool allowZero;

  /// When set, the dialog can also take the amount from selected work items
  /// (unpaid, completed work of the period).
  final List<WorkItem>? selectableWorkItems;

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _noteController = TextEditingController();
  late DateTime _paidAt;
  var _mode = _PaymentInputMode.amount;
  final Set<String> _selectedWorkItemIds = {};
  var _showSelectionError = false;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.initialAmount.toStringAsFixed(2));
    // Prefilled with "."; AppFormatter.parseNumber accepts either separator.
    _paidAt = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _paidAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) {
      setState(() => _paidAt = selected);
    }
  }

  bool get _selectingWorkItems => _mode == _PaymentInputMode.workItems;

  double get _selectedTotal => (widget.selectableWorkItems ?? const [])
      .where((item) => _selectedWorkItemIds.contains(item.id))
      .fold<double>(0, (sum, item) => sum + item.totalPrice);

  void _setMode(_PaymentInputMode mode) {
    setState(() {
      _mode = mode;
      _showSelectionError = false;
      if (_selectingWorkItems) {
        _syncAmountWithSelection();
      } else {
        _amountController.text = widget.initialAmount.toStringAsFixed(2);
      }
    });
  }

  void _toggleWorkItem(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedWorkItemIds.add(id);
      } else {
        _selectedWorkItemIds.remove(id);
      }
      _showSelectionError = false;
      _syncAmountWithSelection();
    });
  }

  void _syncAmountWithSelection() {
    _amountController.text = _selectedTotal.toStringAsFixed(2);
  }

  String? _validateAmount(String? value) {
    // In work mode the exact total is used; the field only shows it rounded.
    final amount = _selectingWorkItems
        ? _selectedTotal
        : AppFormatter.parseNumber(value ?? '');
    if (amount == null || amount < 0) {
      return context.l10n.validAmountRequired;
    }
    if (_selectingWorkItems && _selectedWorkItemIds.isEmpty) {
      return null;
    }
    if (!widget.allowZero && amount == 0) {
      return context.l10n.amountMustBePositive;
    }
    final maxAmount = widget.maxAmount;
    if (maxAmount != null && amount > maxAmount + _amountTolerance) {
      return context.l10n.amountExceedsRemaining;
    }
    return null;
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final selectionMissing =
        _selectingWorkItems && _selectedWorkItemIds.isEmpty;
    if (selectionMissing) {
      setState(() => _showSelectionError = true);
    }
    if (!formValid || selectionMissing) {
      return;
    }
    final amount = _selectingWorkItems
        ? _selectedTotal
        : AppFormatter.parseNumber(_amountController.text)!;
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      PaymentDialogResult(
        amount: amount,
        paidAt: _paidAt,
        note: note.isEmpty ? null : note,
        workItemIds: _selectingWorkItems
            ? [
                for (final item in widget.selectableWorkItems!)
                  if (_selectedWorkItemIds.contains(item.id)) item.id,
              ]
            : const [],
      ),
    );
  }

  Widget _buildWorkItemPicker(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = widget.selectableWorkItems!;
    if (items.isEmpty) {
      return Text(l10n.partialPaymentNoUnpaidWork,
          style: theme.textTheme.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.partialPaymentSelectHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final item in items)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _selectedWorkItemIds.contains(item.id),
                  onChanged: (value) =>
                      _toggleWorkItem(item.id, value ?? false),
                  title: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    l10n.quantityWithUnit(context.number(item.quantity)),
                  ),
                  secondary: Text(context.money(item.totalPrice)),
                ),
            ],
          ),
        ),
        if (_showSelectionError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.partialPaymentSelectAtLeastOne,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? context.l10n.paymentReceivedTitle),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.selectableWorkItems != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<_PaymentInputMode>(
                      segments: [
                        ButtonSegment(
                          value: _PaymentInputMode.amount,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(context.l10n.partialPaymentByAmount),
                        ),
                        ButtonSegment(
                          value: _PaymentInputMode.workItems,
                          icon: const Icon(Icons.checklist),
                          label: Text(context.l10n.partialPaymentByWork),
                        ),
                      ],
                      selected: {_mode},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) =>
                          _setMode(selection.single),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectingWorkItems) ...[
                    _buildWorkItemPicker(context),
                    const SizedBox(height: 16),
                  ],
                ],
                TextFormField(
                  controller: _amountController,
                  autofocus: !_selectingWorkItems,
                  readOnly: _selectingWorkItems,
                  decoration: InputDecoration(
                    labelText: _selectingWorkItems
                        ? context.l10n.selectedWorkTotal
                        : context.l10n.amount,
                    helperText: widget.helperText,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateAmount,
                ),
                const SizedBox(height: 16),
                Text(context.l10n.paymentDate,
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(formatDate(_paidAt)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(labelText: context.l10n.note),
                  minLines: 2,
                  maxLines: 4,
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
          onPressed: _submit,
          child: Text(widget.submitLabel ?? context.l10n.closePeriodAction),
        ),
      ],
    );
  }
}

/// Rounding slack when comparing money totals stored as doubles.
const _amountTolerance = 0.005;
