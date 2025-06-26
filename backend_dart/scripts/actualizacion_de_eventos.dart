import 'dart:convert';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class Event {
  int id;
  String title;
  String date;

  Event({required this.id, required this.title, required this.date});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      date: json['date'],
    );
  }
}

Future<void> sendEmail(Event event) async {
  final password = Platform.environment['GMAIL_APP_PASSWORD'];

  if (password == null || password.trim().isEmpty) {
    print('❌ La variable de entorno GMAIL_APP_PASSWORD no está definida.');
    return;
  }

  final smtpServer = gmail('dfms0115@gmail.com', password.trim());

  final message = Message()
    ..from = Address('dfms0115@gmail.com', 'Agenda Digital')
    ..recipients.add('dfamorales@poligran.edu.co')
    ..subject = 'Alerta de trabajo: Nuevo Evento: ${event.title}'
    ..text = '¡Holi! Se ha creado un nuevo evento para la agenda del Poli ¡A Camellar!:\n\n'
             'Título: ${event.title}\n'
             'Fecha: ${event.date}';

  try {
    final sendReport = await send(message, smtpServer);
    print('✅ Correo enviado, Siuuuu: $sendReport');
  } catch (e) {
    print('❌ Error al enviar correo, ponte trucha mi pana!: $e');
  }
}

Future<void> main() async {
  final file = File('events.json');
  print('Ruta absoluta: ${file.absolute.path}');

  if (!await file.exists()) {
    print('❌ El archivo events.json no existe.');
    return;
  }

  final contents = await file.readAsString();
  final List<dynamic> jsonList = jsonDecode(contents);
  final events = jsonList.map((e) => Event.fromJson(e)).toList();

  if (events.isEmpty) {
    print('⚠️ No hay eventos para enviar.');
    return;
  }

  final latest = events.last;
  print('📬 Enviando correo del evento: ${latest.title}');
  await sendEmail(latest);
}

