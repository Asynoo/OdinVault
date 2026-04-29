class OtpAuthParser {
  static Map<String, String>? parse(String uri) {
    try {
      final parsed = Uri.parse(uri);
      if (parsed.scheme != 'otpauth' || parsed.host != 'totp') return null;

      final secret = parsed.queryParameters['secret'];
      if (secret == null || secret.isEmpty) return null;

      final rawLabel = parsed.pathSegments.isNotEmpty
          ? Uri.decodeComponent(parsed.pathSegments.first)
          : '';

      String name = rawLabel;
      String issuer = parsed.queryParameters['issuer'] ?? '';

      // Label may be "Issuer:Account" — split if present
      if (rawLabel.contains(':')) {
        final colon = rawLabel.indexOf(':');
        final labelIssuer = rawLabel.substring(0, colon).trim();
        name = rawLabel.substring(colon + 1).trim();
        if (issuer.isEmpty) issuer = labelIssuer;
      }

      return {
        'name': name,
        'issuer': issuer,
        'secret': secret.toUpperCase().replaceAll(' ', ''),
      };
    } catch (_) {
      return null;
    }
  }
}
