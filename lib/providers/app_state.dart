import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  List<Map<String, dynamic>> expenses = [];

  void addExpense(String name, double amount) {
    expenses.add({"name": name, "amount": amount});
    notifyListeners();
  }
}
