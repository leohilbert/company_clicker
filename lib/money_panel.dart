import 'dart:async';
import 'dart:math';

import 'package:company_clicker/money_changed_event.dart';
import 'package:company_clicker/money_particle.dart';
import 'package:flutter/material.dart';

class MoneyPanelWidget extends StatefulWidget {
  const MoneyPanelWidget({
    Key? key,
    required int money,
    required Function() onWork,
    required Random random,
    required StreamController eventController,
  })  : _money = money,
        _onWork = onWork,
        _random = random,
        _eventController = eventController,
        super(key: key);

  final int _money;
  final Function() _onWork;
  final StreamController _eventController;
  final Random _random;

  @override
  _MoneyPanelWidgetState createState() => _MoneyPanelWidgetState();
}

class _MoneyPanelWidgetState extends State<MoneyPanelWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<int>? _animation;

  List<MoneyParticleDto> moneyParticles = [];

  late StreamSubscription eventSubscription;

  @override
  void initState() {
    super.initState();
    this._animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    this.eventSubscription =
        widget._eventController.stream.asBroadcastStream().listen(
              (event) => {
                if (event is MoneyChangedEvent) this.updateMoneyParticles(event)
              },
            );
  }

  @override
  Widget build(BuildContext context) {
    int currentlyDisplayed;
    if (_animation != null) {
      currentlyDisplayed = _animation!.value;
    } else {
      currentlyDisplayed = widget._money;
    }

    _animation = IntTween(begin: currentlyDisplayed, end: widget._money)
        .animate(CurvedAnimation(
            parent: _animationController!, curve: Curves.easeOut));
    _animationController!.reset();
    if ((currentlyDisplayed - widget._money).abs() < 20) {
      // skip animation
      _animationController!.forward(from: 1);
    } else {
      _animationController!.forward();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Stack(
            children: moneyParticles
                .map((e) => MoneyParticle(
                      key: e.key,
                      dto: e,
                      onEnd: () {
                        moneyParticles.remove(e);
                      },
                    ))
                .toList()),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            icon: const Icon(Icons.money),
            iconSize: 100,
            color: Colors.green,
            onPressed: () => widget._onWork(),
          ),
          AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) => Text(
                    '${_animation!.value}€',
                    style: TextStyle(
                        fontSize:
                            // ((_animation!.value - widget._money)/30).toDouble().abs().clamp(30, 50),
                            50,
                        color: Colors.green),
                  ))
        ]),
      ],
    );
  }

  updateMoneyParticles(MoneyChangedEvent event) {
    if (event is MoneyChangedEvent) {
      const maxParticles = 20;
      moneyParticles.add(new MoneyParticleDto(
          UniqueKey(),
          widget._random.nextDouble(),
          widget._random.nextDouble(),
          event.amount));
      if (moneyParticles.length > maxParticles) {
        // high numbers win
        moneyParticles.sort((a, b) => b.amount.compareTo(a.amount));
        moneyParticles.removeRange(maxParticles, moneyParticles.length);
      }
    }
  }

  @override
  void dispose() {
    this.eventSubscription.cancel();
    super.dispose();
  }
}
