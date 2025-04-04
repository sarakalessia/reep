import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/therapist_invitation/therapist_invitation_list_tile.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';

class TherapistInvitationList extends ConsumerStatefulWidget {
  const TherapistInvitationList({super.key, required this.userList});

  final List<UserModel> userList;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistInvitationListState();
}

class _TherapistInvitationListState extends ConsumerState<TherapistInvitationList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 50.0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.userList.length,
        itemBuilder: (context, index) => TherapistInvitationListTile(userModel: widget.userList[index]),
      ),
    );
  }
}
