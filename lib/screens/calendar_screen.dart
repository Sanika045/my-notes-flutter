
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/event_storage.dart';
import '../services/notification_service.dart';
import 'add_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  List<Map<String, dynamic>> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final savedEvents = await EventStorage.getEvents();

    if (!mounted) return;

    setState(() {
      events = savedEvents;
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return events.where((event) {
      final eventDate = DateTime.parse(event['dateTime']);

      return isSameDay(eventDate, day);
    }).toList();
  }

  Future<void> addNewEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEventScreen(),
      ),
    );

    if (result == true) {
      await loadEvents();
    }
  }

  Future<void> deleteEvent(Map<String, dynamic> event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text('Delete "${event['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (event['reminderEnabled'] == true) {
      await NotificationService.cancelReminder(
        event['notificationId'] as int,
      );
    }

    await EventStorage.deleteEvent(event['id'].toString());

    await loadEvents();
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = getEventsForDay(selectedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),

      appBar: AppBar(
        title: const Text('My Calendar'),
        backgroundColor: const Color(0xFF8B78C8),
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNewEvent,
        backgroundColor: const Color(0xFF8B78C8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(12),
                  child: TableCalendar<Map<String, dynamic>>(
                    firstDay: DateTime.now(),
                    lastDay: DateTime(2100),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDay, day);
                    },
                    eventLoader: getEventsForDay,
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,

                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDay = selected;
                        focusedDay = focused;
                      });
                    },

                    onPageChanged: (focused) {
                      focusedDay = focused;
                    },

                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Color(0xFFB9A8E8),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF8B78C8),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                    ),

                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Events on ${formatDate(selectedDay)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: selectedEvents.isEmpty
                      ? const Center(
                          child: Text(
                            'No events on this date.\nTap + to add an event!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: 90,
                          ),
                          itemCount: selectedEvents.length,
                          itemBuilder: (context, index) {
                            final event = selectedEvents[index];
                            final eventDate =
                                DateTime.parse(event['dateTime']);

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFEAE3FA),
                                  child: Icon(
                                    Icons.event,
                                    color: Color(0xFF8B78C8),
                                  ),
                                ),

                                title: Text(
                                  event['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if ((event['description'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      Text(event['description']),

                                    const SizedBox(height: 5),

                                    Text(
                                      formatTime(eventDate),
                                      style: const TextStyle(
                                        color: Color(0xFF8B78C8),
                                      ),
                                    ),

                                    if (event['reminderEnabled'] == true)
                                      const Text('🔔 Reminder enabled'),
                                  ],
                                ),

                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteEvent(event),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
