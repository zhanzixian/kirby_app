import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:kirby/feature_box.dart';
import 'package:kirby/openai_service.dart';
import 'package:kirby/pallete.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    // await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    var localeId = 'en-US';

    var locales = await speechToText.locales();

    if (locales.any((element) => element.localeId == 'zh-CN')) {
      localeId = 'zh-CN';
    }

    await speechToText.listen(onResult: onSpeechResult, localeId: localeId);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.setLanguage("zh-CN");
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Kirby'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  // Center(
                  //   child: Container(
                  //     height: 120,
                  //     width: 120,
                  //     margin: const EdgeInsets.only(top: 4),
                  //     decoration: const BoxDecoration(
                  //         color: Pallete.assistantCircleColor,
                  //         shape: BoxShape.circle),
                  //   ),
                  // ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/virtualAssistant.png'),
                      ),
                    ),
                  )
                ],
              ),
            ),
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 40)
                      .copyWith(top: 30),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Pallete.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        topLeft: Radius.zero,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      generatedContent == null
                          ? '你好，有什么可以帮到您的吗？'
                          : generatedContent!,
                      style: TextStyle(
                          color: Pallete.mainFontColor,
                          fontSize: generatedContent == null ? 16 : 18,
                          fontFamily: 'Cera Pro'),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!)),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    '以下是一些功能建议',
                    style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText: '一种基于GPT-3.5的聊天机器人，可以与您进行对话',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText: '利用由 Dall-E 提供支持的个人助理获取灵感并保持创造力',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay * 2),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: '智能语音助手',
                      descriptionText:
                          '智能语音助手通过 ChatGPT 和 Dall-E 提供的语音助手实现两全其美',
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + delay * 3),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech);
              }
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
