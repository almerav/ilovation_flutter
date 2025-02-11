import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final List<String> _eventTypes = ['Venue', 'Online', 'Hybrid'];
  String? _selectedEventType;
  String? _selectedCategory;
  File? _selectedImage;
  String? _base64Image;

  Map<String, List<String>> _categories = {
    'Venue': ['Conference', 'Workshop'],
    'Online': ['Webinar', 'Live Stream'],
    'Hybrid': ['Webinar', 'Workshop'],
  };

  /// **📅 Date-Time Picker**
  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          controller.text = '${pickedDate.year}-${pickedDate.month}-${pickedDate.day} ${pickedTime.format(context)}';
        });
      }
    }
  }

  /// **📷 Pick Image from Gallery**
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Image = base64Encode(bytes); // ✅ Convert image to Base64
      });
    }
  }

  /// **📤 Submit Event to API**
  Future<void> _submitEvent() async {
    if (_titleController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty ||
        _selectedEventType == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';

    final eventData = {
      "title": _titleController.text,
      "email": _emailController.text,
      "description": _descriptionController.text,
      "location": _locationController.text,
      "start_datetime": _startTimeController.text,
      "end_datetime": _endTimeController.text,
      "event_type": _selectedEventType,
      "category": _selectedCategory,
      "image_url": _base64Image ?? "", // ✅ Send image as Base64
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(eventData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event successfully created!'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error connecting to server'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// **🧹 Clear Form Fields**
  void _clearForm() {
    _titleController.clear();
    _emailController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    setState(() {
      _selectedEventType = null;
      _selectedCategory = null;
      _selectedImage = null;
      _base64Image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              /// **Dropdown for Event Type**
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                items: _eventTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEventType = newValue;
                    _selectedCategory = null;
                  });
                },
              ),
              const SizedBox(height: 10),

              /// **Dropdown for Category**
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _selectedEventType == null
                    ? []
                    : _categories[_selectedEventType]!.map((String subType) {
                        return DropdownMenuItem<String>(
                          value: subType,
                          child: Text(subType),
                        );
                      }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 10),

              /// **Start Time Field**
              TextField(
                controller: _startTimeController,
                decoration: const InputDecoration(labelText: 'Start Time', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectDateTime(context, _startTimeController),
              ),
              const SizedBox(height: 10),

              /// **End Time Field**
              TextField(
                controller: _endTimeController,
                decoration: const InputDecoration(labelText: 'End Time', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectDateTime(context, _endTimeController),
              ),
              const SizedBox(height: 20),

              /// **Upload Image**
              Center(
                child: Column(
                  children: [
                    ElevatedButton(onPressed: pickImage, child: const Text('Upload Image')),
                    _selectedImage == null
                        ? const Text("No image uploaded")
                        : Image.memory(base64Decode(_base64Image!), height: 150),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// **Submit Button**
              Center(
                child: ElevatedButton(onPressed: _submitEvent, child: const Text('Submit Event')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
