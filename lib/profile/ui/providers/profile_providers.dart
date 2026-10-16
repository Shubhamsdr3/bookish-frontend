import 'package:bookish/profile/data/datasources/profile_remote_data_source.dart';
import 'package:bookish/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:bookish/profile/data/repositories/profile_repository_impl.dart';
import 'package:bookish/profile/domain/repositories/profile_repository.dart';
import 'package:bookish/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:bookish/profile/domain/usecases/update_profile_image_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_service/network_manager.dart';

final profileRemoteDataSourceProvider =
    Provider<IProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(
    networkManager: NetworkManager(),
  );
});

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final dataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource: dataSource);
});

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserProfileUseCaseImpl(repository: repository);
});

final updateProfileImageUseCaseProvider =
    Provider<UpdateProfileImageUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateProfileImageUseCaseImpl(repository: repository);
});
