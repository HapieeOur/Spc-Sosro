import 'package:spc_sosro/models/activity_log.dart';
import 'package:spc_sosro/models/stock_summary.dart';

class DayTrend {
  final DateTime date;
  final int inBoxes;
  final int outBoxes;

  const DayTrend({
    required this.date,
    required this.inBoxes,
    required this.outBoxes,
  });

  factory DayTrend.fromJson(Map<String, dynamic> json) {
    return DayTrend(
      date: DateTime.parse(json['date'] as String),
      inBoxes: json['in_boxes'] as int,
      outBoxes: json['out_boxes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'in_boxes': inBoxes,
      'out_boxes': outBoxes,
    };
  }
}

class DashboardData {
  final int todayInBoxes;
  final int todayOutBoxes;
  final double todayInPalletEquivalent;
  final double todayOutPalletEquivalent;
  final List<StockSummary> stockByProduct;
  final List<StockSummary> lowStock;
  final List<ActivityLog> recentActivity;
  final List<DayTrend> sevenDayTrend;

  const DashboardData({
    required this.todayInBoxes,
    required this.todayOutBoxes,
    required this.todayInPalletEquivalent,
    required this.todayOutPalletEquivalent,
    required this.stockByProduct,
    required this.lowStock,
    required this.recentActivity,
    required this.sevenDayTrend,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      todayInBoxes: json['today_in_boxes'] as int,
      todayOutBoxes: json['today_out_boxes'] as int,
      todayInPalletEquivalent:
          (json['today_in_pallet_equivalent'] as num).toDouble(),
      todayOutPalletEquivalent:
          (json['today_out_pallet_equivalent'] as num).toDouble(),
      stockByProduct: (json['stock_by_product'] as List<dynamic>)
          .map((e) => StockSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      lowStock: (json['low_stock'] as List<dynamic>)
          .map((e) => StockSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivity: (json['recent_activity'] as List<dynamic>)
          .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      sevenDayTrend: (json['seven_day_trend'] as List<dynamic>)
          .map((e) => DayTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_in_boxes': todayInBoxes,
      'today_out_boxes': todayOutBoxes,
      'today_in_pallet_equivalent': todayInPalletEquivalent,
      'today_out_pallet_equivalent': todayOutPalletEquivalent,
      'stock_by_product': stockByProduct.map((e) => e.toJson()).toList(),
      'low_stock': lowStock.map((e) => e.toJson()).toList(),
      'recent_activity': recentActivity.map((e) => e.toJson()).toList(),
      'seven_day_trend': sevenDayTrend.map((e) => e.toJson()).toList(),
    };
  }
}
