import 'package:bookish/core/error/exceptions.dart';
import 'package:bookish/core/error/failures.dart';
import 'package:bookish/profile/data/datasources/profile_remote_data_source.dart';
import 'package:bookish/profile/domain/entities/user_profile_entity.dart';
import 'package:bookish/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:network_service/util/user_store.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile(
    String userId,
  ) async {
    try {
      final model = await remoteDataSource.getUserProfile(userId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfileImage(String imageUrl) async {
    try {
      final userId = await UserStore.getUserId();
      await remoteDataSource.updateProfileImage(userId, imageUrl);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
