import 'package:owa_flutter/api/external_payment_redirect_stub.dart'
    if (dart.library.html) 'package:owa_flutter/api/external_payment_redirect_web.dart'
    as redirect_impl;

Future<bool> openExternalPaymentUrl(String url) {
  return redirect_impl.openExternalPaymentUrl(url);
}
