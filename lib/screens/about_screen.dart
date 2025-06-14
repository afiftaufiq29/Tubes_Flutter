import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;
  double _scrollPosition = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // Carousel images
  final List<String> _carouselImages = [
    'assets/images/about_images/restaurant.jpg',
    'assets/images/about_images/food.jpg',
    'assets/images/about_images/drink.jpg',
  ];

  // Specialty dishes
  final List<Map<String, String>> specialties = [
    {
      'title': 'Rendang Padang',
      'image': 'assets/images/about_images/rendang_padang.jpg',
      'description': 'Daging lembut dengan bumbu rempah khas Minang'
    },
    {
      'title': 'Soto Betawi',
      'image': 'assets/images/about_images/soto_betawi.jpg',
      'description': 'Kuah susu kental dengan potongan jeroan sapi'
    },
    {
      'title': 'Gudeg Jogja',
      'image': 'assets/images/about_images/gudeg_jogja.jpg',
      'description': 'Nangka muda dimasak dengan santan dan gula jawa'
    },
    {
      'title': 'Papeda Papua',
      'image': 'assets/images/about_images/papeda_papua.jpg',
      'description': 'Sagu khas Papua dengan kuah kuning ikan tongkol'
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _autoScrollCarousel();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1, curve: Curves.easeOut),
    ));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _autoScrollCarousel() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_pageController.hasClients && mounted) {
        final nextPage =
            _currentPage < _carouselImages.length - 1 ? _currentPage + 1 : 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCirc,
        );
        _autoScrollCarousel();
      }
    });
  }

  void _scrollListener() {
    final currentScroll = _scrollController.offset;
    if (currentScroll > _scrollPosition && currentScroll > 50) {
      if (_showAppBar) {
        setState(() => _showAppBar = false);
      }
    } else if (currentScroll < _scrollPosition) {
      if (!_showAppBar) {
        setState(() => _showAppBar = true);
      }
    }
    _scrollPosition = currentScroll;
  }

  Future<void> _launchMaps() async {
    const url =
        'https://www.google.com/maps/search/?api=1&query=Rasa+Nusantara+Bandung ';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/menu').then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
      case 2:
        break;
      case 3:
        Navigator.pushNamed(context, '/profile').then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
              title: AnimatedOpacity(
                opacity: _showAppBar ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'Tentang Kami',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[400],
                    fontSize: 24,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) => true,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Hero Carousel Section
                    SizedBox(
                      height: 280,
                      child: Stack(
                        children: [
                          // Image Carousel with Parallax effect
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              if (mounted) {
                                setState(() {
                                  _currentPage = index;
                                });
                              }
                            },
                            itemCount: _carouselImages.length,
                            itemBuilder: (context, index) {
                              return AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, child) {
                                  double value = 1.0;
                                  if (_pageController.position.haveDimensions) {
                                    value = _pageController.page! - index;
                                    value = (1 - (value.abs() * 0.3))
                                        .clamp(0.7, 1.0);
                                  }
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(_carouselImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Gradient Overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Title Text with Animation
                          Positioned(
                            bottom: 40,
                            left: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              opacity: _showAppBar ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                children: [
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          20 * (1 - _fadeAnimation.value),
                                        ),
                                        child: Opacity(
                                          opacity: _fadeAnimation.value,
                                          child: Text(
                                            'RASA NUSANTARA',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.8),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          20 * (1 - _fadeAnimation.value),
                                        ),
                                        child: Opacity(
                                          opacity: _fadeAnimation.value,
                                          child: Text(
                                            'Kuliner Autentik dengan Sentuhan Modern',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 14,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.8),
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Page Indicators with Animation
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              opacity: _showAppBar ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _carouselImages.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: _currentPage == index ? 20 : 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: _currentPage == index
                                          ? AppColors.primary
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Main Content
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              // Welcome Section
                              SlideTransition(
                                position: _slideAnimation,
                                child: _buildSectionHeader(
                                  'Selamat Datang di Rasa Nusantara',
                                  'Tempat kelezatan kuliner Nusantara disajikan dengan cita rasa otentik dan penyajian modern.',
                                ),
                              ),
                              const SizedBox(height: 24),

                              // History Card with Animation
                              SlideTransition(
                                position: _slideAnimation,
                                child: _buildAnimatedCard(
                                  icon: Icons.history,
                                  title: 'Sejarah Kami',
                                  content:
                                      'Rasa Nusantara didirikan pada tahun 2010 oleh Chef Andika Wibawa. Berawal dari warung kecil di Bandung, kini kami telah berkembang menjadi restoran dengan 5 cabang di Jawa Barat.',
                                  iconColor: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Specialties Section
                              SlideTransition(
                                position: _slideAnimation,
                                child: _buildSectionHeader(
                                  'Spesialisasi Kami',
                                  'Menu andalan yang selalu dinanti pelanggan',
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 220,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    for (var item in specialties)
                                      AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(
                                                50 * (1 - _fadeAnimation.value),
                                                0),
                                            child: Opacity(
                                              opacity: _fadeAnimation.value,
                                              child: _buildSpecialtyCard(
                                                item['title']!,
                                                item['image']!,
                                                item['description']!,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ].map((widget) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: widget,
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Location Card
                              SlideTransition(
                                position: _slideAnimation,
                                child: _buildAnimatedCard(
                                  icon: Icons.location_pin,
                                  title: 'Lokasi Kami',
                                  content:
                                      'Jl. Terusan Buah Batu No.5, Batununggal, Kec. Bandung Kidul, Kota Bandung, Jawa Barat 40266\n\nBuka setiap hari:\n10.00 - 22.00 WIB',
                                  buttonText: 'Petunjuk Arah',
                                  onButtonPressed: _launchMaps,
                                  iconColor: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orange[400],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.orange[400],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard({
    required IconData icon,
    required String title,
    required String content,
    String? buttonText,
    VoidCallback? onButtonPressed,
    Color iconColor = Colors.orange,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            if (buttonText != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(buttonText),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard(
      String title, String imagePath, String description) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      height: 120,
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange[400], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.favorite_border,
                        color: Colors.red[300], size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
