import '../models/fee_model.dart';

class FeeEngine {
  static double calculateNetRate({
    required double marketRate,
    required FeeModel feeModel,
  }) {
    final feeAmount = marketRate * (feeModel.totalFeePercent / 100);
    return marketRate - feeAmount;
  }
}
