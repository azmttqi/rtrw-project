import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;

  const CustomTopAppBar({
    super.key,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: leading,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 32,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.home_work_rounded,
              size: 24,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'LingkarWarga',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: actions ?? [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
