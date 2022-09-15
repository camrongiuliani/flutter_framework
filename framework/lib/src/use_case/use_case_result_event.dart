

import 'dart:async';

import 'package:app/framework.dart';

class UseCaseResultEvent<X extends UseCase> {

  final String id;
  final dynamic result;
  final X request;
  final String? error;
  final bool success;

  const UseCaseResultEvent({
    required this.id,
    required this.result,
    required this.request,
    this.error,
    this.success = true,
  });


}