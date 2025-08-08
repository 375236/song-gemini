import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; // 1. Импортируем плагин
import '../services/song_service.dart';

// 2. Превращаем в StatefulWidget
class SongViewScreen extends StatefulWidget {
  final Song song;

  const SongViewScreen({super.key, required this.song});

  @override
  State<SongViewScreen> createState() => _SongViewScreenState();
}

class _SongViewScreenState extends State<SongViewScreen> {
  @override
  void initState() {
    super.initState();
    // 3. ВКЛЮЧАЕМ режим "не спать" при открытии экрана
    WakelockPlus.enable();
    print("Wakelock enabled");
  }

  @override
  void dispose() {
    // 4. ВЫКЛЮЧАЕМ режим "не спать" при закрытии экрана
    WakelockPlus.disable();
    print("Wakelock disabled");
    super.dispose();
  }

  // --- Весь остальной код остаётся без изменений ---

  bool _isChordLine(String line) {
    if (line.trim().isEmpty) return false;
    final chordPattern = RegExp(
      r'^[A-G][#b]?(m|maj|min|dim|aug|sus|add)?[0-9]?\s*',
    );
    final lowerCaseLetters = line.replaceAll(RegExp(r'[^a-z]'), '').length;
    final upperCaseLetters = line.replaceAll(RegExp(r'[^A-Z]'), '').length;
    return chordPattern.hasMatch(line.trim()) &&
        (lowerCaseLetters < 2 || lowerCaseLetters < upperCaseLetters);
  }

  @override
  Widget build(BuildContext context) {
    // Используем widget.song, чтобы получить доступ к песне из StatefulWidget
    final lines = widget.song.textWithChords.split('\n');

    return Scaffold(
      appBar: AppBar(title: Text(widget.song.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: lines.map((line) {
            final isChord = _isChordLine(line);
            return Text(
              line,
              style: TextStyle(
                fontWeight: isChord ? FontWeight.bold : FontWeight.normal,
                color: isChord ? Theme.of(context).primaryColor : Colors.black,
                fontSize: 15,
                height: 1.3,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
