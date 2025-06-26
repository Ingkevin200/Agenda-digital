import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmail(Event event) async {
  final smtpServer = gmail('dfms0115@gmail.com', Platform.environment['GMAIL_APP_PASSWORD']!,); // Usa una contraseña de aplicación
  final message = Message()
    ..from = Address('dfms0115@gmail.com', 'Agenda Digital')
    ..recipients.add('dfamorales@poligran.edu.co') // o una lista
    ..subject = 'Nuevo Evento: ${event.title}'
    ..text = '¡Hola! Se ha creado un nuevo evento:\n\n'
             'Título: ${event.title}\n'
             'Fecha: ${event.date}';

  try {
    final sendReport = await send(message, smtpServer);
    print('✅ Correo enviado: ' + sendReport.toString());
  } catch (e) {
    print('❌ Error al enviar correo: $e');
  }
}

class Event {
  int id;
  String title;
  String date;

  Event({required this.id, required this.title, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
      };

  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      date: json['date'],
    );
  }
}

List<Event> events = [];
int currentId = 1;
// Archivo donde se guardarán los eventos
const String filePath = 'events.json';

// Guardar los eventos en un archivo
Future<void> saveEventsToFile() async {
  final file = File(filePath);
  final jsonData = jsonEncode(events.map((e) => e.toJson()).toList());
  await file.writeAsString(jsonData);
}

// Cargar los eventos desde un archivo
Future<void> loadEventsFromFile() async {
  final file = File(filePath);
  if (await file.exists()) {
    final contents = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(contents);
    events = jsonList.map((e) => Event.fromJson(e)).toList();

    // Asegurarse de que el siguiente ID sea correcto
    if (events.isNotEmpty) {
      currentId = events.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    }
  }
}

Future<File> generatePdfReport() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Agenda de Eventos', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            ...events.map(
              (event) => pw.Text('📅 ${event.date} - ${event.title}'),
            ),
          ],
        );
      },
    ),
  );

  final file = File('agenda.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}

void main() async {
  await loadEventsFromFile(); // 👈 Cargar eventos guardados al iniciar


  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8085);
  print('✅ Backend listening on http://${server.address.address}:${server.port}');

  await for (HttpRequest request in server) {
    final path = request.uri.path;
    final method = request.method;

    if (path == '/events' && method == 'GET') {
      // Ver eventos
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(events))
        ..close();
        

    }else if (path == '/export/pdf' && method == 'GET') {
  final file = await generatePdfReport();
  final bytes = await file.readAsBytes();

  request.response
    ..headers.contentType = ContentType('application', 'pdf')
    ..headers.set('Content-Disposition', 'attachment; filename=agenda.pdf')
    ..add(bytes)
    ..close();
}
 
    else if (path == '/events' && method == 'POST') {
      // Crear evento
      final content = await utf8.decoder.bind(request).join();
      final data = jsonDecode(content);
      final newEvent = Event(
        id: currentId++,
        title: data['title'],
        date: data['date'],
      );
      events.add(newEvent);
      await saveEventsToFile(); // 👈 Guardar cambios
      await sendEmail(newEvent); // 👈 Enviar notificacion por correo
      
      request.response
        ..statusCode = HttpStatus.created
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(newEvent.toJson()))
        ..close();

    } 
    
    else if (path.startsWith('/events/') && method == 'PUT') {
      // Editar evento
      final id = int.tryParse(path.split('/').last);
      final content = await utf8.decoder.bind(request).join();
      final data = jsonDecode(content);
      final index = events.indexWhere((e) => e.id == id);

      if (index != -1) {
        events[index].title = data['title'];
        events[index].date = data['date'];
        await saveEventsToFile(); // 👈 Guardar cambios
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(events[index].toJson()))
          ..close();
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Evento no encontrado')
          ..close();
      }

    } else if (path.startsWith('/events/') && method == 'DELETE') {
      // Eliminar evento
      final id = int.tryParse(path.split('/').last);
      events.removeWhere((e) => e.id == id);
      await saveEventsToFile(); // 👈 Guardar cambios
      request.response
        ..statusCode = HttpStatus.noContent
        ..close();
    } else if (path == '/export/csv' && method == 'GET') {
      final csvBuffer = StringBuffer();
      csvBuffer.writeln('ID,Título,Fecha');

      for (var e in events) {
        // Evita comas en el contenido, si es necesario puedes sanitizar más
        final safeTitle = e.title.replaceAll(',', ' ');
        csvBuffer.writeln('${e.id},$safeTitle,${e.date}');
      }

      final file = File('agenda.csv');
      await file.writeAsString(csvBuffer.toString());

      request.response
        ..headers.contentType = ContentType('text', 'csv')
        ..headers.set('Content-Disposition', 'attachment; filename=agenda.csv')
        ..write(csvBuffer.toString())
        ..close();

    } else {
      // Ruta no encontrada
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Ruta no válida')
        ..close();
    }
  }
}