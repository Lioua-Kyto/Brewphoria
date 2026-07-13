import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_card/features/orders/data/orders_remote_datasource.dart';
import 'package:coffee_card/features/checkout/domain/order_model.dart';

part 'orders_provider.g.dart';

@riverpod
OrdersRemoteDatasource ordersDataSource(Ref ref) => OrdersRemoteDatasource();

@riverpod
Future<OrdersListResult> orders(Ref ref, {int page = 1}) async {
  return ref.read(ordersDataSourceProvider).getOrders(page: page);
}

@riverpod
Future<OrderModel> orderDetail(Ref ref, String orderId) async {
  return ref.read(ordersDataSourceProvider).getOrderById(orderId);
}
