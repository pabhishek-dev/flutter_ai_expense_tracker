import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense.dart';

class AppDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(
      await getDatabasesPath(),
      'expenses.db',
    );

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            description TEXT,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addExpense(Expense expense) async {
    final db = await database;

    await db.insert(
      'expenses',
      expense.toMap(),
    );
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;

    final result = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );

    return result
        .map((map) => Expense.fromMap(map))
        .toList();
  }

  Future<double> getTotalByCategory(
      String category,
      ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM expenses
      WHERE LOWER(category) = LOWER(?)
      ''',
      [category],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }
}