import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brewphoria/features/loyalty/data/loyalty_remote_datasource.dart';
import 'package:brewphoria/features/loyalty/domain/loyalty_model.dart';

part 'loyalty_provider.g.dart';

@riverpod
LoyaltyRemoteDatasource loyaltyDataSource(Ref ref) => LoyaltyRemoteDatasource();

@riverpod
Future<LoyaltyModel> loyaltyAccount(Ref ref) async {
  return ref.read(loyaltyDataSourceProvider).getLoyaltyAccount();
}

@riverpod
Future<LoyaltyTransactionsResult> loyaltyHistory(Ref ref, {int page = 1}) async {
  return ref.read(loyaltyDataSourceProvider).getHistory(page: page);
}
