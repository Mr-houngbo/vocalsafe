import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TransactionDataService {
  static const String _fileName = 'transaction_data.json';
  
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
  
  static Future<void> saveTransactionData(Map<String, dynamic> data) async {
    try {
      final file = await _getFile();
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
      print('Transaction data saved: $jsonString');
    } catch (e) {
      print('Error saving transaction data: $e');
    }
  }
  
  static Future<Map<String, dynamic>?> getTransactionData() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error reading transaction data: $e');
      return null;
    }
  }
  
  static Future<void> clearTransactionData() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing transaction data: $e');
    }
  }
}
