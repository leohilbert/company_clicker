import 'package:flutter/material.dart';

class MoneyParticle extends StatelessWidget {
  final MoneyParticleDto dto;
  final VoidCallback onEnd;

  const MoneyParticle({Key? key, required this.dto, required this.onEnd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: new Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Align(
          alignment: FractionalOffset(dto.startX, dto.startY - (0.2 * value)),
          child: Text(
            '${dto.amount}',
            style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(
                    (255.0 - value * 255.0).round(), 255, 255, 255)),
          ),
        );
      },
      onEnd: this.onEnd,
    );
  }
}

class MoneyParticleDto {
  Key key;

  double startX;
  double startY;
  int amount;

  MoneyParticleDto(this.key, this.startX, this.startY, this.amount);
}
