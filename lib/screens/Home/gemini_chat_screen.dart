import 'dart:convert';
import 'package:flutter/material.dart';
import '/utils/route_transitions.dart';
import 'dashboard.dart';
import 'package:http/http.dart' as http;

const String kGeminiApiKey = 'AIzaSyCQl1w49W-IqFirOsFh90uSQnvxCzoeGVY';

const String kGeminiSystemPrompt = '''
You are a conveyor belt maintenance assistant. Follow these rules strictly:

RESPONSE FORMAT:
- Keep answers under 150 words
- Use bullet points (•) for lists
- Use CAPS for important terms
- Use numbered steps (1., 2., 3.) for procedures

CONTENT RULES:
- Answer ONLY the specific question asked
- No generic explanations unless requested
- For anomalies: state issue → cause → action (3-5 sentences max)
- For predictions: confidence level + key metric + timeframe
- For diagnostics: most likely cause first, then alternatives

TONE:
- Direct and respectful
- Assume operator knowledge
- Technical but not academic

If asked about something outside conveyor systems, reply: "I specialize in conveyor belt operations. Please ask about system status, maintenance, or troubleshooting."
''';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final List<Map<String, String>> _messages = [
    {'from': 'system', 'text': 'Insights Ready\n\nAsk about:\n• System anomalies\n• Predictive maintenance\n• Diagnostics\n• Performance metrics'}
  ];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _sending = false;

  Future<String> _callGeminiApi(String userMessage) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent?key=$kGeminiApiKey'
    );

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': '$kGeminiSystemPrompt\n\nUser Question: $userMessage\n\nProvide a concise, formatted answer:'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'topK': 20,
        'topP': 0.8,
        'maxOutputTokens': 512,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          if (candidate['content'] != null && 
              candidate['content']['parts'] != null &&
              candidate['content']['parts'].isNotEmpty) {
            return candidate['content']['parts'][0]['text'] ?? 'No response generated.';
          }
        }
        
        if (data['promptFeedback'] != null && 
            data['promptFeedback']['blockReason'] != null) {
          return '⚠️ Response blocked due to safety settings: ${data['promptFeedback']['blockReason']}';
        }
        
        return '⚠️ Unable to generate response. Please try rephrasing your question.';
      } else {
        final errorData = jsonDecode(response.body);
        return '❌ API Error: ${errorData['error']?['message'] ?? 'Unknown error occurred'}';
      }
    } catch (e) {
      return '❌ Connection error: ${e.toString()}';
    }
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({'from': 'user', 'text': text.trim()});
      _sending = true;
      _ctrl.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final botText = await _callGeminiApi(text.trim());
      
      if (!mounted) return;
      setState(() {
        _messages.add({'from': 'bot', 'text': botText});
        _sending = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({'from': 'bot', 'text': '❌ Error: ${e.toString()}'});
        _sending = false;
      });
    }
  }

  List<TextSpan> _parseInlineFormatting(String text, bool isUser) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*|`(.*?)`|__(.*?)__|(\*[^*]+\*)');
    int lastIndex = 0;
    
    for (final match in regex.allMatches(text)) {
      // Add text before match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ));
      }
      
      // Bold (**text**)
      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: isUser ? Colors.black : const Color(0xFF18D8FF),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
        ));
      }
      // Code (`text`)
      else if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: TextStyle(
            color: const Color(0xFF18D8FF),
            fontSize: 14,
            fontFamily: 'monospace',
            backgroundColor: Colors.black.withOpacity(0.3),
            height: 1.5,
          ),
        ));
      }
      // Underline (__text__)
      else if (match.group(3) != null) {
        spans.add(TextSpan(
          text: match.group(3),
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 15,
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFF18D8FF),
            height: 1.5,
          ),
        ));
      }
      // Italic (*text*)
      else if (match.group(4) != null) {
        spans.add(TextSpan(
          text: match.group(4)!.replaceAll('*', ''),
          style: TextStyle(
            color: isUser ? Colors.black87 : Colors.white70,
            fontSize: 15,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ));
      }
      
      lastIndex = match.end;
    }
    
    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          color: isUser ? Colors.black : Colors.white,
          fontSize: 15,
          height: 1.5,
        ),
      ));
    }
    
    return spans;
  }

  Widget _buildFormattedText(String text, bool isUser) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    
    for (var line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      
      // Bullet points
      if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
        final content = line.replaceFirst(RegExp(r'^[\s•\-]+'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(
                  color: isUser ? Colors.black87 : const Color(0xFF18D8FF),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseInlineFormatting(content, isUser),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Numbered lists
      else if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        final match = RegExp(r'^(\d+\.)(.*)').firstMatch(line.trim());
        if (match != null) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.group(1)} ',
                    style: TextStyle(
                      color: isUser ? Colors.black87 : const Color(0xFF18D8FF),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: _parseInlineFormatting(match.group(2)!.trim(), isUser),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
      // Headers (lines with emojis at start)
      else if (line.trim().startsWith('🤖') || line.trim().startsWith('⚠️') || line.trim().startsWith('✓')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: line.trim(),
                    style: TextStyle(
                      color: isUser ? Colors.black : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      // Regular text with inline formatting
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: RichText(
              text: TextSpan(
                children: _parseInlineFormatting(line.trim(), isUser),
              ),
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF18D8FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF18D8FF), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('AI Insights', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined, color: Colors.white70),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add({
                  'from': 'system', 
                  'text': '🤖 Chat Cleared\n\nReady for new questions about conveyor operations.'
                });
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1C),
                  title: const Text('About AI Insights', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Powered by Google Gemini AI\n\n'
                    '• Specialized for conveyor belt operations\n'
                    '• Provides diagnostics and predictions\n'
                    '• Optimized for quick, accurate answers\n\n'
                    'Tip: Ask specific questions for best results.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it', style: TextStyle(color: Color(0xFF18D8FF))),
                    ),
                  ],
                ),
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
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isUser = m['from'] == 'user';
                  final isSystem = m['from'] == 'system';
                  
                  if (isSystem) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF18D8FF).withOpacity(0.1),
                            const Color(0xFF18D8FF).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF18D8FF).withOpacity(0.3)),
                      ),
                      child: _buildFormattedText(m['text'] ?? '', false),
                    );
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF18D8FF), Color(0xFF0EA5E9)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF18D8FF).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(Icons.smart_toy, color: Colors.black, size: 20),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFF18D8FF) : const Color(0xFF1A1A1C),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3), 
                                  blurRadius: 8, 
                                  offset: const Offset(0, 2)
                                )
                              ],
                              border: isUser ? null : Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: _buildFormattedText(m['text'] ?? '', isUser),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            if (_sending)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF18D8FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Analyzing...',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0B0C),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF18D8FF).withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Ask about conveyor status...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _send,
                        enabled: !_sending,
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF18D8FF), Color(0xFF0EA5E9)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF18D8FF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.black),
                      onPressed: _sending ? null : () => _send(_ctrl.text),
                    ),
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