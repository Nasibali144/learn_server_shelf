import 'package:hive/hive.dart';
import '../entity/todo_entity.dart';

class HiveTodo {
  static String todoDB = "todoDB";
  static String todoKey = "todos";
  static Box<List> box = Hive.box(todoDB);

  static Future<void> init() async{
    Hive.init("assets/database");
    if(!Hive.isBoxOpen(todoDB)) {
      await Hive.openBox<List>(todoDB);
    }
  }

  void storeData(Todo todo) async {
    List response = getData;
    response.add(todo.toJson());
    await box.put(todoKey, response);
  }

  void deleteData(int id) {
    List response = getData;
    response.removeWhere((element) => (element["id"] as int) == id);
    box.put(todoKey, response);
  }

  Object? readData(String id) {
    List response = getData;
    final result = response.where((element) => element["id"].toString() == id);
    if(result.isEmpty) {
      return null;
    } else {
      return result.first;
    }
  }



  // Stream<BoxEvent> get getListenable => box.watch();

  List get getData => box.get(todoKey) ?? [];



}