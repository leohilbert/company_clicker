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
    Employee('Intern', "Needs a lot of help", Icons.face, 15, 1, 1000),
    Employee('Trainee', "Great effort", Icons.face, 100, 2, 1000),
    Employee('Lazy Co-Worker', "I'm still working on that one thing..",
        Icons.face, 1000, 3, 1000),
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
                        employee: employee,
                        onHire: () => hireEmployee(employee),
                        affordable: _money ~/ employee.cost))
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
    return setState(() {
      _money -= employee.cost;
      employee.amount++;

      Timer.periodic(Duration(milliseconds: employee.speed), (timer) {
        updateMoney(employee.moneyPerTick);
      });
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
  String name;
  IconData icon;
  int amount = 0;
  int cost;
  int moneyPerTick;
  int speed;
  String description;
  bool visible = false;

  Employee(this.name, this.description, this.icon, this.cost, this.moneyPerTick,
      this.speed);
}
