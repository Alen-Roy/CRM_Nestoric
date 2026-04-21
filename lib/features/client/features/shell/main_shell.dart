import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/components/custome_navigationbar.dart';
import 'package:crm/features/client/pages/attendance_page.dart';
import 'package:crm/features/client/pages/client_page.dart';
import 'package:crm/features/client/pages/home_page.dart';
import 'package:crm/features/client/pages/leads_page.dart';
import 'package:crm/features/client/pages/report_page.dart';
import 'package:crm/features/client/pages/task_page.dart';
import 'package:crm/viewmodels/shell_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabProvider);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor:          AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor:                    Colors.transparent,
      statusBarIconBrightness:           Brightness.dark,
    ));

    const pages = [
      HomePage(),
      LeadsPage(),
      ClientPage(),
      TaskPage(),
      ReportPage(),
      AttendancePage(),   // ← new tab
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(currentTabProvider.notifier).state = index,
      ),
    );
  }
}
