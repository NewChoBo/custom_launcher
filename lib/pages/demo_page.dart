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
                        CustomCard(),
                        CustomCard(),
                        CustomCard(),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      spacing: 2,
                      children: <Widget>[
                        CustomCard(),
                        CustomCard(),
                        CustomCard(),
                        CustomCard(),
                        CustomCard(),
                        CustomCard(),
                        CustomCard(),
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
