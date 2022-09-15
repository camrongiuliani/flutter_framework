import 'package:app/framework.dart';
import 'package:app/src/application/application.dart';
import 'package:app/src/application/registries/component.dart';
import 'package:flutter_test/flutter_test.dart';


class TestModule extends Module {

  TestModule({required super.application});

}

void main() {

  group( 'FrameworkComponent Registry Tests' , () {

    test( 'Registry Starts Empty Test', () {

      ComponentRegistry cReg = ComponentRegistry();

      expect( cReg.modules, isEmpty );
      expect( cReg.services, isEmpty );

    });

    test( 'Register Component Test', () {

      ComponentRegistry cReg = ComponentRegistry();

      TestModule tm = TestModule(
        application: Application.headless( storageID: 't1' ),
      );

      cReg.register( tm );

      expect( cReg.modules, isNotEmpty );
      expect( cReg.modules.length, equals( 1 ) );
      expect( cReg.modules.first, isA<Module>() );
      expect( cReg.modules.first, isA<TestModule>() );
      expect( cReg.modules.first, equals( tm ) );

    });

    test( 'Register Duplicate Component Should Fail Test', () {

      ComponentRegistry cReg = ComponentRegistry();

      TestModule tm = TestModule(
        application: Application.headless( storageID: 't2' ),
      );

      cReg.register( tm );

      expect( () {
        cReg.register( tm );
      }, throwsAssertionError );

    });

    test( 'Component Exists Test', () {

      ComponentRegistry cReg = ComponentRegistry();

      TestModule tm = TestModule(
        application: Application.headless( storageID: 't3' ),
      );

      expect( cReg.exists<TestModule>(), isFalse );

      cReg.register( tm );

      expect( cReg.exists<TestModule>(), isTrue );

    });

    test( 'Component Get Test', () {

      ComponentRegistry cReg = ComponentRegistry();

      TestModule tm = TestModule(
        application: Application.headless( storageID: 't4' ),
      );

      expect( () {
        cReg.get<TestModule>();
      }, throwsAssertionError );

      cReg.register( tm );

      var m = cReg.get<TestModule>();

      expect( m, isNotNull );
      expect( m, isA<Module>() );
      expect( m, isA<TestModule>() );
      expect( m, equals( tm ) );

    });

  });

}