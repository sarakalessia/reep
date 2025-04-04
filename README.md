# repathy

Repathy connects physiotherapists and patients.

## Instructions

# This command creates and corrects generated files in real time

1. Run this command before starting to work on any code generated files

- Build runner
```bash
dart run build_runner watch --delete-conflicting-outputs
```

2. To stop the command just hit ctrl + c in the terminal

# Using @riverpod

This package manages state throughout the app

1. Import package:riverpod_annotation/riverpod_annotation.dart
2. Below it write part 'name_of_directoy.g.dart', this will generate a file automatically 
3. Now you can use the keyword "riverpod" to create providers of either "function" or "class" type
5. Examples of "function" type provider:

@riverpod
int someImportantValue(SomeImportantValueRef ref) => 200:

@riverpod
FirebaseAuth firebaseAuthInstance(FirebaseAuthInstanceRef ref) => FirebaseAuth.instance;

To use them in a widget's build method call ref.read(someImportantValueProvider) and pass it to a local variable

6. Examples of "class" type provider:

@riverpod
class ImportantValueController extends _$ImportantValueController {
  @override
  int build() => return 0;

  void updateState(int newValue) => state = newValue;
}

@riverpod
class ImportantBooleanController extends _$ImportantBooleanController {
  @override
  bool build() => return false;

  void invertState() => state = !state;
  void setTrue() => state = true;
  void setFalse() => state = false;
}

To use them in a widget's build method, call ref.watch(importantBooleanControllerProvider) and pass it to a local variable if needed

To use use their internal methods use ref.read(importantBooleanControllerProvider.notifier).someMethod();

7. For all of this to work, use ConsumerWidget instead of StatelessWidgets, or ConsumerStatefulWidget instead of StatefulWidget
8. For even better use add the VS Code extension called "Flutter Riverpod Snippets"
9. For more complex examples (async code) read this: https://codewithandrea.com/articles/flutter-riverpod-generator/

# Using @freezed 

This package guarantees class immutability, improves the use of riverpod, etc

1. Import 'package:freezed_annotation/freezed_annotation.dart'
2. Import 'package:flutter/foundation.dart'
3. Below the imports, write part 'name_of_directory.freezed.dart'
3. Below the previous line, write part 'name_of_directory.g.dart'
4. Use the following syntax, just substitute "ClassName" and change its properties:

@freezed
abstract class ClassName with _$ClassName {
  const factory ClassName({
    required String firstName,
    required String lastName,
    required int age,
  }) = _ClassName;

  factory ClassName.fromJson(Map<String, Object?> json)
      => _$ClassNameFromJson(json);
}

5. For fields with default values the syntax is:
    - @Default(value) type variableName
    - Ex: @Default(16) int newDay

6. For fields which are collections that need to be mutable (Lists, Maps, etc) substitute @freezed for @Freezed(makeCollectionsUnmodifiable: false)

7. In order for JSON serialization to work with nested objects, create a build.yaml file in your root folder with the following code:

targets:
  $default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true

7. For more examples read docs: https://pub.dev/packages/freezed

# Using intl

This package makes our code translatable to any languages

1. To add a new language go to "lib/l10n"
2. Create a file as "intl_languagecode.arb" and substitute language code for en, pt, es, etc
3. Add the following lines at the start of the file

{
    "@@locale": "languagecode",
    "language_code": "languagecode",
    "language": "LanguageName", 
}

4. Then write keys and values like a standard JSON:

    "registerChargerPointTitle": "Registra il punto di ricarica",
    "registerChargerPointDescription": "Descrizione per la registrazione del punto di ricarica",

5. Optionally add descriptions:

    "next": "Next",
    "@next": {
        "description": "Next page button text"
    },

6. In the terminal run this command: flutter gen-l10n    

7. To use this in real code use the following syntax, which is of type String:

AppLocalizations.of(context)!.jsonKey

8. Also import: import 'package:flutter_gen/gen_l10n/app_localizations.dart';

# Using flutter_dotenv

This package allows us to securely store our secret keys

1. Create a .env file in your local project, it should never be uploaded to Github
2. Get the already existing keys from our One Drive account and paste it on your .env file
3. To add a new key to the .env file (and the OneDrive doc) do:

KEY_NAME = "contentOfTheKey";

4. To use this in our UI, do this:

final variableName = dotenv.env['KEY_NAME']!;