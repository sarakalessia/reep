import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'url_provider.g.dart'; 

@riverpod
String functionBaseUrl(Ref ref) => 'https://keys-getkeys-hrmmd7vx4q-ew.a.run.app';