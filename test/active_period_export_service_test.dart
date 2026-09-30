import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flowledger/app/currency_controller.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/models/payment.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/services/active_period_export_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime(2026, 8, 14, 10, 30);
  final exportData = ActivePeriodExportData(
    clientName: 'Örnek Müşteri',
    startDate: DateTime(2026, 8, 1, 9),
    exportedAt: DateTime(2026, 8, 14, 16, 45),
    strings: lookupAppLocalizations(const Locale('tr')),
    formatter: const AppFormatter(
      localeName: 'tr',
      currency: AppCurrency('TRY', '₺'),
    ),
    workItems: [
      WorkItem(
        id: 'work-completed',
        clientId: 'client',
        paymentPeriodId: 'period',
        title: 'Aylık bakım',
        priceSnapshot: 1250,
        quantity: 2,
        totalPrice: 2500,
        status: WorkItemStatus.completed,
        completedAt: DateTime(2026, 8, 10, 14),
        notes: 'Kontrol edildi',
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      WorkItem(
        id: 'work-progress',
        clientId: 'client',
        paymentPeriodId: 'period',
        title: 'Ek çalışma',
        priceSnapshot: 750,
        quantity: 1.5,
        totalPrice: 1687.5,
        multiplier: 1.5,
        status: WorkItemStatus.inProgress,
        notes: 'Devam\nediyor | öncelikli',
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    ],
    payments: [
      Payment(
        id: 'payment',
        clientId: 'client',
        paymentPeriodId: 'period',
        amount: 1000,
        paidAt: DateTime(2026, 8, 12, 11, 15),
        note: 'Kısmi ödeme',
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    ],
  );
  const service = ActivePeriodExportService();

  test('TXT contains the period summary, work and payments in UTF-8', () {
    final bytes = service.createTxt(exportData);
    final content = utf8.decode(bytes);

    expect(bytes.take(3), orderedEquals([0xef, 0xbb, 0xbf]));
    expect(content, contains('FlowLedger - Aktif Dönem Raporu'));
    expect(content, contains('Müşteri: Örnek Müşteri'));
    expect(content, contains('Tamamlanan işler toplamı: ₺2.500,00'));
    expect(content, contains('Devam eden işler toplamı: ₺1.687,50'));
    expect(content, contains('| Miktar | Çarpan | Tutar |'));
    expect(content, contains('| 2 | ×1 | ₺2.500,00 |'));
    expect(content, contains('| 1,5 | ×1,5 | ₺1.687,50 |'));
    expect(content, contains('Alınan ödeme: ₺1.000,00'));
    expect(content, contains('Kalan tutar: ₺1.500,00'));
    expect(content, contains('Ek çalışma | Devam Ediyor'));
    expect(content, contains('Devam ediyor / öncelikli'));
    expect(content, contains('Kısmi ödeme'));
  });

  test('XLSX uses numeric and date cells', () {
    final bytes = service.createXlsx(exportData);

    expect(bytes.take(2), orderedEquals([0x50, 0x4b]));
    final workbook = Excel.decodeBytes(bytes);
    final sheet = workbook.tables['Aktif Dönem'];
    expect(sheet, isNotNull);

    expect(_text(sheet!, 'A1'), 'FlowLedger - Aktif Dönem Raporu');
    expect(_text(sheet, 'B3'), 'Örnek Müşteri');
    expect(sheet.cell(CellIndex.indexByString('B4')).value,
        isA<DateTimeCellValue>());
    expect(_number(sheet, 'E3'), 2500);
    expect(_number(sheet, 'E4'), 1687.5);
    expect(_number(sheet, 'E5'), 1000);
    expect(_number(sheet, 'E6'), 1500);

    expect(_text(sheet, 'C11'), 'Aylık bakım');
    expect(_number(sheet, 'E11'), 1250);
    expect(_number(sheet, 'F11'), 2);
    expect(_number(sheet, 'G11'), 2500);
    expect(_text(sheet, 'D13'), 'Devam Ediyor');
    expect(_text(sheet, 'H10'), 'Çarpan');
    expect(_number(sheet, 'H11'), 1);
    expect(_number(sheet, 'H13'), 1.5);
    expect(_number(sheet, 'G13'), 1687.5);

    final paymentRow = _findRow(sheet, 'Ödemeler') + 2;
    expect(
      sheet
          .cell(CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: paymentRow,
          ))
          .value,
      isA<DateTimeCellValue>(),
    );
    expect(_numberAt(sheet, paymentRow, 2), 1000);
  });
}

String _text(Sheet sheet, String address) {
  return (sheet.cell(CellIndex.indexByString(address)).value as TextCellValue)
          .value
          .text ??
      '';
}

double _number(Sheet sheet, String address) {
  final value = sheet.cell(CellIndex.indexByString(address)).value;
  return _cellNumber(value, address);
}

double _numberAt(Sheet sheet, int row, int column) {
  final value = sheet
      .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
      .value;
  return _cellNumber(value, 'satır $row, sütun $column');
}

double _cellNumber(CellValue? value, String location) {
  return switch (value) {
    IntCellValue(:final value) => value.toDouble(),
    DoubleCellValue(:final value) => value,
    _ => throw StateError('$location sayısal bir hücre değil.'),
  };
}

int _findRow(Sheet sheet, String text) {
  for (var row = 0; row < sheet.maxRows; row++) {
    final value = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value;
    if (value is TextCellValue && value.value.text == text) {
      return row;
    }
  }
  throw StateError('Row "$text" not found.');
}
