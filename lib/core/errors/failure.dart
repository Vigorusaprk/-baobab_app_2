// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message = '';
  const Failure();
}

//for server failure status code is 502
class ServerFailure extends Failure {
  const ServerFailure();
  @override
  List<Object?> get props => [];

  @override
  final message = 'server failure';
}

//for not found failure status code is 404

class NotFoundFailure extends Failure {
  const NotFoundFailure();
  @override
  List<Object?> get props => [];

  @override
  final message = 'not found failure';
}

//for cache failure from device disk
class CasheFailure extends Failure {
  const CasheFailure();

  @override
  final message = 'cache failure';

  @override
  List<Object?> get props => [message];
}

//for connection failure
class ConnectionFailure extends Failure {
  @override
  final String message;

  const ConnectionFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

//for error from choosing picture
class ChoosePictureFailure extends Failure {
  const ChoosePictureFailure();

  @override
  final message = 'choose picture failure failure';

  @override
  List<Object?> get props => [message];
}

//for otp failure 403
class Otpfailure extends Failure {
  const Otpfailure();

  @override
  final message = 'otp failure';

  @override
  List<Object?> get props => [];
}

//for auth failure 401
class AuthorizationFailure extends Failure {
  const AuthorizationFailure();

  @override
  final message = 'auth failure';
  @override
  List<Object?> get props => [];
}

//for uknown failure
class UnknownFailure extends Failure {
  const UnknownFailure();

  @override
  final message = 'uknown failure';
  @override
  List<Object?> get props => [];
}

//for inital state
class InitFailure extends Failure {
  const InitFailure();

  @override
  final message = 'uknown failure';
  @override
  List<Object?> get props => [];
}

class AuthFailure extends Failure {
  @override
  final String message;
  const AuthFailure({this.message = 'Authentication failure'});

  @override
  List<Object?> get props => [message];
}
