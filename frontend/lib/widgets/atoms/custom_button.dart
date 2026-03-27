import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, text, google }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final Widget? customIcon;
  final bool iconRight;
  final double width;
  final bool useGradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.customIcon,
    this.iconRight = false,
    this.width = double.infinity,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isPrimary = variant == ButtonVariant.primary;

    return Container(
      width: width,
      decoration: useGradient && isPrimary && onPressed != null
          ? BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    if (variant == ButtonVariant.outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: onPressed == null ? Colors.grey : AppColors.primaryGreen,
          ),
          foregroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildContent(context, AppColors.primaryGreen),
      );
    }

    if (variant == ButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildContent(context, AppColors.primaryGreen),
      );
    }

    if (variant == ButtonVariant.google) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.inputBackground,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildContent(context, AppColors.textPrimaryLight),
      );
    }

    // Primary & Secondary
    final bgColor = useGradient ? Colors.transparent : (variant == ButtonVariant.primary ? AppColors.primaryGreen : AppColors.primaryYellow);
    
    final fgColor = variant == ButtonVariant.primary 
        ? Colors.white 
        : Colors.black87;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        shadowColor: useGradient ? Colors.transparent : null,
        elevation: useGradient ? 0 : (variant == ButtonVariant.primary ? 2 : 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildContent(context, fgColor),
    );
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: variant == ButtonVariant.outline || variant == ButtonVariant.text
              ? AppColors.primaryGreen
              : (variant == ButtonVariant.secondary ? Colors.black54 : Colors.white),
        ),
      );
    }

    List<Widget> children = [];
    
    if (customIcon != null || icon != null) {
      final iconWidget = customIcon ?? Icon(icon, size: 20);
      if (iconRight) {
        children.add(Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ));
        children.add(const SizedBox(width: 8));
        children.add(iconWidget);
      } else {
        children.add(iconWidget);
        children.add(const SizedBox(width: 8));
        children.add(Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ));
      }
    } else {
      children.add(Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
