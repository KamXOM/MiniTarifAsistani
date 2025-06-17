import 'package:flutter/material.dart';
import 'package:recipe_app/models/timer_model.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TimerProvider extends ChangeNotifier {
  List<TimerModel> _timers = [];
  Timer? _ticker;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  List<TimerModel> get timers => _timers;

  TimerProvider() {
    _initializeTimerTicker();
    _initializeNotifications();
  }

  void _initializeTimerTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool needsUpdate = false;
      
      for (int i = 0; i < _timers.length; i++) {
        if (_timers[i].isRunning && _timers[i].remaining > 0) {
          _timers[i].remaining -= 1;
          needsUpdate = true;
          
          // Timer completed
          if (_timers[i].remaining == 0) {
            _timers[i].isRunning = false;
            _showTimerCompletedNotification(_timers[i]);
          }
        }
      }
      
      if (needsUpdate) {
        notifyListeners();
      }
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    
    _isInitialized = true;
  }

  Future<void> _showTimerCompletedNotification(TimerModel timer) async {
    if (!_isInitialized) return;
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      channelDescription: 'Notifications for completed timers',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      timer.id.hashCode,
      'Timer Complete',
      '${timer.name} timer is done!',
      platformChannelSpecifics,
    );
  }

  void addTimer(String name, int durationMinutes) {
    if (name.isEmpty || durationMinutes <= 0) return;
    
    final newTimer = TimerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      duration: durationMinutes * 60, // dakikayı saniyeye çevirme
      remaining: durationMinutes * 60,
      isRunning: false,
    );
    
    _timers.add(newTimer);
    notifyListeners();
  }

  void toggleTimer(String id) {
    final index = _timers.indexWhere((timer) => timer.id == id);
    
    if (index != -1) {
      _timers[index].isRunning = !_timers[index].isRunning;
      notifyListeners();
    }
  }

  void resetTimer(String id) {
    final index = _timers.indexWhere((timer) => timer.id == id);
    
    if (index != -1) {
      _timers[index].remaining = _timers[index].duration;
      _timers[index].isRunning = false;
      notifyListeners();
    }
  }

  void deleteTimer(String id) {
    _timers.removeWhere((timer) => timer.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}