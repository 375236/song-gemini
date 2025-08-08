import 'package:flutter/material.dart';
import '../services/song_service.dart';

class SongViewScreen extends StatelessWidget {
  final Song song;

  const SongViewScreen({super.key, required this.song});

  // Эта функция определяет, является ли строка строкой с аккордами
  bool _isChordLine(String line) {
    if (line.trim().isEmpty) return false;

    // Этот паттерн ищет строки, которые похожи на аккорды
    final chordPattern = RegExp(
      r'^[A-G][#b]?(m|maj|min|dim|aug|sus|add)?[0-9]?\s*',
    );

    // Дополнительная проверка: в строке с аккордами почти нет строчных букв
    final lowerCaseLetters = line.replaceAll(RegExp(r'[^a-z]'), '').length;
    final upperCaseLetters = line.replaceAll(RegExp(r'[^A-Z]'), '').length;

    // Считаем строкой аккордов, если она подходит под паттерн
    // и в ней мало или совсем нет строчных букв
    return chordPattern.hasMatch(line.trim()) &&
        (lowerCaseLetters < 2 || lowerCaseLetters < upperCaseLetters);
  }

  @override
  Widget build(BuildContext context) {
    // --- ДОБАВЬТЕ ЭТИ СТРОКИ ДЛЯ ОТЛАДКИ ---
    print("--- Отладка Экрана Песни ---");
    print("Название: ${song.title}");
    print("Текст с аккордами: [${song.textWithChords}]");
    // -----------------------------------------
    final lines = song.textWithChords.split('\n');

    return Scaffold(
      appBar: AppBar(title: Text(song.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Растягиваем строки по ширине
          children: lines.map((line) {
            final isChord = _isChordLine(line);
            return Text(
              line,
              style: TextStyle(
                fontFamily:
                    'RobotoMono', // Используем моноширинный шрифт для аккордов
                fontWeight: isChord ? FontWeight.bold : FontWeight.normal,
                color: isChord ? Theme.of(context).primaryColor : Colors.black,
                fontSize: 15,
                height: 1.3, // Межстрочный интервал
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
