import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/models/payment.dart';
import 'package:flowledger/models/work_item.dart';

enum ActivePeriodExportFormat { txt, xlsx }

class ActivePeriodExportData {
  const ActivePeriodExportData({
    required this.clientName,
    required this.startDate,
    required this.workItems,
    required this.payments,
    required this.strings,
    required this.formatter,
    this.exportedAt,
  });

  final String clientName;
  final DateTime startDate;
  final List<WorkItem> workItems;
  final List<Payment> payments;
  final DateTime? exportedAt;

  /// Report language; the same as the UI language.
  final AppLocalizations strings;

  /// Amount and number format (language + selected currency).
  final AppFormatter formatter;

  Iterable<WorkItem> get completedWorkItems =>
      workItems.where((item) => item.status == WorkItemStatus.completed);

  Iterable<WorkItem> get inProgressWorkItems =>
      workItems.where((item) => item.status == WorkItemStatus.inProgress);

  double get completedTotal => completedWorkItems.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

  double get inProgressTotal => inProgressWorkItems.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

  double get paymentTotal => payments.fold<double>(
        0,
        (sum, payment) => sum + payment.amount,
      );

  double get remainingAmount => completedTotal - paymentTotal;
}

class ActivePeriodExportService {
  const ActivePeriodExportService();

  Uint8List createTxt(ActivePeriodExportData data) {
    final exportedAt = data.exportedAt ?? DateTime.now();
    final t = data.strings;
    final money = data.formatter.money;
    final number = data.formatter.number;
    final buffer = StringBuffer()
      ..writeln(t.reportTitle)
      ..writeln('${t.reportClient}: ${_singleLine(data.clientName)}')
      ..writeln('${t.reportPeriodStart}: ${formatDateTime(data.startDate)}')
      ..writeln('${t.reportDate}: ${formatDateTime(exportedAt)}')
      ..writeln()
      ..writeln(t.reportSummary)
      ..writeln('${t.reportCompletedCount}: ${data.completedWorkItems.length}')
      ..writeln(
          '${t.reportInProgressCount}: ${data.inProgressWorkItems.length}')
      ..writeln('${t.reportCompletedTotal}: ${money(data.completedTotal)}')
      ..writeln('${t.reportInProgressTotal}: ${money(data.inProgressTotal)}')
      ..writeln('${t.reportPaymentReceived}: ${money(data.paymentTotal)}')
      ..writeln('${t.reportRemaining}: ${money(data.remainingAmount)}')
      ..writeln()
      ..writeln(t.reportWorkItems)
      ..writeln(
        [
          t.reportColNo,
          t.reportColDate,
          t.reportColWork,
          t.reportColStatus,
          t.reportColUnitPrice,
          t.reportColQuantity,
          t.reportColMultiplier,
          t.reportColAmount,
          t.reportColNotes,
        ].join(' | '),
      );

    if (data.workItems.isEmpty) {
      buffer.writeln(t.noWorkInPeriod);
    } else {
      for (var index = 0; index < data.workItems.length; index++) {
        final item = data.workItems[index];
        buffer.writeln([
          index + 1,
          formatDateTime(item.completedAt ?? item.createdAt),
          _singleLine(item.title),
          _statusLabel(t, item.status),
          money(item.priceSnapshot),
          number(item.quantity),
          '×${number(item.multiplier)}',
          money(item.totalPrice),
          _singleLine(item.notes ?? '—'),
        ].join(' | '));
      }
    }

    buffer
      ..writeln()
      ..writeln(t.reportPayments)
      ..writeln([
        t.reportColNo,
        t.reportColDate,
        t.reportColAmount,
        t.reportColNote
      ].join(' | '));

    if (data.payments.isEmpty) {
      buffer.writeln(t.noPaymentsInPeriod);
    } else {
      for (var index = 0; index < data.payments.length; index++) {
        final payment = data.payments[index];
        buffer.writeln([
          index + 1,
          formatDateTime(payment.paidAt),
          money(payment.amount),
          _singleLine(payment.note ?? '—'),
        ].join(' | '));
      }
    }

    // The BOM makes Windows text viewers detect UTF-8 reliably.
    return Uint8List.fromList(utf8.encode('\uFEFF$buffer'));
  }

