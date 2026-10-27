import 'package:flutter/material.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, stockOut, danger, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, borderSide, useGradient) = switch (variant) {
      AppButtonVariant.primary => (
          AppColors.merahSosro,
          Colors.white,
          BorderSide.none,
          true,
        ),
      AppButtonVariant.secondary => (
          AppColors.merahMuda,
          AppColors.merahTua,
          BorderSide.none,
          false,
        ),
      AppButtonVariant.stockOut => (
          AppColors.biruTruk,
          Colors.white,
          BorderSide.none,
          false,
        ),
      AppButtonVariant.danger => (
          AppColors.bata,
          Colors.white,
          BorderSide.none,
          false,
        ),
      AppButtonVariant.outline => (
          Colors.transparent,
          AppColors.merahSosro,
          const BorderSide(color: AppColors.garis, width: 1.5),
          false,
        ),
    };

    final content = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: fgColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    final borderRadius = BorderRadius.circular(10);

    if (useGradient && onPressed != null && !isLoading) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.merahSosro.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            child: Center(child: content),
          ),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
          disabledForegroundColor: fgColor.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: content,
      ),
    );
  }
}
