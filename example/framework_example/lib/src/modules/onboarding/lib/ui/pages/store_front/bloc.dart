

import 'package:bvvm/bvvm.dart';

import 'page.dart';
import 'view_model.dart';

class StoreFrontBloc extends Bloc<StoreFrontPage> {

  final StoreFrontViewModel _viewModel;

  // UserService get _userService => getService<UserService>();

  StoreFrontBloc( this._viewModel );



}