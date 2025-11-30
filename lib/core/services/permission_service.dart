import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  static Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }
  
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
  
  static Future<bool> requestAllRequiredPermissions() async {
    // Demander la permission microphone (la plus importante)
    final microphoneGranted = await requestMicrophonePermission();
    
    if (!microphoneGranted) {
      return false;
    }
    
    return true;
  }
}
