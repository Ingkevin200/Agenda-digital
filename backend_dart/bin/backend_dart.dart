import 'dart:io';

void main() async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Server listening on http://${server.address.address}:${server.port}');
  await for (var request in server) {
    request.response
      ..write('Hola desde el backend de la agenda')
      ..close();
  }
}
