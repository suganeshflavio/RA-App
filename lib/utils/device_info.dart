import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceId() async {
  final plugin = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return _formatDeviceId(info.manufacturer, info.model);
    }
    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return _formatDeviceId('APPLE', info.utsname.machine);
    }
    if (Platform.isWindows) {
      final info = await plugin.windowsInfo;
      return _formatDeviceId('WINDOWS', info.computerName);
    }
    if (Platform.isMacOS) {
      final info = await plugin.macOsInfo;
      return _formatDeviceId('APPLE', info.model);
    }
    if (Platform.isLinux) {
      final info = await plugin.linuxInfo;
      return _formatDeviceId('LINUX', info.name);
    }
  } catch (_) {
    // Fall through to the generic identifier below.
  }
  return 'UNKNOWN_DEVICE';
}

String _formatDeviceId(String manufacturer, String model) {
  final raw = '${manufacturer}_$model';
  return raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '_');
}
