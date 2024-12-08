import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newproject/bar%20graph/bar_graph.dart';
import 'package:newproject/components/my_list_tile.dart';
import 'package:newproject/database/expense_database.dart';
import 'package:newproject/helper/helper_functions.dart';
import 'package:newproject/main.dart';
import 'package:newproject/models/expense.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // futures to load the graph data
  Future<Map<int, double>>? _monthlyTotalFuture;

  @override
  void initState() {
    // read db on initial startup
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    // load futures
    refreshGraphData();
    super.initState();
  }

  void refreshGraphData() {
    _monthlyTotalFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
  }

  void opeNewExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('new expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Expense name'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration:
                        const InputDecoration(hintText: 'Expense amount'),
                  )
                ],
              ),
              actions: [
                // cancel button
                _cancelButton(),

                // save button
                _createNewExpenseButton()
              ],
            ));
  }

  // open edit box
  void openEditBox(Expense expense) {
    // pre-fill  existing values
    String existingname = expense.name;
    String existingAmount = expense.amount.toString();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('edit expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: existingname),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: existingAmount),
                  )
                ],
              ),
              actions: [
                // cancel button
                _cancelButton(),

                // save button
                _editExpenseButton(expense)
              ],
            ));
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('delete expense'),
              actions: [
                // cancel button
                _cancelButton(),

                // save button
                _deleteExpenseButton(expense.id)
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        // get dates
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;
        // calculate the number of months since the first month
        int monthCount =
            calculateMonth(startYear, startMonth, currentYear, currentMonth);

        // only display expenses for the current month

        // return ui
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            
            onPressed: opeNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                      future: _monthlyTotalFuture,
                      builder: (context, snapshot) {
                        // data is loaded
                        if (snapshot.connectionState == ConnectionState.done) {
                          final monthlyTotals = snapshot.data ?? {};
                          List<double> monthlySummary = List.generate(
                              monthCount,
                              (index) =>
                                  monthlyTotals[startMonth + index] ?? 0.0);
                          return MyBarGraph(
                              monthlySummary: monthlySummary,
                              startMonth: startMonth);
                        } else {
                          return const Center(
                            child: Text('loading....'),
                          );
                        }
                      }),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: value.allExpense.length,
                    itemBuilder: (context, index) {
                      // get individual expenses
                      Expense individualExpense = value.allExpense[index];

                      return MyListTile(
                        title: individualExpense.name,
                        trailing: formatDouble(individualExpense.amount),
                        onEditPressed: (context) =>
                            openEditBox(individualExpense),
                        onDeletePressed: (context) =>
                            openDeleteBox(individualExpense),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        // pop box
        Navigator.pop(context);

        // clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text('cancel'),
    );
  }

  // save button
  Widget _createNewExpenseButton() {
    return MaterialButton(
        onPressed: () async {
          if (nameController.text.isNotEmpty &&
              amountController.text.isNotEmpty) {
            Navigator.pop(context);
            // create new expense
            Expense newExpense = Expense(
                name: nameController.text,
                amount: convertStringToDouble(amountController.text),
                date: DateTime.now());

            // save to db
            await context.read<ExpenseDatabase>().createNewExpense(newExpense);

            // refresh graph
            refreshGraphData();

            // clear controllers
            nameController.clear();
            amountController.clear();
          }
        },
        child: const Text('save'));
  }

  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          // pop box
          Navigator.pop(context);
          // create a new UPDATED EXPENSE
          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());

          // old expense id
          int existing_id = expense.id;
          // save to db

          await context
              .read<ExpenseDatabase>()
              .updateExpense(existing_id, updatedExpense);

          refreshGraphData();
        }
      },
      child: const Text('save'),
    );
  }

  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // pop box
        Navigator.pop(context);

        // delete the expense
        await context.read<ExpenseDatabase>().deleteExpense(id);

        refreshGraphData();
      },
      child: const Text('delete'),
    );
  }
}
