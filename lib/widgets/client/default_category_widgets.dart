import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/client_default_category.dart';
import 'package:flowledger/repositories/client_default_category_repository.dart';
import 'package:flutter/material.dart';

class DefaultCategoryTile extends StatelessWidget {
  const DefaultCategoryTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final ClientDefaultCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.category_outlined),
        title: Text(category.name),
        subtitle: Text(context.money(category.price)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.edit,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: context.l10n.delete,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class NoDefaultCategories extends StatelessWidget {
  const NoDefaultCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          context.l10n.noDefaultCategories,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class DefaultCategoryDialog extends StatefulWidget {
  const DefaultCategoryDialog({
    super.key,
    required this.clientId,
    required this.repository,
    this.category,
  });

  final String clientId;
  final ClientDefaultCategory? category;
  final ClientDefaultCategoryRepository repository;

  @override
  State<DefaultCategoryDialog> createState() => _DefaultCategoryDialogState();
}

class _DefaultCategoryDialogState extends State<DefaultCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  final List<TextEditingController> _stepControllers = [];
  var _isSaving = false;
  var _isLoadingSteps = false;
  String? _errorMessage;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _priceController = TextEditingController(
      text: widget.category?.price.toStringAsFixed(2) ?? '',
    );
    if (_isEditing) {
      _loadSteps();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSteps() async {
    setState(() => _isLoadingSteps = true);
    try {
      final steps =
          await widget.repository.getStepsForCategory(widget.category!.id);
      if (!mounted) return;
      setState(() {
        for (final controller in _stepControllers) {
          controller.dispose();
        }
        _stepControllers
          ..clear()
          ..addAll(
            steps.map((step) => TextEditingController(text: step.title)),
          );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingSteps = false);
      }
    }
  }

  void _addStep() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStep(int index) {
    setState(() {
      _stepControllers.removeAt(index).dispose();
    });
  }

  void _moveStep(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _stepControllers.length) {
      return;
    }
    setState(() {
      final controller = _stepControllers.removeAt(index);
      _stepControllers.insert(target, controller);
    });
  }

  double? _parsePrice() {
    return AppFormatter.parseNumber(_priceController.text);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final price = _parsePrice();
    if (price == null) {
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final stepTitles = _stepControllers
        .map((controller) => controller.text.trim())
        .where((title) => title.isNotEmpty)
        .toList();
    try {
      if (_isEditing) {
        await widget.repository.updateDefaultCategory(
          widget.category!.id,
          _nameController.text,
          price,
          stepTitles: stepTitles,
        );
      } else {
        await widget.repository.createDefaultCategory(
          widget.clientId,
          _nameController.text,
          price,
          stepTitles: stepTitles,
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = context.l10n.categorySaveFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          _isEditing ? context.l10n.editCategory : context.l10n.addCategory),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration:
                    InputDecoration(labelText: context.l10n.categoryName),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  return value == null || value.trim().isEmpty
                      ? context.l10n.categoryNameRequired
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                    labelText:
                        '${context.l10n.price} (${CurrencyScope.of(context).symbol})'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final price = AppFormatter.parseNumber(value ?? '');
                  return price == null || price < 0
                      ? context.l10n.validPriceRequired
                      : null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.pastPeriodsUnaffected,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.workStages,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.workStagesHelper,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (_isLoadingSteps)
                const LinearProgressIndicator()
              else
                Column(
                  children: [
                    for (var index = 0;
                        index < _stepControllers.length;
                        index++) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stepControllers[index],
                              decoration: InputDecoration(
                                labelText:
                                    '${context.l10n.addStage} ${index + 1}',
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          IconButton(
                            tooltip: context.l10n.moveUp,
                            onPressed:
                                index == 0 ? null : () => _moveStep(index, -1),
                            icon: const Icon(Icons.keyboard_arrow_up),
                          ),
                          IconButton(
                            tooltip: context.l10n.moveDown,
                            onPressed: index == _stepControllers.length - 1
                                ? null
                                : () => _moveStep(index, 1),
                            icon: const Icon(Icons.keyboard_arrow_down),
                          ),
                          IconButton(
                            tooltip: context.l10n.delete,
                            onPressed: () => _removeStep(index),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addStep,
                        icon: const Icon(Icons.add),
                        label: Text(context.l10n.addStage),
                      ),
                    ),
                  ],
                ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(_isSaving ? context.l10n.saving : context.l10n.save),
        ),
      ],
    );
  }
}
