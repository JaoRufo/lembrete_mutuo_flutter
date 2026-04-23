class Payment {
  final DateTime date;

  Payment({required this.date});

  Map<String, dynamic> toJson() => {'date': date.toIso8601String()};

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(date: DateTime.parse(json['date']));
  }
}
