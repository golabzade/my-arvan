enum CloudProvider {
  arvanCloud,
  ferdowsiCloud;

  String get id {
    switch (this) {
      case CloudProvider.arvanCloud:
        return 'arvan';
      case CloudProvider.ferdowsiCloud:
        return 'ferdowsi';
    }
  }

  String get displayName {
    switch (this) {
      case CloudProvider.arvanCloud:
        return 'ArvanCloud';
      case CloudProvider.ferdowsiCloud:
        return 'Ferdowsi Cloud';
    }
  }

  String get baseUrl {
    switch (this) {
      case CloudProvider.arvanCloud:
        return 'https://napi.arvancloud.ir';
      case CloudProvider.ferdowsiCloud:
        return 'https://api.ferdowsi.cloud';
    }
  }

  bool get supportsTerminate {
    switch (this) {
      case CloudProvider.arvanCloud:
        return true;
      case CloudProvider.ferdowsiCloud:
        return false;
    }
  }

  static CloudProvider fromId(String? id) {
    switch (id?.toLowerCase()) {
      case 'ferdowsi':
      case 'ferdowsicloud':
        return CloudProvider.ferdowsiCloud;
      case 'arvan':
      case 'arvancloud':
      default:
        return CloudProvider.arvanCloud;
    }
  }
}
