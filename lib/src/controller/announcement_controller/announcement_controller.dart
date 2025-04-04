import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/announcement_model/announcement_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/repository/announcements_repository/announcements_repository.dart';
import 'package:repathy/src/repository/notification_repository/notification_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'announcement_controller.g.dart';

@riverpod
class AnnouncementController extends _$AnnouncementController {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<AnnouncementModel>> sendAnnouncement({
    required List<String> receiverUserIds,
    required String content,
    required String title,
  }) async {
    final userModel = ref.read(userControllerProvider);
    if (userModel == null) return ResultModel(error: 'user-not-found');
    final result = await ref.read(announcementRepositoryProvider.notifier).sendAnnouncement(
          receiverUserIds: receiverUserIds,
          title: title,
          content: content,
          currentUser: userModel,
        );

    // This notification doesn't have a "await" in front of it because it's ok to let the backend do its thing
    // This way we free the frontend to keep moving and not wait for the notification to be sent
    ref.read(notificationsRepositoryProvider.notifier).notifyUserGroup(receiverUserIds, content, title);
    return result;
  }

  // UPDATE

  Future<ResultModel<AnnouncementModel>> updateAnnouncement({required AnnouncementModel announcementModel}) async {
    return await ref.read(announcementRepositoryProvider.notifier).updateAnnouncement(announcementModel);
  }

  // DELETE

  Future<ResultModel<AnnouncementModel>> deleteAnnouncement({required AnnouncementModel announcementModel}) async {
    return await ref.read(announcementRepositoryProvider.notifier).deleteAnnouncement(announcementModel);
  }
}

// READ

@riverpod
FutureOr<ResultModel<List<AnnouncementModel>>> getAnnouncementList(Ref ref) async {
  final userModel = ref.read(userControllerProvider);
  if (userModel == null) return ResultModel(error: 'user-not-found');
  return await ref.read(announcementRepositoryProvider.notifier).getAnnouncementList(userModel);
}

@riverpod
FutureOr<ResultModel<AnnouncementModel>> getAnnouncementById(Ref ref, String announcementId) async {
  return await ref.read(announcementRepositoryProvider.notifier).getAnnouncementById(announcementId);
}