  Uint8List createXlsx(ActivePeriodExportData data) {
    final exportedAt = (data.exportedAt ?? DateTime.now()).toLocal();
    final workbook = Excel.createExcel();
    final t = data.strings;
    final sheetName = t.reportSheetName;
    // Excel number format: the symbol is quoted so the cell stays numeric.
    final currencyFormat = '"${data.formatter.currency.symbol}" #,##0.00';
    workbook.rename('Sheet1', sheetName);
    workbook.setDefaultSheet(sheetName);
    final sheet = workbook[sheetName];

    final darkBlue = ExcelColor.fromHexString('FF173B57');
    final mediumBlue = ExcelColor.fromHexString('FF2B6F9F');
    final paleBlue = ExcelColor.fromHexString('FFEAF3F8');
    final paleGreen = ExcelColor.fromHexString('FFE8F5EC');
    final paleOrange = ExcelColor.fromHexString('FFFFF1DE');
    final white = ExcelColor.fromHexString('FFFFFFFF');
    final gray = ExcelColor.fromHexString('FF5F6B76');
    final lightBorder = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString('FFD6DEE5'),
    );
    final titleStyle = CellStyle(
      backgroundColorHex: darkBlue,
      fontColorHex: white,
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final labelStyle = CellStyle(
      backgroundColorHex: paleBlue,
      fontColorHex: darkBlue,
      bold: true,
      verticalAlign: VerticalAlign.Center,
    );
    final valueStyle = CellStyle(
      verticalAlign: VerticalAlign.Center,
    );
    final sectionStyle = CellStyle(
      backgroundColorHex: mediumBlue,
      fontColorHex: white,
      bold: true,
      fontSize: 12,
      verticalAlign: VerticalAlign.Center,
    );
    final headerStyle = CellStyle(
      backgroundColorHex: paleBlue,
      fontColorHex: darkBlue,
      bold: true,
      textWrapping: TextWrapping.WrapText,
      verticalAlign: VerticalAlign.Center,
      bottomBorder: lightBorder,
    );
    final bodyTextStyle = CellStyle(
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
      bottomBorder: lightBorder,
    );
    final bodyNumberStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: NumFormat.custom(formatCode: '#,##0.00'),
      bottomBorder: lightBorder,
    );
    final currencyStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: NumFormat.custom(formatCode: currencyFormat),
      bottomBorder: lightBorder,
    );
    final dateStyle = CellStyle(
      verticalAlign: VerticalAlign.Center,
      numberFormat: NumFormat.custom(formatCode: 'dd.mm.yyyy hh:mm'),
      bottomBorder: lightBorder,
    );
    final summaryCurrencyStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: NumFormat.custom(formatCode: currencyFormat),
    );

    final titleStart = CellIndex.indexByString('A1');
    sheet.merge(
      titleStart,
      CellIndex.indexByString('G1'),
      customValue: TextCellValue(t.reportTitle),
    );
    sheet.setMergedCellStyle(titleStart, titleStyle);
    sheet.setRowHeight(0, 30);

    _setCell(sheet, 2, 0, TextCellValue(t.reportClient), labelStyle);
    _setCell(sheet, 2, 1, TextCellValue(data.clientName), valueStyle);
    _setCell(sheet, 3, 0, TextCellValue(t.reportPeriodStart), labelStyle);
    _setCell(
      sheet,
      3,
      1,
      DateTimeCellValue.fromDateTime(data.startDate.toLocal()),
      dateStyle,
    );
    _setCell(sheet, 4, 0, TextCellValue(t.reportDate), labelStyle);
    _setCell(
      sheet,
      4,
      1,
      DateTimeCellValue.fromDateTime(exportedAt),
      dateStyle,
    );
    _setCell(sheet, 5, 0, TextCellValue(t.reportCompletedCount), labelStyle);
    _setCell(
      sheet,
      5,
      1,
      IntCellValue(data.completedWorkItems.length),
      valueStyle,
    );
    _setCell(sheet, 6, 0, TextCellValue(t.reportInProgressCount), labelStyle);
    _setCell(
      sheet,
      6,
      1,
      IntCellValue(data.inProgressWorkItems.length),
      valueStyle,
    );

    _setCell(
      sheet,
      2,
      3,
      TextCellValue(t.reportCompletedTotal),
      labelStyle,
    );
    _setCell(
      sheet,
      2,
      4,
      DoubleCellValue(data.completedTotal),
      summaryCurrencyStyle,
    );
    _setCell(
      sheet,
      3,
      3,
      TextCellValue(t.reportInProgressTotal),
      labelStyle,
    );
    _setCell(
      sheet,
      3,
      4,
      DoubleCellValue(data.inProgressTotal),
      summaryCurrencyStyle,
    );
    _setCell(sheet, 4, 3, TextCellValue(t.reportPaymentReceived), labelStyle);
    _setCell(
      sheet,
      4,
      4,
      DoubleCellValue(data.paymentTotal),
      summaryCurrencyStyle,
    );
    _setCell(sheet, 5, 3, TextCellValue(t.reportRemaining), labelStyle);
    _setCell(
      sheet,
      5,
      4,
      DoubleCellValue(data.remainingAmount),
      summaryCurrencyStyle,
    );

    var row = 8;
    row = _addSection(sheet, row, t.reportWorkItems, sectionStyle);
    final workHeaders = [
      t.reportColNo,
      t.reportColDate,
      t.reportColWork,
      t.reportColStatus,
      t.reportColUnitPrice,
      t.reportColQuantity,
      t.reportColAmount,
      // Appended last so existing columns keep their position.
      t.reportColMultiplier,
    ];
    for (var column = 0; column < workHeaders.length; column++) {
      _setCell(
        sheet,
        row,
        column,
        TextCellValue(workHeaders[column]),
        headerStyle,
      );
    }
    row++;

    if (data.workItems.isEmpty) {
      final start = CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row);
      sheet.merge(
        start,
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row),
        customValue: TextCellValue(t.noWorkInPeriod),
      );
      sheet.setMergedCellStyle(
        start,
        bodyTextStyle.copyWith(
          fontColorHexVal: gray,
          italicVal: true,
        ),
      );
      row++;
    } else {
      for (var index = 0; index < data.workItems.length; index++) {
        final item = data.workItems[index];
        final statusStyle = bodyTextStyle.copyWith(
          backgroundColorHexVal:
              item.status == WorkItemStatus.completed ? paleGreen : paleOrange,
        );
        _setCell(sheet, row, 0, IntCellValue(index + 1), bodyNumberStyle);
        _setCell(
          sheet,
          row,
          1,
          DateTimeCellValue.fromDateTime(
            (item.completedAt ?? item.createdAt).toLocal(),
          ),
          dateStyle,
        );
        _setCell(sheet, row, 2, TextCellValue(item.title), bodyTextStyle);
        _setCell(
          sheet,
          row,
          3,
          TextCellValue(_statusLabel(t, item.status)),
          statusStyle,
        );
        _setCell(
          sheet,
          row,
          4,
          DoubleCellValue(item.priceSnapshot),
          currencyStyle,
        );
        _setCell(
          sheet,
          row,
          5,
          DoubleCellValue(item.quantity),
          bodyNumberStyle,
        );
        _setCell(
          sheet,
          row,
          6,
          DoubleCellValue(item.totalPrice),
          currencyStyle,
        );
        _setCell(
          sheet,
          row,
          7,
          DoubleCellValue(item.multiplier),
          bodyNumberStyle,
        );
        row++;
        if (item.notes != null && item.notes!.trim().isNotEmpty) {
          final noteStart = CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: row,
          );
          sheet.merge(
            noteStart,
            CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row),
            customValue: TextCellValue(t.reportNotePrefix(item.notes!.trim())),
          );
          sheet.setMergedCellStyle(
            noteStart,
            bodyTextStyle.copyWith(
              fontColorHexVal: gray,
              italicVal: true,
            ),
          );
          row++;
        }
      }
    }

    row++;
    row = _addSection(sheet, row, t.reportPayments, sectionStyle);
    final paymentHeaders = [
      t.reportColNo,
      t.reportColDate,
      t.reportColAmount,
      t.reportColNote,
    ];
    for (var column = 0; column < paymentHeaders.length; column++) {
      _setCell(
        sheet,
        row,
        column,
        TextCellValue(paymentHeaders[column]),
        headerStyle,
      );
    }
    row++;
    if (data.payments.isEmpty) {
      final start = CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row);
      sheet.merge(
        start,
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row),
        customValue: TextCellValue(t.noPaymentsInPeriod),
      );
      sheet.setMergedCellStyle(
        start,
        bodyTextStyle.copyWith(
          fontColorHexVal: gray,
          italicVal: true,
        ),
      );
    } else {
      for (var index = 0; index < data.payments.length; index++) {
        final payment = data.payments[index];
        _setCell(sheet, row, 0, IntCellValue(index + 1), bodyNumberStyle);
        _setCell(
          sheet,
          row,
          1,
          DateTimeCellValue.fromDateTime(payment.paidAt.toLocal()),
          dateStyle,
        );
        _setCell(
          sheet,
          row,
          2,
          DoubleCellValue(payment.amount),
          currencyStyle,
        );
        _setCell(
          sheet,
          row,
          3,
          TextCellValue(payment.note?.trim().isNotEmpty == true
              ? payment.note!.trim()
              : '—'),
          bodyTextStyle,
        );
        row++;
      }
    }

    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 32);
    sheet.setColumnWidth(3, 18);
    sheet.setColumnWidth(4, 18);
    sheet.setColumnWidth(5, 12);
    sheet.setColumnWidth(6, 18);
    sheet.setColumnWidth(7, 10);

    final bytes = workbook.encode();
    if (bytes == null) {
      throw StateError('Could not create the XLSX file.');
    }
    return Uint8List.fromList(bytes);
  }

  Future<String?> save(
    ActivePeriodExportData data,
    ActivePeriodExportFormat format,
  ) async {
    final extension = format.name;
    final fileName =
        '${_safeFileName(data.clientName, data.strings.reportUnnamedClient)}_'
        '${data.strings.reportFileSuffix}_'
        '${_fileTimestamp(DateTime.now())}.$extension';
    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        XTypeGroup(
          label: format == ActivePeriodExportFormat.txt
              ? data.strings.reportTextFile
              : data.strings.reportExcelFile,
          extensions: [extension],
        ),
      ],
    );
    if (location == null) {
      return null;
    }

    final bytes = format == ActivePeriodExportFormat.txt
        ? createTxt(data)
        : createXlsx(data);
    final path = location.path.toLowerCase().endsWith('.$extension')
        ? location.path
        : '${location.path}.$extension';
    final file = XFile.fromData(
      bytes,
      name: fileName,
      mimeType: format == ActivePeriodExportFormat.txt
          ? 'text/plain'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    await file.saveTo(path);
    return path;
  }
}

void _setCell(
  Sheet sheet,
  int row,
  int column,
  CellValue value,
  CellStyle style,
) {
  final cell = sheet.cell(
    CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
  );
  cell.value = value;
  cell.cellStyle = style;
}

int _addSection(Sheet sheet, int row, String title, CellStyle style) {
  final start = CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row);
  sheet.merge(
    start,
    CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row),
    customValue: TextCellValue(title),
  );
  sheet.setMergedCellStyle(start, style);
  sheet.setRowHeight(row, 22);
  return row + 1;
}

String _statusLabel(AppLocalizations t, WorkItemStatus status) =>
    switch (status) {
      WorkItemStatus.completed => t.completed,
      WorkItemStatus.inProgress => t.inProgress,
    };

String _singleLine(String value) =>
    value.replaceAll(RegExp(r'[\r\n]+'), ' ').replaceAll('|', '/').trim();

String _safeFileName(String value, String fallback) {
  final safe = value
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'[. ]+$'), '')
      .trim();
  return safe.isEmpty ? fallback : safe;
}

String _fileTimestamp(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${local.year}${twoDigits(local.month)}${twoDigits(local.day)}_'
      '${twoDigits(local.hour)}${twoDigits(local.minute)}';
}
