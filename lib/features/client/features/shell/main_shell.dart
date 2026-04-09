import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/home_page.dart';
import 'package:crm/features/client/components/custome_navigationbar.dart';
import 'package:crm/features/client/pages/client_page.dart';
import 'package:crm/features/client/pages/leads_page.dart';
import 'package:crm/features/client/pages/report_page.dart';
import 'package:crm/features/client/pages/task_page.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    HomePage(),
    LeadsPage(),
    ClientPage(),
    TaskPage(),
    ReportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
