import 'package:idb_shim/idb.dart';

class Utils {
  static int formatRawApiValue(String rawValue) {
    return int.parse(rawValue.replaceAll(".", ""));
  }

  static Future<dynamic> transaction({
    required String type,
    required Database db,
    required String objectStore,
    required String action,
    dynamic data,
    dynamic object,
  }) async {
    var txn = db.transaction(objectStore, action);
    var store = txn.objectStore(objectStore);

    if (type == "save") {
      await store.put(data, object ?? objectStore);
      await txn.completed;

      return "Data type ${data.runtimeType} saved to $objectStore";
    } else if (type == "delete") {
      await store.delete(object ?? objectStore);
      await txn.completed;

      return "Objek dengan key $object delete from $objectStore";
    } else {
      var request = await store.getObject(object ?? objectStore);
      await txn.completed;

      return request;
    }
  }
}
