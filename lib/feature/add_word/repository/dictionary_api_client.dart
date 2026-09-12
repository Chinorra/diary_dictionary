import 'package:dio/dio.dart';

import '../models/dictionary_lookup.dart';

class DictionaryApiClient {
  DictionaryApiClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _dictionaryBase =
      'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const _suggestionsBase = 'https://api.datamuse.com/sug';

  Future<DictionaryLookup> lookup(String word) async {
    final trimmed = word.trim();
    if (trimmed.isEmpty) {
      throw const DictionaryException('Please enter a word to translate.');
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_dictionaryBase/${Uri.encodeComponent(trimmed)}',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const DictionaryException(
          'Unable to find this word. Please check the spelling and try again.',
        );
      }
      return _parseFirstEntry(trimmed, data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const DictionaryException(
          'Unable to find this word. Please check the spelling and try again.',
        );
      }
      throw const DictionaryException(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  Future<List<String>> fetchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    try {
      final response = await _dio.get<List<dynamic>>(
        _suggestionsBase,
        queryParameters: {'s': trimmed, 'max': 8},
      );
      final data = response.data;
      if (data == null) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((entry) => entry['word'] as String? ?? '')
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    } on DioException {
      return const [];
    }
  }

  DictionaryLookup _parseFirstEntry(String word, List<dynamic> data) {
    final firstEntry = data.first as Map<String, dynamic>;
    final meanings = (firstEntry['meanings'] as List?) ?? const [];
    if (meanings.isEmpty) {
      throw const DictionaryException(
        'No definition available for this word.',
      );
    }
    final firstMeaning = meanings.first as Map<String, dynamic>;
    final partOfSpeech = firstMeaning['partOfSpeech'] as String? ?? '';
    final definitions = (firstMeaning['definitions'] as List?) ?? const [];
    if (definitions.isEmpty) {
      throw const DictionaryException(
        'No definition available for this word.',
      );
    }
    final firstDef = definitions.first as Map<String, dynamic>;
    return DictionaryLookup(
      word: word,
      definition: (firstDef['definition'] as String? ?? '').trim(),
      example: (firstDef['example'] as String? ?? '').trim(),
      partOfSpeech: partOfSpeech,
    );
  }
}
