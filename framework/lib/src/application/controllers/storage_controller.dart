import 'dart:async';
import 'package:abstract_kv_store/abstract_kv_store.dart';

class StorageController {

  final String storageID;

  final KVStore mutable;
  final KVStore immutable;

  StorageController( [ String? storageID ] ):
        storageID = storageID ?? 'Core',
        mutable = KVStore.build( '${storageID}_AppStore' ),
        immutable = KVStore.build( '${storageID}_PersistStore', mutable: false );

  Future<void> init({ List<dynamic> typeAdapters = const [] }) async {
    await mutable.init( typeAdapters: typeAdapters );
    await immutable.init( typeAdapters: typeAdapters );
  }

  Future<void> flush({ bool debugAllowImmutableFlush = false }) async {
    await mutable.dump();
    await immutable.dump( debugAllowDumpLocked: debugAllowImmutableFlush );
  }

  Future<T?> get<T>( String key, { bool persistent = false, T? defaultValue } ) {
    return ( persistent ? immutable : mutable ).get<T>( key, fallback: defaultValue );
  }

  Future<void> set<T>( String key, T? value, { bool persistent = false } ) {
    return ( persistent ? immutable : mutable ).set( key, value );
  }
}