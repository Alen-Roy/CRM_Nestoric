import 'package:flutter_riverpod/legacy.dart';

/// Shared provider that controls which tab is selected in MainShell.
/// Any widget in the tree can switch tabs by writing:
///   ref.read(currentTabProvider.notifier).state = 4;
final currentTabProvider = StateProvider<int>((ref) => 0);
