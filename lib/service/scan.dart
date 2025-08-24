import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeLookup {
  static Future<String?> lookupLabel(String barcode) async {
    if (barcode.isEmpty) return null;
    try {
      const headers = {
        'User-Agent': 'DormChef/1.0 (Flutter; +github.com/Yido1007/dorm_chef)',
      };
      final urlV2 = Uri.https(
        'world.openfoodfacts.org',
        '/api/v2/product/$barcode.json',
      );
      final r2 = await http
          .get(urlV2, headers: headers)
          .timeout(const Duration(seconds: 6));
      if (r2.statusCode == 200) {
        final data = json.decode(r2.body) as Map<String, dynamic>;
        final status = data['status'];
        final product = data['product'];
        if (status == 1 && product is Map<String, dynamic>) {
          final name = _bestName(product);
          if (name != null && name.trim().isNotEmpty) return name.trim();
        }
      }

      final urlV0 = Uri.https(
        'world.openfoodfacts.org',
        '/api/v0/product/$barcode.json',
      );
      final r0 = await http
          .get(urlV0, headers: headers)
          .timeout(const Duration(seconds: 6));
      if (r0.statusCode == 200) {
        final data = json.decode(r0.body) as Map<String, dynamic>;
        final status = data['status'];
        final product = data['product'];
        if (status == 1 && product is Map<String, dynamic>) {
          final name = _bestName(product);
          if (name != null && name.trim().isNotEmpty) return name.trim();
        }
      }
    } catch (_) {
    }
    return null;
  }

  static String? _bestName(Map<String, dynamic> p) {
    final candidates = <String?>[
      p['product_name_tr'] as String?,
      p['generic_name_tr'] as String?,
      p['product_name'] as String?,
      p['generic_name'] as String?,
      p['product_name_en'] as String?,
      p['brands'] as String?,
    ];
    for (final v in candidates) {
      if (v != null && v.trim().isNotEmpty) return v;
    }
    final brandsTags = p['brands_tags'];
    if (brandsTags is List &&
        brandsTags.isNotEmpty &&
        brandsTags.first is String) {
      return (brandsTags.first as String).replaceAll('-', ' ');
    }
    return null;
  }
}
