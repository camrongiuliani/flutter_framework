

import 'package:abstract_kv_store/abstract_kv_store.dart';

class Storage {

  final KVStore mutable;
  final KVStore immutable;

  Storage([ String? storageID = '' ]):
        mutable = KVStore.build( '${storageID}_AppStore' ),
        immutable = KVStore.build( '${storageID}_PersistStore', mutable: false );

  Future<void> init( { List<dynamic> typeAdapters = const [] } ) async {
    await mutable.init( typeAdapters: typeAdapters );
    await immutable.init( typeAdapters: typeAdapters );
  }

  Future<void> dump({ bool debugAllowDumpLocked = false }) async {
    await mutable.dump();
    await immutable.dump( debugAllowDumpLocked: debugAllowDumpLocked );
  }
}