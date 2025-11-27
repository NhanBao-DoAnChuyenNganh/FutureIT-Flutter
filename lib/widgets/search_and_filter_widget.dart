import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';

class SearchAndFilterWidget extends StatelessWidget {
  final String searchText;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchPressed;
  final String typeFilter;
  final Function(String) onTypeSelected;

  const SearchAndFilterWidget({
    super.key,
    required this.searchText,
    required this.onSearchChanged,
    required this.onSearchPressed,
    required this.typeFilter,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                hintText: 'Tìm tên khóa học',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: onSearchPressed,
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),

          // 🔥 Popup filter
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) async {
              // Nếu chọn "Danh sách quan tâm"
              if (value == 'goQuanTam') {
                bool loggedIn = await AuthService.isLoggedIn();
                if (!loggedIn) {
                  // Hiển thị dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Thông báo'),
                      content: const Text('Bạn chưa đăng nhập. Vui lòng đăng nhập để tiếp tục.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Text('Đăng nhập'),
                        ),
                      ],
                    ),
                  );
                  return; // Không thực hiện onTypeSelected
                }
              }
              // Nếu đã đăng nhập hoặc chọn loại khác
              onTypeSelected(value);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: '', child: Text('Tất cả loại')),
              PopupMenuItem(value: 'C++', child: Text('C++')),
              PopupMenuItem(value: 'Java', child: Text('Java')),
              PopupMenuItem(value: 'Python', child: Text('Python')),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'goQuanTam',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Danh sách quan tâm"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
