import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/models/timer_model.dart';
import 'package:recipe_app/providers/timer_provider.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool _showAddTimer = false;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _toggleAddTimer() {
    setState(() {
      _showAddTimer = !_showAddTimer;
      if (_showAddTimer) {
        _nameController.clear();
        _durationController.clear();
      }
    });
  }

  void _addTimer() {
    final name = _nameController.text.trim();
    final durationText = _durationController.text.trim();
    
    if (name.isNotEmpty && durationText.isNotEmpty) {
      final duration = int.tryParse(durationText);
      if (duration != null && duration > 0) {
        context.read<TimerProvider>().addTimer(name, duration);
        _toggleAddTimer();
      }
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kitchen Timers',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          final timers = timerProvider.timers;
          
          if (timers.isEmpty && !_showAddTimer) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No timers yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a timer to get started',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _toggleAddTimer,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Timer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Add timer form
              if (_showAddTimer)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add New Timer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Timer Name',
                              hintText: 'e.g., Pasta Boiling',
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _durationController,
                            decoration: const InputDecoration(
                              labelText: 'Duration (minutes)',
                              hintText: 'e.g., 10',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _toggleAddTimer,
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _addTimer,
                                child: const Text('Add Timer'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Timer list
              Expanded(
                child: timers.isEmpty
                    ? const SizedBox() // Zamanlayıcı yokkenki görünüm
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: timers.length,
                        itemBuilder: (context, index) {
                          final timer = timers[index];
                          final progress = timer.remaining / timer.duration;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Timer name
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          timer.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => timerProvider.deleteTimer(timer.id),
                                        iconSize: 20,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                  
                                  // Timer display
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      _formatTime(timer.remaining),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  
                                  // Progress bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ),
                                  
                                  // Controls
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => timerProvider.toggleTimer(timer.id),
                                          icon: Icon(
                                            timer.isRunning ? Icons.pause : Icons.play_arrow,
                                          ),
                                          label: Text(timer.isRunning ? 'Pause' : 'Start'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: timer.isRunning
                                                ? Colors.orange
                                                : Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        OutlinedButton.icon(
                                          onPressed: () => timerProvider.resetTimer(timer.id),
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Reset'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _showAddTimer
          ? null
          : FloatingActionButton(
              onPressed: _toggleAddTimer,
              child: const Icon(Icons.add),
            ),
    );
  }
}