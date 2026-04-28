import 'package:otp/otp.dart';

class TotpService {
  static String generateCode(String secret, {int digits = 6, int period = 30}) {
    return OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      length: digits,
      interval: period,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );
  }

  static int secondsRemaining({int period = 30}) {
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return period - (epoch % period);
  }
}
