import 'dart:async';
import 'dart:convert' show ASCII, BASE64;
import 'dart:io' show HttpStatus, HttpHeaders, HeaderValue;

import 'package:shelf/shelf.dart';

typedef Future<bool> basicCallback(String user, String pass);

class Basic {
  final String realm;
  basicCallback cb;

  Basic(this.cb, [this.realm = 'shelfAccess']);

  Handler call(Handler inner) => (Request request) async {
        var ahead = request.headers[HttpHeaders.AUTHORIZATION];
        var unResp = new Response(HttpStatus.UNAUTHORIZED,
            body: 'unauthorized',
            headers: {HttpHeaders.WWW_AUTHENTICATE: 'Basic realm="$realm"'});
        if (ahead == null) return unResp;

        var auth = ahead.split(' ');
        if (auth[0].toLowerCase() != 'basic') return unResp;

        var userInfo = ASCII.decode(BASE64.decode(auth[1]));
        var ind = userInfo.indexOf(':');
        var user = userInfo.substring(0, ind);
        var pass = userInfo.substring(ind + 1);

        var ok = await cb(user, pass);
        if (!ok) return unResp;

        return inner(request);
      };
}
