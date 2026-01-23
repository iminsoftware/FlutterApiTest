import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission helper for managing app permissions
class PermissionHelper {
  /// Request system alert window permission (for secondary display)
  ///
  /// Returns true if permission is granted, false otherwise.
  static Future<bool> requestSystemAlertWindowPermission(
      BuildContext context) async {
    // Check if permission is already granted
    final status = await Permission.systemAlertWindow.status;

    if (status.isGranted) {
      return true;
    }

    // Show explanation dialog
    if (context.mounted) {
      final shouldRequest = await _showPermissionDialog(
        context,
        title: 'Display Permission Required',
        message:
            'This app needs permission to display content on the secondary screen. '
            'Please grant "Display over other apps" permission in the next screen.',
      );

      if (!shouldRequest) {
        return false;
      }
    }

    // Request permission
    final result = await Permission.systemAlertWindow.request();

    if (result.isDenied || result.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(context);
      }
      return false;
    }

    return result.isGranted;
  }

  /// Check if system alert window permission is granted
  static Future<bool> hasSystemAlertWindowPermission() async {
    return await Permission.systemAlertWindow.isGranted;
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Show permission explanation dialog
  static Future<bool> _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show permission denied dialog
  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'The permission was denied. Some features may not work properly. '
          'You can grant the permission manually in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show a simple snackbar message
  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
