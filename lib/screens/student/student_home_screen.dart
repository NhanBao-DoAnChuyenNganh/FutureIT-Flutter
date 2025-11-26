import 'package:do_an_chuyen_nganh/models/student_home_data.dart';
import 'package:do_an_chuyen_nganh/services/student_home_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentCarouselIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  final List<String> carouselImages = [
    'lib/image/banner1.png',
    'lib/image/banner2.png',
    'lib/image/banner3.png',
  ];

  final List<Map<String, String>> camKetChatLuong = [
    {
      'icon': 'lib/image/tc1.png',
      'title': 'Chất lượng đầu ra rõ ràng',
      'description':
      'Chương trình học được thiết kế từ cơ bản đến nâng cao, bám sát nhu cầu tuyển dụng thực tế.\n\nHọc viên được kiểm tra định kỳ và cam kết có thể tự tin ứng tuyển sau khi hoàn thành khóa học.',
    },
    {
      'icon': 'lib/image/tc2.png',
      'title': 'Giảng viên giàu kinh nghiệm',
      'description':
      'Đội ngũ giảng viên có kinh nghiệm giảng dạy và thực chiến tại doanh nghiệp.\n\nLuôn sẵn sàng chia sẻ kiến thức thực tế và định hướng nghề nghiệp cho học viên.',
    },
    {
      'icon': 'lib/image/tc3.png',
      'title': 'Thực hành là trọng tâm',
      'description':
      'Mỗi khóa học đều gắn liền với bài tập lớn và dự án thực tế.\n\nHọc viên được rèn luyện kỹ năng giải quyết vấn đề như trong môi trường doanh nghiệp.',
    },
    {
      'icon': 'lib/image/tc4.png',
      'title': 'Đa dạng thời gian & hình thức học',
      'description':
      'Lớp học được tổ chức linh hoạt: buổi tối, cuối tuần, trực tiếp hoặc online.\n\nPhù hợp với mọi lịch trình mà vẫn đảm bảo chất lượng đào tạo.',
    },
    {
      'icon': 'lib/image/tc5.png',
      'title': 'Hỗ trợ 24/7',
      'description':
      'Học viên luôn nhận được hỗ trợ nhanh chóng từ giảng viên và đội ngũ kỹ thuật.\n\nKết nối qua nhiều kênh như Facebook, Email, Website để giải đáp mọi thắc mắc.',
    },
    {
      'icon': 'lib/image/tc6.png',
      'title': 'Kèm cặp & theo sát từng học viên',
      'description':
      'Mỗi lớp đều có giảng viên và trợ giảng theo sát quá trình học tập.\n\nHọc viên được hỗ trợ cá nhân hóa, đảm bảo tiến bộ đồng đều và hiệu quả.',
    },
  ];

  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  StudentHomeData? homeData;
  bool isLoading = true;

  void loadHomeData() async {
    homeData = await StudentHomeService().getHomeData();
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
    loadHomeData();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentCarouselIndex < carouselImages.length - 1) {
        _currentCarouselIndex++;
      } else {
        _currentCarouselIndex = 0;
      }

      _pageController.animateToPage(
        _currentCarouselIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'FutureIT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
        body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),

            _buildCarousel(),

            const SizedBox(height: 50),

            const Text(
              'CAM KẾT CHẤT LƯỢNG',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 40),

            _buildCommitmentCards(),

            const SizedBox(height: 50),

            Image.asset(
              'lib/image/CRITERIA.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 50),

            const Text(
              "KHÓA HỌC PHỔ BIẾN",
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
            ),

            SizedBox(
              height: 250,
              child: isLoading || homeData == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: homeData!.list3KhoaHocPhoBien.length,
                itemBuilder: (context, index) {
                  var c = homeData!.list3KhoaHocPhoBien[index];
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.all(12),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              c.hinhAnh,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    c.tenKhoaHoc,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Center(
                                    child: Text(
                                      formatCurrency.format(c.hocPhi),
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Nút XEM KHÓA HỌC >>
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'XEM KHÓA HỌC >>',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            const Text(
              "GIẢNG VIÊN TIÊU BIỂU",
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
            ),


            const SizedBox(height: 30),

            isLoading || homeData == null
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              height: 160,
              child: PageView.builder(
                itemCount: 2,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (context, pageIndex) {
                  final teachers = [
                    homeData!.gvtb1,
                    homeData!.gvtb2,
                    homeData!.gvtb3,
                    homeData!.gvtb4
                  ];

                  int first = pageIndex * 2;
                  int second = first + 1;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _gvCard(teachers[first]),
                      if (second < teachers.length) _gvCard(teachers[second]),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 50),

            _aboutSection(),

            const SizedBox(height: 50),

            const Text(
              "TIN TỨC MỚI NHẤT",
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
            ),

            isLoading || homeData == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                _newsCard(homeData!.tinMoi1),
                _newsCard(homeData!.tinMoi2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gvCard(Teacher? t) {
    if (t == null) return const SizedBox();
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundImage: NetworkImage(t.avatar),
        ),
        const SizedBox(height: 10),
        Text(t.hoTen, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(t.chuyenNganh, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _newsCard(News? n) {
    if (n == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                n.hinhTinTuc,
                width: 150,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.tieuDeTinTuc,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    n.noiDungTinTuc,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: carouselImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(carouselImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: carouselImages.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  entry.key,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == entry.key
                      ? Colors.blue
                      : Colors.grey.shade400,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommitmentCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 1;
          if (constraints.maxWidth > 900) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 2;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: camKetChatLuong.length,
            itemBuilder: (context, index) {
              return _CommitmentCard(
                icon: camKetChatLuong[index]['icon']!,
                title: camKetChatLuong[index]['title']!,
                description: camKetChatLuong[index]['description']!,
              );
            },
          );
        },
      ),
    );
  }

  Widget _aboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;
          return isMobile
              ? Column(
            children: [
              _aboutLeftContent(),
              const SizedBox(height: 30),
              _aboutRightImages(),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _aboutLeftContent()),
              const SizedBox(width: 30),
              Expanded(flex: 1, child: _aboutRightImages()),
            ],
          );
        },
      ),
    );
  }

  Widget _aboutLeftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đôi nét về FUTUREIT',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'FUTUREIT là trung tâm đào tạo công nghệ thông tin uy tín, định hướng thực tiễn và tập trung vào chất lượng đầu ra. '
              'Chúng tôi cung cấp các khóa học từ cơ bản đến nâng cao, được thiết kế bám sát nhu cầu tuyển dụng doanh nghiệp. '
              'Với đội ngũ giảng viên giàu kinh nghiệm và môi trường học tập hiện đại, FUTUREIT cam kết đồng hành cùng học viên trên hành trình chinh phục sự nghiệp công nghệ.',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _AboutItem(icon: Icons.lightbulb_outline, text: 'Đổi mới, sáng tạo là tôn chỉ'),
            _AboutItem(icon: Icons.school, text: 'Tận tâm 24/7'),
            _AboutItem(icon: Icons.cast_for_education, text: 'Học đi đôi với hành'),
            _AboutItem(icon: Icons.checklist, text: '"Practice makes perfect" - CR7'),
          ],
        ),
        const SizedBox(height: 20),

        Center(
            child: ElevatedButton(
                onPressed: () {
                  // Điều hướng đến About us
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                child: const Text('Về chúng tôi >>', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
            ),
        ),
      ],
    );
  }

  Widget _aboutRightImages() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10, bottom: 10),
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('lib/image/KH2c.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('lib/image/KH2d.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

}

class _CommitmentCard extends StatefulWidget {
  final String icon;
  final String title;
  final String description;

  const _CommitmentCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<_CommitmentCard> createState() => _CommitmentCardState();
}

class _AboutItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AboutItem({Key? key, required this.icon, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommitmentCardState extends State<_CommitmentCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: Card(
          elevation: _isHovered ? 10 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  widget.icon,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
