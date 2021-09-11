import 'dart:async';
import 'dart:math';

import 'package:company_clicker/employee_card.dart';
import 'package:company_clicker/money_gained_event.dart';
import 'package:company_clicker/money_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

void main() => runApp(const CompanyClickerApp());

class CompanyClickerApp extends StatelessWidget {
  const CompanyClickerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Company Clicker',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const CompanyClicker());
  }
}

class CompanyClicker extends StatefulWidget {
  const CompanyClicker({Key? key}) : super(key: key);

  @override
  _CompanyClickerState createState() => _CompanyClickerState();
}

class _CompanyClickerState extends State<CompanyClicker> {
  int _money = 0;
  StreamController<MoneyGainedEvent> eventController =
      StreamController<MoneyGainedEvent>.broadcast();

  final List<Employee> employees = [
    Employee('Unpaid Intern', "makes coffee", Icons.face, 15, 2, 0.5),
    Employee('Intern', "makes better coffee", Icons.face, 100, 2, 1),
    Employee('Trainee', "eager to learn", Icons.face, 1100, 8, 1),
    Employee('Lazy Co-Worker', "only here to browse facebook", Icons.face,
        12000, 47, 1),
    Employee('College-Grad', "knows everything", Icons.face, 130000, 260, 1),
    Employee('9-5er', "production is down? i'll check on monday", Icons.face,
        1400000, 1400, 1),
    Employee('Motivated Employee', "i have no personal life", Icons.face,
        20000000, 7800, 1),
    Employee('Senior', "i'm old", Icons.face, 330000000, 44000, 1),
    Employee('CEO', "MORE GROWTH", Icons.face, 5100000000, 260000, 1),
    Employee(
        'Company Owner', "MORE MONEY", Icons.face, 75000000000, 1600000, 1),
    Employee(
        'Government', "MORE TAXES", Icons.face, 1000000000000, 10000000, 1),
    Employee('Government Government', "controls.. the government..?",
        Icons.face, 14000000000000, 65000000, 1),
    Employee('Ruler', "o_o", Icons.face, 170000000000000, 430000000, 1),
    Employee('Literal God', "", Icons.face, 2100000000000000, 2900000000, 1),
  ];

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
                  money: _money,
                  onWork: () => updateMoney(1),
                  eventController: eventController),
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: employees
                    .map((employee) => EmployeeCard(
                        key: employee.key,
                        employee: employee,
                        onHire: () => hireEmployee(employee),
                        onUpgrade: () => upgradeEmployee(employee),
                        buyAffordable: _money ~/ employee.cost,
                        upgradeAffordable: _money ~/ employee.upgradeCost()))
                    .toList(),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                child: Text("Cheat"),
                onPressed: () => updateMoney(1000),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void hireEmployee(Employee employee) {
    updateMoney(-employee.cost);
    return setState(() {
      employee.amount++;

      Timer.periodic(
          Duration(milliseconds: (1000 / employee.clicksPerSecond).round()),
          (timer) {
        updateMoney(pow(employee.moneyPerTick, employee.upgradeLevel).toInt());
      });
    });
  }

  void upgradeEmployee(Employee employee) {
    updateMoney(-employee.upgradeCost());
    return setState(() {
      employee.upgradeLevel++;
    });
  }

  void updateMoney(int amount) {
    setState(() {
      _money += amount;
      for (var employee in employees) {
        if (_money >= employee.cost) {
          employee.visible = true;
        }
      }
      eventController.sink.add(new MoneyGainedEvent(amount));
    });
  }

  @override
  void dispose() {
    eventController.close();
    super.dispose();
  }
}

class Employee {
  final Key key = UniqueKey();
  String name;
  String description;
  IconData icon;
  int cost;
  double clicksPerSecond;
  int moneyPerTick;
  int amount = 0;
  int upgradeLevel = 1;
  bool visible = false;

  Employee(this.name, this.description, this.icon, this.cost, this.moneyPerTick,
      this.clicksPerSecond);

  upgradeCost() {
    return cost * pow(10, upgradeLevel);
  }
}
