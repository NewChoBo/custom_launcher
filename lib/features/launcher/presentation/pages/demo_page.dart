import 'package:custom_launcher/features/launcher/presentation/widgets/cards/custom_card_widget.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:reorderables/reorderables.dart'; // Reorderables 패키지 import

// 카드 데이터 모델 클래스 정의
class CardData {
  final String key;
  final String title;
  final String subtitle;
  final String imagePath;
  final String? executablePath;
  final List<String>? arguments;

  CardData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.executablePath,
    this.arguments,
  });
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late List<CardData> _topRowCardData; // 첫 번째 줄 카드 데이터를 담을 리스트
  late List<CardData> _bottomRowCardData; // 두 번째 줄 카드 데이터를 담을 리스트
  late ScrollController _topRowScrollController;
  late ScrollController _bottomRowScrollController;

  @override
  void initState() {
    super.initState();
    _topRowScrollController = ScrollController();
    _bottomRowScrollController = ScrollController();

    _topRowCardData = <CardData>[
      CardData(
        key: 'steam',
        title: 'Steam',
        subtitle: 'Steam Games Launcher',
        imagePath: 'assets/images/Steam_icon_logo.png',
        executablePath: 'D:/Games/Steam/steam.exe',
      ),
      CardData(
        key: 'epic_games',
        title: 'Epic Games',
        subtitle: 'Epic Games / Unreal Engine',
        imagePath: 'assets/images/Unreal-Engine-Splash-Screen.jpg',
      ),
      CardData(
        key: 'discord',
        title: 'Discord',
        subtitle: 'Discord Launcher',
        imagePath: 'assets/images/discord-logo.png',
        executablePath:
            r'C:\Users\' +
            Platform.environment['USERNAME']! +
            r'\AppData\Local\Discord\Discord.exe',
        arguments: <String>[],
      ),
    ];

    _bottomRowCardData = <CardData>[
      CardData(
        key: 'rainbow_six',
        title: 'Rainbow Six',
        subtitle: 'Rainbow Six Siege',
        imagePath: 'assets/images/IQ_-_Full_Body.webp',
      ),
      CardData(
        key: 'dying_light_2',
        title: 'Dying Light 2',
        subtitle: 'Dying Light 2',
        imagePath: 'assets/images/dyinglight2.jpg',
      ),
      CardData(
        key: 'half_life_alyx',
        title: 'Half-Life Alyx',
        subtitle: 'Half-Life Alyx',
        imagePath: 'assets/images/alyx_feature2.jpg',
      ),
      CardData(
        key: 'palworld',
        title: 'Palworld',
        subtitle: 'Palworld',
        imagePath: 'assets/images/palworld.jpg',
      ),
      CardData(
        key: 'cyberpunk_2077',
        title: 'Cyberpunk 2077',
        subtitle: 'Cyberpunk 2077',
        imagePath: 'assets/images/cyberpunk.webp',
      ),
    ];
  }

  void _onReorderTopRow(int oldIndex, int newIndex) {
    setState(() {
      int targetIndex = newIndex;
      final int maxIndex = _topRowCardData.length;
      if (targetIndex > oldIndex && targetIndex != maxIndex) {
        targetIndex -= 1;
      }
      if (targetIndex > maxIndex) targetIndex = maxIndex;
      if (oldIndex == targetIndex) return;
      final CardData card = _topRowCardData.removeAt(oldIndex);
      _topRowCardData.insert(targetIndex, card);
    });
  }

  void _onReorderBottomRow(int oldIndex, int newIndex) {
    setState(() {
      int targetIndex = newIndex;
      final int maxIndex = _bottomRowCardData.length;
      if (targetIndex > oldIndex && targetIndex != maxIndex) {
        targetIndex -= 1;
      }
      if (targetIndex > maxIndex) targetIndex = maxIndex;
      if (oldIndex == targetIndex) return;
      final CardData card = _bottomRowCardData.removeAt(oldIndex);
      _bottomRowCardData.insert(targetIndex, card);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double cardHorizontalPadding = 2.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double topCardWidth = screenWidth / _topRowCardData.length;
    final double bottomCardWidth = screenWidth / _bottomRowCardData.length;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ReorderableRow(
                    scrollController: _topRowScrollController,
                    children: _topRowCardData.map((data) {
                      return SizedBox(
                        key: ValueKey(data.key),
                        width: topCardWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: cardHorizontalPadding,
                          ),
                          child: CustomCard(
                            title: data.title,
                            subtitle: data.subtitle,
                            imagePath: data.imagePath,
                            executablePath: data.executablePath,
                            arguments: data.arguments,
                          ),
                        ),
                      );
                    }).toList(),
                    onReorder: _onReorderTopRow,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ReorderableRow(
                    scrollController: _bottomRowScrollController,
                    children: _bottomRowCardData.map((data) {
                      return SizedBox(
                        key: ValueKey(data.key),
                        width: bottomCardWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: cardHorizontalPadding,
                          ),
                          child: CustomCard(
                            title: data.title,
                            subtitle: data.subtitle,
                            imagePath: data.imagePath,
                            executablePath: data.executablePath,
                            arguments: data.arguments,
                          ),
                        ),
                      );
                    }).toList(),
                    onReorder: _onReorderBottomRow,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
