import '../repositories/products_repository.dart';

class UploadImageUseCase {
  final ProductsRepository repository;

  UploadImageUseCase({required this.repository});

  Future<String> call(String imagePath) async {
    return await repository.uploadImage(imagePath);
  }
}
