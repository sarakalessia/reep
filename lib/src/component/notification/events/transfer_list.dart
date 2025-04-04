import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/notification/events/transfer_card.dart';
import 'package:repathy/src/controller/transfer_controller/transfer_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/util/enum/role_enum.dart';

class TransferList extends ConsumerStatefulWidget {
  const TransferList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InvitesListState();
}

class _InvitesListState extends ConsumerState<TransferList> {
  @override
  Widget build(BuildContext context) {
    final getTransfers = ref.watch(getTransferListProvider);
    final currentUser = ref.watch(userControllerProvider);

    return SizedBox(
      height: 350,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(getTransferListProvider.future),
        child: getTransfers.when(
          data: (final data) {
            final invitations = data.$1;
            if (invitations == null || currentUser!.role == RoleEnum.patient) return Center(child: Text('Non ci sono eventi'));
            return ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                return TransferCard(
                  transferModel: data.$1![index],
                  patientUserModel: data.$2![index],
                  originalTherapistUserModel: data.$3![index],
                  substituteTherapistUserModel: data.$4![index],
                  currentUser: currentUser,
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
