import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkStatusListener extends StatefulWidget {
  final Widget child;

  const NetworkStatusListener({super.key, required this.child});

  @override
  State<NetworkStatusListener> createState() => _NetworkStatusListenerState();
}

class _NetworkStatusListenerState extends State<NetworkStatusListener> {
  StreamSubscription<InternetStatus>? _subscription;
  bool _hasInternet = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      if (mounted) {
        setState(() => _hasInternet = status == InternetStatus.connected);
      }
    });
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!mounted) return;
    setState(() {
      _hasInternet = hasInternet;
      _isChecking = false;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_hasInternet)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A1F1F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'لا يوجد اتصال بالإنترنت. تحقق من الشبكة ثم أعد المحاولة.',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: _isChecking ? null : _checkConnection,
                            child: _isChecking
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'إعادة المحاولة',
                                    style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
