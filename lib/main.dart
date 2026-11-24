
import 'package:flutter/material.dart';
import 'screens/add_note_screen.dart';
import 'services/note_storage.dart';
import 'screens/calendar_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Personal Organizer',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> notes = [];

  final TextEditingController searchController =
      TextEditingController();

  final List<String> categories = [
    'Personal Info',
    'Professional',
    'Education',
    'Ideas',
    'Tasks',
    'General',
  ];

  String selectedCategoryFilter = 'All';
  bool isLoading = true;
  bool showFavoritesOnly = false;

  static const Color primaryColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFF8F7FC);

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  // Load notes and preserve older notes
  Future<void> loadNotes() async {
    try {
      final savedNotes = await NoteStorage.loadNotes();

      for (final note in savedNotes) {
        note.putIfAbsent('category', () => 'General');
        note.putIfAbsent('isFavorite', () => 'false');
        note.putIfAbsent('createdAt', () => '');
        note.putIfAbsent('updatedAt', () => '');
      }

      if (!mounted) return;

      setState(() {
        notes = savedNotes;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading notes: $error');

      if (!mounted) return;

      setState(() {
        notes = [];
        isLoading = false;
      });
    }
  }

  // Save notes permanently
  Future<void> saveNotes() async {
    await NoteStorage.saveNotes(notes);
  }

  // Add new note
  Future<void> addNote() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNoteScreen(),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      final now = DateTime.now().toIso8601String();

      final newNote = <String, String>{
        'title': result['title'] ?? '',
        'description': result['description'] ?? '',
        'category': result['category'] ?? 'General',
        'isFavorite': 'false',
        'createdAt': now,
        'updatedAt': now,
      };

      setState(() {
        notes.insert(0, newNote);
      });

      await saveNotes();
    }
  }

  // Edit existing note
  Future<void> editNote(int index) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          initialTitle: notes[index]['title'],
          initialDescription: notes[index]['description'],
          initialCategory: notes[index]['category'] ?? 'General',
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      final oldNote = notes[index];

      final updatedNote = Map<String, String>.from(oldNote);

      updatedNote['title'] = result['title'] ?? '';
      updatedNote['description'] = result['description'] ?? '';
      updatedNote['category'] =
          result['category'] ?? 'General';

      updatedNote['isFavorite'] =
          oldNote['isFavorite'] ?? 'false';

      updatedNote['createdAt'] =
          oldNote['createdAt'] ?? '';

      updatedNote['updatedAt'] =
          DateTime.now().toIso8601String();

      setState(() {
        notes[index] = updatedNote;
      });

      await saveNotes();
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(int index) async {
    final currentlyFavorite =
        notes[index]['isFavorite'] == 'true';

    setState(() {
      notes[index]['isFavorite'] =
          (!currentlyFavorite).toString();
    });

    await saveNotes();
  }

  // Delete note
  Future<void> deleteNote(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text(
          'Are you sure you want to delete this note?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      setState(() {
        notes.removeAt(index);
      });

      await saveNotes();
    }
  }

  // Category icons
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Personal Info':
        return Icons.person_outline;
      case 'Professional':
        return Icons.work_outline;
      case 'Education':
        return Icons.school_outlined;
      case 'Ideas':
        return Icons.lightbulb_outline;
      case 'Tasks':
        return Icons.check_circle_outline;
      default:
        return Icons.folder_outlined;
    }
  }

  // Category colors
  Color getCategoryColor(String category) {
    switch (category) {
      case 'Personal Info':
        return Colors.pink.shade50;
      case 'Professional':
        return Colors.blue.shade50;
      case 'Education':
        return Colors.orange.shade50;
      case 'Ideas':
        return Colors.amber.shade50;
      case 'Tasks':
        return Colors.green.shade50;
      default:
        return Colors.deepPurple.shade50;
    }
  }

  // Format date
  String formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date not recorded';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr',
        'May', 'Jun', 'Jul', 'Aug',
        'Sep', 'Oct', 'Nov', 'Dec',
      ];

      final day = date.day.toString().padLeft(2, '0');

      final hour = date.hour % 12 == 0
          ? 12
          : date.hour % 12;

      final minute =
          date.minute.toString().padLeft(2, '0');

      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$day ${months[date.month - 1]} '
          '${date.year}, $hour:$minute $period';
    } catch (_) {
      return 'Date not recorded';
    }
  }

  // Category count
  int categoryCount(String category) {
    return notes.where(
      (note) => (note['category'] ?? 'General') == category,
    ).length;
  }

  // Category card
  Widget buildCategoryCard(String category) {
    final count = categoryCount(category);

    final isSelected = selectedCategoryFilter == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryFilter =
              isSelected ? 'All' : category;
        });
      },
      child: Container(
        width: 135,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : Colors.deepPurple.shade100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              getCategoryIcon(category),
              color: isSelected
                  ? Colors.white
                  : primaryColor,
              size: 25,
            ),
            const SizedBox(height: 9),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF333044),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count notes',
              style: TextStyle(
                color: isSelected
                    ? Colors.white70
                    : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Note card
  Widget buildNoteCard(
    Map<String, String> note,
    int originalIndex,
  ) {
    final isFavorite = note['isFavorite'] == 'true';

    final category = note['category'] ?? 'General';

    final createdAt = note['createdAt'] ?? '';
    final updatedAt = note['updatedAt'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      // Material prevents ListTile ink splash errors
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        clipBehavior: Clip.antiAlias,

        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),

          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: getCategoryColor(category),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              getCategoryIcon(category),
              color: primaryColor,
              size: 25,
            ),
          ),

          title: Text(
            note['title'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF333044),
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 9),

                // Category label
                Row(
                  children: [
                    Icon(
                      getCategoryIcon(category),
                      size: 13,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                // Created date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.deepPurple.shade300,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Created: ${formatDate(createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                if (updatedAt.isNotEmpty &&
                    updatedAt != createdAt) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.update,
                        size: 12,
                        color: Colors.deepPurple.shade300,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Updated: ${formatDate(updatedAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Favorite and menu
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                padding: EdgeInsets.zero,
                onPressed: () {
                  toggleFavorite(originalIndex);
                },
                icon: Icon(
                  isFavorite
                      ? Icons.star
                      : Icons.star_border,
                  color: isFavorite
                      ? Colors.amber.shade700
                      : Colors.grey,
                  size: 22,
                ),
              ),

              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert,
                  color: primaryColor,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    editNote(originalIndex);
                  } else if (value == 'delete') {
                    deleteNote(originalIndex);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          onTap: () {
            editNote(originalIndex);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.toLowerCase().trim();

    // Apply search, category and favorite filters
    final filteredNotes = notes.asMap().entries.where((entry) {
      final note = entry.value;

      final title =
          (note['title'] ?? '').toLowerCase();

      final description =
          (note['description'] ?? '').toLowerCase();

      final matchesSearch =
          title.contains(query) ||
          description.contains(query);

      final matchesCategory =
          selectedCategoryFilter == 'All' ||
          (note['category'] ?? 'General') ==
              selectedCategoryFilter;

      final matchesFavorite =
          !showFavoritesOnly ||
          note['isFavorite'] == 'true';

      return matchesSearch &&
          matchesCategory &&
          matchesFavorite;
    }).toList();

    final favoriteCount = notes.where(
      (note) => note['isFavorite'] == 'true',
    ).length;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: primaryColor,
              size: 27,
            ),
            SizedBox(width: 10),
            Text(
              'My Organizer',
              style: TextStyle(
                color: Color(0xFF333044),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_rounded,
              color: primaryColor,
              size: 28,
            ),
            tooltip: 'My Calendar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Welcome card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF673AB7),
                            Color(0xFF9575CD),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.dashboard_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Your Life, Organized!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'Keep your personal and professional '
                            'life organized.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 17),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              countBadge(
                                Icons.notes,
                                '${notes.length} Notes',
                              ),
                              countBadge(
                                Icons.star,
                                '$favoriteCount Favorites',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Category heading
                    const Text(
                      'My Sections',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333044),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Category cards
                    SizedBox(
                      height: 105,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return buildCategoryCard(
                            categories[index],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Your Notes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333044),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Search bar
                    TextField(
                      controller: searchController,
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Search your notes...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: primaryColor,
                        ),
                        suffixIcon:
                            searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.deepPurple.shade100,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // All and Favorites filters
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('All Notes'),
                          avatar: const Icon(
                            Icons.notes,
                            size: 17,
                          ),
                          selected: !showFavoritesOnly,
                          selectedColor: const Color(0xFFE6DDF5),
                          onSelected: (_) {
                            setState(() {
                              showFavoritesOnly = false;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Favorites'),
                          avatar: const Icon(
                            Icons.star,
                            size: 17,
                          ),
                          selected: showFavoritesOnly,
                          selectedColor: const Color(0xFFFFE8AE),
                          onSelected: (_) {
                            setState(() {
                              showFavoritesOnly = true;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Notes list
                    Expanded(
                      child: notes.isEmpty
                          ? buildEmptyState(
                              'No notes yet!',
                              'Tap + to create your first note.',
                              Icons.note_add_rounded,
                            )
                          : filteredNotes.isEmpty
                              ? buildEmptyState(
                                  'No matching notes',
                                  'Try another category or search term.',
                                  Icons.search_off_rounded,
                                )
                              : ListView.builder(
                                  itemCount: filteredNotes.length,
                                  itemBuilder: (context, index) {
                                    final entry = filteredNotes[index];

                                    return buildNoteCard(
                                      entry.value,
                                      entry.key,
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),

      // Add note button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNote,
        backgroundColor: primaryColor,
        elevation: 4,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Add Note',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // Count badge
  Widget countBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Empty state
  Widget buildEmptyState(
    String title,
    String message,
    IconData icon,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: Colors.deepPurple.shade200,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333044),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
