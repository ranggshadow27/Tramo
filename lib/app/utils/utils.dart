import 'package:flutter/material.dart';
import 'package:idb_shim/idb.dart';
import 'package:tramo/app/constants/themes/app_colors.dart';

class Utils {
  static int formatRawApiValue(String rawValue) {
    return int.parse(rawValue.replaceAll(RegExp(r'[.,]'), ""));
  }

  static Color hexToColor(String? hex) {
    // Kembalikan warna default jika hex null atau kosong
    if (hex == null || hex.isEmpty) {
      return AccentColors.tealColor;
    }

    // Menghapus tanda '#' jika ada
    String cleanHex = hex.replaceAll('#', '');

    // Validasi format hex (6 atau 8 karakter)
    if (!RegExp(r'^[0-9A-Fa-f]{6}$|^[0-9A-Fa-f]{8}$').hasMatch(cleanHex)) {
      return AccentColors.tealColor;
    }

    // Menambahkan alpha channel FF jika panjang 6
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }

    try {
      // Mengonversi hex ke integer dan mengembalikan Color
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      // Kembalikan warna default jika parsing gagal
      return AccentColors.tealColor;
    }
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
