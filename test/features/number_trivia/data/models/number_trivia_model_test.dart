import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_project/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:test_project/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(text: 'test', number: 1);

  test('should be a subclass of numberTrivia entity', () async* {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fomJson', () {
    test('should return a valid model when the JSON number is an integer ',
        () async* {
      final Map<String, dynamic> mapJson =
          jsonDecode(fixture('trivia_double.json'));
      final result = NumberTriviaModel.fromJson(mapJson);
      expect(result, tNumberTriviaModel);
    });
  });
  group('toJson', () {
    test('should return a JSON map containing the proper data', () async* {
      final result = tNumberTriviaModel.toJson();

      final expectedJsonMap = {
        "text": "test",
        "number": 1,
      };

      expect(result, expectedJsonMap);
    });
  });
}
