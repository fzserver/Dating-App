import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class Permissions {
  static Future<bool> cameraAndMicrophonePermissionGranted() async {
    PermissionStatus cameraPermissionStatus = await getCameraPermission();
    PermissionStatus microphonePermissionStatus = await getMicrophonePermission();

    if (cameraPermissionStatus == PermissionStatus.granted && microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      handleInvalidPermissions(cameraPermissionStatus, microphonePermissionStatus);
      return false;
    }
  }

  static Future<PermissionStatus> getCameraPermission() async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    if (permission != PermissionStatus.granted && permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus = await PermissionHandler().requestPermissions([PermissionGroup.camera]);
      return permissionStatus[PermissionGroup.camera] ?? PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  static Future<PermissionStatus> getMicrophonePermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.microphone]);
      return permissionStatus[PermissionGroup.microphone] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  static void handleInvalidPermissions(
    PermissionStatus cameraPermissionStatus,
    PermissionStatus microphonePermissionStatus,
  ) {
    if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (cameraPermissionStatus == PermissionStatus.disabled &&
        microphonePermissionStatus == PermissionStatus.disabled) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

}