import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final List<String> _eventTypes = ['Venue', 'Online', 'Hybrid'];
  String? _selectedEventType;
  String? _selectedCategory;

  Map<String, List<String>> _categories = {
    'Venue': ['Conference', 'Workshop'],
    'Online': ['Webinar', 'Live Stream'],
    'Hybrid': ['Webinar', 'Workshop'],
  };

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
          controller.text = '${pickedDate.toLocal()}'.split(' ')[0] + ' ' + pickedTime.format(context);
        });
      }
    }
  }

  Future<void> _submitEvent() async {
    if (_nameController.text.isEmpty ||
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

    final eventData = {
      "name": _nameController.text,
      "description": _descriptionController.text,
      "location": _locationController.text,
      "start_time": _startTimeController.text,
      "end_time": _endTimeController.text,
      "event_type": _selectedEventType,
      "category": _selectedCategory
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/events'),
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
          const SnackBar(
            content: Text('Failed to create event'),
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

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    setState(() {
      _selectedEventType = null;
      _selectedCategory = null;
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
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name', border: OutlineInputBorder()),
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
              TextField(
                controller: _startTimeController,
                decoration: const InputDecoration(labelText: 'Start Time', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectDateTime(context, _startTimeController),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _endTimeController,
                decoration: const InputDecoration(labelText: 'End Time', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectDateTime(context, _endTimeController),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitEvent,
                child: const Text('Submit Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
