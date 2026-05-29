import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  String fullName = "";
  double tariff1 = 0.0;
  double tariff2 = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Первоначальная настройка')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Введите ваши данные',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ФИО',
                  border: OutlineInputBorder(),
                  hintText: 'Фамилия Имя Отчество',
                ),
                onChanged: (value) => fullName = value,
              ),
              const SizedBox(height: 20),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Тариф 1 (lei/час)',
                  border: OutlineInputBorder(),
                  hintText: '',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => tariff1 = double.tryParse(value) ?? 0.0,
              ),
              const SizedBox(height: 20),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Тариф 2 (lei/час)',
                  border: OutlineInputBorder(),
                  hintText: '',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => tariff2 = double.tryParse(value) ?? 0.0,
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (fullName.trim().isEmpty || tariff1 <= 0 || tariff2 <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Пожалуйста, заполните все поля')),
                      );
                      return;
                    }

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('fullName', fullName.trim());
                    await prefs.setDouble('tariff1', tariff1);
                    await prefs.setDouble('tariff2', tariff2);
                    await prefs.setBool('isFirstLaunch', false);

                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    }
                  },
                  child: const Text('Сохранить и начать работу',
                      style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}