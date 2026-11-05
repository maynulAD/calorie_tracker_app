import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF16A085);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calorie Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          surface: const Color(0xFFF7FAF9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7FAF9),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFEAF0EE)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class FoodEntry {
  FoodEntry({required this.name, required this.calories});

  final String name;
  final int calories;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int dailyGoal = 2000;

  final List<FoodEntry> _foods = [];

  int get _totalCalories =>
      _foods.fold(0, (total, item) => total + item.calories);

  int get _remaining => (dailyGoal - _totalCalories).clamp(0, dailyGoal);

  String get _formattedDate {
    final now = DateTime.now();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${weekdays[now.weekday - 1]}, '
        '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF82928B), size: 21),
      suffixText: suffix,
      filled: true,
      fillColor: const Color(0xFFF7FAF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE7EEEB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE7EEEB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF168B72), width: 1.5),
      ),
    );
  }

  Future<void> _showAddFoodSheet() async {
    final nameController = TextEditingController();
    final calorieController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  const Text(
                    'Add food',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Keep track of what you eat today.',
                    style: TextStyle(color: Color(0xFF788781), fontSize: 14),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Food name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      hint: 'e.g. Grilled chicken salad',
                      icon: Icons.restaurant_menu_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a food name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Calories',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: calorieController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration(
                      hint: 'e.g. 350',
                      icon: Icons.local_fire_department_rounded,
                      suffix: 'kcal',
                    ),
                    validator: (value) {
                      final amount = int.tryParse(value ?? '');

                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter calories';
                      }

                      if (amount == null || amount <= 0) {
                        return 'Enter an amount greater than 0';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            _foods.insert(
                              0,
                              FoodEntry(
                                name: nameController.text.trim(),
                                calories: int.parse(
                                  calorieController.text.trim(),
                                ),
                              ),
                            );
                          });

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Food added to today’s log'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Add to today’s log',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF168B72),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    nameController.dispose();
    calorieController.dispose();
  }

  void _deleteFood(int index) {
    final removed = _foods[index];

    setState(() {
      _foods.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.name} removed'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _foods.insert(index, removed);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_totalCalories / dailyGoal).clamp(0.0, 1.0);

    final overGoal = _totalCalories > dailyGoal;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 22,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE1F4ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.spa_rounded,
                color: Color(0xFF168B72),
                size: 23,
              ),
            ),

            const SizedBox(width: 11),

            const Text(
              'Calorie Tracker',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D302A),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFEAF0EE)),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 17,
              color: Color(0xFF60736B),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          children: [
            Text(
              _formattedDate,
              style: const TextStyle(
                color: Color(0xFF82918B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Your daily nutrition',
              style: TextStyle(
                color: Color(0xFF1D302A),
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 20),

            _buildMainSummary(progress, overGoal),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _summaryTile(
                    title: 'Total calories',
                    value: _totalCalories,
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF8B55),
                    background: const Color(0xFFFFF0E8),
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: _summaryTile(
                    title: 'Daily goal',
                    value: dailyGoal,
                    icon: Icons.flag_rounded,
                    color: const Color(0xFF5B8DEF),
                    background: const Color(0xFFEBF1FF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            _summaryTile(
              title: 'Remaining calories',
              value: _remaining,
              icon: Icons.track_changes_rounded,
              color: const Color(0xFF169B7D),
              background: const Color(0xFFE5F6F0),
              fullWidth: true,
              subtitle: overGoal
                  ? 'You are over your daily goal'
                  : 'Left to reach your daily goal',
            ),

            const SizedBox(height: 27),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today’s food',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D302A),
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Everything you have logged today',
                      style: TextStyle(fontSize: 12, color: Color(0xFF82918B)),
                    ),
                  ],
                ),

                Text(
                  '${_foods.length} items',
                  style: const TextStyle(
                    color: Color(0xFF168B72),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            if (_foods.isEmpty)
              _emptyState()
            else
              ListView.builder(
                itemCount: _foods.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _foodCard(_foods[index], index);
                },
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFoodSheet,
        backgroundColor: const Color(0xFF168B72),
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Food',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildMainSummary(double progress, bool overGoal) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF168B72), Color(0xFF0D705E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calories consumed',
            style: TextStyle(
              color: Color(0xFFD7F2E9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_totalCalories',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 43,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 7, bottom: 8),
                child: Text(
                  'kcal',
                  style: TextStyle(color: Color(0xFFD7F2E9), fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily progress',
                style: TextStyle(color: Color(0xFFD7F2E9), fontSize: 12),
              ),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD78A),
              ),
            ),
          ),

          const SizedBox(height: 11),

          Text(
            overGoal
                ? 'You have exceeded your 2000 kcal goal.'
                : '${dailyGoal - _totalCalories} kcal left of your 2000 kcal goal',
            style: const TextStyle(color: Color(0xFFE3F6EF), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required Color background,
    bool fullWidth = false,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 21),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF82918B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                            fontSize: 21,
                            color: Color(0xFF1D302A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      const Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF82918B),
                        ),
                      ),
                    ],
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF82918B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foodCard(FoodEntry food, int index) {
    const icons = [
      Icons.lunch_dining_rounded,
      Icons.ramen_dining_rounded,
      Icons.egg_alt_rounded,
      Icons.emoji_food_beverage_rounded,
      Icons.set_meal_rounded,
      Icons.bakery_dining_rounded,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6F1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icons[index % icons.length],
                color: const Color(0xFF168B72),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF263A33),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${food.calories} kcal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF82918B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Delete food',
              onPressed: () => _deleteFood(index),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFE07865),
              ),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFF3F0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAF0EE)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF6F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Color(0xFF168B72),
              size: 28,
            ),
          ),

          const SizedBox(height: 13),

          const Text(
            'Your food diary is empty',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF263A33),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Add your first meal or snack to start tracking your daily calories.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF82918B),
            ),
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: _showAddFoodSheet,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add your first food'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF168B72),
              side: const BorderSide(color: Color(0xFFB9DED2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
