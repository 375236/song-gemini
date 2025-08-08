import 'package:flutter/material.dart';
import 'services/song_service.dart';
import 'screens/artist_songs_screen.dart';

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
  late Future<List<Song>> futureSongs;

  @override
  void initState() {
    super.initState();
    futureSongs = SongService().fetchSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Исполнители')),
      body: FutureBuilder<List<Song>>(
        future: futureSongs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final songs = snapshot.data!;
            final artists = songs.map((s) => s.artist).toSet().toList();
            artists.sort();

            // ПРАВИЛЬНЫЙ ListView.builder для этого экрана
            return ListView.builder(
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                return ListTile(
                  title: Text(artist),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArtistSongsScreen(artist: artist, allSongs: songs),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('Ничего не найдено.'));
        },
      ),
    );
  }
}
