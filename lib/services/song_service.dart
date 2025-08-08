import 'dart:convert'; // Импортируем встроенный кодировщик/декодировщик JSON
import 'package:http/http.dart' as http;

// Модель Song остаётся без изменений
class Song {
  final String artist;
  final String title;
  final String textWithChords;

  Song({
    required this.artist,
    required this.title,
    required this.textWithChords,
  });
}

class SongService {
  // 1. Используем URL для API, который вы нашли
  final String gistApiUrl =
      'https://api.github.com/gists/b68947f892a72d3c316dea326cc90ac6';

  // --- ФИНАЛЬНЫЙ, САМЫЙ ПРОСТОЙ И НАДЁЖНЫЙ МЕТОД ---
  Future<List<Song>> fetchSongs() async {
    final List<Song> allSongs = [];
    try {
      // 2. Делаем запрос к API
      final response = await http.get(Uri.parse(gistApiUrl));
      if (response.statusCode != 200) {
        throw Exception('Не удалось загрузить данные из Gist API');
      }

      // 3. Декодируем полученную строку JSON в объект Dart
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      // 4. Получаем доступ к объекту 'files'
      final files = jsonData['files'] as Map<String, dynamic>;

      // 5. Проходим по каждому файлу в Gist
      for (final fileData in files.values) {
        final filename = fileData['filename'] as String;
        final content = fileData['content'] as String;

        // 6. Парсим исполнителя и название прямо из имени файла
        // Удаляем расширение ".txt"
        final cleanFilename = filename.replaceAll(RegExp(r'\.txt$'), '');
        final parts = cleanFilename.split(' - ');

        if (parts.length >= 2) {
          final artist = parts[0].trim();
          final title = parts.sublist(1).join(' - ').trim();

          // 7. Создаем песню и добавляем в список
          allSongs.add(
            Song(
              artist: artist,
              title: title,
              textWithChords: content, // Текст берём напрямую!
            ),
          );
        }
      }
    } catch (e) {
      print('Ошибка при работе с Gist API: $e');
    }

    return allSongs;
  }
}
