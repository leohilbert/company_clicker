import 'dart:async';
import 'dart:math';

import 'package:company_clicker/employee_card.dart';
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
        theme: ThemeData(),
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

  final List<Employee> employees = [
    Employee('Intern', Icons.face, 15, 1, "Needs a lot of help"),
    Employee('Trainee', Icons.face, 100, 2, "Great effort"),
    Employee('Lazy Co-Worker', Icons.face, 1000, 3,
        "I'm still working on that one thing.."),
  ];

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      for (var employee in employees) {
        updateMoney(employee.amount * employee.work);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          alignment: Alignment.center,
          child: Column(children: [
            SizedBox(
              height: max(MediaQuery.of(context).size.height * 0.4, 200),
              child:
                  MoneyPanelWidget(money: _money, onWork: () => updateMoney(1)),
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
          ]),
        ),
      ),
    );
  }

  void hireEmployee(Employee employee) {
    return setState(() {
      _money -= employee.cost;
      employee.amount++;
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
    });
  }
}

class Employee {
  String name;
  IconData icon;
  int amount = 0;
  int cost;
  int work;
  String description;
  bool visible = false;

  Employee(this.name, this.icon, this.cost, this.work, this.description);
}
