import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/client.dart';
import 'package:flowledger/models/work_item_filters.dart';
import 'package:flutter/material.dart';

class WorksFilterPanel extends StatefulWidget {
  const WorksFilterPanel({
    super.key,
    required this.clients,
    required this.categoryNames,
    required this.onChanged,
  });

  final List<Client> clients;
  final List<String> categoryNames;
  final ValueChanged<WorkItemFilters> onChanged;

  @override
  State<WorksFilterPanel> createState() => WorksFilterPanelState();
}

class WorksFilterPanelState extends State<WorksFilterPanel> {
  final _minimumAmountController = TextEditingController();
  final _maximumAmountController = TextEditingController();
  final _minimumQuantityController = TextEditingController();
  final _maximumQuantityController = TextEditingController();

  String? _clientId;
  String? _categoryName;
  DateTime? _startDate;
  DateTime? _endDate;
  var _workType = WorkTypeFilter.all;
  var _periodStatus = PeriodStatusFilter.all;
  var _workStatus = WorkStatusFilter.all;

  @override
  void dispose() {
    _minimumAmountController.dispose();
    _maximumAmountController.dispose();
    _minimumQuantityController.dispose();
    _maximumQuantityController.dispose();
    super.dispose();
  }

  void clear() {
    _minimumAmountController.clear();
    _maximumAmountController.clear();
    _minimumQuantityController.clear();
    _maximumQuantityController.clear();
    setState(() {
      _clientId = null;
      _categoryName = null;
      _startDate = null;
      _endDate = null;
      _workType = WorkTypeFilter.all;
      _periodStatus = PeriodStatusFilter.all;
      _workStatus = WorkStatusFilter.all;
    });
    _emit();
  }

  void _emit() {
    widget.onChanged(
      WorkItemFilters(
        clientId: _clientId,
        categoryName: _categoryName,
        startDate: _startDate,
        endDate: _endDate,
        minimumAmount: _parseOptional(_minimumAmountController),
        maximumAmount: _parseOptional(_maximumAmountController),
        minimumQuantity: _parseOptional(_minimumQuantityController),
        maximumQuantity: _parseOptional(_maximumQuantityController),
        workType: _workType,
        periodStatus: _periodStatus,
        status: _workStatus,
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isStart ? context.l10n.startDate : context.l10n.endDate,
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      if (isStart) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(context.l10n.filters),
        leading: const Icon(Icons.tune_rounded),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final fieldWidth = constraints.maxWidth >= 920
                  ? (constraints.maxWidth - 48) / 4
                  : constraints.maxWidth >= 600
                      ? (constraints.maxWidth - 24) / 2
                      : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<String>(
                      initialValue: _clientId,
                      decoration:
                          InputDecoration(labelText: context.l10n.client),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text(context.l10n.allClients)),
                        for (final client in widget.clients)
                          DropdownMenuItem(
                              value: client.id, child: Text(client.name)),
                      ],
                      onChanged: (value) {
                        setState(() => _clientId = value);
                        _emit();
                      },
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<String>(
                      initialValue: _categoryName,
                      decoration:
                          InputDecoration(labelText: context.l10n.category),
                      items: [
                        DropdownMenuItem(
                            value: null,
                            child: Text(context.l10n.allCategories)),
                        DropdownMenuItem(
                          value: WorkItemFilters.customCategoryValue,
                          child: Text(context.l10n.oneOffWork),
                        ),
                        for (final name in widget.categoryNames)
                          DropdownMenuItem(value: name, child: Text(name)),
                      ],
                      onChanged: (value) {
                        setState(() => _categoryName = value);
                        _emit();
                      },
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _DateFilterField(
                      label: context.l10n.startDate,
                      value: _startDate,
                      onTap: () => _selectDate(isStart: true),
                      onClear: _startDate == null
                          ? null
                          : () {
                              setState(() => _startDate = null);
                              _emit();
                            },
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _DateFilterField(
                      label: context.l10n.endDate,
                      value: _endDate,
                      onTap: () => _selectDate(isStart: false),
                      onClear: _endDate == null
                          ? null
                          : () {
                              setState(() => _endDate = null);
                              _emit();
                            },
                    ),
                  ),
                  _NumberBox(
                    width: fieldWidth,
                    controller: _minimumAmountController,
                    label: context.l10n.minimumAmount,
                    onChanged: _emit,
                  ),
                  _NumberBox(
                    width: fieldWidth,
                    controller: _maximumAmountController,
                    label: context.l10n.maximumAmount,
                    onChanged: _emit,
                  ),
                  _NumberBox(
                    width: fieldWidth,
                    controller: _minimumQuantityController,
                    label: context.l10n.minimumQuantity,
                    onChanged: _emit,
                  ),
                  _NumberBox(
                    width: fieldWidth,
                    controller: _maximumQuantityController,
                    label: context.l10n.maximumQuantity,
                    onChanged: _emit,
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<WorkTypeFilter>(
                      initialValue: _workType,
                      decoration:
                          InputDecoration(labelText: context.l10n.workType),
                      items: [
                        DropdownMenuItem(
                            value: WorkTypeFilter.all,
                            child: Text(context.l10n.all)),
                        DropdownMenuItem(
                            value: WorkTypeFilter.categorized,
                            child: Text(context.l10n.categorizedWork)),
                        DropdownMenuItem(
                            value: WorkTypeFilter.custom,
                            child: Text(context.l10n.oneOffWork)),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _workType = value);
                        _emit();
                      },
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<PeriodStatusFilter>(
                      initialValue: _periodStatus,
                      decoration:
                          InputDecoration(labelText: context.l10n.periodStatus),
                      items: [
                        DropdownMenuItem(
                            value: PeriodStatusFilter.all,
                            child: Text(context.l10n.all)),
                        DropdownMenuItem(
                            value: PeriodStatusFilter.open,
                            child: Text(context.l10n.activePeriod)),
                        DropdownMenuItem(
                            value: PeriodStatusFilter.closed,
                            child: Text(context.l10n.closedPeriod)),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _periodStatus = value);
                        _emit();
                      },
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<WorkStatusFilter>(
                      initialValue: _workStatus,
                      decoration:
                          InputDecoration(labelText: context.l10n.status),
                      items: [
                        DropdownMenuItem(
                          value: WorkStatusFilter.all,
                          child: Text(context.l10n.all),
                        ),
                        DropdownMenuItem(
                          value: WorkStatusFilter.inProgress,
                          child: Text(context.l10n.inProgress),
                        ),
                        DropdownMenuItem(
                          value: WorkStatusFilter.completed,
                          child: Text(context.l10n.completed),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _workStatus = value);
                        _emit();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NumberBox extends StatelessWidget {
  const _NumberBox({
    required this.width,
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}

class _DateFilterField extends StatelessWidget {
  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: onClear == null
              ? const Icon(Icons.calendar_today_outlined, size: 18)
              : IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
        ),
        child: Text(value == null ? context.l10n.select : formatDate(value!)),
      ),
    );
  }
}

double? _parseOptional(TextEditingController controller) =>
    AppFormatter.parseNumber(controller.text);
