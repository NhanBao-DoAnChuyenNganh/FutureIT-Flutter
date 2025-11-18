import 'package:flutter/material.dart';
import '../models/khoa_hoc.dart';

class KhoaHocCard extends StatelessWidget {
  final KhoaHoc khoaHoc;
  final VoidCallback? onTap;

  const KhoaHocCard({required this.khoaHoc, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    // URL ảnh (đã tối ưu, không dùng base64 nữa)
    final imgUrl = khoaHoc.hinhAnhUrl;

    // Rating
    final rating = khoaHoc.soSaoTrungBinh ?? 0.0;
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
                  child: imgUrl != null && imgUrl.isNotEmpty
                      ? Image.network(
                    imgUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Image.asset('assets/avatar.png',
                            height: 100, width: double.infinity),
                  )
                      : Image.asset(
                    'assets/avatar.png',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (khoaHoc.daYeuThich)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.favorite, color: Colors.red),
                  ),
              ],
            ),

            // Thông tin khóa học
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    khoaHoc.tenKhoaHoc,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // ⭐ Rating
                  Row(
                    children: List.generate(5, (i) {
                      if (i < fullStars) {
                        return const Icon(Icons.star,
                            color: Colors.amber, size: 16);
                      } else if (i == fullStars && hasHalfStar) {
                        return const Icon(Icons.star_half,
                            color: Colors.amber, size: 16);
                      } else {
                        return const Icon(Icons.star_border,
                            color: Colors.amber, size: 16);
                      }
                    }),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${khoaHoc.hocPhi.toStringAsFixed(0)} VND',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${khoaHoc.tongLuotQuanTam ?? 0} yêu thích',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${khoaHoc.tongLuotBinhLuan ?? 0} đánh giá',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
