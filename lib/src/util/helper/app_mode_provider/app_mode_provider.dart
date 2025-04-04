import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_mode_provider.g.dart'; 

@riverpod
bool appMode(Ref ref) => kDebugMode;