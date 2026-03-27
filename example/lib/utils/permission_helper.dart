import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';

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
      final l10n = AppLocalizations.of(context);
      final shouldRequest = await _showPermissionDialog(
        context,
        title: l10n.displayPermissionRequired,
        message: l10n.displayPermissionMessage,
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
    await Permission.systemAlertWindow.request();
  }

  /// Show permission explanation dialog
  static Future<bool> _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.continueText),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show permission denied dialog
  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionDenied),
        content: Text(l10n.permissionDeniedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n.openSettings),
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
