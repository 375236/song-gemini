import 'package:flutter/material.dart';
import '../services/song_service.dart';
import '../services/favorites_service.dart'; // Импортируем новый сервис
import 'song_view_screen.dart';

class ArtistSongsScreen extends StatefulWidget {
  final String artist;
  final List<Song> allSongs;

  const ArtistSongsScreen({
    super.key,
    required this.artist,
    required this.allSongs,
  });

  @override
  State<ArtistSongsScreen> createState() => _ArtistSongsScreenState();
}

class _ArtistSongsScreenState extends State<ArtistSongsScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  // Список, чтобы хранить, какие песни на этом экране избраны
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Загружаем текущий список избранных
  void _loadFavorites() async {
    final ids = await _favoritesService.getFavoriteIds();
    setState(() {
      _favoriteIds = ids.toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Song> artistSongs = widget.allSongs
        .where((song) => song.artist == widget.artist)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.artist)),
      body: ListView.builder(
        itemCount: artistSongs.length,
        itemBuilder: (context, index) {
          final song = artistSongs[index];
          final songId = "${song.artist} --- ${song.title}";
          final isFav = _favoriteIds.contains(songId);

          return ListTile(
            title: Text(song.title),
            trailing: IconButton(
              icon: Icon(
                isFav ? Icons.star : Icons.star_border,
                color: isFav ? Colors.amber : Colors.grey,
              ),
              onPressed: () async {
                // При нажатии меняем статус
                await _favoritesService.toggleFavorite(song);
                // И обновляем список избранных на этом экране
                _loadFavorites();
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongViewScreen(song: song),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
