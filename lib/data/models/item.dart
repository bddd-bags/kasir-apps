import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ItemService {
  final String nobarcode;
  final String nama;
  final int harga;
  final int stok;

  ItemService({
    required this.nobarcode,
    required this.nama,
    required this.harga,
    required this.stok,
  });

  factory ItemService.fromJson(Map<String, dynamic> json) {
    return ItemService(
      nobarcode: json['nobarcode'].toString(),
      nama: json['nama'],
      harga: json['harga'],
      stok: json['stok'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nobarcode': nobarcode,
      'nama': nama,
      'harga': harga,
      'stok': stok,
    };
  }

  static Future<List<ItemService>> fetchItems() async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.get(Uri.parse('$apiUrl/barang'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => ItemService.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<int> addItems(Map<String, dynamic> data) async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.post(
      Uri.parse('$apiUrl/barang'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
    return response.statusCode;
  }

  static Future<int> editItems(nobarcode, Map<String, dynamic> data) async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.put(Uri.parse('$apiUrl/barang/$nobarcode'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data));

    return response.statusCode;
  }

  static Future<int> deleteItems(nobarcode) async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.delete(Uri.parse('$apiUrl/barang/$nobarcode'));
    return response.statusCode;
  }
}
