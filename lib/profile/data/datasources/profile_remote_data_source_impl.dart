import 'package:bookish/core/error/exceptions.dart';
import 'package:bookish/profile/data/datasources/profile_remote_data_source.dart';
import 'package:bookish/profile/data/models/user_profile_model.dart';
import 'package:network_service/api.dart';
import 'package:network_service/api_endpoints.dart';
import 'package:network_service/network_manager.dart';

class ProfileRemoteDataSourceImpl implements IProfileRemoteDataSource {
  final NetworkManager networkManager;

  ProfileRemoteDataSourceImpl({required this.networkManager});

  late final IApi _userInfoApi = Api(
    name: ApiEndPoint.PROFILE_INFO_URL,
    method: ApiMethod.get,
  );

  late final IApi _updateProfileApi = Api(
    name: ApiEndPoint.PROFILE_INFO_URL,
    method: ApiMethod.put,
  );

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final response = await networkManager.makeNetworkCall(
        api: _userInfoApi,
        body: {'userId': userId},
        converter: (json) => UserProfileModel.fromJson(json),
        resultKey: 'data',
      );

      if (response.data == null) {
        throw ServerException(message: 'Failed to fetch user profile');
      }

      return response.data!;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await networkManager.makeNetworkCall(
        api: _updateProfileApi,
        body: {
          'userId': userId,
          'profileIcon': imageUrl,
        },
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
