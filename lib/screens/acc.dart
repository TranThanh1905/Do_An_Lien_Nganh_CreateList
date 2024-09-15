import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'appbar.dart'; // Import CustomAppBar

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late User _user;
  late String _firstName;
  late String _email;
  int _doneCount = 0;
  int _doingCount = 0;
  int _todoCount = 0;
  int _totalCount = 0;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _fetchTaskCounts(_selectedMonth);
  }

  void _getUserInfo() async {
    _user = FirebaseAuth.instance.currentUser!;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();
    setState(() {
      _firstName = userSnapshot['firstName'];
      _email = userSnapshot['email'];
    });
  }

  void _fetchTaskCounts(int selectedMonth) async {
    // Truy vấn dữ liệu từ Firebase cho các công việc đã hoàn thành trong tháng đã chọn
    QuerySnapshot completedTasks = await FirebaseFirestore.instance
        .collection('tasks')
        .doc(_user.uid)
        .collection('mytasks')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime(DateTime.now().year, selectedMonth, 1)))
        .where('timestamp',
            isLessThan: Timestamp.fromDate(
                DateTime(DateTime.now().year, selectedMonth + 1, 1)))
        .get();

    int doneCount = 0;
    int doingCount = 0;
    int todoCount = 0;

    completedTasks.docs.forEach((doc) {
      String category = doc['category'];
      if (category == 'DONE') {
        doneCount++;
      } else if (category == 'DOING') {
        doingCount++;
      } else if (category == 'TODO') {
        todoCount++;
      }
    });

    setState(() {
      _doneCount = doneCount;
      _doingCount = doingCount;
      _todoCount = todoCount;
      _totalCount = doneCount + doingCount + todoCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appName: 'TO DO APP',
        slogan: 'All in one!',
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Thông tin cá nhân:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            UserInfoItem(label: 'Tên người dùng:', value: _firstName),
            UserInfoItem(label: 'Email:', value: _email),
            SizedBox(height: 20),
            Text(
              'Thống kê công việc theo tháng:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedMonth,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('Tháng ${index + 1}'),
                      );
                    }),
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                          _fetchTaskCounts(_selectedMonth);
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _fetchTaskCounts(_selectedMonth);
                  },
                  child: Text('Thống kê'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: true, border: Border.all()),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barsSpace: 12,
                      barRods: [
                        BarChartRodData(
                          y: _doneCount.toDouble(),
                          width: 20,
                          colors: [Colors.green],
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barsSpace: 12,
                      barRods: [
                        BarChartRodData(
                          y: _doingCount.toDouble(),
                          width: 20,
                          colors: [Colors.blue],
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barsSpace: 12,
                      barRods: [
                        BarChartRodData(
                          y: _todoCount.toDouble(),
                          width: 20,
                          colors: [Colors.orange],
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barsSpace: 12,
                      barRods: [
                        BarChartRodData(
                          y: _totalCount.toDouble(),
                          width: 20,
                          colors: [Colors.red],
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) => const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      margin: 16,
                      getTitles: (double value) {
                        switch (value.toInt()) {
                          case 0:
                            return 'Done';
                          case 1:
                            return 'Doing';
                          case 2:
                            return 'Todo';
                          case 3:
                            return 'Total';
                          default:
                            return '';
                        }
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) => const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      margin: 16,
                      getTitles: (double value) {
                        return value.toInt().toString();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}

class UserInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const UserInfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
