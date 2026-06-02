import 'dart:ui';

import 'package:aurora/aurora.dart';
import 'package:catmovie/app/modules/home/views/tv.dart';
import 'package:catmovie/app/widget/k_body.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/views/index_home_view.dart';
import 'package:catmovie/app/modules/home/views/settings_view.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:xi/xi.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final List<Widget> _views = [
    const IndexHomeView(),
    const TVUI(),
    const SettingsView(),
  ];

  final List<Map<String, dynamic>> _tabs = [
    {
      "icon": CupertinoIcons.home,
      "title": "首页",
      "color": Colors.blue,
    },
    {
      "icon": CupertinoIcons.tv,
      "title": "电视",
      "color": Colors.orange,
    },
    {
      "icon": CupertinoIcons.settings,
      "title": "设置",
      "color": Colors.pink,
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDarkMode;
    Color backgroundColor = isDark
        ? const Color.fromRGBO(0, 0, 0, .63)
        : const Color.fromRGBO(255, 255, 255, .63);

    return GetBuilder<HomeController>(
      builder: (homeview) {
        return Shortcuts(
          shortcuts: {
            const SingleActivator(LogicalKeyboardKey.keyK, control: true):
                const ActivateIntent(),
            const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
                const ActivateIntent(),
          },
          child: Actions(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  homeview.showCommandPalette(context);
                  return null;
                },
              ),
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Aurora(
                      size: 88,
                      colors: [
                        Color(0xffc2e59c).withValues(alpha: .24),
                        Color(0xff64b3f4).withValues(alpha: .24)
                      ],
                      blur: 42,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    width: 88,
                    child: Aurora(
                      size: 88,
                      colors: [
                        Color(0xFFff0f7b),
                        Color(0xFFf89b29),
                      ],
                      blur: 120,
                    ),
                  ),
                  Positioned(
                    top: 120,
                    right: 12,
                    width: 88,
                    child: Aurora(
                      size: 88,
                      colors: [
                        Color(0xFF595cff),
                        Color(0xFFc6f8ff),
                      ],
                      blur: 120,
                    ),
                  ),
                  Positioned.fill(
                    child: PageView.builder(
                      controller: homeview.currentBarController,
                      itemBuilder: (context, index) {
                        return _views[index];
                      },
                      itemCount: _views.length,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        var currentFocus = FocusScope.of(context);
                        currentFocus.unfocus();
                        EasyLoading.dismiss();
                        controller.focusNode.requestFocus();
                        homeview.changeCurrentBarIndex(index);
                      },
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: homeview.showBottomNavigationBar
                  ? BottomAppBar(
                      elevation: 0,
                      color: homeview.currentBarIndex == 2
                          ? Colors.transparent
                          : backgroundColor,
                      padding: EdgeInsets.zero,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                          child: Container(
                            height: kDefaultAppBottomBarHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(_tabs.length, (index) {
                                final tab = _tabs[index];
                                final isSelected =
                                    homeview.currentBarIndex == index;
                                final selectedColor = tab['color'] as Color;

                                return Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        homeview.changeCurrentBarIndex(index);
                                      },
                                      borderRadius: BorderRadius.circular(0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: Icon(
                                                tab['icon'],
                                                key: ValueKey('icon_$index'),
                                                size: 22,
                                                color: isSelected
                                                    ? selectedColor
                                                    : (isDark
                                                        ? Colors.white54
                                                        : Colors.black54),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            AnimatedDefaultTextStyle(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                color: isSelected
                                                    ? selectedColor
                                                    : (isDark
                                                        ? Colors.white70
                                                        : Colors.black54),
                                              ),
                                              child: Text(tab['title']),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
              extendBody: homeview.showBottomNavigationBar,
            ),
          ),
        );
      },
    );
  }
}
