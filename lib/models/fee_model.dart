class FeeModel {
  final double platformFeePercent;
  final double bankMarginPercent;

  FeeModel({required this.platformFeePercent, required this.bankMarginPercent});

  double get totalFeePercent => platformFeePercent + bankMarginPercent;
}
