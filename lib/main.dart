import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/app.dart';
import 'src/utils/preferences/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix Android < 7 Handshake error in client (OS Error:CERTIFICATE_VERIFY_FAILED: certificate has expired
  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  // Enable SharedPreferences
  await Preferences.init();

  // Call permissions
  if (Platform.isAndroid) {
    final storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
  }

  runApp(
    const ProviderScope(child: App()),
  );
}
