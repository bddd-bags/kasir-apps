import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupplierService {
  final String idsup;
  final String nama;
  final String alamat;
  final String nohp;

  SupplierService({
    required this.idsup,
    required this.nama,
    required this.alamat,
    required this.nohp,
  });

  factory SupplierService.fromJson(Map<String, dynamic> json) {
    return SupplierService(
      idsup: json['idsup'].toString(),
      nama: json['nama'],
      alamat: json['alamat'],
      nohp: json['nohp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idsup': idsup,
      'nama': nama,
      'alamat': alamat,
      'nohp': nohp,
    };
  }

  static Future<List<SupplierService>> fetchSuppliers() async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.get(Uri.parse('$apiUrl/supplier'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => SupplierService.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load supplier');
    }
  }

  static Future<int> addSuppliers(Map<String, dynamic> data) async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.post(
      Uri.parse('$apiUrl/supplier'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
    return response.statusCode;
  }

  static Future<int> editSuppliers(idsup, Map<String, dynamic> data) async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.put(Uri.parse('$apiUrl/supplier/$idsup'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data));

    return response.statusCode;
  }

  static Future<int> deleteSuppliers(idsup) async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.delete(Uri.parse('$apiUrl/supplier/$idsup'));
    return response.statusCode;
  }
}
