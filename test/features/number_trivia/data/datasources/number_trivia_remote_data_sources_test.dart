import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:test_project/core/error/exception.dart';
import 'package:test_project/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:test_project/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  MockHttpClient? mockHttpClient;
  NumberTriviaRemoteDataSourceImpl remoteDataSources;

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient!
            .get(any.toString() as Uri, headers: anyNamed('headers')))
        .thenAnswer(
      (_) async => http.Response(fixture('trivia.json'), 200),
    );
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient!
            .get(any.toString() as Uri, headers: anyNamed('headers')))
        .thenAnswer(
      (_) async => http.Response('Something went wrong', 404),
    );
  }

  setUp(() {
    mockHttpClient = MockHttpClient();
    remoteDataSources = NumberTriviaRemoteDataSourceImpl(
        HttpClient: mockHttpClient as MockHttpClient);
    group('getConcreteNumberTrivia', () {
      final tNumber = 1;
      final tNumberTriviaModel =
          NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));
      test(
          'should preform a GET request on a URL with number being the endpoint and with application/json header',
          () async {
        setUpMockHttpClientSuccess200();

        remoteDataSources.getConcreteNumberTrivia(tNumber);

        verify(mockHttpClient!.get(
          'http://numbersapi.com/$tNumber' as Uri,
          headers: {'Content-Type': 'application/json'},
        ));
      });
      test('should return NumberTrivia when the response code is 200 (success)',
          () async {
        setUpMockHttpClientSuccess200();

        final result = remoteDataSources.getConcreteNumberTrivia(tNumber);

        expect(result, equals(tNumberTriviaModel));
      });

      test(
          'should throw a ServerException when the response code is 404 or other',
          () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = remoteDataSources.getConcreteNumberTrivia;
        // assert
        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      });
    });

    group('getRandomNumberTrivia', () {
      final tNumberTriviaModel =
          NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

      test(
        '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
        () async {
          // arrange
          setUpMockHttpClientSuccess200();
          // act
          remoteDataSources.getRandomNumberTrivia();
          // assert
          verify(mockHttpClient!.get(
            'http://numbersapi.com/random' as Uri,
            headers: {
              'Content-Type': 'application/json',
            },
          ));
        },
      );
      test(
        'should return NumberTrivia when the response code is 200 (success)',
        () async {
          // arrange
          setUpMockHttpClientSuccess200();
          // act
          final result = await remoteDataSources.getRandomNumberTrivia();
          // assert
          expect(result, equals(tNumberTriviaModel));
        },
      );

      test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
          // arrange
          setUpMockHttpClientFailure404();
          // act
          final call = remoteDataSources.getRandomNumberTrivia;
          // assert
          expect(() => call(), throwsA(TypeMatcher<ServerException>()));
        },
      );
    });
  });
}
