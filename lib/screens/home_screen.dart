import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_entry.dart';
import 'add_entry_screen.dart';
import 'report_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box<WorkEntry> box = Hive.box<WorkEntry>('work_entries');
  DateTime selectedMonth = DateTime.now();

  String fullName = "Не указано";
  double tariff1 = 0.0;
  double tariff2 = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? "Не указано";
      tariff1 = prefs.getDouble('tariff1') ?? 0.0;
      tariff2 = prefs.getDouble('tariff2') ?? 0.0;
    });
  }

  void _changeMonth(int months) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + months);
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = box.values.where((e) =>
    e.date.year == selectedMonth.year &&
        e.date.month == selectedMonth.month).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    double totalHours = 0;
    double totalEarned = 0;
    double totalAdvance = 0;

    for (var entry in entries) {
      double rate = entry.tariffType == 1 ? tariff1 : tariff2;
      totalHours += entry.hours;
      totalEarned += entry.hours * rate;
      totalAdvance += entry.advance;
    }

    double balance = totalEarned - totalAdvance;
    String monthTitle = DateFormat('MMMM yyyy', 'ru').format(selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Учёт Рабочих Часов'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_left, size: 32), onPressed: () => _changeMonth(-1)),
                    Text(monthTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.arrow_right, size: 32), onPressed: () => _changeMonth(1)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Баланс к выплате — $monthTitle', style: const TextStyle(fontSize: 18)),
                    Text('${balance.toStringAsFixed(0)} lei',
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: balance >= 0 ? Colors.green : Colors.red)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [Text(totalHours.toStringAsFixed(1), style: const TextStyle(fontSize: 22)), const Text('Часов')]),
                        Column(children: [Text('${totalEarned.toStringAsFixed(0)} lei', style: const TextStyle(fontSize: 22)), const Text('Заработано')]),
                        Column(children: [Text('${totalAdvance.toStringAsFixed(0)} lei', style: const TextStyle(fontSize: 22)), const Text('Аванс')]),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text('Смены', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('В этом месяце нет смен'))
                  : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  double earned = entry.hours * (entry.tariffType == 1 ? tariff1 : tariff2);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text('${entry.date.day.toString().padLeft(2, '0')}.${entry.date.month.toString().padLeft(2, '0')}'),
                          const SizedBox(width: 12),
                          Text('${entry.hours} ч'),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(entry.tariffType == 1 ? 'Тариф 1' : 'Тариф 2',
                              style: TextStyle(color: entry.tariffType == 2 ? Colors.yellow : Colors.white)),
                          if (entry.advance > 0)
                            Text(' • Аванс ${entry.advance.toStringAsFixed(0)} lei', style: const TextStyle(color: Colors.orange)),
                        ],
                      ),
                      trailing: Text('${earned.toStringAsFixed(0)} lei', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEntryScreen(entryToEdit: entry)))
                          .then((_) => setState(() {})),
                      onLongPress: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Удалить смену?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                            TextButton(
                              onPressed: () {
                                entry.delete();
                                Navigator.pop(context);
                                setState(() {});
                              },
                              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEntryScreen()))
            .then((_) => setState(() {})),
        child: const Icon(Icons.add),
      ),
    );
  }
}