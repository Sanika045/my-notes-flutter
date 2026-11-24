
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EventStorage {
  static const String _eventsKey = 'saved_events';

  static Future<List<Map<String, dynamic>>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_eventsKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData.map((event) {
      return Map<String, dynamic>.from(event);
    }).toList();
  }

  static Future<void> saveEvents(
      List<Map<String, dynamic>> events) async {
    final prefs = await SharedPreferences.getInstance();

    final String encodedData = jsonEncode(events);

    await prefs.setString(_eventsKey, encodedData);
  }

  static Future<void> addEvent(
      Map<String, dynamic> newEvent) async {
    final events = await getEvents();

    events.add(newEvent);

    await saveEvents(events);
  }

  static Future<void> deleteEvent(String eventId) async {
    final events = await getEvents();

    events.removeWhere((event) => event['id'] == eventId);

    await saveEvents(events);
  }
}
