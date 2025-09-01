import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Servidor WebSocket rodando em: ws://${server.address.address}:${server.port}');

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      print("Cliente conectado.");

      socket.listen(
        (data) {
          try {
            final decoded = jsonDecode(data as String);

            final code = decoded['code'];
            final longitude = decoded['longitude'];
            final altitude = decoded['altitude'];
            final status = decoded['status'];

            print("📡 Dados recebidos:");
            print("Code: $code, Longitude: $longitude, Altitude: $altitude, Status: $status");

            socket.add("Geo dados recebidos com sucesso");
          } catch (e) {
            print("Erro ao processar mensagem: $e");
          }
        },
      );
    } else {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
    }
  }
}
