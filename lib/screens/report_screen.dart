import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final box = Hive.box<WorkEntry>('work_entries');
      final entries = box.values.toList()..sort((a, b) => a.date.compareTo(b.date));

      if (entries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет данных')));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final fullName = prefs.getString('fullName') ?? "Не указано";
      final tariff1 = prefs.getDouble('tariff1') ?? 0.0;
      final tariff2 = prefs.getDouble('tariff2') ?? 0.0;

      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(35),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Заголовок в одной строке
              pw.Center(
                child: pw.Text(
                  'Заработная Плата • $fullName • ${DateFormat('MMMM yyyy', 'ru').format(DateTime.now())}',
                  style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),

              // Таблица
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 10.5),
                cellStyle: pw.TextStyle(font: ttf, fontSize: 9.8),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Дата', 'Тариф 1 (ч)', 'Тариф 2 (ч)', 'Аванс', 'Итог'],
                data: entries.map((e) {
                  double earned = e.hours * (e.tariffType == 1 ? tariff1 : tariff2);
                  return [
                    DateFormat('dd.MM.yyyy').format(e.date),
                    e.tariffType == 1 ? e.hours.toStringAsFixed(1) : '-',
                    e.tariffType == 2 ? e.hours.toStringAsFixed(1) : '-',
                    e.advance > 0 ? e.advance.toStringAsFixed(0) : '-',
                    earned.toStringAsFixed(0),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 25),

              // Простой итог без рамки и без слова "ИТОГО"
              pw.Text(
                'Всего часов: ${entries.fold(0.0, (s, e) => s + e.hours).toStringAsFixed(1)}',
                style: pw.TextStyle(font: ttf, fontSize: 11),
              ),
              pw.Text(
                'Всего заработано: ${entries.fold(0.0, (s, e) => s + e.hours * (e.tariffType == 1 ? tariff1 : tariff2)).toStringAsFixed(0)} lei',
                style: pw.TextStyle(font: ttf, fontSize: 11),
              ),
              pw.Text(
                'Всего аванс: ${entries.fold(0.0, (s, e) => s + e.advance).toStringAsFixed(0)} lei',
                style: pw.TextStyle(font: ttf, fontSize: 11),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Остаток к оплате: ${entries.fold(0.0, (s, e) => s + e.hours * (e.tariffType == 1 ? tariff1 : tariff2) - e.advance).toStringAsFixed(0)} lei',
                style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = "зп_${DateFormat('yyyy-MM').format(DateTime.now())}.pdf";
      final file = File("${directory.path}/$fileName");

      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ PDF сохранён')),
      );

      await OpenFile.open(file.path);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отчёт')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf, size: 32),
          label: const Text('Экспорт в PDF', style: TextStyle(fontSize: 18)),
          onPressed: () => _exportToPDF(context),
        ),
      ),
    );
  }
}