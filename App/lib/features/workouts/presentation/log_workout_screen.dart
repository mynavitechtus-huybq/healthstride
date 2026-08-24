import 'package:flutter/material.dart';

import '../domain/workout_repository.dart';
import 'log_workout_controller.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({required this.controller, super.key});

  final LogWorkoutController controller;

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  var _type = 'strength';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _durationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.controller.submit(
      WorkoutDraft(
        workoutType: _type,
        durationMinutes: int.parse(_durationController.text),
        distanceKm: _type == 'cardio' && _distanceController.text.isNotEmpty
            ? double.parse(_distanceController.text)
            : null,
        loggedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Log workout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Workout type'),
              items: const [
                DropdownMenuItem(value: 'strength', child: Text('Strength')),
                DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                DropdownMenuItem(
                  value: 'flexibility',
                  child: Text('Flexibility'),
                ),
              ],
              onChanged: state.isSubmitting
                  ? null
                  : (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
              ),
              validator: (value) {
                final minutes = int.tryParse(value ?? '');
                return minutes == null || minutes <= 0
                    ? 'Enter a positive duration.'
                    : null;
              },
            ),
            if (_type == 'cardio') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanceController,
                enabled: !state.isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Distance (km)'),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  return double.tryParse(value) == null
                      ? 'Enter a valid distance.'
                      : null;
                },
              ),
            ],
            const SizedBox(height: 28),
            if (state.failure != null)
              Text(
                state.failure!.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (state.workout != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_rounded),
                  title: Text(
                    'Workout saved: +${state.workout!.pointsAwarded} points',
                  ),
                  subtitle: Text('${state.workout!.calories} calories'),
                ),
              ),
            FilledButton.icon(
              onPressed: state.isSubmitting ? null : _submit,
              icon: state.isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Save workout'),
            ),
          ],
        ),
      ),
    );
  }
}
