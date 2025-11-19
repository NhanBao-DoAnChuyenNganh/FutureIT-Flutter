import 'package:flutter/material.dart';

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
              decoration: InputDecoration(
                hintText: 'Tìm tên khóa học',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: onSearchPressed,
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: onTypeSelected,
            itemBuilder: (_) => const [
              PopupMenuItem(value: '', child: Text('Tất cả loại')),
              PopupMenuItem(value: 'C++', child: Text('C++')),
              PopupMenuItem(value: 'Java', child: Text('Java')),
              PopupMenuItem(value: 'Python', child: Text('Python')),
            ],
          ),
        ],
      ),
    );
  }
}
