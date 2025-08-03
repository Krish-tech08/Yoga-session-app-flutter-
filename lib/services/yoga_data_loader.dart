import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/asana_session.dart';
import '../utils/constants.dart';

class AsanaDataLoader {
  // Load from assets bundle
  static Future<AsanaSession> loadFromAssets([String? jsonPath]) async {
    try {
      final String path = jsonPath ?? AppConstants.posesJsonPath;
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return AsanaSession.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load asana session from assets: $e');
    }
  }

  // Load from network URL
  static Future<AsanaSession> loadFromNetwork(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return AsanaSession.fromJson(jsonData);
      } else {
        throw Exception('Failed to load from network: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Load from local file
  static Future<AsanaSession> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final String jsonString = await file.readAsString();
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return AsanaSession.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load from file: $e');
    }
  }

  // Validate session data
  static bool validateSession(AsanaSession session) {
    if (session.sequence.isEmpty) return false;

    for (final seq in session.sequence) {
      if (seq.name.isEmpty || seq.audioRef.isEmpty || seq.durationSec <= 0) {
        return false;
      }

      for (final script in seq.script) {
        if (script.text.isEmpty || script.imageRef.isEmpty) {
          return false;
        }
      }
    }

    return true;
  }
}

