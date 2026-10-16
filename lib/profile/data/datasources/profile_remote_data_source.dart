import 'package:bookish/profile/data/models/user_profile_model.dart';

abstract class IProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);

  Future<void> updateProfileImage(String userId, String imageUrl);
}
