import 'package:company_clicker/persistence.dart';
import 'package:flutter/material.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final Function() onHire;
  final Function() onUpgrade;
  final int buyAffordable;
  final int upgradeAffordable;

  const EmployeeCard({
    required Key key,
    required this.employee,
    required this.onHire,
    required this.onUpgrade,
    required this.buyAffordable,
    required this.upgradeAffordable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    if (!employee.visible) {
      return ListTile(
        title: Text("??? (${employee.cost})"),
      );
    }
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: Icon(employee.icon),
              title: Text(employee.name),
              subtitle: Text(
                employee.description,
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => buyAffordable > 0 ? onHire.call() : null,
                  child: Text(
                    "Hire (Costs ${employee.cost})",
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: buyAffordable > 0 ? Colors.blue : Colors.black12,
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      upgradeAffordable > 0 ? onUpgrade.call() : null,
                  child: Text(
                    "Upgrade (Costs ${employee.upgradeCost()})",
                  ),
                  style: ElevatedButton.styleFrom(
                    primary:
                        upgradeAffordable > 0 ? Colors.blue : Colors.black12,
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: [
                Text(
                  'You have',
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
                Text(
                  '${employee.amount}',
                  style: TextStyle(
                      fontSize: 20, color: Colors.black.withOpacity(0.6)),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
