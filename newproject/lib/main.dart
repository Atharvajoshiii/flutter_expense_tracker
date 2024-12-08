import 'package:flutter/material.dart';
import 'package:newproject/database/expense_database.dart';
import 'package:newproject/pages/HomePage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ExpenseDatabase.initialize();
  runApp(ChangeNotifierProvider(
    create: (context)=>ExpenseDatabase(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Optional: Remove debug banner
      home: Scaffold(
        body: Homepage(), // Ensure `HomePage` is properly imported and defined
      ),
    );
  }
}
