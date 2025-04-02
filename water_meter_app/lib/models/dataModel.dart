class Datamodel {
  final String date;
  final double totalFlow;  // 🔹 Dùng `double` thay vì `Float`

  Datamodel({
    required this.date,
    required this.totalFlow,
  });

  // chuyển đổi từ JSON
  factory Datamodel.fromJson(Map<String, dynamic> json) {
    return Datamodel(
      date: json['date'], 
       totalFlow: (json['totalFlow'] as num?)?.toDouble() ?? 0.0,  // Đảm bảo kiểu `double`
    );
  }
  
  @override
  String toString() {
    return '(date: $date, totalFlow: $totalFlow)';
  }
}
