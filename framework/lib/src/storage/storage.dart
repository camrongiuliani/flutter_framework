

import 'package:abstract_kv_store/abstract_kv_store.dart';

class Storage {

  final KVStore mutable;
  final KVStore singleSet;

  Storage():
        mutable = KVStore.build( 'AppStore' ),
        singleSet = KVStore.build( 'PersistStore', mutable: false );

  Future<void> init( { List<dynamic> typeAdapters = const [] } ) async {
    await mutable.init( typeAdapters: typeAdapters );
    await singleSet.init( typeAdapters: typeAdapters );
  }

  Future<void> dump({ bool debugAllowDumpLocked = false }) async {
    await mutable.dump();
    await singleSet.dump( debugAllowDumpLocked: debugAllowDumpLocked );
  }
}