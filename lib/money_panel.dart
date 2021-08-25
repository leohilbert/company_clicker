import 'package:flutter/material.dart';

class MoneyPanelWidget extends StatefulWidget {
  const MoneyPanelWidget({
    Key? key,
    required int money,
    required Function() onWork,
  })  : _money = money,
        _onWork = onWork,
        super(key: key);

  final int _money;
  final Function() _onWork;

  @override
  _MoneyPanelWidgetState createState() => _MoneyPanelWidgetState();
}

class _MoneyPanelWidgetState extends State<MoneyPanelWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<int>? _animation;

  @override
  void initState() {
    super.initState();
    this._animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
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
    if ((currentlyDisplayed - widget._money).abs() < 10) {
      // skip animation
      _animationController!.forward(from: 1);
    } else {
      _animationController!.forward();
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
    ]);
  }
}
