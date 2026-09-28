import 'package:firebase_ai/firebase_ai.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart';
import '../models/expense.dart';

class AiService {
  final AppDatabase database;

  late final GenerativeModel model;

  AiService(this.database) {
    model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash-preview',
      tools: [
        Tool.functionDeclarations( [
            FunctionDeclaration(
              'add_expense',
              'Add a new expense to the database.',
              parameters: {
                'amount': Schema.number(
                  description: 'Expense amount',
                ),
                'category': Schema.string(
                  description:
                  'Expense category such as Food, Travel or Shopping',
                ),
                'description': Schema.string(
                  description: 'Short description of the expense',
                ),
              },
            ),
            FunctionDeclaration(
              'get_category_total',
              'Get the total amount spent in a category.',
              parameters: {
                'category': Schema.string(
                  description: 'Expense category',
                ),
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<String> ask(String question) async {
    final chat = model.startChat();

    var response = await chat.sendMessage(
      Content.text('''
You are an expense management assistant.

You can help the user manage their expenses.

Use the available tools whenever the user wants to:
- add an expense
- calculate spending
- retrieve expense information

Never invent expense values.

User request:
$question
'''),
    );

    while (response.functionCalls.isNotEmpty) {
      for (final call in response.functionCalls) {
        final result = await _executeTool(
          call.name,
          call.args,
        );

        response = await chat.sendMessage(
          Content.functionResponse(
            call.name,
            result,
          ),
        );
      }
    }

    return response.text ?? 'I could not generate a response.';
  }

  Future<Map<String, Object?>> _executeTool(
      String name,
      Map<String, Object?> args,
      ) async {
    switch (name) {
      case 'add_expense':
        final expense = Expense(
          id: const Uuid().v4(),
          amount: (args['amount'] as num).toDouble(),
          category: args['category'] as String,
          description: args['description'] as String,
          date: DateTime.now(),
        );

        await database.addExpense(expense);

        return {
          'success': true,
          'message': 'Expense added successfully',
          'amount': expense.amount,
          'category': expense.category,
        };

      case 'get_category_total':
        final category = args['category'] as String;

        final total = await database.getTotalByCategory(
          category,
        );

        return {
          'category': category,
          'total': total,
        };

      default:
        return {
          'error': 'Unknown tool: $name',
        };
    }
  }
}