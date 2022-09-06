library meetri_core;

import 'package:app/framework.dart';
import 'package:app/src/models/framework_component.dart';

abstract class Service extends FrameworkComponent {

  final Application application;

  Service( { required this.application, super.customBus } );

}