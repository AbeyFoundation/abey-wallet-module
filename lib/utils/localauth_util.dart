import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:get/get.dart';

const andStrings = const AndroidAuthMessages(
  cancelButton: 'Cancel',
  goToSettingsButton: 'Set Up',
  biometricNotRecognized: 'Identification failed',
  goToSettingsDescription: 'Please set the touch ID.',
  biometricHint: 'Touch ID',
  biometricSuccess: 'Identification succeeded',
  signInTitle: 'Authentication',
  biometricRequiredTitle: 'Please enter the touch ID first!',
);

const iosStrings = const IOSAuthMessages(
  cancelButton: 'Cancel',
  goToSettingsButton: 'Set Up',
  goToSettingsDescription: 'Please set the touch ID.',
  lockOut: 'Unlock',
);

class LocalauthUtil {
  final LocalAuthentication auth = LocalAuthentication();
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'FALSE';
  bool _isAuthenticating = false;

  Future<bool> isSupportBiometrics() async {
    bool canCheckBiometrics = false;
    bool isSupport = await checkBiometrics();
    if (isSupport) {
      List<BiometricType> btList = await getAvailableBiometrics();
      if (btList.length > 0) {
        canCheckBiometrics = true;
      }
    }
    return canCheckBiometrics;
  }

  Future<bool> checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    _canCheckBiometrics = canCheckBiometrics;
    return _canCheckBiometrics!;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      if (Platform.isIOS) {
        if (availableBiometrics.contains(BiometricType.face)) {
          // Face ID.
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          // Touch ID.
        }
      }
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    _availableBiometrics = availableBiometrics;
    return _availableBiometrics!;
  }

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      _isAuthenticating = true;
      _authorized = 'Authenticating';
      authenticated = await auth.authenticate(localizedReason: 'Please verify your identity'.tr, authMessages: [andStrings,iosStrings], options: AuthenticationOptions(
        useErrorDialogs: true,
        stickyAuth: true,
        sensitiveTransaction: false,
        biometricOnly: true,
      ),);
      _isAuthenticating = false;
      _authorized = 'Authenticating';
    } on PlatformException catch (e) {
      print(e);
      if (e.code == auth_error.notAvailable) {

      } else if (e.code == auth_error.passcodeNotSet) {

      } else if (e.code == auth_error.notEnrolled) {

      } else if (e.code == auth_error.otherOperatingSystem) {

      }
    }
    final String message = authenticated ? 'TRUE' : 'FALSE';
    _authorized = message;
    return authenticated;
  }

  void cancelAuthentication() {
    auth.stopAuthentication();
  }

}
