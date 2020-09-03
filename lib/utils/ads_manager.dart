import 'dart:io';

class AdsManager {

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7688128470074396~1851296898";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdsUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7688128470074396/3324160667";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

}