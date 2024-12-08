import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:newproject/models/expense.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  // Function to initialize the database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ExpenseSchema],
      directory: dir.path,
    );
  }

  // Getter method
  List<Expense> get allExpense => _allExpenses;

  // Operations

  // Create
  Future<void> createNewExpense(Expense newExpense) async {
    // Add to DB
    await isar.writeTxn(() => isar.expenses.put(newExpense));
    await readExpenses();
  }

  // Read
  Future<void> readExpenses() async {
    // Fetch all existing expenses from DB
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // Update local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    // Notify UI
    notifyListeners();
  }

  // Update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;

    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await readExpenses();
  }

  // Delete
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
    await readExpenses();
  }

  // calculate total expenses for each month
  Future<Map<int, double>> calculateMonthlyTotals() async {
    // ensure the expenses are read from the database
    await readExpenses();

    // create a map to keep track of total expenses per month
    Map<int, double> monthlyTotals = {};

    // interate over all expenses
    for (var expense in _allExpenses) {
      // extract the month from the date of expenses
      int month = expense.date.month;

      // if the month is not in map yet , initialize it to zero
      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }

      // add the expense amount to the total for the month
      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }

    return monthlyTotals;
  }

  // get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.month;
  }

  //get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.year;
  }
}
