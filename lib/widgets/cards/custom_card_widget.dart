import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    this.imagePath = 'assets/images/discord-logo.png',
    this.title = 'title',
    this.subtitle = '',
    this.imageOpacity = 0.8,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final double imageOpacity;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        clipBehavior: Clip.hardEdge,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2123).withValues(alpha: 0.5),
            borderRadius: BorderRadius.zero,
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              opacity: imageOpacity,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
