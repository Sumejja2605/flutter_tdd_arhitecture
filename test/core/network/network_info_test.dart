import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/mockito.dart';
import 'package:test_project/core/network/network_info.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  NetworkInfoImp networkInfoImp;
  MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfoImp = NetworkInfoImp(
        internetConnectionChecker: mockInternetConnectionChecker);

    group('is Connected', () {
      test('should forward the call to DataConnectionChecker.hasConnection',
          () async {
        final tHasConnection = Future.value(true);

        when(mockInternetConnectionChecker.hasConnection)
            .thenAnswer((_) => tHasConnection);
        final result = networkInfoImp.isConnected;

        verify(mockInternetConnectionChecker.hasConnection);

        expect(result, tHasConnection);
      });
    });
  });
}
