import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kirby/secrets.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIKey',
          },
          body: jsonEncode(
            {
              "model": "gpt-3.5-turbo",
              "messages": [
                {
                  "role": "user",
                  // "content":
                  // "Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.",
                  "content":
                      '该消息是否想要生成人工智能图片、图像、艺术或类似的东西？ $prompt。 只需回答“是”或“否”即可。',
                }
              ]
            },
          ));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        String content = utf8
            .decode(body['choices'][0]['message']['content'].runes.toList());
        content = content.trim();

        debugPrint('--------------$content');

        // switch (content) {
        //   case 'Yes':
        //   case 'yes':
        //   case 'Yes.':
        //   case 'yes.':
        //     final res = await dallEAPI(prompt);
        //     return res;
        //   default:
        //     final res = await chatGPTAPI(prompt);
        //     return res;
        // }
        if (content.contains('是')) {
          final res = await dallEAPI(prompt);
          return res;
        } else {
          final res = await chatGPTAPI(prompt);
          return res;
        }
      }

      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});

    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIKey'
          },
          body: jsonEncode({"model": "gpt-3.5-turbo", "messages": messages}));

      debugPrint(res.body);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        String content = utf8
            .decode(body['choices'][0]['message']['content'].runes.toList());
        content = content.trim();

        messages.add({'role': 'assistant', 'content': content});

        return content;
      }

      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});

    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/images/generations'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIKey'
          },
          body: jsonEncode({
            "prompt": prompt,
            "n": 1,
          }));

      debugPrint(res.body);

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({'role': 'assistant', 'content': imageUrl});

        return imageUrl;
      }

      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
