import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/patient_list/patient_list_tile.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';

class PatientListPageBody extends ConsumerWidget {
  const PatientListPageBody({super.key, required this.userList});

  final List<UserModel> userList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) => PatientListPageTile(patientUserModel: userList[index]),
      ),
    );
  }
}
