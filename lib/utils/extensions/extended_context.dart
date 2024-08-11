
import 'package:flutter/material.dart';

extension ExtendedContext on BuildContext {

  Size get deviceSize => MediaQuery.of(this).size;

  ThemeData get themeData => Theme.of(this);


}