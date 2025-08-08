import 'package:flutter/material.dart';
import 'services/song_service.dart';
import 'services/favorites_service.dart'; // Импортируем сервис
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

  // Метод, который загружает ВСЕ данные
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

  @override
  Widget build(BuildContext context) {
    final artists = _allSongs.map((s) => s.artist).toSet().toList();
    artists.sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Исполнители'),
        // Кнопка для ручного обновления списка
        actions: [
          IconButton(onPressed: _loadAllData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- СЕКЦИЯ "ИЗБРАННОЕ" ---
                  if (_favoriteSongs.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '⭐ Избранное',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                  // ------------------------

                  // --- СПИСОК ИСПОЛНИТЕЛЕЙ ---
                  ...artists.map(
                    (artist) => ListTile(
                      title: Text(artist),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        // Эта конструкция дождется возвращения с экрана
                        // и перезагрузит данные, чтобы обновить избранное
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
                  // ---------------------------
                ],
              ),
            ),
    );
  }
}
