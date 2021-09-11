import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Persistence {
  int _money = 0;

  int get money => _money;

  final List<Employee> employees = [
    Employee(0, 'Unpaid Intern', "makes coffee", Icons.face, 15, 2, 0.5),
    Employee(1, 'Intern', "makes better coffee", Icons.face, 100, 2, 1),
    Employee(2, 'Trainee', "eager to learn", Icons.face, 1100, 8, 1),
    Employee(3, 'Lazy Co-Worker', "only here to browse facebook", Icons.face,
        12000, 47, 1),
    Employee(4, 'College-Grad', "knows everything", Icons.face, 130000, 260, 1),
    Employee(5, '9-5er', "production is down? i'll check on monday", Icons.face,
        1400000, 1400, 1),
    Employee(6, 'Motivated Employee', "i have no personal life", Icons.face,
        20000000, 7800, 1),
    Employee(7, 'Senior', "i'm old", Icons.face, 330000000, 44000, 1),
    Employee(8, 'CEO', "MORE GROWTH", Icons.face, 5100000000, 260000, 1),
    Employee(
        9, 'Company Owner', "MORE MONEY", Icons.face, 75000000000, 1600000, 1),
    Employee(
        10, 'Government', "MORE TAXES", Icons.face, 1000000000000, 10000000, 1),
    Employee(11, 'Government Government', "controls.. the government..?",
        Icons.face, 14000000000000, 65000000, 1),
    Employee(12, 'Ruler', "o_o", Icons.face, 170000000000000, 430000000, 1),
    Employee(
        13, 'Literal God', "", Icons.face, 2100000000000000, 2900000000, 1),
  ];

  final SharedPreferences pref;

  Persistence(this.pref) {
    readPreferences();
  }

  void readPreferences() {
    _money = pref.getInt("money") ?? 0;
    employees.forEach((e) {
      e.amount = pref.getInt("${e.id}.amount") ?? 0;
      e.upgradeLevel = pref.getInt("${e.id}.upgradeLevel") ?? 1;
      e.visible = pref.getBool("${e.id}.visible") ?? false;
    });
  }

  void updateMoney(int amount) {
    _money += amount;
    pref.setInt("money", _money);
    for (var employee in employees) {
      if (_money >= employee.cost) {
        employee.visible = true;
        pref.setBool("${employee.id}.visible", true);
      }
    }
  }

  void hireEmployee(Employee employee) {
    employee.amount++;
    pref.setInt("${employee.id}.amount", employee.amount);
  }

  void upgradeEmployee(Employee employee) {
    employee.upgradeLevel++;
    pref.setInt("${employee.id}.upgradeLevel", employee.upgradeLevel);
  }

  void reset() {
    pref.clear();
    readPreferences();
  }
}

class Employee {
  final Key key = UniqueKey();
  final int id;
  final String name;
  final String description;
  final IconData icon;
  final int cost;
  final double clicksPerSecond;
  final int moneyPerTick;

  int amount = 0;
  int upgradeLevel = 1;
  bool visible = false;

  Employee(this.id, this.name, this.description, this.icon, this.cost,
      this.moneyPerTick, this.clicksPerSecond);

  upgradeCost() {
    return cost * pow(10, upgradeLevel);
  }
}
