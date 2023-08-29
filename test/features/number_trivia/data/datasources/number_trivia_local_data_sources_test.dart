import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/core/error/exception.dart';
import 'package:test_project/features/number_trivia/data/datasources/number_trivia_local_data_sources.dart';
import 'package:test_project/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferencies extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourcesImpl? localDataSourcesImpl;
  MockSharedPreferencies? mockSharedPreferencies;

  setUp(() {
    mockSharedPreferencies = MockSharedPreferencies();
    localDataSourcesImpl = NumberTriviaLocalDataSourcesImpl(
        sharedPreferences: mockSharedPreferencies);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture("trivia_cached.json")));
    test(
        'Should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async* {
      when(mockSharedPreferencies!.getString(any.toString()))
          .thenReturn(fixture("trivia_cached.json"));

      final result = await localDataSourcesImpl!.getLastNumberTrivia();
      verify(mockSharedPreferencies!.getString('CACHED_NUMBER_TRIVIA'));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a CacheException when there is not a cached value',
        () async* {
      when(mockSharedPreferencies!.getString(any.toString())).thenReturn(null);

      final call = localDataSourcesImpl!.getLastNumberTrivia;

      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'test trivia');

    test('should call SharedPreferences to cache the data', () async* {
      // act
      localDataSourcesImpl!.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferencies!.setString(
        CACHED_NUMBER_TRIVIA,
        expectedJsonString,
      ));
    });
  });
}
