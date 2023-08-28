import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'src/db/hive_db.dart';
import 'src/entity/todo_entity.dart';

final db = HiveTodo();

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/todos/<id>', _todoHandler)
  ..get('/todos', _todosHandler)
  ..post("/todos", _postHandler);

Future<Response> _postHandler(Request request) async {
  print("context : ${request.context}");
  print("params : ${request.params}");
  final todo = await request.readAsString();
  print("todo : $todo");

  db.storeData(Todo.fromJson(jsonDecode(todo)));
  return Response.ok({
    "message": "Successfully created!",
    "todo": todo,
  }.toString());
}

Response _rootHandler(Request req) {
  return Response.ok("Welcome Our Todos Server!\n");
}

Response _todoHandler(Request request) {
  final id = request.params['id'].toString();
  final response = db.readData(id);
  if(response == null) {
    return Response.notFound({
      "message": "$id is not found",
    });
  }
  return Response.ok(response);
}

Response _todosHandler(Request request) {
  return Response.ok(db.getData);
}

void main(List<String> args) async {
  // Database init
  await HiveTodo.init();


  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.tryParse("10.10.1.58") ?? InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);


  print('Server listening on port ${server.port}');
  print('Header ${server.serverHeader}');
  print('Host ${server.address.host}');
}
