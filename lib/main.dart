import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
        // Сделаем цвет для ExpansionTile таким же, как у всего остального
        dividerColor: Colors.transparent,
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

    // --- НОВАЯ СОРТИРОВКА ИЗБРАННОГО ---
    favSongs.sort(
      (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
    );

    setState(() {
      _allSongs = songs;
      _favoriteSongs = favSongs;
      _isLoading = false;
    });
  }

  // Функции импорта и экспорта остаются без изменений
  Future<void> _exportFavorites() async {
    // ... код экспорта ...
  }
  Future<void> _importFavorites() async {
    // ... код импорта ...
  }

  @override
  Widget build(BuildContext context) {
    final artists = _allSongs.map((s) => s.artist).toSet().toList();
    artists.sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Исполнители'),
        actions: [
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
              onRefresh: _loadAllData,
              child: ListView(
                // Заменяем SingleChildScrollView+Column на ListView для простоты
                children: [
                  // --- ОБНОВЛЕННАЯ СЕКЦИЯ "ИЗБРАННОЕ" В ВИДЕ ПАПКИ ---
                  if (_favoriteSongs.isNotEmpty)
                    ExpansionTile(
                      leading: const Icon(Icons.star),
                      title: Text(
                        'Избранное',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${_favoriteSongs.length} песен'),
                      // Кнопку экспорта можно вынести сюда
                      trailing: IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: _exportFavorites,
                        tooltip: 'Экспорт избранного',
                      ),
                      children: _favoriteSongs.map((song) {
                        return ListTile(
                          // Теперь название песни выглядит как "Исполнитель - Название"
                          title: Text("${song.artist} - ${song.title}"),
                          contentPadding: const EdgeInsets.only(
                            left: 30.0,
                            right: 16.0,
                          ), // Отступ для вложенности
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SongViewScreen(song: song),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                  // Разделитель между папкой и списком
                  if (_favoriteSongs.isNotEmpty) const Divider(),

                  // --- СПИСОК ИСПОЛНИТЕЛЕЙ (остаётся как был) ---
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
    );
  }
}

// Код функций _exportFavorites и _importFavorites нужно скопировать из предыдущего ответа
// и вставить на место комментариев, либо оставить как есть, если они у вас уже в коде.
