import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flutter/material.dart';

class PaymentDialogResult {
  const PaymentDialogResult({
    required this.amount,
    required this.paidAt,
    this.note,
  });

  final double amount;
  final DateTime paidAt;
  final String? note;
}

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({
    super.key,
    required this.initialAmount,
    this.title,
    this.submitLabel,
    this.helperText,
    this.maxAmount,
    this.allowZero = true,
  });

  final double initialAmount;

  /// Defaults to the "record payment" title and button text.
  final String? title;
  final String? submitLabel;
  final String? helperText;
  final double? maxAmount;
  final bool allowZero;

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _noteController = TextEditingController();
  late DateTime _paidAt;

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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final amount = AppFormatter.parseNumber(_amountController.text)!;
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      PaymentDialogResult(
        amount: amount,
        paidAt: _paidAt,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? context.l10n.paymentReceivedTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: context.l10n.amount,
                  helperText: widget.helperText,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final amount = AppFormatter.parseNumber(value ?? '');
                  if (amount == null || amount < 0) {
                    return context.l10n.validAmountRequired;
                  }
                  if (!widget.allowZero && amount == 0) {
                    return context.l10n.amountMustBePositive;
                  }
                  final maxAmount = widget.maxAmount;
                  if (maxAmount != null && amount > maxAmount) {
                    return context.l10n.amountExceedsRemaining;
                  }
                  return null;
                },
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
