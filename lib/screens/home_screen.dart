import 'package:flutter/material.dart';

import '../data/database.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = TextEditingController();

  late final AiService aiService;

  String response = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();

    aiService = AiService(
      AppDatabase(),
    );
  }

  Future<void> sendMessage() async {
    final question = controller.text.trim();

    if (question.isEmpty) return;

    setState(() {
      loading = true;
      response = '';
    });

    try {
      final result = await aiService.ask(question);

      setState(() {
        response = result;
      });
    } catch (e) {
      setState(() {
        response = 'Error: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketPilot AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText:
                'Ask something about your expenses...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : sendMessage,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Ask AI'),
              ),
            ),

            const SizedBox(height: 24),

            if (response.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(response),
                ),
              ),
          ],
        ),
      ),
    );
  }
}