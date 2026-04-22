import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/viewmodels/auth_viewmodel.dart';
import 'package:crm/viewmodels/user_role_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // ── local prefs (in-memory; swap for SharedPreferences if needed) ──────────
  bool _notificationsEnabled = true;
  bool _activityReminders    = true;
  bool _taskAlerts           = true;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final fbUser    = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textDark, size: 17),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: userAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (_, __) => const Center(
                      child: Text('Failed to load profile',
                          style: TextStyle(color: AppColors.textMid))),
                  data: (user) {
                    final name  = user?.name  ?? fbUser?.displayName ?? 'User';
                    final email = user?.email ?? fbUser?.email        ?? '';
                    final isAdmin = user?.isAdmin ?? false;
                    final joinedAt = user?.createdAt;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Profile card ─────────────────────────────────────
                        _ProfileCard(
                          name: name,
                          email: email,
                          isAdmin: isAdmin,
                          joinedAt: joinedAt,
                          onEditName: () => _showEditNameSheet(name),
                        ),
                        const SizedBox(height: 28),

                        // ── Account section ──────────────────────────────────
                        _SectionLabel(label: 'Account'),
                        const SizedBox(height: 10),
                        _SettingsCard(children: [
                          _SettingsTile(
                            icon: Symbols.person_edit,
                            label: 'Edit Name',
                            subtitle: name,
                            onTap: () => _showEditNameSheet(name),
                          ),
                          _divider(),
                          _SettingsTile(
                            icon: Symbols.lock,
                            label: 'Change Password',
                            subtitle: 'Update your login password',
                            onTap: () => _showChangePasswordSheet(email),
                          ),
                          _divider(),
                          _SettingsTile(
                            icon: Symbols.email,
                            label: 'Email Address',
                            subtitle: email,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Verified',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // ── Notifications section ────────────────────────────
                        _SectionLabel(label: 'Notifications'),
                        const SizedBox(height: 10),
                        _SettingsCard(children: [
                          _SwitchTile(
                            icon: Symbols.notifications,
                            label: 'Push Notifications',
                            subtitle: 'Enable all app notifications',
                            value: _notificationsEnabled,
                            onChanged: (v) =>
                                setState(() => _notificationsEnabled = v),
                          ),
                          _divider(),
                          _SwitchTile(
                            icon: Symbols.task_alt,
                            label: 'Task Reminders',
                            subtitle: 'Alerts for upcoming tasks',
                            value: _taskAlerts,
                            onChanged: _notificationsEnabled
                                ? (v) => setState(() => _taskAlerts = v)
                                : null,
                          ),
                          _divider(),
                          _SwitchTile(
                            icon: Symbols.timeline,
                            label: 'Activity Reminders',
                            subtitle: 'Follow-up & lead reminders',
                            value: _activityReminders,
                            onChanged: _notificationsEnabled
                                ? (v) =>
                                    setState(() => _activityReminders = v)
                                : null,
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // ── App info section ─────────────────────────────────
                        _SectionLabel(label: 'App'),
                        const SizedBox(height: 10),
                        _SettingsCard(children: [
                          _SettingsTile(
                            icon: Symbols.info,
                            label: 'App Version',
                            subtitle: 'v0.1.0 · Nexify CRM',
                            onTap: null,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Up to date',
                                  style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          _divider(),
                          _SettingsTile(
                            icon: Symbols.security,
                            label: 'Privacy Policy',
                            onTap: () => _showComingSoon('Privacy Policy'),
                          ),
                          _divider(),
                          _SettingsTile(
                            icon: Symbols.article,
                            label: 'Terms of Service',
                            onTap: () => _showComingSoon('Terms of Service'),
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // ── Danger zone ──────────────────────────────────────
                        _SectionLabel(label: 'Account Actions'),
                        const SizedBox(height: 10),
                        _SettingsCard(children: [
                          _SettingsTile(
                            icon: Symbols.logout,
                            label: 'Sign Out',
                            labelColor: AppColors.danger,
                            iconColor: AppColors.danger,
                            iconBg: AppColors.dangerLight,
                            onTap: () => _confirmLogout(),
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // ── Footer ───────────────────────────────────────────
                        Center(
                          child: Text(
                            'Nexify CRM · Made by Nestoric Digital',
                            style: const TextStyle(
                                color: AppColors.textLight, fontSize: 11),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit name bottom sheet ─────────────────────────────────────────────────
  void _showEditNameSheet(String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Edit Name',
        icon: Symbols.person_edit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Display Name',
                style: TextStyle(
                    color: AppColors.textMid,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppColors.textDark, fontSize: 15),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Your full name',
                hintStyle: const TextStyle(color: AppColors.textLight),
                prefixIcon: const Icon(Symbols.person,
                    color: AppColors.textLight, size: 20),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            _PrimaryButton(
              label: 'Save Changes',
              onTap: () async {
                final name = ctrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context);
                try {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  await FirebaseAuth.instance.currentUser
                      ?.updateDisplayName(name);
                  if (uid != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .update({'name': name});
                  }
                  if (mounted) _toast('Name updated');
                } catch (e) {
                  if (mounted) _toast('Failed to update name');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Change password bottom sheet ───────────────────────────────────────────
  void _showChangePasswordSheet(String email) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew     = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSS) => _BottomSheet(
          title: 'Change Password',
          icon: Symbols.lock,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PwField(
                ctrl: currentCtrl,
                label: 'Current Password',
                obscure: obscureCurrent,
                onToggle: () =>
                    setSS(() => obscureCurrent = !obscureCurrent),
              ),
              const SizedBox(height: 14),
              _PwField(
                ctrl: newCtrl,
                label: 'New Password',
                obscure: obscureNew,
                onToggle: () => setSS(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 14),
              _PwField(
                ctrl: confirmCtrl,
                label: 'Confirm New Password',
                obscure: obscureConfirm,
                onToggle: () =>
                    setSS(() => obscureConfirm = !obscureConfirm),
              ),
              const SizedBox(height: 20),
              _PrimaryButton(
                label: 'Update Password',
                onTap: () async {
                  final current = currentCtrl.text.trim();
                  final next    = newCtrl.text.trim();
                  final confirm = confirmCtrl.text.trim();

                  if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                    _toast('Please fill all fields');
                    return;
                  }
                  if (next != confirm) {
                    _toast('New passwords do not match');
                    return;
                  }
                  if (next.length < 6) {
                    _toast('Password must be at least 6 characters');
                    return;
                  }

                  Navigator.pop(context);
                  try {
                    final user = FirebaseAuth.instance.currentUser!;
                    final cred = EmailAuthProvider.credential(
                        email: email, password: current);
                    await user.reauthenticateWithCredential(cred);
                    await user.updatePassword(next);
                    if (mounted) _toast('Password updated successfully');
                  } on FirebaseAuthException catch (e) {
                    if (mounted) {
                      _toast(e.code == 'wrong-password'
                          ? 'Current password is incorrect'
                          : 'Failed: ${e.message}');
                    }
                  } catch (_) {
                    if (mounted) _toast('Something went wrong');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logout confirmation ────────────────────────────────────────────────────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sign Out',
            style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        content: const Text(
            'Are you sure you want to sign out of Nexify CRM?',
            style: TextStyle(color: AppColors.textMid, fontSize: 14)),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Cancel',
                        style: TextStyle(
                            color: AppColors.textMid,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Sign Out',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _showComingSoon(String name) => _toast('$name coming soon');

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _divider() => const Divider(
      color: AppColors.divider, height: 1, indent: 56, endIndent: 0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile card
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String name, email;
  final bool isAdmin;
  final DateTime? joinedAt;
  final VoidCallback onEditName;
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.isAdmin,
    this.joinedAt,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.30),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: [
        // Avatar
        Stack(alignment: Alignment.bottomRight, children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          GestureDetector(
            onTap: onEditName,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.edit_rounded,
                  color: AppColors.primary, size: 14),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Text(name,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(email,
            style:
                TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
        const SizedBox(height: 12),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _badge(isAdmin ? 'Admin' : 'Employee',
              isAdmin ? Colors.amber : Colors.white.withOpacity(0.25),
              isAdmin ? const Color(0xFF7B5200) : Colors.white),
          if (joinedAt != null) ...[
            const SizedBox(width: 8),
            _badge(
                'Joined ${DateFormat('MMM yyyy').format(joinedAt!)}',
                Colors.white.withOpacity(0.2),
                Colors.white),
          ],
        ]),
      ]),
    );
  }

  Widget _badge(String label, Color bg, Color fg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: AppColors.textMid,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8));
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Column(children: children),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? labelColor, iconColor, iconBg;
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.labelColor,
    this.iconColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final iColor = iconColor ?? AppColors.primary;
    final iBg    = iconBg    ?? AppColors.primaryLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: iColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      color: labelColor ?? AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
            ]),
          ),
          if (trailing != null) trailing!
          else if (onTap != null)
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight, size: 20),
        ]),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textLight, fontSize: 12)),
            ]),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveThumbColor: AppColors.textLight,
            inactiveTrackColor: AppColors.border,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _BottomSheet(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 24),
            child,
          ]),
        ),
      );
}

class _PwField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  const _PwField({
    required this.ctrl,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMid,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            obscureText: obscure,
            style:
                const TextStyle(color: AppColors.textDark, fontSize: 15),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: AppColors.textLight),
              prefixIcon: const Icon(Symbols.lock,
                  color: AppColors.textLight, size: 20),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Symbols.visibility : Symbols.visibility_off,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      );
}
