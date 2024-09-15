import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appName;
  final String slogan;
  final List<Widget>? actions; // Thêm tham số actions

  const CustomAppBar({
    Key? key,
    required this.appName,
    required this.slogan,
    this.actions, // Đánh dấu tham số này là tùy chọn
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 16),
        child: Column(
          children: [
            Text(
              appName, // Tên ứng dụng
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Roboto', // Sử dụng font 'Roboto'
                fontWeight: FontWeight.bold, // Đặt độ đậm
              ),
            ),
            // Tăng khoảng cách giữa tên ứng dụng và slogan
            Text(
              slogan, // Slogan ứng dụng
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13,
                fontFamily: 'Roboto', // Sử dụng font 'Roboto'
              ),
            ),
          ],
        ),
      ),
      centerTitle: true, // Đặt tiêu đề ở giữa
      backgroundColor: Colors.transparent, // Đặt màu nền trong suốt
      elevation: 0, // Xóa độ nâng của AppBar
      actions: actions, // Sử dụng tham số actions ở đây
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120); // Đặt kích thước cho AppBar
}
