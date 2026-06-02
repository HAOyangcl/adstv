import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/views/history.dart';
import 'package:catmovie/app/modules/home/views/search.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/utils/boop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:catmovie/app/modules/home/views/source_help.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/routes/app_pages.dart';
import 'package:catmovie/app/widget/k_body.dart';
import 'package:catmovie/app/widget/k_empty_mirror.dart';
import 'package:catmovie/app/widget/k_error_stack.dart';
import 'package:catmovie/app/widget/movie_card_item.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:simple/x.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:xi/xi.dart';

double kHomeMovieCardSpacing = 12;

CallbackAction<Intent> shortcutCallback<T extends Intent>(
    int curr, VoidCallback cb) {
  return CallbackAction(onInvoke: (_) {
    if (curr != 0) return;
    cb();
    return null;
  });
}

class IndexHomeView extends StatefulWidget {
  const IndexHomeView({super.key});

  @override
  createState() => _IndexHomeViewState();
}

class _IndexHomeViewState extends State<IndexHomeView>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  HomeController controller = Get.find<HomeController>();

  ScrollController scrollController = ScrollController();

  int get cardCount {
    double screenWidth = context.mediaQuery.size.width;
    double minCardWidth = 188;
    double spacing = kHomeMovieCardSpacing;
    int count = ((screenWidth + spacing) / (minCardWidth + spacing)).floor();
    count = count.clamp(1, 6);
    return count;
  }

  /// 错误日志
  String get errorMsg => controller.indexHomeLoadDataErrorMessage;

  /// 错误日志最大展示行数
  int get errorMsgMaxLines => 12;

  // 在 handleClickItem 方法中添加错误处理
  Future<void> handleClickItem(VideoDetail subItem, HomeController cx) async {
    try {
      var data = subItem;
      if (subItem.videos.isEmpty) {
        var id = subItem.id;
        var isNext = await showLoadingPlaceholderTask(() async {
          data = await controller.currentMirrorItem.getDetail(id);
          data = subItem.mergeWith(data);
        });
        if (!isNext) return;
      }
      data.setContext(controller.currentMirrorItem.meta);
      Get.toNamed(
        Routes.PLAY,
        arguments: data,
      );
    } catch (e) {
      EasyLoading.showError("加载失败: ${e.toString()}");
    }
  }

  double get _calcImageWidth {
    var width = controller.windowLastSize.width;
    if (width >= 500) return 120;
    return width * .6;
  }

  bool get indexEnablePullDown {
    return !controller.isLoading && false;
  }

  bool get indexEnablePullUp {
    return !controller.isLoading && controller.homedata.isNotEmpty;
  }

  String get currentTitle {
    // 如果没有数据源，直接显示"小猫影视"
    if (controller.mirrorListIsEmpty) {
      return "小猫影视";
    }
    try {
      return controller.currentMirrorItem.meta.name;
    } catch (e) {
      return "小猫影视";
    }
  }

  bool get categoryIsEmpty {
    return controller.currentCategoryer.isEmpty;
  }

  int get currCategoryIndex {
    var now = controller.currentCategoryerNow;
    if (now == null) return -1;
    return controller.currentCategoryer.indexOf(now);
  }

  void switchCategory(SourceSpiderQueryCategory curr) {
    if (curr == controller.currentCategoryerNow) {
      return;
    }
    controller.setCurrentCategoryerNow(curr);
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    initWithOnBoarding();
  }

  void initWithOnBoarding() {
    // 引导页逻辑保持不变
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<HomeController>(
      builder: (homeview) => ScrollsToTop(
        onScrollsToTop: (cx) async {
          if (homeview.isLoading) return;
          if (homeview.currentBarIndex != 0) return;
          scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        },
        child: Scaffold(
          backgroundColor:
              context.isDarkMode ? Color(0xFF0A0A0A) : Color(0xFFF8F9FA),
          appBar: WindowAppBar(
            iosBackStyle: true,
            title: Zoom(
              onTap: () {
                EasyLoading.dismiss();
                homeview.showMirrorModel(context);
                boop.selection();
              },
              child: Builder(builder: (context) {
                return Row(
                  spacing: 8,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColorLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.string(
                        r"""
      <svg t="1757795810585" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="8443" width="200" height="200"><path d="M909.31 307.42c-32.09-36.66-77.05-62.04-128.53-68.91-6.36-0.85-12.73-1.67-19.1-2.45l68.58-98.85c12.86-18.58 8.27-44.07-10.31-56.93-18.6-12.94-44.07-8.27-56.93 10.27L668.57 226.7h-0.01c-52.57-4.07-105.26-6.11-157.95-6.11s-105.37 2.04-157.94 6.11h-0.01L258.21 90.54c-12.9-18.54-38.43-23.21-56.93-10.27-18.58 12.86-23.17 38.35-10.31 56.93l68.59 98.85c-6.37 0.78-12.74 1.6-19.1 2.45C137.51 252.24 60.62 340.06 60.62 443.92v288.06c0 51.93 19.22 99.85 51.31 136.5 32.09 36.66 77.05 62.04 128.53 68.91a2043.998 2043.998 0 0 0 540.32 0c102.95-13.73 179.84-101.55 179.84-205.41V443.92c0-51.93-19.22-99.85-51.31-136.5z m-267.5 315.96l-148.1 115.6c-29.51 23.04-72.61 2.01-72.61-35.43v-231.2c0-37.44 43.1-58.47 72.61-35.43l148.1 115.59c23.06 18 23.06 52.88 0 70.87z" p-id="8444"></path></svg>
      """,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text(
                      currentTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color:
                            context.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                );
              }),
            ),
            actions: [
              Zoom(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.search,
                      size: 20,
                      color: context.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  onPressed: () {
                    EasyLoading.dismiss();
                    if (homeview.mirrorListIsEmpty) {
                      EasyLoading.showError('暂无可用源');
                      return;
                    }
                    Get.to(() => const SearchV2());
                  },
                ),
              ),
              SizedBox(width: 4),
              Zoom(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.clock,
                      size: 20,
                      color: context.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  onPressed: () {
                    EasyLoading.dismiss();
                    Get.to(() => const HistoryPage());
                  },
                ),
              ),
            ],
          ),
          body: Shortcuts(
            shortcuts: {
              const SingleActivator(LogicalKeyboardKey.keyP, control: true):
                  ScrollUpIntent(),
              const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                  ScrollDownIntent(),
              const SingleActivator(LogicalKeyboardKey.keyK, control: true):
                  ScrollUpIntent(),
              const SingleActivator(LogicalKeyboardKey.keyJ, control: true):
                  ScrollDownIntent(),
              const SingleActivator(LogicalKeyboardKey.bracketLeft, meta: true):
                  CategoryPrevIntent(),
              const SingleActivator(LogicalKeyboardKey.bracketRight,
                  meta: true): CategoryNextIntent(),
              const SingleActivator(LogicalKeyboardKey.keyT, meta: true):
                  MirrorTableIntent(),
            },
            child: Actions(
              actions: {
                ScrollUpIntent:
                    shortcutCallback(controller.currentBarIndex, () {
                  scrollUp(scrollController);
                }),
                ScrollDownIntent:
                    shortcutCallback(controller.currentBarIndex, () {
                  scrollDown(scrollController);
                }),
                CategoryPrevIntent:
                    shortcutCallback(controller.currentBarIndex, () {
                  if (categoryIsEmpty || currCategoryIndex == 0) return;
                  var cx = controller.currentCategoryer[currCategoryIndex - 1];
                  switchCategory(cx);
                }),
                CategoryNextIntent:
                    shortcutCallback(controller.currentBarIndex, () {
                  if (categoryIsEmpty ||
                      currCategoryIndex ==
                          controller.currentCategoryer.length - 1) {
                    return;
                  }
                  var cx = controller.currentCategoryer[currCategoryIndex + 1];
                  switchCategory(cx);
                }),
                MirrorTableIntent:
                    shortcutCallback(controller.currentBarIndex, () {
                  homeview.showMirrorModel(context);
                }),
              },
              child: KeyboardListener(
                focusNode: controller.homeFocusNode,
                autofocus: true,
                child: KBody(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        width: double.infinity,
                        height: !categoryIsEmpty ? 52 : 0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: List.generate(
                                controller.currentCategoryer.length, (index) {
                              SourceSpiderQueryCategory curr =
                                  controller.currentCategoryer[index];
                              bool isCurr =
                                  curr == controller.currentCategoryerNow;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Zoom(
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    color: isCurr
                                        ? Theme.of(context).primaryColor
                                        : (context.isDarkMode
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.05)),
                                    child: Text(
                                      curr.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isCurr
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isCurr
                                            ? Colors.white
                                            : (context.isDarkMode
                                                ? Colors.white70
                                                : Colors.black87),
                                      ),
                                    ),
                                    onPressed: () {
                                      EasyLoading.dismiss();
                                      switchCategory(curr);
                                      boop.selection();
                                    },
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Builder(builder: (context) {
                          if (controller.mirrorListIsEmpty) {
                            return KEmptyMirror(
                              cx: controller,
                              width: _calcImageWidth,
                              context: context,
                            );
                          }
                          return RefreshConfiguration(
                            springDescription: const SpringDescription(
                              mass: 1,
                              stiffness: 364.71867768595047,
                              damping: 35.2,
                            ),
                            child: SmartRefresher(
                              header: WaterDropHeader(
                                refresh: Row(
                                  spacing: 12,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CupertinoActivityIndicator(),
                                    Text("加载中", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                complete: Row(
                                  spacing: 12,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.smiley, size: 16),
                                    Text("加载完成",
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              footer: CustomFooter(
                                builder:
                                    (BuildContext context, LoadStatus? mode) {
                                  Widget body;
                                  if (mode == LoadStatus.idle) {
                                    body = Text("上划加载更多",
                                        style: TextStyle(color: Colors.grey));
                                  } else if (mode == LoadStatus.loading) {
                                    body = CupertinoActivityIndicator();
                                  } else if (mode == LoadStatus.failed) {
                                    body = Text("加载失败, 请重试",
                                        style: TextStyle(color: Colors.red));
                                  } else if (mode == LoadStatus.canLoading) {
                                    body = Text("释放以加载更多",
                                        style: TextStyle(color: Colors.grey));
                                  } else {
                                    body = Text("没有更多数据",
                                        style: TextStyle(color: Colors.grey));
                                  }
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: body),
                                  );
                                },
                              ),
                              enablePullDown: indexEnablePullDown,
                              enablePullUp: indexEnablePullUp,
                              scrollController: scrollController,
                              physics: const BouncingScrollPhysics(),
                              controller: homeview.refreshController,
                              onLoading: homeview.refreshOnLoading,
                              onRefresh: homeview.refreshOnRefresh,
                              child: Builder(
                                builder: (_) {
                                  if (homeview.isLoading) {
                                    return const Center(
                                      child: CupertinoActivityIndicator(
                                          radius: 20),
                                    );
                                  }
                                  if (homeview.homedata.isEmpty) {
                                    if (errorMsg.isNotEmpty) {
                                      // 显示友好的错误提示
                                      return SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 60),
                                              Container(
                                                padding: EdgeInsets.all(32),
                                                decoration: BoxDecoration(
                                                  color: context.isDarkMode
                                                      ? Colors.white
                                                          .withOpacity(0.05)
                                                      : Colors.black
                                                          .withOpacity(0.02),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.warning_amber_rounded,
                                                  size: 64,
                                                  color: Colors.orange.shade400,
                                                ),
                                              ),
                                              SizedBox(height: 24),
                                              Text(
                                                "视频源无法访问",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: context.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 32),
                                                child: Text(
                                                  errorMsg.contains("所有视频源")
                                                      ? errorMsg
                                                      : "当前视频源无法访问，请尝试以下方法：",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: context.isDarkMode
                                                        ? Colors.white70
                                                        : Colors.black54,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              SizedBox(height: 24),
                                              // 操作按钮组
                                              Wrap(
                                                spacing: 16,
                                                runSpacing: 12,
                                                alignment: WrapAlignment.center,
                                                children: [
                                                  Zoom(
                                                    child:
                                                        CupertinoButton.filled(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      onPressed: () {
                                                        homeview
                                                            .showMirrorModel(
                                                                context);
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              CupertinoIcons
                                                                  .switch_camera,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Text("切换视频源"),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Zoom(
                                                    child: CupertinoButton(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: context.isDarkMode
                                                          ? Colors.white
                                                              .withOpacity(0.1)
                                                          : Colors.black
                                                              .withOpacity(
                                                                  0.05),
                                                      onPressed: () {
                                                        homeview
                                                            .refreshOnRefresh();
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              CupertinoIcons
                                                                  .refresh,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Text("重新加载"),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (errorMsg.contains("请添加其他源"))
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 16),
                                                  child: Zoom(
                                                    child: CupertinoButton(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: Colors.green,
                                                      onPressed: () {
                                                        // 打开源管理帮助页面
                                                        Get.to(() =>
                                                            const SourceHelpTable());
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              CupertinoIcons
                                                                  .add,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Text("添加视频源"),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              SizedBox(height: 40),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(32),
                                          decoration: BoxDecoration(
                                            color: context.isDarkMode
                                                ? Colors.white.withOpacity(0.05)
                                                : Colors.black
                                                    .withOpacity(0.02),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.inbox_outlined,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 24),
                                        Text(
                                          "暂无数据",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: context.isDarkMode
                                                ? Colors.white54
                                                : Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 88),
                                      ],
                                    );
                                  }
                                  return GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(16),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cardCount,
                                      crossAxisSpacing: kHomeMovieCardSpacing,
                                      mainAxisSpacing: kHomeMovieCardSpacing,
                                      childAspectRatio: 2 / 3,
                                    ),
                                    itemCount: homeview.homedata.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var subItem = homeview.homedata[index];
                                      return MovieCardItem(
                                        imageUrl: subItem.smallCoverImage,
                                        title: subItem.title,
                                        note: subItem.remark,
                                        onTap: () {
                                          EasyLoading.dismiss();
                                          handleClickItem(subItem, controller);
                                          boop.selection();
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
