import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/util/enum/gender_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';

part 'user.freezed.dart';
part 'user.g.dart';

// TODO: REMOVE BASICALLY ALL LIST PROPERTIES, QUERY STRAIGHT FROM COLLECTIONS
@Freezed(makeCollectionsUnmodifiable: false)
abstract class UserModel with _$UserModel {
  const factory UserModel({
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? birthDate,
    String? id,
    String? authId,
    String? qrCodeId,
    String? studioId, // therapists only, optional
    String? studioName,
    String? substituteTherapistId,
    String? firebaseMessagingId,
    String? patientSubscriptionId,
    String? therapistSubscriptionId,
    String? email,
    String? password,
    String? phoneNumber,
    String? name,
    String? lastName,
    String? coverImage, // therapists only, download URL
    String? profileImage, // download URL
    String? description,
    String? addressString,
    String? professionalLicense, // therapists only
    double? height,
    double? weight,
    @Default(<String>[]) List<String> subscriptionIdHistory, // all subscriptions a user has had
    @Default(<String>[]) List<String> eventIds, // all events related to a user, used for notifications, etc
    @Default(<String>[]) List<String> announcementIdList, // therapists only, announcements he has created
    @Default(<String>[]) List<String> mediaIdList, // therapists only, media he has created
    @Default(<String>[]) List<String> therapistId, // patients only
    @Default(<String>[]) List<String> patientId, // therapists only
    @Default(<String>[]) List<String> temporaryPatientIds, // therapists only
    @Default(<String>[]) List<String> transferId, // revoked transfers are removed from here
    @Default(<String>[]) List<String> invitationId, // patients and therapists invite each other to work together
    @Default(GenderEnum.other) GenderEnum gender,
    @Default(RoleEnum.unknown) RoleEnum role,
    @Default(false) bool consentToTermsOfService,
    @Default(false) bool consentToPrivacyPolicy,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, Object?> json) => _$UserModelFromJson(json);
}
