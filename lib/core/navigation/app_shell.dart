import 'package:flutter/material.dart';

import '../../features/chat/presentation/chat_page.dart';
import '../../features/habits/presentation/habits_page.dart';
import '../../features/journal/presentation/journal_list_page.dart';
import '../../features/today/presentation/today_page.dart';
import '../theme/app_colors.dart';
import '../widgets/coming_soon_page.dart';

/// Bottom navigation shell: Today, Journal, Habits, Insights, Settings,
/// plus the floating "Talk" button for the AI chat (W2) from any inner
/// screen. Only Today is wired to real data in this branch; the rest are
/// honest stubs until their own feature branches land.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    TodayPage(),
    JournalListPage(),
    HabitsPage(),
    ComingSoonPage(title: 'Insights'),
    ComingSoonPage(title: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatPage())),
        backgroundColor: colors.primary,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text('Talk', style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today_outlined), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Habits'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
