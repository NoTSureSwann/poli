import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Enhanced Card Widget with modern design
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final BoxShadow? shadow;
  final VoidCallback? onTap;
  final bool elevated;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
    this.backgroundColor,
    this.shadow,
    this.onTap,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: elevated
              ? [
                  shadow ??
                      const BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// Enhanced Button Widget
class ModernButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonVariant variant;
  final IconData? icon;
  final double width;
  final double height;
  final EdgeInsets padding;

  const ModernButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.width = double.infinity,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppTheme.primary;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppTheme.primaryLight;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppTheme.primary;
        break;
      case ButtonVariant.danger:
        backgroundColor = AppTheme.error;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.success:
        backgroundColor = AppTheme.success;
        foregroundColor = Colors.white;
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: variant == ButtonVariant.outline
                ? BorderSide(color: AppTheme.primary)
                : BorderSide.none,
          ),
          elevation: variant == ButtonVariant.outline ? 0 : 2,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

enum ButtonVariant { primary, secondary, outline, danger, success }

/// Enhanced Text Field Widget
class ModernTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int maxLines;
  final int minLines;

  const ModernTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscured,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: _obscured ? 1 : widget.maxLines,
          minLines: widget.minLines,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppTheme.primary)
                : null,
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscured = !_obscured;
                      });
                    },
                    child: Icon(
                      _obscured ? Icons.visibility : Icons.visibility_off,
                      color: AppTheme.primary,
                    ),
                  )
                : widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixTap,
                    child: Icon(widget.suffixIcon, color: AppTheme.primary),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// Enhanced Loading Widget
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingWidget({super.key, this.message, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              strokeWidth: 4,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Enhanced Error Widget
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ],
      ),
    );
  }
}

/// Enhanced Info Card
class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.backgroundColor = const Color(0xFFE3F2FD),
    this.iconColor = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: iconColor),
                ),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
