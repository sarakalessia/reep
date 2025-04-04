import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'role_controller.g.dart';

@riverpod
Future<RoleEnum> getCurrentUserRole(Ref ref) async {
  String? currentUserRole = await ref.read(sharedPreferencesProvider).getString('currentUserRole');
  RoleEnum role = RoleEnum.unknown;

  role = RoleEnum.values.firstWhere((RoleEnum element) => element.name == currentUserRole);

  debugPrint('Controller: getCurrentUserRole role: $role');

  return role;
}