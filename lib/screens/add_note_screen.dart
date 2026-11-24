
import 'package:flutter/material.dart';

class AddNoteScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final String? initialCategory;

  const AddNoteScreen({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialCategory,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late String selectedCategory;

  static const Color primaryColor = Color(0xFF673AB7);

  final List<String> categories = [
    'Personal Info',
    'Professional',
    'Education',
    'Ideas',
    'Tasks',
    'General',
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.initialTitle ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );

    selectedCategory = categories.contains(widget.initialCategory)
        ? widget.initialCategory!
        : 'General';
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

  // Save or update note
  void saveNote() {
    String title = titleController.text.trim();
    String description = descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a note title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'title': title,
      'description': description,
      'category': selectedCategory,
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialTitle != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Note' : 'Create Note',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        backgroundColor: const Color(0xFFF8F7FC),
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
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
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.edit_note,
                      color: Colors.white,
                      size: 42,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      isEditing
                          ? 'Update your thoughts'
                          : 'Capture your thoughts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Organize your ideas in the right category.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Title
              const Text(
                'Note Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,

                decoration: InputDecoration(
                  hintText: 'Enter your note title',
                  prefixIcon: const Icon(
                    Icons.title,
                    color: primaryColor,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(18),

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

              const SizedBox(height: 25),

              // Category
              const Text(
                'Select Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 10),

              
DropdownButtonFormField<String>(
  value: selectedCategory,
  isExpanded: true,

  decoration: InputDecoration(
    prefixIcon: const Icon(
      Icons.category_outlined,
      color: primaryColor,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(16),

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

  items: categories.map((category) {
    return DropdownMenuItem<String>(
      value: category,
      child: Row(
        children: [
          Icon(
            getCategoryIcon(category),
            color: primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(category),
        ],
      ),
    );
  }).toList(),

  onChanged: (value) {
    if (value != null) {
      setState(() {
        selectedCategory = value;
      });
    }
  },
),


              const SizedBox(height: 25),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: descriptionController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 8,
                maxLines: 12,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,

                decoration: InputDecoration(
                  hintText: 'Write your thoughts here...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(18),

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

              const SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: saveNote,

                  icon: Icon(
                    isEditing ? Icons.save : Icons.add,
                    color: Colors.white,
                  ),

                  label: Text(
                    isEditing ? 'Update Note' : 'Save Note',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
