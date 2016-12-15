// Copyright (c) 2016, matt. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_access/shelf_access.dart';

main() {
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(new Basic(_checkCredentials))
      .addHandler(_echoRequest);

  io.serve(handler, '0.0.0.0', 8080).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  var reqBody =  await request.readAsString();
  print('Body was: $reqBody');
  return new shelf.Response.ok('Request for "${request.url}"\nBody: $reqBody');
}

Future<bool> _checkCredentials(String user, String pass) async {
  if (user == 'test' && pass == 'test') return true;
  return false;
}

