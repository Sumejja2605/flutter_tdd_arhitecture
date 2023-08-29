import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_project/core/error/exception.dart';
import 'package:test_project/core/error/failures.dart';
import 'package:test_project/core/network/network_info.dart';
import 'package:mockito/mockito.dart';
import 'package:test_project/features/number_trivia/data/datasources/number_trivia_local_data_sources.dart';
import 'package:test_project/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:test_project/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:test_project/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:test_project/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSources {}

class MockLocalDataSource extends Mock
    implements NumberTriviaLocalDataSources {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl? repositoryImpl;
  MockRemoteDataSource? remoteDataSource;
  MockLocalDataSource? localDataSource;
  MockNetworkInfo? networkInfo;

  setUp(
    () {
      remoteDataSource = MockRemoteDataSource();
      localDataSource = MockLocalDataSource();
      networkInfo = MockNetworkInfo();
      repositoryImpl = NumberTriviaRepositoryImpl(
          numberTriviaLocalDataSources: localDataSource as MockLocalDataSource,
          numberTriviaRemoteDataSources:
              remoteDataSource as MockRemoteDataSource,
          networkInfo: networkInfo as NetworkInfo);
    },
  );

  void runTestOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(networkInfo?.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(networkInfo!.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(text: 'test', number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async* {
      when(networkInfo?.isConnected).thenAnswer((_) async => true);
      repositoryImpl?.getConcreteNumberTrivia(tNumber);
      verify(networkInfo?.isConnected);
    });
    runTestOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async* {
          when(remoteDataSource!.getConcreteNumberTrivia(1))
              .thenAnswer((_) async => tNumberTriviaModel);
          final result = await repositoryImpl?.getConcreteNumberTrivia(tNumber);
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        'should cache the data locally when the call to remote data source is successful',
        () async* {
          when(remoteDataSource!.getConcreteNumberTrivia(1))
              .thenAnswer((realInvocation) async => tNumberTriviaModel);
          await repositoryImpl?.getConcreteNumberTrivia(tNumber);
          verify(remoteDataSource!.getConcreteNumberTrivia(tNumber));
          verify(localDataSource!.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async* {
          when(remoteDataSource!.getConcreteNumberTrivia(1))
              .thenThrow(ServerException());
          final result = await repositoryImpl?.getConcreteNumberTrivia(tNumber);

          verify(remoteDataSource!.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(localDataSource);

          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async* {
          // arrange
          when(localDataSource!.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repositoryImpl?.getConcreteNumberTrivia(tNumber);
          // assert
          verifyZeroInteractions(remoteDataSource);
          verify(localDataSource!.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async* {
          // arrange
          when(localDataSource!.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repositoryImpl?.getConcreteNumberTrivia(tNumber);
          // assert
          verifyZeroInteractions(remoteDataSource);
          verify(localDataSource!.getLastNumberTrivia());
          expect(result, equals(Left(CachFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'test', number: 234);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async* {
      when(networkInfo?.isConnected).thenAnswer((_) async => true);

      repositoryImpl?.getRandomNumberTrivia();

      verify(networkInfo?.isConnected);
    });
    runTestOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async* {
          when(remoteDataSource!.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          final result = await repositoryImpl?.getRandomNumberTrivia();
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        'should cache the data locally when the call to remote data source is successful',
        () async* {
          when(remoteDataSource!.getRandomNumberTrivia())
              .thenAnswer((realInvocation) async => tNumberTriviaModel);
          await repositoryImpl?.getRandomNumberTrivia();
          verify(remoteDataSource!.getRandomNumberTrivia());
          verify(localDataSource!.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async* {
          when(remoteDataSource!.getRandomNumberTrivia())
              .thenThrow(ServerException());
          final result = await repositoryImpl?.getRandomNumberTrivia();

          verify(remoteDataSource!.getRandomNumberTrivia());
          verifyZeroInteractions(remoteDataSource);

          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async* {
          // arrange
          when(localDataSource!.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repositoryImpl?.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(remoteDataSource);
          verify(localDataSource!.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async* {
          // arrange
          when(localDataSource!.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repositoryImpl?.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(remoteDataSource);
          verify(localDataSource!.getLastNumberTrivia());
          expect(result, equals(Left(CachFailure())));
        },
      );
    });
  });
}
