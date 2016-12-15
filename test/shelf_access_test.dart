// Copyright (c) 2016, matt. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_access/shelf_access.dart';
import 'package:test/test.dart';

Future<Null> main() async {
  var handler = const shelf.Pipeline()
                .addMiddleware(new Basic(_authenticate))
                .addHandler(_ok);

  var serv = await io.serve(handler, '0.0.0.0', 0);
  var port = serv.port;

  group('A group of tests', () {

    test('Authentication Realm', () async {
      var cl = new HttpClient();
      cl.authenticate = (Uri uri, String scheme, String realm) async {
        var cred = new HttpClientBasicCredentials('test', 'test');
        expect(realm, equals('shelfAccess'));
        cl.addCredentials(uri, realm, cred);
        return true;
      };

      var req = await cl.get('localhost', port, '/');
      var resp = await req.close();
      expect(resp.statusCode, equals(HttpStatus.OK));
    });

    test('Failed/No Authentication', () async {
      var cl = new HttpClient();
      var req = await cl.get('localhost', port, '/');
      var resp = await req.close();
      expect(resp.statusCode, equals(HttpStatus.UNAUTHORIZED));
      expect(resp.headers[HttpHeaders.WWW_AUTHENTICATE], isNotEmpty);
    });
  });
}

Future<bool> _authenticate(String user, String pass) async {
  if (user == 'test' && pass == 'test') return true;
  return false;
}

shelf.Response _ok(shelf.Request request) {
  return new shelf.Response.ok('Ok');
}
