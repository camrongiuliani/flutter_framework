import 'dart:async';
import 'package:app/framework.dart';
import 'package:app/src/models/framework_component.dart';
import 'package:flutter/foundation.dart';

export 'use_case_result_event.dart';

abstract class UseCase<T extends Object?> {

  String get id;

  final FrameworkComponent owner;

  const UseCase({
    required this.owner,
  });

  @protected
  FutureOr<T> execute( Map<String, dynamic>? args );

  Future<void> call([ Map<String, dynamic>? args ]) async {
    T result = await execute( args );

    owner.emit(
        UseCaseResultEvent(
          id: id,
          result: result,
          request: this,
        )
    );
  }
}