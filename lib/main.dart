import 'dart:async';
import 'dart:math';

import 'package:company_clicker/employee_card.dart';
import 'package:company_clicker/money_changed_event.dart';
import 'package:company_clicker/money_panel.dart';
import 'package:company_clicker/persistence.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CompanyClickerApp(prefs: await SharedPreferences.getInstance()));
}

class CompanyClickerApp extends StatelessWidget {
  final Persistence persistence;

  CompanyClickerApp({Key? key, required SharedPreferences prefs})
      : persistence = new Persistence(prefs),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Company Clicker',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
        ),
        home: CompanyClicker(persistence));
  }
}

class CompanyClicker extends StatefulWidget {
  final Persistence persistence;

  CompanyClicker(this.persistence, {Key? key}) : super(key: key);

  @override
  _CompanyClickerState createState() => _CompanyClickerState();
}

class _CompanyClickerState extends State<CompanyClicker> {
  StreamController<MoneyChangedEvent> eventController =
      StreamController<MoneyChangedEvent>.broadcast();
  Random _random = new Random();

  @override
  void initState() {
    super.initState();

    widget.persistence.employees.forEach((employee) {
      for (int i = 1; i <= employee.amount; i++) {
        Future.delayed(
            Duration(milliseconds: (_random.nextDouble() * 2000).toInt()), () {
          startEmployeeTimer(i, employee);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          alignment: Alignment.center,
          child: Column(children: [
            SizedBox(
              height: max(MediaQuery.of(context).size.height * 0.4, 200),
              child: MoneyPanelWidget(
                money: widget.persistence.money,
                onWork: () => updateMoney(1),
                eventController: eventController,
                random: _random,
              ),
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: widget.persistence.employees
                    .map((employee) => EmployeeCard(
                        key: employee.key,
                        employee: employee,
                        onHire: () => hireEmployee(employee),
                        onUpgrade: () => upgradeEmployee(employee),
                        buyAffordable:
                            widget.persistence.money ~/ employee.cost,
                        upgradeAffordable:
                            widget.persistence.money ~/ employee.upgradeCost()))
                    .toList(),
              ),
            ),
            Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: TextButton(
                    child: Text("Reset"),
                    onPressed: () => reset(),
                  ),
                ),
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: TextButton(
                //     child: Text("Cheat"),
                //     onPressed: () => updateMoney(1000),
                //   ),
                // ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  updateMoney(int money) {
    setState(() {
      widget.persistence.updateMoney(money);
      eventController.sink.add(new MoneyChangedEvent(money));
    });
  }

  void hireEmployee(Employee employee) {
    updateMoney(-employee.cost);
    return setState(() {
      widget.persistence.hireEmployee(employee);

      startEmployeeTimer(employee.amount, employee);
    });
  }

  reset() {
    return setState(() {
      widget.persistence.reset();
    });
  }

  void startEmployeeTimer(int employeeNumber, Employee employee) {
    Timer.periodic(
        Duration(milliseconds: (1000 / employee.clicksPerSecond).round()),
        (timer) {
      //print("${employee.name} -> ${employeeNumber}");
      if (employee.amount >= employeeNumber) {
        updateMoney(pow(employee.moneyPerTick, employee.upgradeLevel).toInt());
      } else {
        timer.cancel();
      }
    });
  }

  void upgradeEmployee(Employee employee) {
    updateMoney(-employee.upgradeCost());
    return setState(() {
      widget.persistence.upgradeEmployee(employee);
    });
  }

  @override
  void dispose() {
    eventController.close();
    super.dispose();
  }
}
