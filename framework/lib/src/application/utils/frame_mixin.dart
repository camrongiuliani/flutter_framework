// part of '../application.dart';

import 'dart:async';

import 'package:flutter/widgets.dart';

typedef FrameMutator = FutureOr<void> Function();

mixin FrameMixin {

  Future<void> workBetweenFrames( List<FrameMutator> mutations ) async {
    for ( var mutation in mutations ) {
      await _workBetweenFrames( mutation );
    }
  }

  Future<void> _workBetweenFrames( FrameMutator mutation ) {
    return WidgetsBinding.instance.endOfFrame.then( ( _ ) => mutation() );
  }

}