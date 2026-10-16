import 'package:bookish/core/error/failures.dart';
import 'package:bookish/profile/domain/entities/user_profile_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getUserProfile(String userId);

  Future<Either<Failure, void>> updateProfileImage(String imageUrl);
}
