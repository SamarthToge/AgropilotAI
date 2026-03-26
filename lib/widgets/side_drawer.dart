import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_state.dart';
import '../screens/settings_screen.dart';
import '../screens/farmer_profile_screen.dart';
import '../screens/ai_analysis_screen.dart';
import '../screens/history_screen.dart';

class SideDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const SideDrawer({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    state.farmerName.isNotEmpty
                        ? state.farmerName[0].toUpperCase()
                        : "F",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.farmerName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "🌿 Growing ${state.cropType}",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: "Home Dashboard",
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: "Settings",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: "Farmer Profile",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FarmerProfileScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.history_outlined,
                    label: "History & Reports",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.auto_graph_outlined,
                    label: "🤖 AI Analysis",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AiAnalysisScreen()),
                      );
                    },
                  ),
                  const Divider(height: 24),
                  const Spacer(),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: "Logout",
                    iconColor: AppColors.critical,
                    labelColor: AppColors.critical,
                    onTap: () {
                      Navigator.pop(context);
                      onLogout();
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "AgroPilot AI v1.0.0",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: labelColor ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      horizontalTitleGap: 8,
    );
  }
}
