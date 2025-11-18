import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/khoa_hoc.dart';
import '../../services/khoa_hoc_student_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/khoa_hoc_card.dart';
import '../auth/login_screen.dart';
import '../auth/profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  List<KhoaHoc> listKhoaHoc = [];
  bool loading = true;

  // Filter / search
  String searchText = '';
  int priceFilter = 0;
  String typeFilter = '';

  // User info
  Map<String, String> userData = {};
  String avatarBase64 = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);

    // Load user
    final prefs = await SharedPreferences.getInstance();
    userData = {
      'username': prefs.getString('username') ?? 'Người dùng',
      'email': prefs.getString('email') ?? '',
      'sdt': prefs.getString('sdt') ?? '',
      'diaChi': prefs.getString('diaChi') ?? '',
      'avatarBase64': prefs.getString('avatarBase64') ?? '',
    };
    avatarBase64 = userData['avatarBase64']!;

    // Load khóa học
    listKhoaHoc = await KhoaHocService.getAllKhoaHoc();

    setState(() => loading = false);
  }

  ImageProvider get avatarImage {
    if (avatarBase64.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(avatarBase64.split(',').last));
      } catch (_) {
        return const AssetImage('assets/avatar.png');
      }
    }
    return const AssetImage('assets/avatar.png');
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _searchOrFilter() async {
    setState(() => loading = true);
    listKhoaHoc = await KhoaHocService.searchOrFilter(
      ten: searchText,
      tenLoai: typeFilter,
    );
    setState(() => loading = false);
  }

  Future<void> _filterByPrice(int luaChon) async {
    setState(() => loading = true);
    listKhoaHoc = await KhoaHocService.filterByPrice(luaChon);
    setState(() {
      priceFilter = luaChon;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: avatarImage),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                userData['username'] ?? 'Người dùng',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      email: userData['email'] ?? '',
                      username: userData['username'] ?? '',
                      sdt: userData['sdt'] ?? '',
                      diaChi: userData['diaChi'] ?? '',
                      avatarBase64: avatarBase64,
                    ),
                  ),
                );
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Hồ sơ cá nhân')),
              PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm tên khóa học',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchOrFilter,
                      ),
                    ),
                    onChanged: (val) => searchText = val,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() => typeFilter = value);
                    _searchOrFilter();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: '', child: Text('Tất cả loại')),
                    PopupMenuItem(value: 'C++', child: Text('C++')),
                    PopupMenuItem(value: 'Java', child: Text('Java')),
                    PopupMenuItem(value: 'Python', child: Text('Python')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _priceButton(0, 'Tất cả'),
                _priceButton(1, 'Cao -> Thấp'),
                _priceButton(2, 'Thấp -> Cao'),
                _priceButton(3, '< 5M'),
                _priceButton(4, '5M -> 7M'),
                _priceButton(5, '> 7M'),
              ],
            ),
          ),
          Expanded(
            child: listKhoaHoc.isEmpty
                ? const Center(child: Text('Không tìm thấy khóa học'))
                : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: listKhoaHoc.length,
              itemBuilder: (context, index) {
                return KhoaHocCard(khoaHoc: listKhoaHoc[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceButton(int luaChon, String text) {
    final selected = priceFilter == luaChon;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.blue : Colors.grey[200],
          foregroundColor: selected ? Colors.white : Colors.black,
        ),
        onPressed: () => _filterByPrice(luaChon),
        child: Text(text),
      ),
    );
  }
}
