import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String userId;
  final String userName;
  final String? profileIcon;
  final String? phoneNumber;

  const UserProfileEntity({
    required this.userId,
    required this.userName,
    this.profileIcon,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [userId, userName, profileIcon, phoneNumber];
}
