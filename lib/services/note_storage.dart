
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NoteStorage {
  static const String notesKey = 'saved_notes';

  // Save notes permanently
  static Future<void> saveNotes(
    List<Map<String, String>> notes,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Add default values for new features
    final updatedNotes = notes.map((note) {
      final updatedNote = Map<String, String>.from(note);

      updatedNote.putIfAbsent('isFavorite', () => 'false');
      updatedNote.putIfAbsent('createdAt', () => '');
      updatedNote.putIfAbsent('updatedAt', () => '');

      return updatedNote;
    }).toList();

    final encodedNotes = jsonEncode(updatedNotes);

    await prefs.setString(notesKey, encodedNotes);
  }

  // Load saved notes
  static Future<List<Map<String, String>>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(notesKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    final decodedNotes = jsonDecode(savedData);

    if (decodedNotes is! List) {
      throw const FormatException('Invalid saved notes format');
    }

    return decodedNotes.map((note) {
      final updatedNote = <String, String>{};

      if (note is Map) {
        note.forEach((key, value) {
          updatedNote[key.toString()] = value?.toString() ?? '';
        });
      }

      // Backward compatibility with existing notes
      updatedNote.putIfAbsent('isFavorite', () => 'false');
      updatedNote.putIfAbsent('createdAt', () => '');
      updatedNote.putIfAbsent('updatedAt', () => '');

      return updatedNote;
    }).toList();
  }
}
