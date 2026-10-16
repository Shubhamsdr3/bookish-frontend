import 'package:bookish/core/error/failures.dart';
import 'package:bookish/profile/domain/entities/user_profile_entity.dart';
import 'package:bookish/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

abstract class GetUserProfileUseCase {
  Future<Either<Failure, UserProfileEntity>> call(String userId);
}

class GetUserProfileUseCaseImpl implements GetUserProfileUseCase {
  final IProfileRepository repository;

  GetUserProfileUseCaseImpl({required this.repository});

  @override
  Future<Either<Failure, UserProfileEntity>> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
