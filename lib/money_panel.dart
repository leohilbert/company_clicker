import 'dart:async';
import 'dart:math';

import 'package:company_clicker/money_gained_event.dart';
import 'package:company_clicker/money_particle.dart';
import 'package:flutter/material.dart';

class MoneyPanelWidget extends StatefulWidget {
  const MoneyPanelWidget({
    Key? key,
    required int money,
    required Function() onWork,
    required StreamController eventController,
  })  : _money = money,
        _onWork = onWork,
        _eventController = eventController,
        super(key: key);

  final int _money;
  final Function() _onWork;
  final StreamController _eventController;

  @override
  _MoneyPanelWidgetState createState() => _MoneyPanelWidgetState();
}

class _MoneyPanelWidgetState extends State<MoneyPanelWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<int>? _animation;

  List<MoneyParticleDto> moneyParticles = [];

  late StreamSubscription eventSubscription;
  Random random = new Random();

  @override
  void initState() {
    super.initState();
    this._animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    this.eventSubscription =
        widget._eventController.stream.asBroadcastStream().listen(
              (event) => {
                if (event is MoneyGainedEvent)
                  {
                    moneyParticles.add(new MoneyParticleDto(UniqueKey(),
                        random.nextDouble(), random.nextDouble(), event.amount))
                  },
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

  @override
  void dispose() {
    this.eventSubscription.cancel();
    super.dispose();
  }
}
