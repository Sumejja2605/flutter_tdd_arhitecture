import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ServerFailure extends Failure {}

class CachFailure extends Failure {}
