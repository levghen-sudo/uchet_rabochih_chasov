import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry.dart';

class AddEntryScreen extends StatefulWidget {
  final WorkEntry? entryToEdit;

  const AddEntryScreen({super.key, this.entryToEdit});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  String fullName = "";
  DateTime selectedDate = DateTime.now();
  double hours = 8.0;
  int tariffType = 1;
  double advance = 0.0;
  String note = "";

  double tariff1 = 0.0;
  double tariff2 = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    if (widget.entryToEdit != null) {
      final e = widget.entryToEdit!;
      fullName = e.fullName;
      selectedDate = e.date;
      hours = e.hours;
      tariffType = e.tariffType;
      advance = e.advance;
      note = e.note ?? "";
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? "";
      tariff1 = prefs.getDouble('tariff1') ?? 0.0;
      tariff2 = prefs.getDouble('tariff2') ?? 0.0;
    });
  }

  void _saveEntry() async {
    if (tariff1 <= 0 || tariff2 <= 0) return;

    final box = Hive.box<WorkEntry>('work_entries');
    final existing = box.values.where((e) =>
    e.date.year == selectedDate.year &&
        e.date.month == selectedDate.month &&
        e.date.day == selectedDate.day).toList();

    final entry = WorkEntry(
      id: existing.isNotEmpty ? existing.first.id : const Uuid().v4(),
      fullName: fullName,
      date: selectedDate,
      hours: hours,
      tariffType: tariffType,
      advance: advance,
      note: note.isEmpty ? null : note,
    );

    if (existing.isNotEmpty) {
      existing.first.hours = hours;
      existing.first.tariffType = tariffType;
      existing.first.advance = advance;
      existing.first.note = note;
      await existing.first.save();
    } else {
      await box.add(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentTariff = tariffType == 1 ? tariff1 : tariff2;
    double earned = hours * currentTariff;

    return Scaffold(
      appBar: AppBar(title: const Text('Смена')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'ФИО', border: OutlineInputBorder()),
              controller: TextEditingController(text: fullName),
              onChanged: (value) {
                fullName = value;
                _saveEntry();
              },
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('Дата'),
              subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2027),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                  _saveEntry();
                }
              },
            ),

            TextField(
              decoration: const InputDecoration(labelText: 'Часы', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: TextEditingController(text: hours.toStringAsFixed(1)),
              onChanged: (value) {
                hours = double.tryParse(value) ?? 0;
                _saveEntry();
              },
            ),

            const SizedBox(height: 20),
            const Text('Тариф', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('Тариф 1 — $tariff1 lei'),
                    selected: tariffType == 1,
                    onSelected: (val) {
                      setState(() => tariffType = 1);
                      _saveEntry();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: Text('Тариф 2 — $tariff2 lei'),
                    selected: tariffType == 2,
                    onSelected: (val) {
                      setState(() => tariffType = 2);
                      _saveEntry();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Аванс (lei)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: advance.toStringAsFixed(0)),
              onChanged: (value) {
                advance = double.tryParse(value) ?? 0;
                _saveEntry();
              },
            ),

            TextField(
              decoration: const InputDecoration(labelText: 'Примечание', border: OutlineInputBorder()),
              onChanged: (value) {
                note = value;
                _saveEntry();
              },
            ),

            const SizedBox(height: 30),
            Card(
              color: Colors.green.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Итого: ${earned.toStringAsFixed(0)} lei',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}