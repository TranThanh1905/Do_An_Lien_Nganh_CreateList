import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'appbar.dart'; // Import CustomAppBar

class AddTask extends StatefulWidget {
  const AddTask({Key? key}) : super(key: key);

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectedDeadline = DateTime.now(); // Default deadline
  String selectedCategory = 'TODO'; // Default category

  addTaskToFirebase() async {
    String title = titleController.text.trim();
    String description = descriptionController.text.trim();

    // Kiểm tra xem tiêu đề và mô tả có được nhập hay không và có độ dài hợp lệ hay không
    if (title.isEmpty || description.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter title and description');
      return;
    }
    if (title.length > 50) {
      Fluttertoast.showToast(msg: 'Title is too long');
      return;
    }
    if (description.length > 200) {
      Fluttertoast.showToast(msg: 'Description is too long');
      return;
    }

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }
      String uid = user.uid;
      var time = DateTime.now();

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('mytasks')
          .doc(time.toString())
          .set({
        'title': title,
        'description': description,
        'deadline': Timestamp.fromDate(selectedDeadline),
        'timestamp': time,
        'category': selectedCategory, // Save selected category
      });

      // Hiển thị thông báo khi dữ liệu được thêm thành công
      Fluttertoast.showToast(msg: 'Task Added Successfully');
    } catch (error) {
      // Xử lý lỗi và hiển thị thông báo cho người dùng
      print('Error adding task: $error');
      Fluttertoast.showToast(msg: 'Failed to add task. Please try again later');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appName: 'TO DO APP', // Tên ứng dụng của bạn
        slogan: 'All in one!', // Slogan của ứng dụng
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Enter Title',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Enter Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              child: Row(
                children: [
                  Text('Deadline: '),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      _selectDeadline(context);
                    },
                  ),
                  Text(
                      selectedDeadline.toString()), // Display selected deadline
                ],
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              items: <String>['TODO', 'DOING', 'DONE']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Add Task'),
              onPressed: addTaskToFirebase,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDeadline)
      setState(() {
        selectedDeadline = picked;
      });
  }
}
