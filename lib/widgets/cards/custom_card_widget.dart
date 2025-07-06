import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key});

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
            image: const DecorationImage(
              image: AssetImage('assets/images/discord-logo.png'),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
