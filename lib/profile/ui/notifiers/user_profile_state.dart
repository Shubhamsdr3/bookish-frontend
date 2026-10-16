import 'package:bookish/profile/domain/entities/user_profile_entity.dart';

/// Consolidated profile state — single source of truth for the profile screen.
class ProfileState {
  final ProfileStatus status;
  final UserProfileEntity? profile;
  final String? errorMessage;
  final String currentUserId;
  final String appVersion;
  final bool isImageUploading;
  final String? localImagePath;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.currentUserId = '',
    this.appVersion = '',
    this.isImageUploading = false,
    this.localImagePath,
  });

  bool get isOwner =>
      currentUserId.isNotEmpty &&
      profile != null &&
      currentUserId == profile!.userId;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfileEntity? profile,
    String? errorMessage,
    String? currentUserId,
    String? appVersion,
    bool? isImageUploading,
    String? localImagePath,
    bool clearLocalImage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUserId: currentUserId ?? this.currentUserId,
      appVersion: appVersion ?? this.appVersion,
      isImageUploading: isImageUploading ?? this.isImageUploading,
      localImagePath: clearLocalImage
          ? null
          : (localImagePath ?? this.localImagePath),
    );
  }
}

enum ProfileStatus { initial, loading, loaded, error }
