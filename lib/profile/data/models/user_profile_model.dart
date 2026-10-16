import 'package:bookish/profile/domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.userId,
    required super.userName,
    super.profileIcon,
    super.phoneNumber,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      profileIcon: json['profileIcon'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'profileIcon': profileIcon,
      'phoneNumber': phoneNumber,
    };
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      userId: userId,
      userName: userName,
      profileIcon: profileIcon,
      phoneNumber: phoneNumber,
    );
  }
}
