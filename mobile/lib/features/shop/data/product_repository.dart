import 'package:brewphoria/features/shop/data/product_remote_datasource.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';
import 'package:brewphoria/features/shop/domain/category_model.dart';

class ProductRepository {
  ProductRepository(this._datasource);

  final ProductRemoteDatasource _datasource;

  Future<List<CategoryModel>> getCategories() => _datasource.getCategories();

  Future<ProductListResult> getProducts(ProductQueryParams params) =>
      _datasource.getProducts(params);

  Future<ProductModel> getProductBySlug(String slug) =>
      _datasource.getProductBySlug(slug);
}
