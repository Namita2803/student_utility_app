import 'package:flutter/material.dart';

class AddTimetableEntryScreen extends StatefulWidget {
  const AddTimetableEntryScreen({Key? key}) : super(key: key);

  @override
  _AddTimetableEntryScreenState createState() =>
      _AddTimetableEntryScreenState();
}

class _AddTimetableEntryScreenState extends State<AddTimetableEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDay;
  TimeOfDay? _selectedTime;
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _selectedDay != null &&
        _selectedTime != null) {
      // Here you can send the data back or save it to your timetable list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added: $_selectedDay at ${_selectedTime!.format(context)} - ${_subjectController.text}',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Scaffold(
      appBar: AppBar(title: const Text('Add Timetable Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Day selection
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Day'),
                items:
                    days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                value: _selectedDay,
                onChanged: (v) => setState(() => _selectedDay = v),
                validator: (v) => v == null ? 'Select a day' : null,
              ),
              const SizedBox(height: 16),

              // Time picker field
              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Pick Time'),
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Tap to choose',
                    style: TextStyle(
                      color:
                          _selectedTime != null ? null : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Subject input
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Enter subject' : null,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Add Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
