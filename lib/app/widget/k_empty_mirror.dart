import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';

class KEmptyMirror extends StatelessWidget {
  const KEmptyMirror({
    super.key,
    this.width,
    required this.cx,
    required this.context,
  });

  final double? width;
  final HomeController cx;
  final BuildContext context;

  double get _width {
    if (width == null) {
      return 120;
    }
    return width as double;
  }

  TextStyle get _style {
    return Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(color: (context.isDarkMode ? Colors.white : Colors.black).withValues(alpha: .72));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/error.png",
            fit: BoxFit.cover,
            width: _width,
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '无可用源, 请在',
                  style: TextStyle(
                    color: context.isDarkMode
                        ? Colors.white.withOpacity(0.5)
                        : const Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '视频源管理',
                      style: TextStyle(
                        color: context.isDarkMode
                            ? Colors.white.withOpacity(0.8)
                            : const Color(0xFF666666),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: '中添加',
                  style: TextStyle(
                    color: context.isDarkMode
                        ? Colors.white.withOpacity(0.5)
                        : const Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => cx.changeCurrentBarIndex(2),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? const Color(0xFFFF9800).withOpacity(0.15)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: context.isDarkMode
                        ? const Color(0xFFFF9800).withOpacity(0.4)
                        : const Color(0xFFFFB74D),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: context.isDarkMode
                          ? const Color(0xFFFFB74D)
                          : const Color(0xFFFF9800),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '前往设置',
                      style: TextStyle(
                        color: context.isDarkMode
                            ? const Color(0xFFFFB74D)
                            : const Color(0xFFFF9800),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
