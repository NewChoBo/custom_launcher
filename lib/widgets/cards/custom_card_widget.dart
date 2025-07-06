import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2123).withValues(alpha: 0.5),
          borderRadius: BorderRadius.zero,
          image: const DecorationImage(
            image: AssetImage('assets/images/discord-logo.png'), // 정확한 에셋 경로
            fit: BoxFit.cover, // 이미지 크기 조정 방식
            opacity: 0.3, // 이미지 투명도 (0.0-1.0)
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Euro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text(
                        '6 428 ',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
              Transform.scale(
                scale: 2.2,
                child: Transform.translate(
                  offset: const Offset(-5, 12),
                  child: const Icon(
                    Icons.euro_rounded,
                    color: Colors.white,
                    size: 88,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
