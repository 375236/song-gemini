import 'package:shared_preferences/shared_preferences.dart';
import 'song_service.dart'; // Нам нужна модель Song

class FavoritesService {
  // Ключ, под которым мы будем хранить список в "записной книжке" телефона
  static const _favoritesKey = 'favorite_songs';

  // Вспомогательная функция для генерации уникального ID для песни
  String _getSongId(Song song) {
    return "${song.artist} --- ${song.title}";
  }

  // Получить список ID всех избранных песен
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Проверить, является ли песня избранной
  Future<bool> isFavorite(Song song) async {
    final ids = await getFavoriteIds();
    return ids.contains(_getSongId(song));
  }

  // Добавить/Удалить песню из избранного
  Future<void> toggleFavorite(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getFavoriteIds();
    final songId = _getSongId(song);

    if (ids.contains(songId)) {
      ids.remove(songId); // Если уже в избранном - удаляем
    } else {
      ids.add(songId); // Если нет - добавляем
    }

    // Сохраняем обновленный список обратно в хранилище
    await prefs.setStringList(_favoritesKey, ids);
  }
}
