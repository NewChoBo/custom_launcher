import 'package:custom_launcher/widgets/cards/custom_card_widget.dart';
import 'package:flutter/material.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      spacing: 2,
                      children: <Widget>[
                        CustomCard(
                          title: 'Steam',
                          subtitle: 'Steam Games Launcher',
                          imagePath: 'assets/images/Steam_icon_logo.png',
                        ),
                        CustomCard(
                          title: 'Epic Games',
                          subtitle: 'Epic Games / Unreal Engine',
                          imagePath:
                              'assets/images/Unreal-Engine-Splash-Screen.jpg',
                        ),
                        CustomCard(
                          title: 'Discord',
                          subtitle: 'Discord Launcher',
                          imagePath: 'assets/images/discord-logo.png',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      spacing: 2,
                      children: <Widget>[
                        CustomCard(
                          title: 'Rainbow Six',
                          subtitle: 'Rainbow Six Siege',
                          imagePath: 'assets/images/IQ_-_Full_Body.webp',
                        ),
                        CustomCard(
                          title: 'Dying Light 2',
                          subtitle: 'Dying Light 2',
                          imagePath: 'assets/images/dyinglight2.jpg',
                        ),
                        CustomCard(
                          title: 'Half-Life Alyx',
                          subtitle: 'Half-Life Alyx',
                          imagePath: 'assets/images/alyx_feature2.jpg',
                        ),
                        CustomCard(
                          title: 'Palworld',
                          subtitle: 'Palworld',
                          imagePath: 'assets/images/palworld.jpg',
                        ),
                        CustomCard(
                          title: 'Cyberpunk 2077',
                          subtitle: 'Cyberpunk 2077',
                          imagePath: 'assets/images/cyberpunk.webp',
                        ),
                      ],
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
