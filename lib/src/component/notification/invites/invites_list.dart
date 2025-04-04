import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/notification/invites/invites_card.dart';
import 'package:repathy/src/controller/invitation_controller/invitation_controller.dart';
import 'package:repathy/src/model/data_models/invitation_model/invitation_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';

class InvitesList extends ConsumerStatefulWidget {
  const InvitesList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InvitesListState();
}

class _InvitesListState extends ConsumerState<InvitesList> {
  @override
  Widget build(BuildContext context) {
    AsyncValue<(List<InvitationModel>?, List<UserModel>?, List<UserModel>?, RoleEnum)> getInvitationList = ref.watch(getInvitationListProvider);

    return SizedBox(
      height: 350,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(getInvitationListControllerProvider.future),
        child: getInvitationList.when(
          data: ((List<InvitationModel>? invitation, List<UserModel>? patient, List<UserModel>? therapist, RoleEnum currentUserRole) data) {
            debugPrint('View: InvitesList getInvitationList data is $data');
            if (data.$1 == null) return Center(child: Text('Non ci sono collegamenti'));
            return ListView.builder(
              itemCount: data.$1!.length,
              itemBuilder: (context, index) {
                return InvitesCard(
                  invitationModel: data.$1![index],
                  patientUserModel: data.$2![index],
                  therapistUserModel: data.$3![index],
                  currentUserRole: data.$4,
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
