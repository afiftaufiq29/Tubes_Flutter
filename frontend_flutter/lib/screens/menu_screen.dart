import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/api_service.dart'; // Import service baru kita
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/food_card.dart';
import '../widgets/food_detail_dialog.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  bool _showFoods = true;

  List<FoodModel> _foodItems = [];
  List<FoodModel> _drinkItems = [];
  bool _isLoading = true;
  String? _error;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _buttonController;
  late AnimationController _gridController;
  late AnimationController _pageTransitionController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pageTransitionAnimation;

  // For card tap animation
  int? _tappedIndex;
  late AnimationController _cardTapController;
  late Animation<double> _cardTapAnimation;

  @override
  void initState() {
    super.initState();
    _fetchMenuItems(); // Panggil fungsi untuk mengambil data dari API

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _cardTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _pageTransitionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _pageTransitionController, curve: Curves.easeInOut),
    );

    _cardTapAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _cardTapController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _gridController.forward();
    _pageTransitionController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _buttonController.dispose();
    _gridController.dispose();
    _pageTransitionController.dispose();
    _cardTapController.dispose();
    super.dispose();
  }

  Future<void> _fetchMenuItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final apiService = ApiService();
      final foods = await apiService.fetchFoods();
      final drinks = await apiService.fetchDrinks();
      setState(() {
        _foodItems = foods;
        _drinkItems = drinks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load menu items: $e';
        _isLoading = false;
      });
      print('Error fetching menu items: $e'); // For debugging
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
        const AssetImage('assets/images/background_images/food_background.png'),
        context);
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    // Animate out before navigation
    _pageTransitionController.reverse().then((_) {
      if (mounted) {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
            break;
          case 1:
            break;
          case 2:
            Navigator.pushNamed(context, '/about').then((_) {
              if (mounted) setState(() => _selectedIndex = 0);
            });
            break;
          case 3:
            Navigator.pushNamed(context, '/profile').then((_) {
              if (mounted) setState(() => _selectedIndex = 0);
            });
            break;
        }
      }
    });
  }

  Future<void> _showFoodDetail(FoodModel food, int index) async {
    setState(() => _tappedIndex = index);
    await _cardTapController.forward();
    await _cardTapController.reverse();

    _scaleController.reverse();
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1).animate(
            CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: ModalRoute.of(context)!.animation!,
            child: FoodDetailDialog(food: food),
          ),
        ),
      ),
    );
    _scaleController.forward();
    setState(() => _tappedIndex = null);
  }

  void _toggleFoods(bool showFoods) {
    if (_showFoods == showFoods) return;

    setState(() {
      _showFoods = showFoods;
      _buttonController.reverse();
    });

    _buttonController.forward(from: 0);
    _gridController.reset();
    _gridController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final List<FoodModel> currentItems = _showFoods ? _foodItems : _drinkItems;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) => FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, (1 - _fadeAnimation.value) * 20),
              child: Text(
                'Menu Kami',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[400],
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: AnimatedBuilder(
        animation: _pageTransitionController,
        builder: (context, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _pageTransitionController,
              curve: Curves.easeOutQuart,
            )),
            child: FadeTransition(
              opacity: _pageTransitionAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  color: Colors.grey[50],
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Toggle Button with animation
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                                animation: _buttonController,
                                builder: (context, child) {
                                  return ElevatedButton(
                                    onPressed: () => _toggleFoods(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _showFoods
                                          ? Colors.orange[400]
                                          : Colors.grey[300],
                                      foregroundColor: _showFoods
                                          ? Colors.white
                                          : Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: _showFoods ? 4 : 0,
                                      shadowColor:
                                          Colors.orange.withOpacity(0.3),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (child, animation) =>
                                          ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                      child: Text(
                                        'Makanan',
                                        key: ValueKey<bool>(_showFoods),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _buttonController,
                              builder: (context, child) {
                                return ElevatedButton(
                                  onPressed: () => _toggleFoods(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: !_showFoods
                                        ? Colors.orange[400]
                                        : Colors.grey[300],
                                    foregroundColor: !_showFoods
                                        ? Colors.white
                                        : Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: !_showFoods ? 4 : 0,
                                    shadowColor: Colors.orange.withOpacity(0.3),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                    child: Text(
                                      'Minuman',
                                      key: ValueKey<bool>(!_showFoods),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // GridView Menu with staggered animation
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _error != null
                                ? Center(child: Text(_error!))
                                : currentItems.isEmpty
                                    ? const Center(
                                        child: Text('No items to display.'))
                                    : AnimatedBuilder(
                                        animation: _gridController,
                                        builder: (context, child) {
                                          return GridView.builder(
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            physics:
                                                const BouncingScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 12,
                                              childAspectRatio: 0.9,
                                            ),
                                            itemCount: currentItems.length,
                                            itemBuilder: (context, index) {
                                              final animationInterval =
                                                  0.5 / currentItems.length;
                                              final animation = Tween<double>(
                                                begin: 0,
                                                end: 1,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: _gridController,
                                                  curve: Interval(
                                                    index * animationInterval,
                                                    (index + 1) *
                                                        animationInterval,
                                                    curve: Curves.easeOut,
                                                  ),
                                                ),
                                              );

                                              final item = currentItems[index];

                                              // Card tap animation
                                              final isTapped =
                                                  _tappedIndex == index;
                                              final tapAnimation = isTapped
                                                  ? _cardTapAnimation
                                                  : AlwaysStoppedAnimation(1.0);

                                              return GestureDetector(
                                                onTapDown: (_) {
                                                  setState(() =>
                                                      _tappedIndex = index);
                                                  _cardTapController.forward();
                                                },
                                                onTapUp: (_) {
                                                  _cardTapController.reverse();
                                                  _showFoodDetail(item, index);
                                                },
                                                onTapCancel: () {
                                                  setState(() =>
                                                      _tappedIndex = null);
                                                  _cardTapController.reverse();
                                                },
                                                child: AnimatedBuilder(
                                                  animation: animation,
                                                  builder: (context, child) {
                                                    return Transform.translate(
                                                      offset: Offset(
                                                          0,
                                                          (1 -
                                                                  animation
                                                                      .value) *
                                                              50 *
                                                              (index % 2 == 0
                                                                  ? 1
                                                                  : -1)),
                                                      child: Opacity(
                                                        opacity:
                                                            animation.value,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              tapAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Transform
                                                                .scale(
                                                              scale: animation
                                                                      .value *
                                                                  tapAnimation
                                                                      .value,
                                                              child: child,
                                                            );
                                                          },
                                                          child: Hero(
                                                            tag:
                                                                'food_${item.id}',
                                                            flightShuttleBuilder:
                                                                (
                                                              BuildContext
                                                                  flightContext,
                                                              Animation<double>
                                                                  animation,
                                                              HeroFlightDirection
                                                                  flightDirection,
                                                              BuildContext
                                                                  fromHeroContext,
                                                              BuildContext
                                                                  toHeroContext,
                                                            ) {
                                                              final Hero hero = flightDirection ==
                                                                      HeroFlightDirection
                                                                          .push
                                                                  ? fromHeroContext
                                                                          .widget
                                                                      as Hero
                                                                  : toHeroContext
                                                                          .widget
                                                                      as Hero;
                                                              return hero.child;
                                                            },
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: FoodCard(
                                                                  food: item),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
