import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@pragma('vm:entry-point')
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EmployeeScreen(),
    );
  }
}

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen>
    with WidgetsBindingObserver {
  // ← ADD THIS
  String employeeName = "Loading...";
  String employeeId = "Loading...";
  Timer? _debugTimer;
  int _timerCount = 0;

  static const platform = MethodChannel('employee_channel');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ← ADD THIS
    _receiveDataFromAndroid();
    _startDebugTimer();
  }

  // ← ADD THIS ENTIRE METHOD
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        // User went back to Android screen
        debugPrint('⏸️ Flutter screen paused — stopping timer');
        _stopTimer();
        break;
      case AppLifecycleState.resumed:
        // User came back to Flutter screen
        debugPrint('▶️ Flutter screen resumed — restarting timer');
        _startDebugTimer();
        break;
      case AppLifecycleState.detached:
        debugPrint('🛑 Flutter screen detached — stopping timer');
        _stopTimer();
        break;
      default:
        break;
    }
  }

  void _startDebugTimer() {
    _stopTimer(); // always cancel existing before starting new
    _debugTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _timerCount++;
      debugPrint('═══════════════════════════════════');
      debugPrint('🕐 Timer tick #$_timerCount');
      debugPrint('👤 Employee Name: $employeeName');
      debugPrint('🪪 Employee ID: $employeeId');
      debugPrint('📡 MethodChannel: employee_channel');
      debugPrint('═══════════════════════════════════');
    });
    debugPrint('✅ Timer started');
  }

  void _stopTimer() {
    _debugTimer?.cancel();
    _debugTimer = null;
    debugPrint('🛑 Timer stopped');
  }

  Future<void> _receiveDataFromAndroid() async {
    debugPrint('🚀 Flutter screen started — waiting for Android data...');
    platform.setMethodCallHandler((call) async {
      debugPrint('📩 Received method call: ${call.method}');
      if (call.method == 'sendEmployeeData') {
        debugPrint('✅ Data received from Android!');
        debugPrint('   name = ${call.arguments['name']}');
        debugPrint('   empId = ${call.arguments['empId']}');
        setState(() {
          employeeName = call.arguments['name'] ?? 'Unknown';
          employeeId = call.arguments['empId'] ?? 'Unknown';
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ← ADD THIS
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Flutter version test 2'),
                const Icon(Icons.badge, size: 64, color: Color(0xFF1A237E)),
                const SizedBox(height: 16),
                const Text(
                  'Employee Registered!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 32),
                _infoRow('Name', employeeName),
                const SizedBox(height: 12),
                _infoRow('Emp ID', employeeId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.indigo)),
      ],
    );
  }
}
