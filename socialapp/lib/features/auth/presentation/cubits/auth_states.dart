/*

Auth States

*/

import 'package:socialapp/features/auth/domain/entities/app_user.dart';

abstract class AuthState {}

// Initial 
class AuthInitial extends AuthState {}

// loading...
class AuthLoading extends AuthState {}

// authenticated
class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

// unauthenticated
class Unauthenticated extends AuthState {}

// errors...
class AuthError extends AuthState {
  final String errorMessage;
  AuthError(this.errorMessage);
}

