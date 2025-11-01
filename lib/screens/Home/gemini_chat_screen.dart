import 'package:flutter/material.dart';
import '/utils/route_transitions.dart';
import 'dashboard.dart';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final List<Map<String, String>> _messages = [
    {'from': 'system', 'text': 'Gemini insights will appear here. Ask about conveyor status or predictive checks.'}
  ];
  final TextEditingController _ctrl = TextEditingController();
  bool _sending = false;

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'from': 'user', 'text': text.trim()});
      _sending = true;
      _ctrl.clear();
    });

    // Placeholder response - replace with real model/backend later
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _messages.add({
        'from': 'bot',
        'text': 'Received: "$text". (This is a placeholder response — integration with Gemini will be added later.)'
      });
      _sending = false;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121214),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context, fadeRoute(const DashboardScreen())),
        ),
        title: const Text('Insights (Gemini)', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This is a cosmetic chat screen. Backend will be connected later.')),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isUser = m['from'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF18D8FF) : const Color(0xFF232323),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m['text'] ?? '',
                        style: TextStyle(color: isUser ? Colors.black : Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: const Color(0xFF0B0B0C),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ask about conveyor status, predictions, anomalies...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  _sending
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF18D8FF)),
                          onPressed: () => _send(_ctrl.text),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}