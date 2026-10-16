import 'package:bookish/core/error/failures.dart';
import 'package:bookish/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

abstract class UpdateProfileImageUseCase {
  Future<Either<Failure, void>> call(String imageUrl);
}

class UpdateProfileImageUseCaseImpl implements UpdateProfileImageUseCase {
  final IProfileRepository repository;

  UpdateProfileImageUseCaseImpl({required this.repository});

  @override
  Future<Either<Failure, void>> call(String imageUrl) async {
    return await repository.updateProfileImage(imageUrl);
  }
}
