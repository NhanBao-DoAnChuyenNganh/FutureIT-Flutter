import 'dart:convert';
import 'package:do_an_chuyen_nganh/screens/auth/login_screen.dart';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:do_an_chuyen_nganh/services/deep_link_service.dart';
import 'package:do_an_chuyen_nganh/services/thanh_toan_service.dart';
import 'package:do_an_chuyen_nganh/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/chi_tiet_khoa_hoc.dart';
import '../../services/khoa_hoc_student_service.dart';

class ChiTietKhoaHocScreen extends StatefulWidget {
  final int maKhoaHoc;
  const ChiTietKhoaHocScreen({super.key, required this.maKhoaHoc});

  @override
  State<ChiTietKhoaHocScreen> createState() => _ChiTietKhoaHocScreenState();
}

class _ChiTietKhoaHocScreenState extends State<ChiTietKhoaHocScreen> {
  ChiTietKhoaHoc? chiTiet;
  bool loading = true;
  int selectedImageIndex = 0;
  int selectedStar = 0;
  bool daQuanTam = false;
  int selectedPaymentTab = 0;
  TextEditingController noiDungController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChiTiet();
    _loadTrangThaiQuanTam();
    _setupPaymentCallback();
  }

  void _setupPaymentCallback() {
    DeepLinkService().onPaymentCallback = (success, message, maKhoaHoc) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: success ? Colors.green.shade50 : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    success ? Icons.check_circle : Icons.cancel,
                    color: success ? Colors.green : Colors.red,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  success ? 'Thanh toán thành công!' : 'Thanh toán thất bại',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: success ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cảm ơn bạn! Chúng tôi sẽ xác nhận thanh toán trong ít phút.'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        _loadChiTiet();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: success ? Colors.green : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    };
  }

  @override
  void dispose() {
    DeepLinkService().onPaymentCallback = null;
    noiDungController.dispose();
    super.dispose();
  }

  Future<void> saveChiTietCache(ChiTietKhoaHoc data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_chi_tiet_${data.maKhoaHoc}', jsonEncode(data.toJson()));
    await prefs.setInt('cache_time_chi_tiet_${data.maKhoaHoc}', DateTime.now().millisecondsSinceEpoch);
  }

  Future<ChiTietKhoaHoc?> loadChiTietCache(int maKhoaHoc) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_chi_tiet_$maKhoaHoc');
    if (jsonString == null) return null;
    return ChiTietKhoaHoc.fromJson(jsonDecode(jsonString));
  }

  Future<bool> isChiTietCacheExpired(int maKhoaHoc) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_time_chi_tiet_$maKhoaHoc') ?? 0;
    return (DateTime.now().millisecondsSinceEpoch - savedTime) > 30 * 60 * 1000;
  }


  Future<void> _loadChiTiet() async {
    setState(() => loading = true);
    final cache = await loadChiTietCache(widget.maKhoaHoc);
    final expired = await isChiTietCacheExpired(widget.maKhoaHoc);
    if (cache != null && !expired && mounted) {
      setState(() {
        chiTiet = cache;
        loading = false;
      });
    }
    try {
      final data = await KhoaHocService.getChiTietKhoaHoc(widget.maKhoaHoc);
      if (!mounted) return;
      setState(() => chiTiet = data);
      await saveChiTietCache(data);
    } catch (e) {
      debugPrint("Lỗi tải chi tiết khóa học: $e");
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _loadTrangThaiQuanTam() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getBool('cache_daQuanTam_${widget.maKhoaHoc}');
    if (cached != null && mounted) setState(() => daQuanTam = cached);
    try {
      final dsQuanTam = await KhoaHocService.getDanhSachQuanTam();
      final isQuanTam = dsQuanTam.any((k) => k.maKhoaHoc == widget.maKhoaHoc);
      if (!mounted) return;
      setState(() => daQuanTam = isQuanTam);
      await prefs.setBool('cache_daQuanTam_${widget.maKhoaHoc}', isQuanTam);
    } catch (e) {
      debugPrint("Lỗi tải trạng thái quan tâm: $e");
    }
  }

  Future<bool> _checkLogin() async {
    bool loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) return true;
    await _showLoginDialog();
    return false;
  }

  Future<void> _showLoginDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Bạn chưa đăng nhập. Vui lòng đăng nhập để tiếp tục.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleQuanTam() async {
    if (!await _checkLogin()) return;
    final success = await KhoaHocService.toggleYeuThich(widget.maKhoaHoc);
    if (!mounted || !success) return;
    setState(() => daQuanTam = !daQuanTam);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cache_daQuanTam_${widget.maKhoaHoc}', daQuanTam);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(daQuanTam ? 'Đã thêm vào danh sách quan tâm' : 'Đã bỏ quan tâm'),
        backgroundColor: daQuanTam ? AppColors.primary : Colors.grey,
      ),
    );
  }

  Future<void> _sendDanhGia() async {
    if (chiTiet == null || !await _checkLogin()) return;
    if (selectedStar == 0 || noiDungController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao và nhập nội dung')),
      );
      return;
    }
    final success = await KhoaHocService.guiDanhGia(
      maKhoaHoc: chiTiet!.maKhoaHoc,
      soSao: selectedStar,
      noiDung: noiDungController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Gửi đánh giá thành công' : 'Gửi đánh giá thất bại')),
    );
    if (success) {
      noiDungController.clear();
      selectedStar = 0;
      _loadChiTiet();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : chiTiet == null
          ? const Center(child: Text("Không tìm thấy khóa học"))
          : CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: chiTiet!.hinhAnh.isNotEmpty
                  ? Image.network(chiTiet!.hinhAnh[selectedImageIndex], fit: BoxFit.cover)
                  : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: Icon(
                      daQuanTam ? Icons.favorite : Icons.favorite_border,
                      color: daQuanTam ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleQuanTam,
                  ),
                ),
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Thumbnails
                  if (chiTiet!.hinhAnh.length > 1)
                    Container(
                      height: 80,
                      margin: const EdgeInsets.only(top: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: chiTiet!.hinhAnh.length,
                        itemBuilder: (_, index) => GestureDetector(
                          onTap: () => setState(() => selectedImageIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedImageIndex == index ? AppColors.primary : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(chiTiet!.hinhAnh[index], width: 80, height: 70, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          chiTiet!.tenKhoaHoc,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        // Info Cards
                        Row(
                          children: [
                            _buildInfoCard(Icons.calendar_today, 'Ngày học', chiTiet!.ngayHoc, AppColors.primaryLight),
                            const SizedBox(width: 12),
                            _buildInfoCard(Icons.access_time, 'Giờ học', '${chiTiet!.gioBatDau} - ${chiTiet!.gioKetThuc}', AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Price & Rating
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryLight.withOpacity(0.1), AppColors.primary.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Học phí', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${chiTiet!.hocPhi.toStringAsFixed(0)} VND',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildStarRating(chiTiet!.soSaoTrungBinh),
                                  const SizedBox(height: 4),
                                  Text('${chiTiet!.tongLuotDanhGia} đánh giá', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Payment Methods
                        _buildPaymentSection(),
                        const SizedBox(height: 20),
                        // Description
                        const Text('Mô tả khóa học', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Html(data: chiTiet!.moTa),
                        const SizedBox(height: 20),
                        // Favorite Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _toggleQuanTam,
                            icon: Icon(daQuanTam ? Icons.favorite : Icons.favorite_border),
                            label: Text(daQuanTam ? 'Đã quan tâm' : 'Thêm vào danh sách quan tâm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: daQuanTam ? Colors.red.shade400 : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        // Review Section
                        _buildReviewSection(),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        // Reviews List
                        _buildReviewsList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildPaymentTab(0, 'Momo', const Color(0xFFD82D8B)),
                _buildPaymentTab(1, 'ZaloPay', const Color(0xFF0068FF)),
                _buildPaymentTab(2, 'Tiền mặt', const Color(0xFF4CAF50)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tab Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildPaymentContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab(int index, String label, Color color) {
    final isSelected = selectedPaymentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPaymentTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentContent() {
    switch (selectedPaymentTab) {
      case 0: // Momo
        return _buildMomoPayment();
      case 1: // ZaloPay
        return _buildZaloPayPayment();
      case 2: // Tiền mặt
        return _buildCashPayment();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMomoPayment() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFD82D8B).withOpacity(0.1), const Color(0xFFD82D8B).withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset('lib/image/momo.png', width: 40, height: 40),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thanh toán qua Momo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Nhanh chóng, tiện lợi', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handlePayment('Momo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD82D8B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Thanh toán Momo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZaloPayPayment() {
    // Kiểm tra nếu học phí > 999.000 VND
    final isOverLimit = chiTiet != null && chiTiet!.hocPhi > 999000;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF0068FF).withOpacity(0.1), const Color(0xFF0068FF).withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('lib/image/zalopay.png', width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thanh toán qua ZaloPay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('An toàn, bảo mật', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isOverLimit)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Do trị giá khóa học > 1.000.000 VND. Vui lòng dùng phương thức thanh toán khác.',
                      style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePayment('ZaloPay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0068FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thanh toán ZaloPay'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCashPayment() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF4CAF50).withOpacity(0.1), const Color(0xFF4CAF50).withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Thanh toán tiền mặt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Quý học viên vui lòng đến trực tiếp quầy thu ngân.', style: TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 12),
          _buildCashInfoRow(Icons.location_on, 'Địa chỉ:', 'Lô E1, Võ Nguyên Giáp, TP. Thủ Đức, TP.HCM'),
          const SizedBox(height: 8),
          _buildCashInfoRow(Icons.access_time, 'Giờ làm việc:', 'Thứ 2 - Thứ 7 (8:00 - 17:00)'),
        ],
      ),
    );
  }

  Widget _buildCashInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 4),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }


  Future<void> _handlePayment(String method) async {
    void _showLoginDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('Bạn chưa đăng nhập. Vui lòng đăng nhập để tiếp tục.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      );
    }
    if (!await _checkLogin()) {
      _showLoginDialog();
      return;
    }
    if (chiTiet == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đang chuyển đến thanh toán $method...'), backgroundColor: AppColors.primary),
    );

    Map<String, dynamic> result;

    if (method == 'Momo') {
      result = await ThanhToanService.createPaymentMomo(
        maKhoaHoc: chiTiet!.maKhoaHoc,
        hocPhi: chiTiet!.hocPhi,
        tenKhoaHoc: chiTiet!.tenKhoaHoc,
        ngayHoc: chiTiet!.ngayHoc,
      );
    } else {
      result = await ThanhToanService.createPaymentZaloPay(
        maKhoaHoc: chiTiet!.maKhoaHoc,
        hocPhi: chiTiet!.hocPhi,
        tenKhoaHoc: chiTiet!.tenKhoaHoc,
        ngayHoc: chiTiet!.ngayHoc,
      );
    }

    if (!mounted) return;

    if (result.containsKey('error')) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon cảnh báo
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.schedule, color: Colors.orange.shade700, size: 40),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Trùng lịch học',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  result['error'],
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Đã hiểu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }


    //URL thanh toán từ response
    String? payUrl;
    if (method == 'Momo') {
      payUrl = result['deeplink'] ?? result['payUrl'];
    } else {
      payUrl = result['orderUrl'] ?? result['deeplink'];
    }
    
    if (payUrl != null && payUrl.toString().isNotEmpty) {
      final uri = Uri.parse(payUrl.toString());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở trang thanh toán'), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không nhận được link thanh toán'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gửi đánh giá của bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _StarInput(onSelected: (val) => selectedStar = val),
          const SizedBox(height: 12),
          TextField(
            controller: noiDungController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendDanhGia,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Gửi đánh giá'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    if (chiTiet!.danhGia.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Khóa học chưa nhận được đánh giá nào', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Đánh giá (${chiTiet!.danhGia.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...chiTiet!.danhGia.map((dg) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: dg.avatarBase64.isNotEmpty ? MemoryImage(base64Decode(dg.avatarBase64)) : null,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: dg.avatarBase64.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dg.user, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _buildStarRating(dg.soSaoDanhGia.toDouble(), size: 14),
                            const SizedBox(width: 8),
                            Text(dg.ngayDanhGia, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(dg.noiDungDanhGia, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStarRating(double rating, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (rating >= i + 1) return Icon(Icons.star, color: Colors.amber, size: size);
        if (rating >= i + 0.5) return Icon(Icons.star_half, color: Colors.amber, size: size);
        return Icon(Icons.star_border, color: Colors.amber.shade200, size: size);
      }),
    );
  }
}

class _StarInput extends StatefulWidget {
  final Function(int) onSelected;
  const _StarInput({required this.onSelected});

  @override
  State<_StarInput> createState() => _StarInputState();
}

class _StarInputState extends State<_StarInput> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () {
            setState(() => selected = i + 1);
            widget.onSelected(selected);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              i < selected ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}
