class Hair {
  final String amount;
  final DateTime date;
  final String note;
  Hair({required this.amount, required this.date, required this.note});
  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'amount': amount,
      'dateTime': date.toIso8601String(),
    };
  }

  // Convert JSON map back to an object
  factory Hair.fromJson(Map<String, dynamic> json) {
    return Hair(
      note: json['note'],
      amount: json['amount'],
      date: DateTime.parse(json['dateTime']),
    );
  }
}