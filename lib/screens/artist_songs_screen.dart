import 'package:flutter/material.dart';
import '../services/song_service.dart';

// Убедитесь, что этот импорт на месте
import 'song_view_screen.dart';

class ArtistSongsScreen extends StatelessWidget {
  final String artist;
  final List<Song> allSongs;

  const ArtistSongsScreen({
    super.key,
    required this.artist,
    required this.allSongs,
  });

  @override
  Widget build(BuildContext context) {
    final List<Song> artistSongs = allSongs
        .where((song) => song.artist == artist)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(artist)),
      body: ListView.builder(
        itemCount: artistSongs.length,
        itemBuilder: (context, index) {
          // Здесь мы работаем с одной конкретной песней
          final song = artistSongs[index];
          return ListTile(
            title: Text(song.title),
            trailing: const Icon(Icons.music_note),

            // --- ЭТО КЛЮЧЕВОЙ МОМЕНТ ---
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongViewScreen(
                    // Передаем выбранную песню на следующий экран
                    song: song,
                  ),
                ),
              );
            },
            // -----------------------------
          );
        },
      ),
    );
  }
}
