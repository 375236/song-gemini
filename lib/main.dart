import 'dart:convert'; // Для работы с JSON
import 'dart:io'; // Для работы с файлами

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Импорты новых плагинов
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/song_service.dart';
import 'services/favorites_service.dart';
import 'screens/artist_songs_screen.dart';
import 'screens/song_view_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мой песенник',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ArtistsScreen(),
    );
  }
}

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  final SongService _songService = SongService();
  final FavoritesService _favoritesService = FavoritesService();

  List<Song> _allSongs = [];
  List<Song> _favoriteSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    final songs = await _songService.fetchSongs();
    final favoriteIds = await _favoritesService.getFavoriteIds();

    final favSongs = songs.where((song) {
      final songId = "${song.artist} --- ${song.title}";
      return favoriteIds.contains(songId);
    }).toList();

    setState(() {
      _allSongs = songs;
      _favoriteSongs = favSongs;
      _isLoading = false;
    });
  }

  // --- НОВАЯ ФУНКЦИЯ ЭКСПОРТА ---
  Future<void> _exportFavorites() async {
    final favoriteIds = await _favoritesService.getFavoriteIds();
    if (favoriteIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет избранных песен для экспорта.')),
      );
      return;
    }

    // Превращаем список ID в красивый JSON-текст
    final jsonString = jsonEncode(favoriteIds);
    // Находим временную папку, куда можно сохранить файл
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/favorites_backup.json');

    // Записываем наш JSON в файл
    await file.writeAsString(jsonString);

    // Вызываем системное окно "Поделиться"
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Мои избранные песни',
      subject: 'Бэкап избранных песен',
    );
  }

  // --- НОВАЯ ФУНКЦИЯ ИМПОРТА ---
  Future<void> _importFavorites() async {
    // Открываем файловый менеджер для выбора .json файла
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      try {
        // Декодируем JSON и проверяем, что это список строк
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        final importedIds = decoded.cast<String>().toList();

        // Полностью заменяем текущее избранное на импортированное
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('favorite_songs', importedIds);

        // Обновляем UI
        await _loadAllData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Избранное успешно импортировано!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: Неверный формат файла. $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final artists = _allSongs.map((s) => s.artist).toSet().toList();
    artists.sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Исполнители'),
        actions: [
          // --- КНОПКА ИМПОРТА ---
          IconButton(
            onPressed: _importFavorites,
            icon: const Icon(Icons.file_upload),
            tooltip: 'Импорт избранного',
          ),
          IconButton(
            onPressed: _loadAllData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить песни',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Добавим обновление списка по свайпу вниз
              onRefresh: _loadAllData,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Чтобы свайп работал всегда
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_favoriteSongs.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '⭐ Избранное',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // --- КНОПКА ЭКСПОРТА ---
                            IconButton(
                              onPressed: _exportFavorites,
                              icon: const Icon(Icons.share),
                              tooltip: 'Экспорт избранного',
                            ),
                          ],
                        ),
                      ),
                      ..._favoriteSongs.map(
                        (song) => ListTile(
                          title: Text(song.title),
                          subtitle: Text(song.artist),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongViewScreen(song: song),
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
                    ...artists.map(
                      (artist) => ListTile(
                        title: Text(artist),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistSongsScreen(
                                artist: artist,
                                allSongs: _allSongs,
                              ),
                            ),
                          );
                          _loadAllData();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
