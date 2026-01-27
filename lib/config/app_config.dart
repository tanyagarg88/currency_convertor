import '../models/fee_model.dart';

class AppConfig {
  static FeeModel defaultFees = FeeModel(
    platformFeePercent: 1.2,
    bankMarginPercent: 0.8,
  );
}
