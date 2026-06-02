# Flutter 项目 lib 目录代码导出

> 自动生成的项目代码文档，按目录结构整理

## 📂 lib/

#### 📄 `lib/main.dart`

```dart
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:catmovie/shared/env.dart';
import 'package:catmovie/utils/boop.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:catmovie/isar/repo.dart';
import 'package:catmovie/shared/auto_injector.dart';
// TODO: hide_cursor已移除，使用系统默认光标
// import 'package:hide_cursor/hide_cursor.dart';
import 'package:media_kit/media_kit.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xi/xi.dart';
import 'shared/manage.dart';
import 'package:catmovie/shared/enum.dart';

import 'app/routes/app_pages.dart';

ThemeData applyTheme({bool isDark = true}) {
  var theme = isDark ? ThemeData.dark() : ThemeData.light();
  // TODO(d1y): support linux fallback font(s)
  // https://github.com/LastMonopoly/chinese_font_library/issues/11
  // NOTE(d1y): Linux 下最好指定一个字体(OPPO Sans 字体就不错)
  // > https://www.coloros.com/article/A00000074
  // https://github.com/wordshub/free-font
  theme = theme.copyWith(
    textTheme: TextTheme().useSystemChineseFont(
      isDark ? Brightness.dark : Brightness.light,
    ),
  );
  return theme;
}

/// 返回当前主题 -> [ThemeMode]
Future<ThemeMode> runBefore() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make sure to add the required packages to pubspec.yaml:
  // * https://github.com/media-kit/media-kit#installation
  // * https://pub.dev/packages/media_kit#installation
  MediaKit.ensureInitialized();

  // Register a custom protocol
  // For macOS platform needs to declare the scheme in ios/Runner/Info.plist
  await protocolHandler.register('yoyo');

  if (GetPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    windowManager.setTitle("小猫影视");
  }

  var enableHttpLog = CMEnv.isDebug && CMEnv.enableFullHttpLog;
  await XHttp.init(enableLog: enableHttpLog);
  await IsarRepository().init();
  await SpiderManage.init();
  await boop.init();
  await js2.init();
  registerAutoInjector();
  var currTheme = IsarRepository().settingsSingleModel.themeMode;
  Brightness wrapperIfDark = Brightness.light;
  if (currTheme.isDark) {
    wrapperIfDark = Brightness.dark;
  }
  if (GetPlatform.isWindows && currTheme.isSytem) {
    wrapperIfDark = getWindowsThemeMode();
  }
  if (currTheme.isSytem) return ThemeMode.system;
  return wrapperIfDark == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
}

void runAfter() {
  if (GetPlatform.isDesktop) {
    // 确保光标可见
    // hideCursor.showCursor();
    doWhenWindowReady(() {
      const minSize = Size(420, 420);
      appWindow.minSize = minSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

void main() async {
  ThemeMode currentThemeMode = await runBefore();
  runApp(
    GetMaterialApp(
      title: "小猫影视",
      scrollBehavior: DragonScrollBehavior(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      themeMode: currentThemeMode,
      theme: applyTheme(isDark: false),
      darkTheme: applyTheme(),
      builder: EasyLoading.init(),
    ),
  );
  runAfter();
}

```

### 📂 lib/app

#### 📄 `lib/app\extension.dart`

```dart
import 'dart:ui';

import 'package:catmovie/isar/schema/category_schema.dart';
import 'package:catmovie/isar/schema/video_history_schema.dart';
import 'package:isar_community/isar.dart';
import 'package:catmovie/isar/repo.dart';
import 'package:catmovie/isar/schema/history_schema.dart';
import 'package:catmovie/isar/schema/mirror_schema.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:catmovie/isar/schema/settings_schema.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension StringWithColor on String {
  Color get $color {
    String hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension ISettingMixin on Object {
  IsarCollection<SettingsIsarModel> get settingAs => IsarRepository().settingAs;
  SettingsIsarModel get settingAsValue => IsarRepository().settingsSingleModel;

  IsarCollection<HistoryIsarModel> get historyAs =>
      IsarRepository().isar.historyIsarModels;

  IsarCollection<ParseIsarModel> get parseAs =>
      IsarRepository().isar.parseIsarModels;

  IsarCollection<MirrorIsarModel> get mirrorAs =>
      IsarRepository().isar.mirrorIsarModels;

  IsarCollection<VideoHistoryIsarModel> get videoHistoryAs =>
      IsarRepository().isar.videoHistoryIsarModels;

  IsarCollection<CategoryIsarModel> get categoryAs =>
      IsarRepository().isar.categoryIsarModels;

  Isar get isarInstance => IsarRepository().isar;

  T getSettingAsKeyIdent<T>(SettingsAllKey key, {T? defaultValue}) {
    try {
      return getSettingAsKey(key) as T;
    } catch (e) {
      return defaultValue!;
    }
  }

  Object getSettingAsKey(SettingsAllKey key) {
    var curr = settingAsValue;
    if (key == SettingsAllKey.themeMode) {
      return curr.themeMode;
    } else if (key == SettingsAllKey.isNsfw) {
      return curr.isNSFW;
    } else if (key == SettingsAllKey.mirrorIndex) {
      return curr.mirrorIndex;
    } else if (key == SettingsAllKey.mirrorTextarea) {
      return curr.mirrorTextarea;
    } else if (key == SettingsAllKey.showPlayTips) {
      return curr.showPlayTips;
    } else if (key == SettingsAllKey.webviewPlayType) {
      return curr.webviewPlayType;
    } else if (key == SettingsAllKey.onBoardingShowed) {
      return curr.onBoardingShowed;
    } else if (key == SettingsAllKey.videoKernel) {
      return curr.videoKernel;
    } else if (key == SettingsAllKey.hapticFeedback) {
      return curr.hapticFeedback;
    } else if (key == SettingsAllKey.showNsfwSetting) {
      return curr.showNsfwSetting;
    }
    return curr.id;
  }

  void updateSetting(SettingsAllKey key, dynamic value) {
    var curr = settingAsValue;
    if (key == SettingsAllKey.themeMode) {
      curr.themeMode = value;
    } else if (key == SettingsAllKey.isNsfw) {
      curr.isNSFW = value;
    } else if (key == SettingsAllKey.mirrorIndex) {
      curr.mirrorIndex = value;
    } else if (key == SettingsAllKey.mirrorTextarea) {
      curr.mirrorTextarea = value;
    } else if (key == SettingsAllKey.showPlayTips) {
      curr.showPlayTips = value;
    } else if (key == SettingsAllKey.webviewPlayType) {
      curr.webviewPlayType = value;
    } else if (key == SettingsAllKey.onBoardingShowed) {
      curr.onBoardingShowed = value;
    } else if (key == SettingsAllKey.videoKernel) {
      curr.videoKernel = value;
    } else if (key == SettingsAllKey.hapticFeedback) {
      curr.hapticFeedback = value;
    } else if (key == SettingsAllKey.showNsfwSetting) {
      curr.showNsfwSetting = value;
    } else {
      return;
    }
    IsarRepository().isar.writeTxnSync(() {
      settingAs.putSync(curr);
    });
  }
}

extension Mixxxx on String {
  Future<void> openURL() async {
    await canLaunchUrlString(this)
        ? await launchUrlString(this)
        : throw 'Could not launch $this';
  }

  Future openToIINA() async {
    return 'iina://weblink?url=$this&new_window=1'.openURL();
  }
}

```

#### 📂 lib/app\components

#### 📄 `lib/app\components\command_palette.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 命令项
class CommandPaletteItem {
  final String id;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final List<String> keywords;
  final VoidCallback? onTap;
  final bool enabled;

  CommandPaletteItem({
    required this.id,
    required this.label,
    this.subtitle,
    this.icon,
    this.keywords = const [],
    this.onTap,
    this.enabled = true,
  });
}

/// 命令面板控制器
class CommandPaletteController extends GetxController {
  final RxList<CommandPaletteItem> _allItems = <CommandPaletteItem>[].obs;
  final RxList<CommandPaletteItem> filteredItems = <CommandPaletteItem>[].obs;
  final RxString query = ''.obs;
  final RxInt selectedIndex = 0.obs;

  List<CommandPaletteItem> get allItems => _allItems.toList();

  void setItems(List<CommandPaletteItem> items) {
    _allItems.value = items;
    _filter();
  }

  void updateQuery(String value) {
    query.value = value;
    selectedIndex.value = 0;
    _filter();
  }

  void _filter() {
    final q = query.value.toLowerCase().trim();
    if (q.isEmpty) {
      filteredItems.value = _allItems.where((e) => e.enabled).toList();
      return;
    }

    filteredItems.value = _allItems.where((item) {
      if (!item.enabled) return false;
      final searchText = '${item.label} ${item.subtitle ?? ''} ${item.keywords.join(' ')}';
      return searchText.toLowerCase().contains(q);
    }).toList();
  }

  void selectNext() {
    if (filteredItems.isEmpty) return;
    selectedIndex.value = (selectedIndex.value + 1) % filteredItems.length;
  }

  void selectPrevious() {
    if (filteredItems.isEmpty) return;
    selectedIndex.value = (selectedIndex.value - 1 + filteredItems.length) % filteredItems.length;
  }

  void executeSelected() {
    if (filteredItems.isEmpty) return;
    final item = filteredItems[selectedIndex.value];
    item.onTap?.call();
  }

  void clear() {
    query.value = '';
    selectedIndex.value = 0;
    _filter();
  }
}

/// 命令面板组件
class CommandPalette extends StatelessWidget {
  final CommandPaletteController controller;
  final VoidCallback? onClose;
  final String? title;
  final String? hintText;

  const CommandPalette({
    super.key,
    required this.controller,
    this.onClose,
    this.title,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 640,
            maxHeight: 480,
          ),
          child: Container(
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 搜索输入框
                _buildSearchField(context),
                const Divider(height: 1),
                // 结果列表
                Flexible(
                  child: Obx(() {
                    if (controller.filteredItems.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            '没有找到匹配的命令',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.filteredItems[index];
                        return Obx(() => _buildItem(
                          context,
                          item,
                          index == controller.selectedIndex.value,
                        ));
                      },
                    );
                  }),
                ),
                // 底部提示
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) {
                if (event is RawKeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    controller.selectNext();
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    controller.selectPrevious();
                  } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                    controller.executeSelected();
                    onClose?.call();
                  } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                    onClose?.call();
                  }
                }
              },
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hintText ?? '输入命令或搜索...',
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: controller.updateQuery,
              ),
            ),
          ),
          Obx(() {
            if (controller.query.value.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => controller.clear(),
              child: Icon(
                Icons.close,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, CommandPaletteItem item, bool isSelected) {
    return InkWell(
      onTap: () {
        item.onTap?.call();
        onClose?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Enter',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: (Theme.of(context).colorScheme.surfaceContainerHighest ?? 
               Theme.of(context).colorScheme.onSurface.withOpacity(0.05)).withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          _buildShortcutHint(context, '↑↓', '选择'),
          const SizedBox(width: 16),
          _buildShortcutHint(context, '↵', '执行'),
          const SizedBox(width: 16),
          _buildShortcutHint(context, 'Esc', '关闭'),
        ],
      ),
    );
  }

  Widget _buildShortcutHint(BuildContext context, String key, String action) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
            ),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          action,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

/// 显示命令面板的便捷方法
void showCommandPalette({
  required BuildContext context,
  required List<CommandPaletteItem> items,
  String? title,
  String? hintText,
}) {
  final controller = Get.put(CommandPaletteController());
  controller.setItems(items);
  
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (ctx) {
      return CommandPalette(
        controller: controller,
        title: title,
        hintText: hintText,
        onClose: () {
          Navigator.of(ctx).pop();
          // 延迟删除控制器，避免立即删除导致的问题
          Future.delayed(const Duration(milliseconds: 100), () {
            if (Get.isRegistered<CommandPaletteController>()) {
              Get.delete<CommandPaletteController>();
            }
          });
        },
      );
    },
  );
}

```

#### 📂 lib/app\modules

##### 📂 lib/app\modules\home

###### 📂 lib/app\modules\home\bindings

#### 📄 `lib/app\modules\home\bindings\home_binding.dart`

```dart
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}

```

###### 📂 lib/app\modules\home\controllers

#### 📄 `lib/app\modules\home\controllers\home_controller.dart`

```dart
import 'package:catmovie/utils/boop.dart';
import 'package:catmovie/app/components/command_palette.dart' as cmd_palette;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:catmovie/app/modules/home/views/mirrortable.dart';
import 'package:catmovie/app/shared/bus.dart';
import 'package:catmovie/app/shared/mirror_category.dart';
import 'package:catmovie/app/shared/mirror_status_stack.dart';
import 'package:catmovie/isar/repo.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:catmovie/app/extension.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xi/xi.dart';

const kSmoothListViewDuration = Duration(milliseconds: 210);

/// 历史记录处理类型
enum UpdateSearchHistoryType {
  /// 添加
  add,

  /// 删除
  remove,

  /// 清除所有
  clean
}

/// 标签页切换方向
enum TabSwitchDirection {
  /// 向左切换
  left,

  /// 向右切换
  right,
}

Widget kActivityIndicator = NutsActivityIndicator(
  tickCount: 9,
  radius: 12,
  relativeWidth: 1.24,
  inactiveColor: Colors.white.withValues(alpha: 0.42),
  activeColor: Colors.white,
);

Function showLoading(String msg) {
  EasyLoading.show(
    // status: msg,
    // indicator: Image.asset(
    //   "assets/loading.gif",
    //   width: 120,
    //   height: 120,
    // ),
    indicator: kActivityIndicator,
  );
  return EasyLoading.dismiss;
}

Future<bool> showLoadingPlaceholderTask(AsyncCallback task) async {
  var errMsg = "";
  try {
    Get.dialog(
      Center(
        // child: Image.asset(
        //   "assets/loading.gif",
        //   width: 120,
        //   height: 120,
        // ),
        child: kActivityIndicator,
      ),
    );
    await task();
  } catch (e) {
    errMsg = e.toString();
  } finally {
    Get.back();
  }
  if (errMsg.isNotEmpty) {
    EasyLoading.showError(errMsg);
    return false;
  }
  return true;
}

class HomeController extends GetxController
    with WidgetsBindingObserver, ProtocolListener {
  final FocusScopeNode focusNode = FocusScopeNode();
  final FocusNode homeFocusNode = FocusNode();

  late Size windowLastSize;

  bool showBottomNavigationBar = true;

  void setBottomNavigationBar(bool newVal) {
    showBottomNavigationBar = newVal;
    update();
  }

  var currentBarIndex = 0;

  var currentBarController = PageController(initialPage: 0, keepPage: true);

  int _currentParseVipIndex = 0;
  List<ParseIsarModel> _parseVipList = [];
  int get currentParseVipIndex => _currentParseVipIndex;
  List<ParseIsarModel> get parseVipList => _parseVipList;
  ParseIsarModel? get currentParseVipModelData {
    if (parseVipList.isEmpty || currentParseVipIndex >= parseVipList.length) {
      return null;
    }
    return parseVipList[currentParseVipIndex];
  }

  final cacheCategory = CacheWithCategory();

  String get currentMirrorItemId {
    if (mirrorListIsEmpty) return "";
    return currentMirrorItem.meta.id;
  }

  List<SourceSpiderQueryCategory> get currentCategoryer {
    var data = cacheCategory.data(currentMirrorItemId);
    return data;
  }

  bool get currentHasCategoryer {
    return cacheCategory.has(currentMirrorItemId);
  }

  SourceSpiderQueryCategory? currentCategoryerNow;

  void setCurrentCategoryerNow(SourceSpiderQueryCategory category) {
    currentCategoryerNow = category;
    cacheCategory.setLastUsed(currentMirrorItem.meta.id, category);
    updateHomeData(isFirst: true);
    update();
  }

  bool _isNsfw = false;

  bool get isNsfw {
    return _isNsfw;
  }

  set isNsfw(bool newVal) {
    _isNsfw = newVal;
    _mirrorIndex = 0;
    update();
    updateSetting(SettingsAllKey.isNsfw, newVal);
  }

  int get mirrorIndex {
    if (_cacheMirrorIndex == -1) {
      try {
        // 这里在清除缓存时会抛出索引异常, 主要是取 settingsSingleModel 取不到了
        return getSettingAsKeyIdent<int>(SettingsAllKey.mirrorIndex);
      } catch (e) {
        // workaround: 因为有内置源的存在, 所以这里设置为 0 是不会出错的
        return 0;
      }
    }
    return _cacheMirrorIndex;
  }

  set mirrorIndex(int newVal) {
    updateSetting(SettingsAllKey.mirrorIndex, newVal);
  }

  set _mirrorIndex(int newVal) {
    if (newVal >= mirrorList.length) {
      // 如果新设置的索引大于 mirrorList 的长度的话, 则默认设置为 0
      newVal = 0;
    }
    mirrorIndex = newVal;
    _cacheMirrorIndex = newVal;
    currentCategoryerNow = null;
    update();
    updateHomeData(
      isFirst: true,
    );
  }

  /// 清理缓存
  /// => 重启之后部分设置才会生效
  void easyCleanCacheHook() {
    _isNsfw = false;
    _cacheMirrorIndex = -1;
    cacheCategory.clean();
    cacheCategory.cleanupLastUsed();
    if (_parseVipList.isNotEmpty) {
      _parseVipList = [];
      update();
    }
  }

  /// -1 = 未初始化
  /// >= 0 = 初始化好的值
  int _cacheMirrorIndex = -1;

  /// 删除单个源之后需要手动的设置 [mirrorIndex]
  ///
  /// 如果是在源之前的, 则 [index] = [mirrorIndex] - 1
  ///
  /// 如果是在源之后, 则 [index] = [mirrorIndex]
  void removeMirrorItemSync(ISpiderAdapter item) {
    var index = mirrorList.indexOf(item);
    if (index == -1) return;
    var oldIndex = mirrorIndex;
    var afterIndex = oldIndex;
    if (index < oldIndex) {
      afterIndex = oldIndex - 1;
    }
    mirrorIndex = afterIndex;
    _cacheMirrorIndex = afterIndex;
    update();
  }

  void updateMirrorIndex(int index) {
    _mirrorIndex = index;
  }

  ISpiderAdapter get currentMirrorItem {
    if (mirrorIndex <= mirrorList.length - 1) {
      // 也有可能是 -1 吗?
      if (mirrorIndex == -1) return EmptySpiderAdapter();
      return mirrorList[mirrorIndex];
    }
    return EmptySpiderAdapter();
  }

  bool get mirrorListIsEmpty {
    return mirrorList.isEmpty;
  }

  List<ISpiderAdapter> get mirrorList {
    if (isNsfw) {
      return SpiderManage.data.where((e) => e.isNsfw).toList();
    }
    return SpiderManage.data.where((e) => !e.isNsfw).toList();
  }

  int page = 1;
  int limit = 10;

  List<VideoDetail> homedata = [];

  bool isLoading = true;

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  void showMirrorModel(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: Get.height * .88,
        width: double.infinity,
        child: const MirrorTableView(),
      ),
    );
  }

  void refreshOnLoading() async {
    boop.selection();
    try {
      page++;
      update();
      await updateHomeData();
      refreshController.loadComplete();
      boop.success();
    } catch (e) {
      refreshController.loadFailed();
      boop.error();
    }
  }

  void refreshOnRefresh() async {
    boop.selection();
    try {
      await updateHomeData(isFirst: true, missIsLoading: true);
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
    }
  }

  double cacheMirrorTableScrollControllerOffset = 0;

  void updateCacheMirrorTableScrollControllerOffset(double newVal) {
    cacheMirrorTableScrollControllerOffset = newVal;
    update();
  }

  /// 初始化滚动条坐标值
  ///
  /// 判断条件
  ///
  /// ```js
  /// (屏幕高度 - kToolbarHeight) < (_offset * 69)
  /// // - 源数量必须 >= 10
  /// // - 当前正在使用的源 >= 10
  /// ```
  ///
  /// 高度计算
  ///
  /// ```
  /// // 每个卡片 69 * index
  /// ```
  void initCacheMirrorTableScrollControllerOffset() {
    double h = Get.height - kToolbarHeight;

    double offset = mirrorIndex * 69.0;

    bool screenCheckFlag = offset > h;

    // bool _lengthCheckFlag = mirrorList.length <= 9 || mirrorIndex <= 9;
    // if (_lengthCheckFlag) return;

    if (screenCheckFlag) {
      updateCacheMirrorTableScrollControllerOffset(offset);
    }
  }

  void initMovieParseVipList() {
    var data = parseAs.where(distinct: false).findAllSync();
    _parseVipList = data;
    update();
  }

  bool addMovieParseVip(dynamic model) {
    bool isOK = false;
    if (model is List<ParseIsarModel>) {
      _parseVipList.addAll(model);
      _currentParseVipIndex = 0;
      isOK = true;
    } else if (model is ParseIsarModel) {
      _parseVipList.insert(0, model);
      if (_parseVipList.length >= 2) {
        _currentParseVipIndex++;
      }
      isOK = true;
    } else if (model is List<String>) {
      var m = ParseIsarModel(model[0], model[1]);
      _parseVipList.insert(0, m);
      isOK = true;
    }
    if (isOK) {
      update();
      isarInstance.writeTxnSync(() {
        parseAs.putAllSync(_parseVipList);
      });
    }
    return isOK;
  }

  void removeMovieParseVipOnce(int index) {
    _parseVipList.removeAt(index);

    // TODO: 实现正确的索引而不是每次都重置
    _currentParseVipIndex = 0;

    update();

    parseAs.clearSync();
    parseAs.putAllSync(_parseVipList);
  }

  void setDefaultMovieParseVipIndex(int index) {
    if (_parseVipList.length <= index) return;
    _currentParseVipIndex = index;
    update();
  }

  void initHapticFeedback() {
    var __hapticFeedback = getSettingAsKeyIdent<bool>(
      SettingsAllKey.hapticFeedback,
      defaultValue: true,
    );
    boop.enabled = __hapticFeedback;
  }

  @override
  void onInit() {
    protocolHandler.addListener(this);
    updateWindowLastSize();
    WidgetsBinding.instance.addObserver(this);
    cacheCategory.init();
    updateNsfwSetting();
    updateHomeData(isFirst: true);
    initCacheMirrorTableScrollControllerOffset();
    initMovieParseVipList();
    initHapticFeedback();
    super.onInit();
  }

  void updateWindowLastSize() {
    windowLastSize = View.of(Get.context!).physicalSize;
    update();
  }

  String indexHomeLoadDataErrorMessage = "";

  void updateNsfwSetting() {
    _isNsfw = getSettingAsKeyIdent<bool>(SettingsAllKey.isNsfw);
    update();
  }

  Future<SourceSpiderQueryCategory?> syncCurrentCategoryer() async {
    try {
      if (mirrorListIsEmpty) return null;
      var category = await currentMirrorItem.getCategory();

      // NOTE(d1y): 为空也是一种错误的表现
      if (category.isEmpty) {
        cacheCategory.fetchCountPP(currentMirrorItemId);
        return null;
      }
      cacheCategory.put(currentMirrorItemId, category);
      currentCategoryerNow = category.first;
      update();
      return category.first;
    } catch (e) {
      if (currentMirrorItemId.isNotEmpty) {
        cacheCategory.fetchCountPP(currentMirrorItemId);
      }
      debugPrint(e.toString());
      return null;
    }
  }

  /// [isFirst] 初始化加载数据需要将 [isLoading] => true
  /// [missIsLoading] 某些特殊情况下不需要设置 [isLoading] => true
  Future<void> updateHomeData(
      {bool isFirst = false, missIsLoading = false}) async {
    /// 如果都没有源, 则不需要加载数据
    /// => +_+ 还玩个球啊
    if (mirrorListIsEmpty) return;

    var onceCategory = "";
    if (currentCategoryerNow != null) {
      onceCategory = currentCategoryerNow!.id;
    }
    if (isFirst) {
      var dispose = showLoading("加载分类中");

      // NOTE(d1y): 不存在分类并且请求次数没有超过阈值
      var needFetch = !currentHasCategoryer &&
          !cacheCategory.fetchCountAlreadyMax(currentMirrorItemId);

      if (needFetch) {
        try {
          var category = (await syncCurrentCategoryer()) ?? kDefaultAllCategory;
          onceCategory = category.id;
        } catch (e) {
          debugPrint(e.toString());
        } finally {
          dispose();
        }
      } else {
        var lastUsed = cacheCategory.getLastUsed(currentMirrorItem.meta.id);
        if (lastUsed != null) {
          currentCategoryerNow = lastUsed;
          update();
        }
        if (currentCategoryerNow == null && currentCategoryer.isNotEmpty) {
          currentCategoryerNow = currentCategoryer.first;
          update();
        }
        onceCategory = currentCategoryerNow!.id;
      }
    }

    /// 如果 [indexHomeLoadDataErrorMessage] 错误栈有内容的话
    /// 并且 [isFirst] 不是初始化数据的话, 就不允许加载更多
    if (indexHomeLoadDataErrorMessage != "" && !isFirst) return;

    try {
      if (isFirst) {
        showLoading("加载内容中");
        isLoading = !missIsLoading;
        page = 1;
        update();
      }
      debugPrint("get home data: $page, $limit");
      List<VideoDetail> data = await currentMirrorItem.getHome(
        page: page,
        limit: limit,
        category: onceCategory,
      );
      if (isFirst) {
        homedata = data;
      } else {
        homedata.addAll(data);
      }
      indexHomeLoadDataErrorMessage = "";
      update();
    } catch (e) {
      indexHomeLoadDataErrorMessage = e.toString();
      homedata = [];
      update();
    } finally {
      isLoading = false;
      EasyLoading.dismiss();
    }

    String id = currentMirrorItem.meta.id;
    bool notError = indexHomeLoadDataErrorMessage == "";

    // NOTE: 只会在 [isFirst] 后存入持久化缓存
    MirrorStatusStack().pushStatus(
      id,
      notError,
      canSave: isFirst,
    );
  }

  @override
  void onReady() {
    refreshController = RefreshController();
    super.onReady();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    protocolHandler.removeListener(this);
  }

  @override
  void didChangeMetrics() {
    updateWindowLastSize();
  }

  void switchTabview(TabSwitchDirection direction) {
    if (currentBarIndex == 0 && direction == TabSwitchDirection.left) return;
    if (currentBarIndex == 2 && direction == TabSwitchDirection.right) return;
    if (direction == TabSwitchDirection.left) {
      currentBarIndex--;
    } else {
      currentBarIndex++;
    }
    currentBarController.jumpToPage(currentBarIndex);
    update();
  }

  void changeCurrentBarIndex(int i) {
    if (currentBarIndex == i) return;
    currentBarIndex = i;
    // ignore: dead_code
    if (GetPlatform.isDesktop && false) {
      // 这个动画好悬没给我眼睛看花了
      int absVal = currentBarIndex - i;
      var val = absVal.abs();
      if (val >= 2) {
        currentBarController.jumpToPage(i);
      } else {
        currentBarController.animateToPage(
          i,
          curve: Curves.ease,
          duration: const Duration(milliseconds: 120),
        );
      }
    } else {
      currentBarController.jumpToPage(i);
    }
    boop.selection();
    update();
  }

  void clearCache() async {
    SpiderManage.cleanAll();
    easyCleanCacheHook();
    IsarRepository().safeWrite(() {
      isarInstance.clearSync();
    });
  }

  bool _isProtocolUrlReceived = false;

  /// unstable method
  ///
  /// 嘛钱不钱的，乐呵乐呵得了。
  /// ![mmp](http://k.sinaimg.cn/n/translate/288/w662h426/20190916/a339-ietnfsp5148644.jpg/w700d1q75cms.jpg)
  Future<bool> confirmAlert(
    String content, {
    BuildContext? context,
    showCancel = true,
    title = "提示",
    cancelText = "取消",
    confirmText = "确认",
  }) async {
    late BuildContext cx;
    if (context != null) {
      cx = context;
    } else {
      // 怎么可能为空? 我觉得这是一种自信
      // https://steamcommunity.com/sharedfiles/filedetails/?id=2899834211
      cx = Get.context!;
    }
    var flag = await showCupertinoDialog<bool>(
      context: cx,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <CupertinoDialogAction>[
            if (showCancel)
              CupertinoDialogAction(
                child: Text(
                  cancelText,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
              child: Text(confirmText),
            )
          ],
        );
      },
    );
    if (flag == null || !flag) return false;
    return true;
  }

  @override
  onProtocolUrlReceived(String url) async {
    if (GetPlatform.isDesktop) {
      await windowManager.show();
      await windowManager.focus();
    }
    // https://github.com/waifu-project/movie/pull/50
    if (_isProtocolUrlReceived) return;
    _isProtocolUrlReceived = true;
    var cx = Uri.tryParse(url);
    if (cx == null) return;
    var authority = cx.authority;
    var qs = cx.queryParameters;
    var realURL = qs["url"] ?? "";
    if (realURL.isNotEmpty) {
      realURL = decodeURL(realURL);
    }
    switch (authority) {
      // yoyo://import?name=非凡资源&url=http://api.ffzyapi.com/api.php/provide/vod/at/xml&nsfw=false
      // yoyo://import?name=卧龙&url=https://collect.wolongzyw.com/api.php/provide/vod/at/json&nsfw=false
      case "import":
        String name = qs["name"] ?? "";
        late bool nsfw;
        var $qs = qs["nsfw"] ?? "false";
        if ($qs == "true") {
          nsfw = true;
        } else {
          nsfw = false;
        }
        var msg = "将添加视频源\n名称: $name\n源地址: $realURL\n类型: ${nsfw ? '18+' : '-'}";
        var flag = await confirmAlert(msg);
        if (!flag) break;
        var $id = Xid().toString();
        var meta = SourceMeta(
          id: $id,
          name: name,
          type: SourceType.maccms,
          api: realURL,
          desc: nsfw ? '18+' : '',
          isNsfw: nsfw,
        );
        var cms = MacCMSSpider(meta);
        if (!SpiderManage.addItem(cms)) {
          await confirmAlert(
            "源已经存在了, 无法添加",
            showCancel: false,
            confirmText: "我知道了",
          );
          break;
        }
        await confirmAlert(
          "视频源添加成功",
          showCancel: false,
          confirmText: "我知道了",
        );

        /// [SpiderManage.data] 中的顺序是 <扩展 + 内建>
        /// 所以当添加了源之后, 如果只有一个源的话(即当前添加的), 需要手动刷新一下
        if (SpiderManage.extend.length == 1) {
          updateHomeData(isFirst: true);
        }
        break;
      // yoyo://reset
      case "reset":
        var flag = await confirmAlert("重置后将清空缓存, 包括视频源和一些设置");
        if (!flag) break;
        clearCache();
        await confirmAlert(
          "已删除缓存, 部分内容重启之后生效!",
          showCancel: false,
          confirmText: "我知道了",
        );
        if (SpiderManage.extend.isEmpty) {
          updateHomeData(isFirst: true);
        }
        break;
      // yoyo://sub?url=https://cdn.jsdelivr.net/gh/waifu-project/v1@latest/yoyo.json
      // yoyo://sub?url=https://raw.githubusercontent.com/hd9211/Tvbox1/main/zy.json
      case "sub":
        if (realURL.isEmpty || Uri.tryParse(realURL) == null) {
          break; // TODO: need show error toast
        }
        var flag = await confirmAlert("将添加订阅源: $realURL");
        if (!flag) break;
        List<String> text =
            getSettingAsKeyIdent(SettingsAllKey.mirrorTextarea).split("\n");
        if (text.contains(realURL)) {
          await confirmAlert(
            "该订阅源已存在!",
            showCancel: false,
            confirmText: "我知道",
          );
          break;
        }
        text.add(realURL);
        var newText = text.join("\n");
        updateSetting(SettingsAllKey.mirrorTextarea, newText);
        await confirmAlert(
          "已添加订阅源, 添加之后请在 设置->视频源 更新配置",
          showCancel: false,
          confirmText: "我知道了",
        );
        break;
      // yoyo://jiexi?name=云解析&url=https://yparse.ik9.cc/index.php?url=
      case "jiexi":
        var name = qs['name'] ?? "";
        if (realURL.isEmpty || Uri.tryParse(realURL) == null || name.isEmpty) {
          break;
        }
        var flag = await confirmAlert("将添加解析源: $realURL");
        if (!flag) break;
        List<String> model = [name, realURL];
        // 默认添加到 0 位置, 但还是需要手动设置默认才行!
        if (!addMovieParseVip(model)) {
          // 理论上不可能哈
        }
        await confirmAlert(
          "已添加解析源, 要启用请在 设置->解析源管理中 更新配置",
          showCancel: false,
          confirmText: "我知道了",
        );
        break;
      // yoyo://nsfw?enable=1
      case "nsfw":
        int nsfw = int.tryParse(qs["enable"] ?? "") ?? 0;
        var enable = nsfw == 1;
        var flag = await confirmAlert("将${enable ? '开启' : '关闭'}nsfw设置");
        if (!flag) break;
        isNsfw = enable;
        $bus.fire(SettingEvent(nsfw: enable));
        break;
      // case "search":
      default:
        confirmAlert(
          "未知协议: $authority",
          showCancel: false,
          confirmText: "我知道了",
        );
    }
    _isProtocolUrlReceived = false;
  }

  /// 显示命令面板
  void showCommandPalette(BuildContext context) {
    final items = <cmd_palette.CommandPaletteItem>[
      // 导航相关
      cmd_palette.CommandPaletteItem(
        id: 'nav_home',
        label: '返回首页',
        subtitle: '导航到首页',
        icon: CupertinoIcons.home,
        keywords: ['home', '首页', '导航'],
        onTap: () {
          changeCurrentBarIndex(0);
        },
      ),
      cmd_palette.CommandPaletteItem(
        id: 'nav_tv',
        label: '电视直播',
        subtitle: '导航到电视直播页面',
        icon: CupertinoIcons.tv,
        keywords: ['tv', '电视', '直播'],
        onTap: () {
          changeCurrentBarIndex(1);
        },
      ),
      cmd_palette.CommandPaletteItem(
        id: 'nav_settings',
        label: '设置',
        subtitle: '导航到设置页面',
        icon: CupertinoIcons.settings,
        keywords: ['settings', '设置', '配置'],
        onTap: () {
          changeCurrentBarIndex(2);
        },
      ),
      
      // 功能相关
      cmd_palette.CommandPaletteItem(
        id: 'toggle_nsfw',
        label: isNsfw ? '关闭成人模式' : '开启成人模式',
        subtitle: '切换成人内容显示',
        icon: isNsfw ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
        keywords: ['nsfw', '成人', '绅士'],
        onTap: () {
          isNsfw = !isNsfw;
          $bus.fire(SettingEvent(nsfw: isNsfw));
        },
      ),
      
      cmd_palette.CommandPaletteItem(
        id: 'refresh_home',
        label: '刷新首页',
        subtitle: '重新加载首页数据',
        icon: CupertinoIcons.refresh,
        keywords: ['refresh', '刷新', '重载'],
        onTap: () {
          refreshOnRefresh();
        },
      ),
      
      cmd_palette.CommandPaletteItem(
        id: 'show_mirror_table',
        label: '视频源管理',
        subtitle: '打开视频源管理表格',
        icon: CupertinoIcons.list_bullet,
        keywords: ['mirror', '视频源', '管理'],
        onTap: () {
          showMirrorModel(Get.context!);
        },
      ),
    ];
    
    cmd_palette.showCommandPalette(
      context: context,
      items: items,
      hintText: '输入命令或搜索...',
    );
  }
}

```

###### 📂 lib/app\modules\home\views

#### 📄 `lib/app\modules\home\views\auto_update.dart`

```dart
import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:xi/xi.dart';

const kUpdateUpstream =
    "https://api.github.com/repos/waifu-project/movie/releases";

/// 豆包
/// 将HTML中的img标签转换为Markdown图片格式
/// [input] 包含img标签的原始字符串
/// [defaultAlt] 当img标签没有alt属性时使用的默认文本
String convertImgTagsToMarkdown(String input, {String defaultAlt = '图片'}) {
  // 使用原始字符串处理各种引号情况，避免转义问题
  // 处理alt在src后面的情况
  final regexSrcFirst = RegExp(r'''<img[^>]*src=("|')([^"']*)\1[^>]*alt=("|')([^"']*)\3[^>]*>''',
      caseSensitive: false);
  
  // 处理alt在src前面的情况
  final regexAltFirst = RegExp(r'''<img[^>]*alt=("|')([^"']*)\1[^>]*src=("|')([^"']*)\3[^>]*>''',
      caseSensitive: false);

  // 处理没有alt属性的情况
  final regexNoAlt = RegExp(r'''<img[^>]*src=("|')([^"']*)\1[^>]*>''',
      caseSensitive: false);

  // 分步替换，确保所有情况都能被处理
  String result = input
      .replaceAllMapped(regexSrcFirst, (match) {
        String imageUrl = match.group(2) ?? '';
        String altText = match.group(4) ?? defaultAlt;
        return '![$altText]($imageUrl)';
      })
      .replaceAllMapped(regexAltFirst, (match) {
        String altText = match.group(2) ?? defaultAlt;
        String imageUrl = match.group(4) ?? '';
        return '![$altText]($imageUrl)';
      })
      .replaceAllMapped(regexNoAlt, (match) {
        String imageUrl = match.group(2) ?? '';
        return '![$defaultAlt]($imageUrl)';
      });
  
  return result;
}


class AutoUpdate extends StatefulWidget {
  const AutoUpdate({super.key});

  @override
  State<AutoUpdate> createState() => _AutoUpdateState();
}

class _AutoUpdateState extends State<AutoUpdate> with AfterLayoutMixin {
  GithubTag? tag;

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    var resp = await XHttp.dio.get<List<dynamic>>(
      kUpdateUpstream,
      options: $noCacheOption(),
    );
    var tags = (resp.data ?? []).map((item) {
      return GithubTag.fromJson(item as Map<String, dynamic>);
    }).toList();
    tag = tags[0];
    tag!.body = convertImgTagsToMarkdown(tag!.body);
    setState(() {});
  }

  Widget _buildChangelog() {
    if (tag == null) {
      return Expanded(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                child: MarkdownWidget(data: tag!.body),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.mediaQuery.size.height * .72,
      child: Column(
        children: [
          _buildChangelog(),
          Zoom(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ).copyWith(
                bottom: context.mediaQuery.padding.bottom + 24,
              ),
              child: CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.medium,
                onPressed: () {
                  if (tag == null) return;
                  String url =
                      "https://github.com/waifu-project/movie/releases/latest/download/";
                  if (GetPlatform.isAndroid) {
                    url += "catmovie.apk";
                  } else if (GetPlatform.isIOS) {
                    url += "catmovie.ipa";
                  } else if (GetPlatform.isMacOS) {
                    url += "catmovie-mac.zip";
                  } else if (GetPlatform.isWindows) {
                    url += "catmovie-windows.zip";
                  } else if (GetPlatform.isLinux) {
                    url += "catmovie-linux-x86_64.tar.gz";
                  }
                  url.openURL();
                },
                onLongPress: () {
                  if (GetPlatform.isIOS) {
                    var url =
                        "apple-magnifier://install?url=https://github.com/waifu-project/movie/releases/latest/download/catmovie.ipa";
                    url.openURL();
                  }
                },
                child: Text("下载"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GithubTag {
  String tag_name;
  String body;

  GithubTag({
    required this.tag_name,
    required this.body,
  });

  factory GithubTag.fromJson(Map<String, dynamic> json) => GithubTag(
        tag_name: json["tag_name"],
        body: json["body"],
      );
}

```

#### 📄 `lib/app\modules\home\views\cupertino_license.dart`

```dart
import 'package:aurora/aurora.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/modules/home/views/settings_view.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/widget/flutter_custom_license_page.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:tuple/tuple.dart';

const kGithubRepo = "https://github.com/waifu-project/movie";

// 开发者们
var kDevelopers = <Tuple2<String, String>>[
  Tuple2("d1y", "https://avatars.githubusercontent.com/u/45585937?v=4"),
  Tuple2("左福龙", "https://s2.loli.net/2025/09/13/WgfESD8aziGscRI.jpg"),
];

void _showInfo(
  String currentPackage,
  List<LicenseEntry> packageLicenses,
  BuildContext context,
) {
  Navigator.of(context).push(
    CupertinoPageRoute(builder: (context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoEasyAppBar(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CupertinoNavigationBarBackButton(),
                  Expanded(
                    child: Text(
                      currentPackage,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Text(''),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
        child: Material(
          child: SmoothListView.builder(
            duration: kSmoothListViewDuration,
            itemCount: packageLicenses.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  packageLicenses[index]
                      .paragraphs
                      .map((paragraph) => paragraph.text)
                      .join("\n"),
                ),
              );
            },
          ),
        ),
      );
    }),
  );
}

Widget _buildRealBody(LicenseData? licenseData, BuildContext context) {
  Widget _title(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, color: CupertinoColors.systemBlue),
    );
  }

  return Stack(
    children: [
      Positioned.fill(
        child: ClipRRect(
          child: Aurora(
            size: 88,
            colors: [
              Color(0xffc2e59c).withValues(alpha: .24),
              Color(0xff64b3f4).withValues(alpha: .24),
            ],
            blur: 66,
          ),
        ),
      ),
      Positioned.fill(
        child: Padding(
          padding: const EdgeInsets.all(18).copyWith(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              // Text("该项目仅可用于学习交流, 请勿用于商业用途, 如有侵权请联系开发者进行删除"),
              _title("开发者"),
              Row(
                spacing: 18,
                children: kDevelopers.map((item) {
                  return Zoom(
                    onTap: () {
                      if (item.item1 == "d1y") {
                        "https://github.com/d1y".openURL();
                      }
                    },
                    child: Column(
                      spacing: 6,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(42),
                          child: CachedNetworkImage(
                            imageUrl: item.item2,
                            width: 42,
                            height: 42,
                          ),
                        ),
                        Text(item.item1),
                      ],
                    ),
                  );
                }).toList(),
              ),
              _title("开源地址"),
              Zoom(
                onTap: kGithubRepo.openURL,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: .12),
                    ),
                  ),
                  width: double.infinity,
                  height: 88,
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Aurora(
                            size: 88,
                            colors: [
                              Color(0xffc2e59c).withValues(alpha: .88),
                              Color(0xff64b3f4).withValues(alpha: .88),
                            ],
                            blur: 120,
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            spacing: 12,
                            children: [
                              SvgPicture.string(
                                kGithubIconSvg,
                                width: 80,
                              ),
                              Column(
                                spacing: 6,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("waifu-project/movie",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text(
                                    "仅供学习参考, 请勿用于商业用途",
                                    maxLines: 2,
                                    style: TextStyle(
                                        color:
                                            Colors.blue.withValues(alpha: .72),
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _title("以下是使用到的开源项目"),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    children: licenseData!.packages
                        .where((item) {
                          return !item.startsWith("_");
                        })
                        .toList()
                        .map(
                          (currentPackage) => CupertinoButton(
                            sizeStyle: CupertinoButtonSize.small,
                            child: Text(currentPackage),
                            onPressed: () {
                              List<LicenseEntry> packageLicenses = licenseData
                                  .packageLicenseBindings[currentPackage]!
                                  .map((binding) =>
                                      licenseData.licenses[binding])
                                  .toList();
                              _showInfo(
                                  currentPackage, packageLicenses, context);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

CustomLicensePage cupertinoLicensePage = CustomLicensePage((
  context,
  licenseData,
) {
  return CupertinoPageScaffold(child: body(licenseData, context));
});

Widget body(
  AsyncSnapshot<LicenseData> licenseDataFuture,
  BuildContext context,
) {
  switch (licenseDataFuture.connectionState) {
    case ConnectionState.done:
      LicenseData? licenseData = licenseDataFuture.data;
      return _buildRealBody(licenseData, context);
    default:
      return const Center(
        child: CupertinoActivityIndicator(),
      );
  }
}

```

#### 📄 `lib/app\modules\home\views\history.dart`

```dart
import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/modules/play/views/play_view.dart';
import 'package:catmovie/app/routes/app_pages.dart';
import 'package:catmovie/app/widget/helper.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/isar/schema/video_history_schema.dart';
import 'package:catmovie/utils/boop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:tuple/tuple.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with AfterLayoutMixin {
  HomeController home = Get.find<HomeController>();

  List<VideoHistoryIsarModel> history = [];

  bool isEditing = false;

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    history = videoHistoryAs.filter().isNsfwEqualTo(home.isNsfw).findAllSync();
    setState(() {});
  }

  void handleDeleteHistoryByItem(VideoHistoryIsarModel item) {
    isarInstance.writeTxnSync(() {
      videoHistoryAs.deleteSync(item.id);
    });
    history.remove(item);
    EasyLoading.showToast(
      "删除成功(${item.ctx.title})",
      toastPosition: EasyLoadingToastPosition.bottom,
    );
    if (history.isEmpty) {
      isEditing = false;
    }
    boop.success();
    setState(() {});
  }

  Future<void> handleDeleteAll() async {
    boop.warning();
    bool isNext = await showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: const Text("确定要删除所有历史记录吗?"),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              '取消',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.blue),
            ),
          )
        ],
      ),
      context: context,
    );
    if (!isNext) return;
    isarInstance.writeTxnSync(() {
      videoHistoryAs.filter().isNsfwEqualTo(home.isNsfw).deleteAllSync();
    });
    history = [];
    isEditing = false;
    setState(() {});
  }

  Widget _buildWithEmptry() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          spacing: 24,
          children: [
            Image.asset(
              "assets/images/error.png",
              width: 120,
              height: 120,
            ),
            Text(
              "当前暂无历史记录",
              style: TextStyle(
                color: (context.isDarkMode ? '#6f737a' : '#767a82').$color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var textColor = context.isDarkMode ? Colors.white : Colors.black;
    return Scaffold(
      appBar: CupertinoEasyAppBar(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Text(
                  "历史记录",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ),
            Zoom(child: CupertinoNavigationBarBackButton()),
            if (history.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Zoom(
                  child: IconButton(
                    onPressed: () {
                      isEditing = !isEditing;
                      setState(() {});
                      boop.selection();
                    },
                    icon: Row(
                      spacing: 6,
                      children: [
                        if (!isEditing) ...[
                          Icon(CupertinoIcons.square_pencil, size: 20),
                          Text("管理", style: TextStyle(color: textColor)),
                        ] else ...[
                          Icon(CupertinoIcons.text_append, size: 20),
                          Text("完成", style: TextStyle(color: textColor)),
                        ],
                        SizedBox(width: 6),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Builder(builder: (context) {
                if (history.isEmpty) {
                  return _buildWithEmptry();
                }
                return SingleChildScrollView(
                  child: Column(
                    spacing: 24,
                    children: history.map((item) {
                      return SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Zoom(
                                onTap: () async {
                                  var cx = home.mirrorList
                                      .firstWhereOrNull((mirror) {
                                    return mirror.meta.id == item.sid;
                                  });
                                  if (cx == null) {
                                    EasyLoading.showError("未找到源");
                                    return;
                                  }
                                  showLoadingPlaceholderTask(() async {
                                    var data =
                                        await cx.getDetail(item.ctx.detailID);
                                    data.setContext(cx.meta);
                                    try {
                                      Tuple2<PlayState, String> ps =
                                          await Get.toNamed(
                                        Routes.PLAY,
                                        arguments: data,
                                      );
                                      item.ctx.pText = ps.item2;
                                      if (mounted) setState(() {});
                                    } catch (e) {
                                      debugPrint(e.toString());
                                    }
                                  });
                                },
                                scaleRatio: .98,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 12,
                                  children: [
                                    Builder(builder: (context) {
                                      var img = item.ctx.cover;
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: img,
                                          width: 120,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey[200],
                                          ),
                                          errorWidget: (context, url, error) =>
                                              kErrorImage,
                                        ),
                                      );
                                    }),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 6,
                                        children: [
                                          Text(
                                            item.ctx.title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: 18, color: textColor),
                                          ),
                                          // 无语死了, 一开始使用 RichText 实现
                                          // 只不过发现 RichText 下的 TextSpan 下划线会有问题
                                          // 都这么久了还没修复, 拉胯的一批
                                          // https://github.com/flutter/flutter/issues/42833#issuecomment-1605590098
                                          Opacity(
                                            opacity: .72,
                                            child: DefaultTextStyle(
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: context.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black),
                                              child: Row(
                                                spacing: 6,
                                                children: [
                                                  Text("上次看到"),
                                                  DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          width: .66,
                                                          color: context
                                                                  .isDarkMode
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(item.ctx.pText),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xFF6750A4)),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 3, horizontal: 6),
                                            child: Text(
                                              item.sourceName,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: textColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isEditing)
                              IconButton(
                                onPressed: () =>
                                    handleDeleteHistoryByItem(item),
                                icon: Icon(CupertinoIcons.delete),
                              )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ),
          AnimatedPositioned(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 240),
            left: 0,
            bottom: isEditing ? 24 : -88,
            width: context.mediaQuery.size.width,
            child: Center(
              child: CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.medium,
                mouseCursor: SystemMouseCursors.click,
                padding: EdgeInsets.symmetric(horizontal: 42),
                onPressed: handleDeleteAll,
                child: Text("一键清空"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

```

#### 📄 `lib/app\modules\home\views\home_view.dart`

```dart
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
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
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

  List<ISpiderAdapter> get mirror => controller.mirrorList;

  int get mirrorIndex => controller.mirrorIndex;

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDarkMode;
    Color color = isDark
        ? const Color.fromRGBO(0, 0, 0, .63)
        : const Color.fromRGBO(255, 255, 255, .63);
    return GetBuilder<HomeController>(
      builder: (homeview) {
        return Shortcuts(
          shortcuts: {
            // Ctrl+K 或 Cmd+K 打开命令面板
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
                    Color(0xFFff0f7b), Color(0xFFf89b29),
                    // Color(0xFF595cff), Color(0xFFc6f8ff),
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
                    // Color(0xFFff0f7b), Color(0xFFf89b29),
                    Color(0xFF595cff), Color(0xFFc6f8ff),
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
                    // fix ios keyboard auto up
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
                      : color,
                  padding: EdgeInsets.zero,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: kDefaultAppBottomBarHeight,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 360,
                              ),
                              child: SalomonBottomBar(
                                itemPadding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                  horizontal: 18,
                                ),
                                currentIndex: homeview.currentBarIndex,
                                onTap: (int i) {
                                  homeview.changeCurrentBarIndex(i);
                                },
                                items: _tabs
                                    .map(
                                      (e) => SalomonBottomBarItem(
                                        icon: Zoom(child: Icon(e['icon'])),
                                        title: Text(e['title']),
                                        selectedColor: e['color'],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
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

```

#### 📄 `lib/app\modules\home\views\index_home_view.dart`

```dart
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

double kHomeMovieCardSpacing = 9;

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

  Future<void> handleClickItem(VideoDetail subItem, HomeController cx) async {
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
  }

  double get _calcImageWidth {
    var width = controller.windowLastSize.width;
    // 桌面平台
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
    // if (getSettingAsKeyIdent<bool>(SettingsAllKey.onBoardingShowed)) return;
    // showCupertinoModalBottomSheet(
    //   context: context,
    //   topRadius: Radius.circular(24),
    //   builder: (_) => OnBoarding(
    //     onNext: () {
    //       updateSetting(SettingsAllKey.onBoardingShowed, true);
    //       controller.updateHomeData(isFirst: true);
    //     },
    //   ),
    // );
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
            duration: Duration(milliseconds: 120),
            curve: Curves.bounceIn,
          );
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: WindowAppBar(
            iosBackStyle: true,
            title: Zoom(
              onTap: () {
                EasyLoading.dismiss();
                homeview.showMirrorModel(context);
                boop.selection();
              },
              child: Builder(builder: (context) {
                // var logo = homeview.currentMirrorItem.meta.logo;
                // if (logo.isNotEmpty) {
                //   return CachedNetworkImage(imageUrl: logo, width: 120,);
                // }
                return Row(
                  spacing: 6,
                  children: [
                    // Icon(
                    //   CupertinoIcons.arrowtriangle_right_square_fill,
                    //   color: context.isDarkMode ? Colors.white : Colors.black,
                    //   size: 28,
                    // ),
                    // https://www.iconfont.cn/user/detail?spm=a313x.search_index.0.d214f71f6.7fd43a81jlqJoE&uid=149438&nid=WJvLCUeSEEyE
                    SvgPicture.string(
                      r"""
      <svg t="1757795810585" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="8443" width="200" height="200"><path d="M909.31 307.42c-32.09-36.66-77.05-62.04-128.53-68.91-6.36-0.85-12.73-1.67-19.1-2.45l68.58-98.85c12.86-18.58 8.27-44.07-10.31-56.93-18.6-12.94-44.07-8.27-56.93 10.27L668.57 226.7h-0.01c-52.57-4.07-105.26-6.11-157.95-6.11s-105.37 2.04-157.94 6.11h-0.01L258.21 90.54c-12.9-18.54-38.43-23.21-56.93-10.27-18.58 12.86-23.17 38.35-10.31 56.93l68.59 98.85c-6.37 0.78-12.74 1.6-19.1 2.45C137.51 252.24 60.62 340.06 60.62 443.92v288.06c0 51.93 19.22 99.85 51.31 136.5 32.09 36.66 77.05 62.04 128.53 68.91a2043.998 2043.998 0 0 0 540.32 0c102.95-13.73 179.84-101.55 179.84-205.41V443.92c0-51.93-19.22-99.85-51.31-136.5z m-267.5 315.96l-148.1 115.6c-29.51 23.04-72.61 2.01-72.61-35.43v-231.2c0-37.44 43.1-58.47 72.61-35.43l148.1 115.59c23.06 18 23.06 52.88 0 70.87z" p-id="8444"></path></svg>
      """,
                      width: 30,
                      colorFilter: ColorFilter.mode(
                        context.isDarkMode ? Colors.white : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      currentTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        color: context.isDarkMode ? Colors.white : Colors.black,
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
                  child: Icon(
                    CupertinoIcons.search,
                    size: 24,
                    color: context.isDarkMode ? Colors.white : Colors.black,
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
              Zoom(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.clock,
                    size: 24,
                    color: context.isDarkMode ? Colors.white : Colors.black,
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
              // ctrl-p
              const SingleActivator(LogicalKeyboardKey.keyP, control: true):
                  ScrollUpIntent(),
              // ctrl-n
              const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                  ScrollDownIntent(),
              // ctrl-k
              const SingleActivator(LogicalKeyboardKey.keyK, control: true):
                  ScrollUpIntent(),
              // ctrl-j
              const SingleActivator(LogicalKeyboardKey.keyJ, control: true):
                  ScrollDownIntent(),
              // cmd-[
              const SingleActivator(LogicalKeyboardKey.bracketLeft, meta: true):
                  CategoryPrevIntent(),
              // cmd-]
              const SingleActivator(LogicalKeyboardKey.bracketRight,
                  meta: true): CategoryNextIntent(),
              // cmd-t
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
                        height: !categoryIsEmpty ? 42 : 0,
                        duration: const Duration(
                          milliseconds: 420,
                        ),
                        curve: Curves.decelerate,
                        child: SmoothListView.builder(
                          duration: kSmoothListViewDuration,
                          itemCount: controller.currentCategoryer.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: ((context, index) {
                            SourceSpiderQueryCategory curr =
                                controller.currentCategoryer[index];
                            bool isCurr =
                                curr == controller.currentCategoryerNow;
                            return Zoom(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.2,
                                  vertical: 6.2,
                                ),
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  color: isCurr
                                      ? (context.isDarkMode
                                              ? "#f1f1f1"
                                              : "#0f0f0f")
                                          .$color
                                      : (context.isDarkMode
                                              ? '#272727'
                                              : "#e2e8f0")
                                          .$color,
                                  child: Text(
                                    curr.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isCurr
                                          ? (context.isDarkMode
                                              ? Colors.black
                                              : Colors.white)
                                          : Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .color,
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
                      SizedBox(height: 6),
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
                              header: const WaterDropHeader(
                                refresh: Row(
                                  spacing: 12,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CupertinoActivityIndicator(),
                                    Text("加载中"),
                                  ],
                                ),
                                complete: Row(
                                  spacing: 12,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.smiley),
                                    Text("加载完成"),
                                  ],
                                ),
                              ),
                              footer: CustomFooter(
                                builder:
                                    (BuildContext context, LoadStatus? mode) {
                                  Widget body;
                                  if (mode == LoadStatus.idle) {
                                    body = const Text("上划加载更多");
                                  } else if (mode == LoadStatus.loading) {
                                    body = const CupertinoActivityIndicator();
                                  } else if (mode == LoadStatus.failed) {
                                    body = const Text("加载失败, 请重试");
                                  } else if (mode == LoadStatus.canLoading) {
                                    body = const Text("释放以加载更多");
                                  } else {
                                    body = const Text("没有更多数据");
                                  }
                                  return Center(child: body);
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
                                    return const SizedBox.shrink();
                                  }
                                  if (homeview.homedata.isEmpty) {
                                    if (errorMsg.isNotEmpty) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: Column(
                                          children: [
                                            SizedBox(height: 42),
                                            Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                spacing: 12,
                                                children: [
                                                  Image.asset(
                                                    "assets/images/error.png",
                                                    width: 120,
                                                    height: 120,
                                                  ),
                                                  Zoom(
                                                    child:
                                                        CupertinoButton.filled(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 12.0,
                                                        horizontal: 24.0,
                                                      ),
                                                      onPressed: () {
                                                        boop.selection();
                                                        homeview.updateHomeData(
                                                            isFirst: true);
                                                      },
                                                      child: const Text(
                                                        "重新加载",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: 720,
                                              ),
                                              width: context
                                                      .mediaQuery.size.width *
                                                  .88,
                                              child: KErrorStack(msg: errorMsg),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return Column(
                                      spacing: 12,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 42),
                                        Image.asset(
                                          "assets/images/error.png",
                                          width: 120,
                                          height: 120,
                                        ),
                                        Text("当前请求列表为空",
                                            style: TextStyle(
                                              color: (context.isDarkMode
                                                      ? '#6f737a'
                                                      : '#767a82')
                                                  .$color,
                                            )),
                                        SizedBox(height: 88),
                                      ],
                                    );
                                  }
                                  return GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cardCount,
                                      crossAxisSpacing: kHomeMovieCardSpacing,
                                      mainAxisSpacing: kHomeMovieCardSpacing,
                                      childAspectRatio: 12 / 9,
                                    ),
                                    itemCount: homeview.homedata.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
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

```

#### 📄 `lib/app\modules\home\views\mirrortable.dart`

```dart
import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/utils/boop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/modules/home/views/mirror_check.dart';
import 'package:catmovie/app/shared/mirror_status_stack.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xi/xi.dart';

enum MenuActionType {
  /// 检测源
  check,

  /// 删除不可用源
  deleteUnavailable,

  /// 导出
  export,
}

class ItemModel {
  String title;
  IconData icon;
  MenuActionType action;

  ItemModel(
    this.title,
    this.icon,
    this.action,
  );
}

class MirrorTableView extends StatefulWidget {
  const MirrorTableView({super.key});

  @override
  createState() => _MirrorTableViewState();
}

class _MirrorTableViewState extends State<MirrorTableView>
    with AfterLayoutMixin {
  final HomeController home = Get.find<HomeController>();

  List<ISpiderAdapter> get _mirrorList {
    return home.mirrorList;
  }

  List<ISpiderAdapter> mirrorList = [];

  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: true,
  );

  double get cacheMirrorTableScrollControllerOffset {
    return home.cacheMirrorTableScrollControllerOffset;
  }

  void updateCacheMirrorTableScrollControllerOffset() {
    if (cacheMirrorTableScrollControllerOffset <= 0) return;

    if (mounted &&
        scrollController.hasClients &&
        scrollController.position.hasContentDimensions &&
        scrollController.position.maxScrollExtent > 0) {
      double targetOffset = cacheMirrorTableScrollControllerOffset;
      double maxOffset = scrollController.position.maxScrollExtent;

      if (targetOffset > maxOffset) {
        targetOffset = maxOffset;
      }

      scrollController.jumpTo(targetOffset);
    }
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    updateCacheMirrorTableScrollControllerOffset();
  }

  @override
  void initState() {
    super.initState();

    mirrorList = _mirrorList;
    updateMirrorStatusMap();

    scrollController.addListener(() {
      double offset = scrollController.offset;
      home.updateCacheMirrorTableScrollControllerOffset(offset);
    });
  }

  @override
  void didUpdateWidget(MirrorTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mirrorList != _mirrorList) {
      setState(() {
        mirrorList = _mirrorList;
      });
    }
  }

  void updateMirrorStatusMap() {
    __statusMap = MirrorStatusStack().getStacks;
    setState(() {});
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Map<String, bool> __statusMap = {};

  int get mirrorGridCount {
    double screenWidth = MediaQuery.of(context).size.width;
    double minCardWidth = 160;
    double spacing = 12;
    int count = ((screenWidth + spacing) / (minCardWidth + spacing)).floor();
    count = count.clamp(2, 6);
    return count;
  }

  Future<void> handleClickSubMenu(MenuActionType action) async {
    switch (action) {
      case MenuActionType.check:
        XHttp.setTimeout(24, 24);
        bool? checkCanDone = await showCupertinoDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            var refData = home.mirrorList;
            return MirrorCheckView(
              list: refData,
            );
          },
        );
        XHttp.setDefaultTImeout();
        if (checkCanDone ?? false) {
          updateMirrorStatusMap();
        }
        break;
      case MenuActionType.deleteUnavailable:
        bool status = await showDelUnavailableMirrorDialog();
        if (!status) return;
        List<String> result = SpiderManage.removeUnavailable(
          __statusMap,
        );
        setState(() {
          mirrorList.removeWhere((element) => result.contains(element.meta.id));
        });
        if (result.isNotEmpty) {
          home.updateMirrorIndex(0);
        }
        break;
      case MenuActionType.export:
        String append = SpiderManage.export(
          full: home.isNsfw,
        );

        DateTime today = DateTime.now();
        String dateSlug =
            "${today.year.toString()}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}";

        String filename = "YY$dateSlug.json";
        if (GetPlatform.isIOS) {
          Directory directory = await getTemporaryDirectory();
          String path = '${directory.path}/$filename';
          File file = File(path);
          await file.writeAsString(append);
          SharePlus.instance.share(ShareParams(files: [XFile(path)]));
        } else if (GetPlatform.isDesktop) {
          Directory? directory = await getDownloadsDirectory();
          if (directory == null) return;
          String? path = await FilePicker.platform.saveFile(
            initialDirectory: directory.path,
            fileName: filename,
          );
          if (path == null) return;
          File file = File(path);
          file.existsSync();
          file.writeAsStringSync(append);
        }
        break;
    }
  }

  Future<bool> showDelUnavailableMirrorDialog() async {
    var completer = Completer<bool>();
    showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: const Text('确定要删除所有失效源吗？'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text(
              '取消',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            onPressed: () {
              Get.back();
              completer.complete(false);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Get.back();
              completer.complete(true);
            },
            child: const Text(
              '确定',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
      context: Get.context as BuildContext,
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.mediaQuery.size.height * .72,
      child: Column(
        spacing: 0,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.blue.shade700.withValues(alpha: .3)
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        CupertinoIcons.cube_box,
                        size: 24,
                        color: context.isDarkMode
                            ? Colors.blue.shade300
                            : Colors.blue.shade700,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "源管理",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          "${_mirrorList.length} 个数据源",
                          style: TextStyle(
                            fontSize: 12,
                            color: context.isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  spacing: 12,
                  children: [
                    PullDownButton(
                      itemBuilder: (BuildContext context) {
                        return [
                          PullDownMenuItem(
                            onTap: () {
                              handleClickSubMenu(MenuActionType.check);
                              boop.selection();
                            },
                            title: '批量检测源',
                            icon: Icons.assignment,
                          ),
                          PullDownMenuItem(
                            title: '导出源',
                            onTap: () {
                              // handleClickSubMenu(MenuActionType.export);
                              // boop.selection();
                            },
                            icon: CupertinoIcons.arrowshape_turn_up_right,
                          ),
                          PullDownMenuItem(
                            onTap: () {
                              // handleClickSubMenu(
                              //     MenuActionType.deleteUnavailable);
                              // boop.selection();
                            },
                            title: '一键删除失效源',
                            isDestructive: true,
                            icon: CupertinoIcons.delete,
                          ),
                        ];
                      },
                      buttonBuilder: (BuildContext context, showMenu) {
                        return Zoom(
                          onTap: showMenu,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.isDarkMode
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Icon(
                              CupertinoIcons.ellipsis,
                              size: 18,
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        );
                      },
                    ),
                    Zoom(
                      onTap: () {
                        EasyLoading.dismiss();
                        Navigator.pop(context);
                      },
                      child: Container(
                              padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Colors.red.shade700.withValues(alpha: .2)
                              : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                            Icons.close,
                            size: 18,
                            color: context.isDarkMode
                                ? Colors.red.shade300
                                : Colors.red.shade600,
                          ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
              child: SizedBox(
                width: double.infinity,
                child: Scrollbar(
                  controller: scrollController,
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: mirrorGridCount,
                      mainAxisExtent: 88,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: mirrorList.length,
                    itemBuilder: (_, index) {
                      var e = mirrorList[index];
                      return MirrorCard(
                        item: e,
                        current: home.currentMirrorItem == e,
                        onTap: () {
                          var index = mirrorList.indexOf(e);
                          home.updateMirrorIndex(index);
                          Get.back();
                          boop.selection();
                        },
                        hashTable: __statusMap,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MirrorCard extends StatelessWidget {
  const MirrorCard({
    super.key,
    required this.item,
    this.current = false,
    required this.onTap,
    required this.hashTable,
  });

  final ISpiderAdapter item;

  final bool current;

  final VoidCallback onTap;

  final Map<String, bool> hashTable;

  String get _title => item.meta.name;

  String get _desc => item.meta.desc;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = current
        ? (context.isDarkMode ? "#f1f1f1" : "#1a237e").$color
        : (context.isDarkMode ? '#272727' : "#e2e8f0").$color;

    Color textColor = current
        ? (context.isDarkMode ? Colors.black : Colors.white)
        : (context.isDarkMode ? Colors.white : Colors.black);

    return Zoom(
      scaleRatio: .99,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: current
              ? LinearGradient(
                  colors: context.isDarkMode
                      ? [Colors.grey.shade100, Colors.grey.shade200]
                      : [Colors.indigo.shade700, Colors.purple.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: current ? null : backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: current
              ? [
                  BoxShadow(
                    color: (context.isDarkMode ? Colors.grey : Colors.indigo)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 3,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  current ? Icons.done : CupertinoIcons.right_chevron,
                  color: textColor,
                  size: 16,
                ),
              ],
            ),
            if (_desc.isNotEmpty)
              Text(
                _desc,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 10,
                  decoration: TextDecoration.none,
                  fontWeight: current ? FontWeight.bold : FontWeight.w300,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Builder(builder: (context) {
              var status = item.meta.status
                  ? MovieStatusType.available
                  : MovieStatusType.unavailable;
              var cacheStatus = hashTable[item.meta.id] ?? true;
              return MovieStatusWidget(
                status: status,
                cacheStatus: cacheStatus,
              );
            }),
            Builder(builder: (context) {
              var gfw = item.meta.extra['gfw'];
              var _type = item.meta.type;
              var status = item.meta.status
                  ? MovieStatusType.available
                  : MovieStatusType.unavailable;
              var cacheStatus = hashTable[item.meta.id] ?? true;

              bool isAvailable =
                  status == MovieStatusType.available && cacheStatus;

              var list = [
                _type == SourceType.maccms ? "VOD" : "JS",
                if (gfw is bool) gfw ? "直连" : "翻墙",
              ];
              return Row(
                spacing: 6,
                children: list.asMap().entries.map((entry) {
                  int index = entry.key;
                  String item = entry.value;

                  Color backgroundColor;
                  Color textColor;
                  BoxDecoration decoration;

                  if (isAvailable) {
                    textColor = Colors.white;
                    if (index == 0) {
                      backgroundColor = item == "VOD"
                          ? Colors.blue.shade600
                          : Colors.purple.shade600;
                    } else {
                      backgroundColor = item == "直连"
                          ? Colors.green.shade600
                          : Colors.orange.shade600;
                    }
                    decoration = BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: backgroundColor.withValues(alpha: .3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    );
                  } else {
                    textColor = Colors.grey.shade600;
                    decoration = BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    );
                  }

                  return Opacity(
                    opacity: isAvailable ? 1.0 : 0.6,
                    child: Container(
                      decoration: decoration,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 10,
                          color: textColor,
                          fontWeight:
                              isAvailable ? FontWeight.w600 : FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

enum MovieStatusType {
  /// 可用
  available,

  /// 不可用
  unavailable,
}

extension MovieStatusTypeExtension on MovieStatusType {
  String get text {
    switch (this) {
      case MovieStatusType.available:
        return '可用';
      case MovieStatusType.unavailable:
        return '上次不可用';
    }
  }
}

class MovieStatusWidget extends StatelessWidget {
  const MovieStatusWidget({
    super.key,
    this.status = MovieStatusType.available,
    required this.cacheStatus,
  });

  final MovieStatusType status;
  final bool cacheStatus;
  String get _text {
    return _type.text;
  }

  Color get _color {
    switch (_type) {
      case MovieStatusType.available:
        return Colors.green;
      case MovieStatusType.unavailable:
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  MovieStatusType get _type {
    return cacheStatus
        ? MovieStatusType.available
        : MovieStatusType.unavailable;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _color,
          ),
        ),
        Text(
          _text,
          style: TextStyle(
            color: _color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class PopMenuBox extends StatefulWidget {
  const PopMenuBox({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<ItemModel> items;

  final ValueChanged<MenuActionType> onTap;

  @override
  State<PopMenuBox> createState() => _PopMenuBoxState();
}

class _PopMenuBoxState extends State<PopMenuBox> {
  ItemModel? _hoverPopMenuItem;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: const Color(0xFF4C4C4C),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.items
                .map(
                  (item) => InkWell(
                    onTap: () {
                      widget.onTap(item.action);
                    },
                    onHover: (isHover) {
                      _hoverPopMenuItem = isHover ? item : null;
                      setState(() {});
                    },
                    onTapDown: (_) {
                      _hoverPopMenuItem = item;
                      setState(() {});
                    },
                    onTapCancel: () {
                      _hoverPopMenuItem = null;
                      setState(() {});
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: _hoverPopMenuItem?.title == item.title
                            ? Colors.blue
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            item.icon,
                            size: 15,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: 10,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

```

#### 📄 `lib/app\modules\home\views\mirror_check.dart`

```dart
import 'package:executor/executor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/shared/mirror_status_stack.dart';
import 'package:xi/xi.dart';

// 这里的代码借鉴(抄袭)了:
//
// https://github.com/Hentioe/mikack-mobile/blob/d6c92e509ae4c7fce6aaea48202b34ebb3b9f546/lib/pages/search.dart#L3
// https://github.com/honjow/FEhViewer/blob/d3c0d773418cbf5ee3697bff3a081764b74aca04/lib/common/controller/download_state.dart#L4
// https://github.com/jiangtian616/JHenTai/blob/cbcb16d422ba28bff5c560493b8ad760e6746d20/lib/src/utils/eh_executor.dart#L6
//
// 可参考的包:
//
// https://pub.dev/packages/concurrent_queue
// https://pub.dev/packages/computer
//
// now impl is stupid, need reimpl...

enum MirrorTabButtonStatus {
  /// 取消
  cancel,

  /// 确定
  done,
}

class MirrorCheckView extends StatefulWidget {
  const MirrorCheckView({
    super.key,
    required this.list,
  });

  final List<ISpiderAdapter> list;

  @override
  State<MirrorCheckView> createState() => _MirrorCheckViewState();
}

class _MirrorCheckViewState extends State<MirrorCheckView> {
  double get _checkBoxWidth {
    var w = Get.width;
    if (w >= 900) return 320;
    return w * .6;
  }

  double get _checkBoxHeight {
    var h = Get.height;
    if (h >= 900) return 420;
    return h * .48;
  }

  bool running = false;

  List<ISpiderAdapter> get listStack => widget.list;

  int get listStackLen => listStack.length;

  Executor? executor = Executor(concurrency: 12);

  List<String> currCacheID = [];

  Future<void> runTasks() async {
    running = true;
    setState(() {});
    executor = Executor(concurrency: 12);
    var target = widget.list.where((element) {
      return !currCacheID.contains(element.meta.id);
    }).toList();
    if (target.isEmpty) {
      running = false;
      setState(() {});
      return;
    }
    debugPrint("即将执行任务(共${target.length})");
    for (var curr in target) {
      executor!.scheduleTask(() async {
        if (!mounted) return;
        bool isSuccess = false;
        updateCurrentStatusText("开始测试 ${curr.meta.name}");
        try {
          await curr.getHome();
          isSuccess = true;
          _success++;
          setState(() {});
        } catch (e) {
          isSuccess = false;
          debugPrint(e.toString());
          _fail++;
          setState(() {});
        }
        String id = curr.meta.id;
        debugPrint("测试: $id, 结果: ${isSuccess ? '成功' : '失败'}");
        MirrorStatusStack().pushStatus(id, isSuccess);
        if (_taskCount < listStackLen) {
          _taskCount++;
        }
        setState(() {});
        currCacheID.add(id);
      });
    }
    await executor!.join(withWaiting: true);
    await executor!.close();
    running = false;
    setState(() {});
  }

  void handleTapAction() {
    if (running) {
      executor?.close();
      running = false;
      setState(() {});
    } else {
      if (_taskCount != 0) {
        _taskCount--;
        setState(() {});
      }
      runTasks();
    }
  }

  /// 成功
  int _success = 0;

  /// 失败
  int _fail = 0;

  /// 当前执行任务数
  int _taskCount = 0;

  String get _taskText {
    return "任务: $_taskCount/$listStackLen";
  }

  String get _text {
    return "成功: $_success, 失败: $_fail";
  }

  void beforeHook() {
    running = true;
    setState(() {});
    runTasks();
  }

  bool get easyDone {
    return _taskCount == listStackLen && !running;
  }

  @override
  void initState() {
    super.initState();

    beforeHook();
  }

  @override
  void dispose() {
    super.dispose();
    executor?.close();
  }

  void handleClickMenu(MirrorTabButtonStatus action) {
    switch (action) {
      case MirrorTabButtonStatus.cancel:
        running = false;
        // MirrorStatusStack().clean();
        debugPrint("已取消 >_<");
        setState(() {});
        Get.back(
          result: false,
        );
        break;
      case MirrorTabButtonStatus.done:
        MirrorStatusStack().flash();
        Get.back(
          result: true,
        );
        break;
    }
  }

  String _currentStatusText = "";

  void updateCurrentStatusText(String text) {
    _currentStatusText = text;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: context.isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          width: _checkBoxWidth,
          height: _checkBoxHeight,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                "获取源状态",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 6,
              ),
              const Divider(
                thickness: 2,
              ),
              Expanded(
                child: Column(
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      child: Expanded(
                        child: Column(
                          children: [
                            Text(
                              _taskText,
                            ),
                            Text(
                              _text,
                            )
                          ],
                        ),
                      ),
                    ),
                    Builder(builder: (context) {
                      if (easyDone) {
                        return const Icon(
                          CupertinoIcons.archivebox,
                          size: 66,
                        );
                      }
                      return const CircularProgressIndicator();
                    }),
                    Builder(builder: (context) {
                      if (easyDone) return const SizedBox.shrink();
                      Color bgColor = Colors.white;
                      if (!context.isDarkMode) {
                        bgColor = Colors.black;
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _currentStatusText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                    if (!easyDone)
                      const SizedBox(
                        height: 12,
                      ),
                    Builder(builder: (context) {
                      var text = "执行任务中";
                      if (easyDone) {
                        text = "任务已完成";
                      }
                      var child = Text(text);
                      if (easyDone) return Expanded(child: child);
                      return child;
                    }),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              if (!easyDone)
                CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  onPressed: handleTapAction,
                  child: Builder(builder: (context) {
                    String text = "暂停任务";
                    if (!running) {
                      text = "继续任务";
                    }
                    return Text(text);
                  }),
                ),
              const SizedBox(
                height: 8,
              ),
              const Divider(
                thickness: 1,
                height: 0,
              ),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text("取消"),
                        onPressed: () {
                          handleClickMenu(
                            MirrorTabButtonStatus.cancel,
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 1,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text("确定"),
                        onPressed: () {
                          handleClickMenu(
                            MirrorTabButtonStatus.done,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

#### 📄 `lib/app\modules\home\views\onboarding.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'package:xi/xi.dart';

String kV1JSON =
    "https://cdn.jsdelivr.net/gh/waifu-project/v1@latest/yoyo.json";

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key, this.onNext});

  final VoidCallback? onNext;

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  bool isLoading = false;

  Future<void> withTap() async {
    if (isLoading) return;
    isLoading = true;
    setState(() {});
    List<ISpiderAdapter> sources = [];
    try {
      sources = await SourceUtils.runTaks([kV1JSON]);
    } catch (e) {
      debugPrint(e.toString());
      EasyLoading.showError("获取源失败, 请重试");
    }
    isLoading = false;
    setState(() {});
    if (sources.isEmpty) {
      EasyLoading.showError("没有找到源, 请重试");
      return;
    }
    Get.back();
    SpiderManage.extend.addAll(sources);
    SpiderManage.saveToCache(SpiderManage.extend);
    EasyLoading.showSuccess("获取成功, 已添加${sources.length}个源!");
    widget.onNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = context.mediaQuery.size.width >= 600;
    Widget child = SizedBox(
      width: double.infinity,
      height: context.mediaQuery.size.height * (isDesktop ? .96 : .72),
      child: CupertinoOnboarding(
        backgroundColor: Colors.transparent,
        bottomButtonChild: Zoom(
          child: Row(
            spacing: 6,
            children: [
              if (isLoading) CupertinoActivityIndicator(color: Colors.white),
              Text("初始化"),
            ],
          ),
        ),
        onPressedOnLastPage: withTap,
        pages: [
          WhatsNewPage(
            title: const Text("小猫影视"),
            featuresSeperator: const SizedBox(height: 24),
            titleToBodySpacing: 24,
            features: [
              WhatsNewFeature(
                icon: Icon(
                  CupertinoIcons.cursor_rays,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
                title: const Text('欢迎使用 🐈'),
                description: const Text(
                  '在开始使用之前先导入一些源吧\n(可能需要科学上网)',
                ),
              ),
              WhatsNewFeature(
                icon: Icon(
                  CupertinoIcons.gift,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
                title: const Text('内建苹果源支持 🌠'),
                description: const Text(
                  '我们精心挑选了目前最好的一些苹果源, 保证基本可用',
                ),
              ),
            ],
          ),
          CupertinoOnboardingPage(
            titleToBodySpacing: 18,
            title: Text('使用技巧'),
            body: DefaultTextStyle(
              style: TextStyle(
                fontSize: 16,
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("点击可切换首页源"),
                      CachedNetworkImage(
                        imageUrl:
                            "https://s2.loli.net/2025/09/17/UKtBJSdwfsc63aI.png",
                      ),
                      Text("长按播放单个选集可复制链接或投屏播放"),
                      CachedNetworkImage(
                        imageUrl:
                            "https://s2.loli.net/2025/09/17/t8OqBQPe9Db7Xnx.gif",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return child;
  }
}

```

#### 📄 `lib/app\modules\home\views\parse_vip_manage.dart`

```dart
import 'dart:io';

import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:xi/xi.dart';

import '../controllers/home_controller.dart';
import 'source_help.dart';

enum KStatusCounter {
  success,
  fail,
  total,
}

typedef ValueImportCallback<T> = void Function(T value, List<dynamic> data);

class ParseVipManagePageView extends StatefulWidget {
  const ParseVipManagePageView({super.key});

  @override
  State<ParseVipManagePageView> createState() => _ParseVipManagePageViewState();
}

class _ParseVipManagePageViewState extends State<ParseVipManagePageView> {
  final HomeController home = Get.find<HomeController>();
  List<ParseIsarModel> get parseList => home.parseVipList;
  int get parseListCurrentIndex => home.currentParseVipIndex;

  @override
  initState() {
    super.initState();
  }

  Future<void> easyAddVipParseModel() async {
    var futureWith = await showCupertinoModalBottomSheet<ParseIsarModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => ParseVipAddDialog(
        onImport: (data, statusCounter) {
          home.addMovieParseVip(data);
          setState(() {});
          String msg =
              '''本次导入成功${statusCounter[0]}, 失败${statusCounter[1]}, 共${statusCounter[2]}''';
          showEasyCupertinoDialog(
            title: '提示',
            content: msg,
            onDone: () {
              Get.back();
            },
          );
        },
      ),
    );
    if (futureWith == null) return;
    home.addMovieParseVip(futureWith);
    setState(() {});
  }

  void easyRemoveOnceVipParseModel(int index) {
    home.removeMovieParseVipOnce(index);
    setState(() {});
  }

  void easySetDefaultOnceVipParseModal(int index) {
    home.setDefaultMovieParseVipIndex(index);
    setState(() {});
  }

  void easyShowHelp() {
    showEasyCupertinoDialog(
      title: '帮助',
      content: '''某些白名单播放链接(例如.爱奇艺,腾讯)需要解析才可以播放''',
      confirmText: '我知道了',
      onDone: () {
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var textColor = context.isDarkMode ? Colors.white : Colors.black;
    return Scaffold(
      appBar: WindowAppBar(
        iosBackStyle: true,
        title: Zoom(
          onTap: () => Get.back(),
          child: Row(
            children: [
              const SizedBox(width: 6.0),
              GestureDetector(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    CupertinoIcons.back,
                    color: textColor,
                  ),
                ),
                onTap: () {
                  Get.back();
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 9),
                child: Text(
                  "解析源管理",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: textColor),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Zoom(onTap: easyAddVipParseModel, child: Icon(Icons.add, color: textColor,)),
          const SizedBox(width: 12.0),
          Zoom(onTap: easyShowHelp, child: Icon(Icons.help, color: textColor,)),
          const SizedBox(width: 12.0),
        ],
      ),
      body: Builder(builder: (context) {
        if (parseList.isEmpty) {
          return _buildWithEmptry;
        }
        return _buildWithListBody;
      }),
    );
  }

  Widget get _buildWithEmptry {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          spacing: 24,
          children: [
            Image.asset(
              "assets/images/error.png",
              width: 120,
              height: 120,
            ),
            Text(
              "暂无解析接口 :(",
              style: TextStyle(
                color: (context.isDarkMode ? '#6f737a' : '#767a82').$color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _buildWithListBody {
    return SmoothListView.builder(
      duration: kSmoothListViewDuration,
      controller: ScrollController(),
      itemCount: parseList.length,
      itemBuilder: (BuildContext context, int index) {
        var curr = parseList[index];
        bool isSelected = parseListCurrentIndex == index;
        return Material(
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              key: ObjectKey(curr),
              children: [
                if (!isSelected)
                  SlidableAction(
                    onPressed: (_) {
                      easySetDefaultOnceVipParseModal(index);
                    },
                    backgroundColor: CupertinoColors.systemBlue,
                    foregroundColor: Colors.white,
                    icon: CupertinoIcons.bag,
                    flex: 2,
                    label: '设为默认',
                  ),
                SlidableAction(
                  onPressed: (_) {
                    easyRemoveOnceVipParseModel(index);
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.delete,
                  flex: 1,
                  label: '删除',
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(),
              margin: const EdgeInsets.symmetric(
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 12.0,
                      ),
                      Text(
                        curr.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? CupertinoColors.systemBlue : null,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                    ),
                    child: Text(
                      curr.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: isSelected
                            ? CupertinoColors.systemGrey
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ParseVipAddDialog extends StatefulWidget {
  const ParseVipAddDialog({
    super.key,
    required this.onImport,
  });

  final ValueImportCallback<List<ParseIsarModel>> onImport;

  @override
  State<ParseVipAddDialog> createState() => _ParseVipAddDialogState();
}

class _ParseVipAddDialogState extends State<ParseVipAddDialog> {
  String name = '';
  String url = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    bool isNext = _formKey.currentState!.validate();
    if (!isNext) return;
    var model = ParseIsarModel(
      name,
      url,
    );
    Get.back<ParseIsarModel>(result: model);
  }

  Future<void> handleImportFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'json',
      ],
    );
    if (result == null) {
      showEasyCupertinoDialog(
        content: "未选择文件 :(",
        confirmText: '我知道了',
      );
      return;
    }
    var files = result.paths.map((path) => File(path!)).toList();
    List<String> contents = [];
    for (var file in files) {
      var data = file.readAsStringSync();
      contents.add(data);
    }
    contents = contents.where(verifyStringIsJSON).toList();
    List<ParseIsarModel> outputData = [];

    /// 状态计数器
    /// [0] => 成功
    /// [1] => 失败
    /// [2] => 总数()
    List<int> statusCounter = [0, 0, 0];
    try {
      for (var content in contents) {
        JSONBodyType? jsonType = getJSONBodyType(content);
        List<ParseIsarModel> data = [];
        if (jsonType == JSONBodyType.array) {
          var verifiedData = movieParseModelFromJson(content);
          for (var whenData in verifiedData) {
            var canBeNext = isURL(whenData.url);
            var point =
                canBeNext ? KStatusCounter.success : KStatusCounter.fail;
            statusCounter[point.index]++;
            if (canBeNext) {
              data.add(whenData);
            }
          }
        } else if (jsonType == JSONBodyType.obj) {
          var onceData = ParseIsarModel.fromJson(jsonc.decode(content));
          var canBeNext = isURL(onceData.url);
          var point = canBeNext ? KStatusCounter.success : KStatusCounter.fail;
          statusCounter[point.index]++;
          if (canBeNext) {
            data.add(onceData);
          }
        }
        if (data.isEmpty) continue;
        statusCounter[KStatusCounter.total.index] = data.length;
        outputData.addAll(data);
      }
    } catch (e) {
      showEasyCupertinoDialog(
        title: '解析失败',
        content: e.toString(),
      );
      return;
    }
    if (statusCounter[KStatusCounter.total.index] >= 1) {
      Get.back();
      widget.onImport(outputData, statusCounter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: CupertinoPageScaffold(
            backgroundColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Text("解析源需要填写名称和URL",
                            style: TextStyle(fontSize: 18)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                              decoration:
                                  const InputDecoration(hintText: '输入名称'),
                              onChanged: (value) {
                                name = value;
                                setState(() {});
                              },
                              validator: (value) {
                                var b = value!.length >= 2;
                                var msg = b ? null : '名称最少2个字符';
                                return msg;
                              },
                            ),
                            TextFormField(
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                              decoration:
                                  const InputDecoration(hintText: '输入URL'),
                              onChanged: (value) {
                                url = value;
                                setState(() {});
                              },
                              validator: (value) {
                                bool bindCheck = isURL(value);
                                return !bindCheck ? '不是url' : null;
                              },
                            ),
                            const SizedBox(height: 12.0),
                            Zoom(
                              child: SizedBox(
                                width: double.infinity,
                                child: CupertinoButton.filled(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  onPressed: submit,
                                  child: const Text(
                                    "添加",
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                          ],
                        ),
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
}

```

#### 📄 `lib/app\modules\home\views\search.dart`

```dart
import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/routes/app_pages.dart';
import 'package:catmovie/app/shared/bus.dart';
import 'package:catmovie/app/widget/helper.dart';
import 'package:catmovie/app/widget/k_tag.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/isar/schema/history_schema.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:catmovie/utils/boop.dart';
import 'package:concurrent_queue/concurrent_queue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/extension.dart';
import 'package:isar_community/isar.dart';
import 'package:tuple/tuple.dart';
import 'package:xi/xi.dart';

const kNsfwFlag = "114514";

final kAllSourceMeta =
    SourceMeta(id: "6324", name: "全部", type: SourceType.maccms, api: "empty");

final int kDefaultPagingSize = 20;

typedef MapVideosRecord = Tuple2<SourceMeta, List<VideoDetail>>;

class SearchV2 extends StatefulWidget {
  const SearchV2({super.key});

  @override
  State<SearchV2> createState() => _SearchV2State();
}

class _SearchV2State extends State<SearchV2> with AfterLayoutMixin {
  final home = Get.find<HomeController>();

  Map<SourceMeta, List<VideoDetail>> map = {};

  // [int]  -> 当前 page-size
  // [bool] -> 是否有更多视频
  Map<SourceMeta, Tuple2<int, bool>> pagingMap = {};

  TextEditingController textEditingController = TextEditingController();

  String keyword = "";

  bool isSearching = false;

  bool showHistory = true;

  List<String> _searchHistory = [];

  List<String> get searchHistory {
    return _searchHistory;
  }

  set searchHistory(List<String> newVal) {
    setState(() {
      _searchHistory = newVal;
    });
  }

  SourceMeta currSource = kAllSourceMeta;

  List<SourceMeta> get sourceList {
    var result = map.keys.toList();
    result = result.where((item) {
      return (map[item] ?? []).isNotEmpty;
    }).toList();
    if (result.isNotEmpty) {
      result.insert(
        0,
        kAllSourceMeta,
      );
    }
    return result;
  }

  List<VideoDetail> get videos {
    if (currSource == kAllSourceMeta) {
      return map.values.expand((e) => e).toList();
    }
    return map[currSource] ?? [];
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    searchFocusNode.addListener(() {
      if (mounted) _hasFocus = searchFocusNode.hasFocus;
      setState(() {});
    });
    loadSources();
    loadSearchHistory();
    scrollController.addListener(() {
      if (currSource == kAllSourceMeta) return;
      var cx = pagingMap[currSource];
      if (cx == null || !cx.item2) return;
      double currentPosition = scrollController.position.pixels;
      double maxScrollExtent = scrollController.position.maxScrollExtent;
      if (currentPosition >= maxScrollExtent - 1) {
        // debugPrint("已经滚动到底部");
        showMoreBtn = true;
        if (mounted) setState(() {});
      }
      if (currentPosition > _lastScrollPosition) {
        // debugPrint("向下滚动");
      } else if (currentPosition < _lastScrollPosition) {
        // debugPrint("向上滚动");
        showMoreBtn = false;
        if (mounted) setState(() {});
      }
      _lastScrollPosition = currentPosition;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
    stopSearch();
  }

  final queue = ConcurrentQueue(concurrency: 3);
  bool searchDone = false;
  bool showMoreBtn = false;
  bool moreBtnLoading = false;

  // 记录上一次滚动位置
  double _lastScrollPosition = 0;

  List<ISpiderAdapter> sources = [];

  ScrollController scrollController = ScrollController();

  /// 根据源类型获取期望的分页大小
  int getPageSize(SourceMeta sourceMeta) {
    return sourceMeta.searchLimit;
  }

  FocusNode searchFocusNode = FocusNode();
  bool _hasFocus = true;

  void stopSearch() {
    queue.pause();
    queue.clear();
  }

  void handleClean() {
    stopSearch();
    textEditingController.clear();
    keyword = "";
    showHistory = true;
    isSearching = false;
    searchDone = true;
    map.clear();
    setState(() {});
  }

  Future<void> loadSearchHistory() async {
    var data = historyAs.filter().isNsfwEqualTo(home.isNsfw).findAllSync();
    setState(() {
      _searchHistory = data.map((e) => e.content).toList();
    });
  }

  void loadSources() {
    List<ISpiderAdapter> _sources = List.from(home.mirrorList);
    _sources.remove(home.currentMirrorItem);
    _sources.insert(0, home.currentMirrorItem);
    sources = _sources;
    debugPrint("load ${sources.length} source");
    setState(() {});
  }

  void handleSearch(String _keyword) async {
    if (kNsfwFlag == _keyword) {
      var flag = getSettingAsKeyIdent<bool>(SettingsAllKey.showNsfwSetting);
      var newFlag = !flag;
      var msg = "绅士模式设置已${newFlag ? "显示" : "隐藏"}";
      EasyLoading.showInfo(msg);
      updateSetting(SettingsAllKey.showNsfwSetting, newFlag);
      $bus.fire(ShowNsfwSettingEvent(newFlag));
      Get.back();
      return;
    }
    textEditingController.text = _keyword;
    showHistory = false;
    isSearching = true;
    searchDone = false;
    keyword = _keyword;
    currSource = kAllSourceMeta;
    map.clear();
    setState(() {});
    handleUpdateSearchHistory(_keyword);
    stopSearch();
    for (var item in sources) {
      queue.add<MapVideosRecord>(() async {
        var list = await item.getSearch(keyword: _keyword, page: 1, limit: 12);
        for (var video in list) {
          video.setContext(item.meta);
        }
        return Tuple2(item.meta, list);
      });
    }
    queue.on(QueueEventAction.completed, (event) {
      if (mounted) {
        var result = event.result as MapVideosRecord;
        if (result.item2.isNotEmpty) {
          map[result.item1] = result.item2;
          int expectedSize = getPageSize(result.item1);
          if (result.item2.length == expectedSize) {
            pagingMap[result.item1] = Tuple2(1, true);
          } else {
            pagingMap[result.item1] = Tuple2(1, false);
          }
          setState(() {});
        }
      }
    });
    queue.on(QueueEventAction.idle, (event) {
      debugPrint("search done");
      if (mounted) {
        isSearching = false;
        searchDone = true;
        setState(() {});
      }
    });
    queue.start();
  }

  void handleUpdateSearchHistory(
    String text, {
    type = UpdateSearchHistoryType.add,
  }) {
    var oldData = _searchHistory;
    var nsfw = home.isNsfw;
    void safe(VoidCallback cb) {
      isarInstance.writeTxnSync(cb);
    }

    switch (type) {
      case UpdateSearchHistoryType.add: // 添加
        oldData.remove(text);
        oldData.insert(0, text);
        safe(() {
          historyAs
              .filter()
              .isNsfwEqualTo(nsfw)
              .contentEqualTo(text)
              .deleteAllSync();
          historyAs.putSync(HistoryIsarModel(nsfw, text));
        });
        break;
      case UpdateSearchHistoryType.remove: // 删除单个
        oldData.remove(text);
        safe(() {
          historyAs
              .filter()
              .isNsfwEqualTo(nsfw)
              .contentEqualTo(text)
              .deleteAllSync();
        });
        break;
      case UpdateSearchHistoryType.clean: // 清除所有
        oldData = [];
        safe(() {
          historyAs.filter().isNsfwEqualTo(nsfw).deleteAllSync();
        });
        break;
      default:
    }
    searchHistory = oldData;
  }

  Widget? _buildActionButton() {
    return (!isSearching || map.isEmpty)
        ? null
        : FloatingActionButton(
            tooltip: "停止搜索",
            onPressed: () {
              stopSearch();
              isSearching = false;
              searchDone = true;
              setState(() {});
            },
            child: const Icon(CupertinoIcons.stop_fill),
          );
  }

  PreferredSizeWidget _buildAppBar() {
    double top = MediaQuery.of(context).padding.top;
    double height = GetPlatform.isDesktop ? 81 : top;
    if (GetPlatform.isAndroid) {
      height *= 2;
    }
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: CustomMoveWindow(
          child: Column(
            children: [
              SizedBox(
                height: GetPlatform.isDesktop ? (kMacPaddingTop + 12) : top,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
                  child: Row(
                    spacing: 12,
                    children: [
                      // TODO(d1y): 支持选择(过滤)源
                      // Icon(Icons.filter_alt_outlined, size: 26),
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.text,
                          child: CupertinoTextField(
                            controller: textEditingController,
                            onSubmitted: handleSearch,
                            textInputAction: TextInputAction.search,
                            autofocus: true,
                            focusNode: searchFocusNode,
                            showCursor: true,
                            decoration: BoxDecoration(
                              color: CupertinoDynamicColor.withBrightness(
                                color: "#f0f0f0".$color,
                                darkColor: "#1c1c1e".$color,
                              ),
                              border: Border.all(
                                color: CupertinoDynamicColor.withBrightness(
                                  color: CupertinoColors.inactiveGray,
                                  darkColor: CupertinoColors.white,
                                ).withValues(alpha: _hasFocus ? .72 : .12),
                                width: 1,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            onChanged: (_keyword) {
                              keyword = _keyword;
                              setState(() {});
                            },
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            placeholder: "搜索",
                            prefix: Padding(
                              padding: EdgeInsets.only(
                                left: 6,
                              ),
                              child: Icon(
                                CupertinoIcons.search,
                                size: 21,
                                color: "#707070".$color,
                              ),
                            ),
                            suffix: keyword.isEmpty
                                ? null
                                : Zoom(
                                    onTap: handleClean,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: "#d0d0d0"
                                              .$color
                                              .withValues(alpha: .42),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          CupertinoIcons.clear,
                                          size: 12,
                                          weight: 12,
                                          color: (Get.isDarkMode
                                                  ? '#f0f0f0'
                                                  : '#1c1c1e')
                                              .$color,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Zoom(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Text(
                            "取消",
                            style: TextStyle(
                              color: CupertinoDynamicColor.withBrightness(
                                  color: '#767a82'.$color,
                                  darkColor: '#6f737a'.$color),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    String textColor = context.isDarkMode ? '#6f737a' : '#767a82';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/loading.gif",
            width: 120,
            height: 120,
          ),
          SizedBox(height: 12),
          Text("搜索中..", style: TextStyle(color: textColor.$color)),
          SizedBox(height: context.mediaQuerySize.height * .24),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    String textColor = context.isDarkMode ? '#6f737a' : '#767a82';
    return Center(
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/error.png", width: 120, height: 120),
          Text(
            "没有找到相关内容",
            style: TextStyle(color: textColor.$color),
          ),
          SizedBox(height: context.mediaQuery.size.height * .24),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return Column(
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: searchHistory.isEmpty
                    ? EdgeInsets.symmetric(vertical: 5)
                    : EdgeInsets.zero,
                child: Text(
                  "搜索历史",
                  style: TextStyle(
                      fontSize: 21,
                      color: Get.isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              if (searchHistory.isNotEmpty)
                Zoom(
                  child: IconButton(
                    iconSize: 18,
                    tooltip: "删除所有历史记录",
                    padding: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 2,
                    ),
                    onPressed: () {
                      handleUpdateSearchHistory(
                        "",
                        type: UpdateSearchHistoryType.clean,
                      );
                      boop.warning();
                    },
                    icon: const Icon(CupertinoIcons.trash),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 6,
                children: searchHistory
                    .map(
                      (_keyword) => Zoom(
                        child: KTag(
                          backgroundColor:
                              (Get.isDarkMode ? '#1f2122' : '#dfe2e4').$color,
                          onTap: (type) {
                            switch (type) {
                              case KTagTapEventType.content: // 内容
                                handleUpdateSearchHistory(
                                  _keyword,
                                  type: UpdateSearchHistoryType.add,
                                );
                                keyword = _keyword;
                                setState(() {});
                                handleSearch(keyword);
                                boop.selection();
                                break;
                              case KTagTapEventType.action: // 操作
                                handleUpdateSearchHistory(
                                  _keyword,
                                  type: UpdateSearchHistoryType.remove,
                                );
                                break;
                              default:
                            }
                          },
                          child: Text(_keyword,
                              style: TextStyle(
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        Container(
          width: 120,
          height: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 9),
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                spacing: 12,
                children: sourceList.map((item) {
                  var textColor = Get.isDarkMode ? Colors.white : Colors.black;
                  if (item == currSource) {
                    textColor = Color(0xFF6750A4);
                  }
                  return Zoom(
                    onTap: () {
                      showMoreBtn = false;
                      moreBtnLoading = false;
                      currSource = item;
                      setState(() {});
                      boop.selection();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: (Get.isDarkMode ? '#1c1c1e' : "#f0f0f0").$color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      child: Text(
                        item.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ).copyWith(right: 18),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      spacing: 12,
                      children: videos.map((item) {
                        return GestureDetector(
                          onTap: () async {
                            var data = item;
                            if (item.videos.isEmpty) {
                              var isNext =
                                  await showLoadingPlaceholderTask(() async {
                                String id = item.id;
                                var curr =
                                    home.mirrorList.firstWhereOrNull((cx) {
                                  return cx.meta == item.getContext();
                                });
                                if (curr == null) {
                                  throw Exception("未找到对应的源");
                                }
                                data = await curr.getDetail(id);
                                data = item.mergeWith(data);
                                data.setContext(curr.meta);
                              });
                              if (!isNext) return;
                            }
                            Get.toNamed(
                              Routes.PLAY,
                              arguments: data,
                            );
                          },
                          child: Zoom(
                            scaleRatio: .99,
                            child: Container(
                              decoration: BoxDecoration(
                                color: (Get.isDarkMode ? '#1c1c1e' : "#f0f0f0")
                                    .$color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: double.infinity,
                              height: 160,
                              padding: EdgeInsets.all(12),
                              child: Row(
                                spacing: 12,
                                children: [
                                  Builder(builder: (context) {
                                    String img = item.smallCoverImage;
                                    if (img.isEmpty) {
                                      return SizedBox.shrink();
                                    }
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0),
                                      child: CachedNetworkImage(
                                        imageUrl: item.smallCoverImage,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: double.infinity,
                                        progressIndicatorBuilder:
                                            (context, url, progress) =>
                                                DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: .12),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: progress.progress,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) =>
                                            kErrorImage,
                                      ),
                                    );
                                  }),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          spacing: 6,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                color: Get.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (item.remark.isNotEmpty)
                                              Text(
                                                item.remark,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: (Get.isDarkMode
                                                          ? Colors.white
                                                          : Colors.black)
                                                      .withValues(alpha: .42),
                                                ),
                                              ),
                                            // Text(item.updateTime),
                                          ],
                                        ),
                                        Builder(builder: (context) {
                                          var source = item.getContext();
                                          if (source == null) {
                                            return const SizedBox.shrink();
                                          }
                                          var color = (Get.isDarkMode
                                                  ? '#a4a4a6'
                                                  : '#71727a')
                                              .$color;
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: color,
                                                width: .72,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            child: Text(
                                              source.name,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: color,
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                width: context.mediaQuery.size.width - 120,
                left: 0,
                bottom: showMoreBtn ? 24 : -88,
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 420),
                child: Center(
                  child: CupertinoButton.filled(
                    mouseCursor: SystemMouseCursors.click,
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 32),
                    sizeStyle: CupertinoButtonSize.medium,
                    child: Row(
                      spacing: 6,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (moreBtnLoading)
                          SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 1.8,
                            ),
                          ),
                        Text("加载更多", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    onPressed: () async {
                      moreBtnLoading = true;
                      if (mounted) setState(() {});
                      var cx = pagingMap[currSource];
                      if (cx == null || !cx.item2) return;
                      var axios = home.mirrorList.firstWhere((item) {
                        return item.meta == currSource;
                      });
                      var nextPage = cx.item1 + 1;
                      List<VideoDetail> list = [];
                      boop.selection();
                      try {
                        list = await axios.getSearch(
                          keyword: keyword,
                          page: nextPage,
                        );
                        boop.success();
                      } catch (e) {
                        boop.error();
                        debugPrint(e.toString());
                      }
                      moreBtnLoading = false;
                      showMoreBtn = false;
                      if (mounted) setState(() {});
                      map[currSource]!.addAll(list);
                      int expectedSize = getPageSize(currSource);
                      if (list.length == expectedSize) {
                        pagingMap[currSource] = Tuple2(nextPage, true);
                      } else {
                        pagingMap[currSource] = Tuple2(nextPage, false);
                      }
                      if (mounted) setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (context.isDarkMode ? Colors.black : Colors.white)
          .withValues(alpha: .88),
      appBar: _buildAppBar(),
      floatingActionButton: _buildActionButton(),
      body: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Builder(builder: (context) {
            if (showHistory) {
              return _buildHistory();
            }
            if (searchDone && map.isEmpty) {
              return _buildEmpty();
            }
            if (isSearching && map.isEmpty) {
              return _buildLoading();
            }
            return _buildBody();
          }),
        ),
      ),
    );
  }
}

```

#### 📄 `lib/app\modules\home\views\settings_view.dart`

```dart
import 'dart:async';

import 'package:catmovie/app/modules/home/views/auto_update.dart';
import 'package:catmovie/app/widget/k_body.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/utils/boop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/modules/home/views/parse_vip_manage.dart';
import 'package:catmovie/app/modules/home/views/source_help.dart';
import 'package:catmovie/app/shared/bus.dart';
// import 'package:catmovie/git_info.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:catmovie/app/modules/home/views/cupertino_license.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:xi/xi.dart';

const kTelegramGroup = "https://t.me/catmovie1145";

const kGithubIconSvg = r"""
<svg t="1757744978460" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="13267" width="200" height="200"><path d="M512 42.666667A464.64 464.64 0 0 0 42.666667 502.186667 460.373333 460.373333 0 0 0 363.52 938.666667c23.466667 4.266667 32-9.813333 32-22.186667v-78.08c-130.56 27.733333-158.293333-61.44-158.293333-61.44a122.026667 122.026667 0 0 0-52.053334-67.413333c-42.666667-28.16 3.413333-27.733333 3.413334-27.733334a98.56 98.56 0 0 1 71.68 47.36 101.12 101.12 0 0 0 136.533333 37.973334 99.413333 99.413333 0 0 1 29.866667-61.44c-104.106667-11.52-213.333333-50.773333-213.333334-226.986667a177.066667 177.066667 0 0 1 47.36-124.16 161.28 161.28 0 0 1 4.693334-121.173333s39.68-12.373333 128 46.933333a455.68 455.68 0 0 1 234.666666 0c89.6-59.306667 128-46.933333 128-46.933333a161.28 161.28 0 0 1 4.693334 121.173333A177.066667 177.066667 0 0 1 810.666667 477.866667c0 176.64-110.08 215.466667-213.333334 226.986666a106.666667 106.666667 0 0 1 32 85.333334v125.866666c0 14.933333 8.533333 26.88 32 22.186667A460.8 460.8 0 0 0 981.333333 502.186667 464.64 464.64 0 0 0 512 42.666667" fill="#231F20" p-id="13268"></path></svg>
""";

enum GetBackResultType {
  /// 失败
  fail,

  /// 成功
  success
}

enum HandleDiglogTapType {
  /// 清空
  clean,

  /// 获取配置
  kget,
}

GlobalKey kVideoKernelBtnKey = GlobalKey();

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with AutomaticKeepAliveClientMixin {
  final HomeController home = Get.find<HomeController>();

  late StreamSubscription $busWithNSFW;
  late StreamSubscription $busWithShowNsfwSetting;

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/data/source_help.txt');
  }

  String sourceHelpText = "";

  bool _isDark = false;

  bool get isDark {
    return _isDark;
  }

  set isDark(bool newVal) {
    updateSetting(
      SettingsAllKey.themeMode,
      newVal ? SystemThemeMode.dark : SystemThemeMode.light,
    );
    setState(() {
      _isDark = newVal;
    });
    Get.changeThemeMode(newVal ? ThemeMode.dark : ThemeMode.light);
  }

  bool _autoDarkMode = false;

  VideoKernel _videoKernel = VideoKernel.webview;

  bool _hapticFeedback = true;

  bool _showNsfwSetting = false;
  int _copyrightClickCount = 0;

  bool get hapticFeedback => _hapticFeedback;
  set hapticFeedback(bool flag) {
    boop.call(HapticsType.selection, force: true);
    boop.setEnabled(flag);
    _hapticFeedback = flag;
    if (mounted) setState(() {});
  }

  set autoDarkMode(bool newVal) {
    if (newVal) {
      updateSetting(SettingsAllKey.themeMode, SystemThemeMode.system);
    }
    setState(() {
      _autoDarkMode = newVal;
    });
    if (!newVal) {
      _isDark = Get.isPlatformDarkMode;
      Get.changeThemeMode(!_isDark ? ThemeMode.light : ThemeMode.dark);
      return;
    }
    if (GetPlatform.isWindows) {
      var mode = getWindowsThemeMode();
      Get.changeTheme(ThemeData(brightness: mode));
    }
    Get.changeThemeMode(ThemeMode.system);
  }

  bool get autoDarkMode {
    return _autoDarkMode;
  }

  @override
  void initState() {
    setState(() {
      var themeMode =
          getSettingAsKeyIdent<SystemThemeMode>(SettingsAllKey.themeMode);
      _isDark = themeMode.isDark;
      _autoDarkMode = themeMode.isSytem;
      _videoKernel =
          getSettingAsKeyIdent<VideoKernel>(SettingsAllKey.videoKernel);
      _mirrorLength = SpiderManage.data.length;
      // var __hapticFeedback = getSettingAsKeyIdent<bool>(
      //   SettingsAllKey.hapticFeedback,
      //   defaultValue: true,
      // );
      // _hapticFeedback = __hapticFeedback;
      // boop.enabled = _hapticFeedback;
      _hapticFeedback = boop.enabled; // 初始化已经在 initHapticFeedback 中做了
      _showNsfwSetting = getSettingAsKeyIdent<bool>(
        SettingsAllKey.showNsfwSetting,
        defaultValue: false,
      );
    });
    loadSourceHelp();
    addMirrorMangerTextareaLister();
    $busWithNSFW = $bus.on<SettingEvent>().listen((event) {
      updateNSFW(event.nsfw, onlyUpdate: true);
    });
    $busWithShowNsfwSetting = $bus.on<ShowNsfwSettingEvent>().listen((event) {
      _showNsfwSetting = event.flag;
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _editingController.dispose();
    $busWithNSFW.cancel();
    $busWithShowNsfwSetting.cancel();
    super.dispose();
  }

  void updateNSFW(bool flag, {bool onlyUpdate = false}) {
    home.isNsfw = flag;
    if (!onlyUpdate) {
      showNSFW = flag;
    }
    boop.selection();
    home.update();
  }

  void addMirrorMangerTextareaLister() {
    editingControllerValue =
        getSettingAsKeyIdent<String>(SettingsAllKey.mirrorTextarea);
    _lines = editingControllerValue;
    _editingController.addListener(() {
      _lines = editingControllerValue;
      if (mounted) setState(() {});
      updateSetting(SettingsAllKey.mirrorTextarea, editingControllerValue);
    });
  }

  Future<void> loadSourceHelp() async {
    var data = await loadAsset();
    setState(() {
      sourceHelpText = data;
    });
  }

  bool get showNSFW {
    return (home.isNsfw || nShowNSFW >= 10);
  }

  set showNSFW(bool newVal) {
    setState(() {
      nShowNSFW = !newVal ? 0 : 10;
    });
  }

  int _nShowNSFW = 0;

  int get nShowNSFW => _nShowNSFW;

  set nShowNSFW(int newVal) {
    setState(() {
      _nShowNSFW = newVal;
    });
  }

  int _mirrorLength = 0;

  String get mirrorLengthWithText {
    if (_mirrorLength == 0) {
      return "暂无";
    }
    return _mirrorLength.toString();
  }

  // NOTE(d1y): 这里的 home.parseVipList 会动态更新吗?
  String get parseVipListWithText {
    if (home.parseVipList.isEmpty) {
      return "暂无";
    }
    return home.parseVipList.length.toString();
  }

  final TextEditingController _editingController = TextEditingController();

  String get editingControllerValue {
    return _editingController.text.trim();
  }

  set editingControllerValue(String newVal) {
    _editingController.text = newVal;
  }

  var _lines = "";
  int get realLineLength {
    return _lines.split('\n').where((element) => element.isNotEmpty).length;
  }

  Future<void> handleDiglogTap(HandleDiglogTapType type) async {
    switch (type) {
      case HandleDiglogTapType.clean:
        editingControllerValue = "";
        EasyLoading.showInfo("解析内容已经清空!");
        boop.success();
        break;
      case HandleDiglogTapType.kget:
        if (editingControllerValue.isEmpty) {
          EasyLoading.showError("内容为空, 请填写url!");
          boop.error();
          return;
        }
        var target = SourceUtils.getSources(editingControllerValue);
        if (target.isEmpty) {
          EasyLoading.showError("没有找到匹配的源!");
          boop.error();
          return;
        }
        Get.dialog(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: kActivityIndicator,
            ),
          ),
          barrierColor: CupertinoColors.black.withValues(alpha: .9),
        );
        var data = await SourceUtils.runTaks(target);
        Get.back();
        if (data.isEmpty) {
          EasyLoading.showError("获取的内容为空!");
          boop.error();
          return;
        }
        SpiderManage.extend.clear();
        SpiderManage.extend.addAll(data);
        SpiderManage.saveToCache(SpiderManage.extend);
        var showMessage = "已同步成功(${data.length}个源)!";
        updateSetting(SettingsAllKey.onBoardingShowed, true);
        EasyLoading.showSuccess(showMessage);
        _mirrorLength = data.length;
        if (mounted) setState(() {});
        boop.success();
        break;
      default:
    }
  }

  void handleCleanCache() {
    boop.success();
    home.clearCache();
    home.confirmAlert(
      "已删除缓存, 部分内容重启之后生效!",
      showCancel: false,
      confirmText: "我知道了",
      context: context,
    );
    _mirrorLength = 0;
    if (mounted) setState(() {});
  }

  List<PullDownMenuEntry> _buildVideoKernel() {
    void action(VideoKernel vk) {
      _videoKernel = vk;
      updateSetting(SettingsAllKey.videoKernel, vk);
      setState(() {});
      boop.selection();
    }

    var result = [VideoKernel.webview, VideoKernel.mediaKit].map((item) {
      return PullDownMenuItem.selectable(
        selected: item == _videoKernel,
        onTap: () => action(item),
        title: item.name,
      );
    }).toList();
    if (GetPlatform.isMacOS) {
      result.add(
        PullDownMenuItem.selectable(
          selected: VideoKernel.iina == _videoKernel,
          onTap: () {
            boop.success();
            final bool isInstall = checkInstalledIINA();
            if (!isInstall) {
              EasyLoading.showError("未安装IINA, 请先安装!");
              boop.error();
              return;
            }
            action(VideoKernel.iina);
          },
          title: VideoKernel.iina.name,
        ),
      );
    }
    return result;
  }

  void handleSourceHelp() {
    var cx = getSettingAsKeyIdent<String>(SettingsAllKey.mirrorTextarea,
            defaultValue: "")
        .trim();
    if (cx.isNotEmpty && cx != editingControllerValue) {
      editingControllerValue = cx;
    }
    var fullWidth = context.mediaQuery.size.width;
    var width = fullWidth * .48;
    if (fullWidth <= 700) {
      width = 620;
    }
    showCupertinoModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          width: width,
          height: context.mediaQuery.size.height * .72,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              spacing: 9,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.isDarkMode
                                ? Colors.blue.shade700.withValues(alpha: .3)
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            CupertinoIcons.cube_box,
                            size: 24,
                            color: context.isDarkMode
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "源管理",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              "$realLineLength 个数据源",
                              style: TextStyle(
                                fontSize: 12,
                                color: context.isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      spacing: 9,
                      children: [
                        Zoom(
                          child: IconButton(
                            tooltip: "清空",
                            icon: SvgPicture.string(
                              r"""
<svg t="1758656052478" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="24530" width="200" height="200"><path d="M384 298.666667V128q0-35.328 25.002667-60.330667T469.333333 42.666667h85.333334q35.328 0 60.330666 25.002666T640 128v170.666667h-42.666667V256h202.922667q28.245333 0 50.944 16.853333 22.656 16.896 30.805333 43.946667l38.4 128q12.288 41.088-13.269333 75.477333-25.6 34.389333-68.48 34.389334H185.344q-42.88 0-68.48-34.389334-25.6-34.389333-13.226667-75.477333l38.4-128q8.106667-27.050667 30.762667-43.946667Q195.498667 256 223.744 256H426.666667v42.666667H384z m85.333333 0q0 4.181333-0.853333 8.32-0.768 4.138667-2.389333 8.021333-1.621333 3.84-3.968 7.381333-2.304 3.456-5.290667 6.442667-2.986667 2.986667-6.442667 5.290667-3.498667 2.346667-7.381333 3.968-3.882667 1.621333-8.021333 2.432Q430.848 341.333333 426.666667 341.333333H223.744l-38.4 128h653.312l-38.4-128H597.333333q-4.224 0-8.32-0.853333-4.138667-0.768-8.021333-2.389333-3.84-1.621333-7.381333-3.968-3.498667-2.304-6.442667-5.290667-2.986667-2.986667-5.333333-6.442667-2.304-3.498667-3.925334-7.381333-1.621333-3.882667-2.432-8.021333Q554.666667 302.848 554.666667 298.666667V128h-85.333334v170.666667z" fill="#333333" p-id="24531"></path><path d="M862.08 868.565333q12.586667-114.602667 12.586667-190.634666 0-103.424-23.253334-178.56-0.981333-3.242667-2.474666-6.272-1.536-3.029333-3.498667-5.802667-1.962667-2.773333-4.352-5.205333-2.389333-2.432-5.12-4.437334-2.730667-2.005333-5.717333-3.584-3.029333-1.536-6.272-2.602666-3.2-1.066667-6.570667-1.578667Q814.08 469.333333 810.666667 469.333333H192q-4.181333 0-8.32 0.853334-4.138667 0.768-8.021333 2.389333-3.84 1.621333-7.381334 3.968-3.456 2.304-6.442666 5.290667-2.986667 2.986667-5.290667 6.442666-2.346667 3.498667-3.968 7.381334-1.621333 3.882667-2.432 8.021333-0.810667 4.138667-0.810667 8.32v1.664q2.645333 67.541333 0 163.072-1.706667 63.36-71.509333 169.258667-28.544 43.306667-4.138667 89.173333Q98.261333 981.333333 150.4 981.333333h585.344q48.384 0 84.608-32.170666 36.437333-32.384 41.728-80.64zM777.813333 554.666667q11.562667 53.333333 11.562667 123.264 0 71.338667-12.074667 181.333333-1.706667 15.573333-13.568 26.112-11.946667 10.624-27.946666 10.624H150.357333q-0.853333 0-1.322666-0.896-0.597333-1.152 0.042666-2.133333 83.2-126.208 85.589334-213.888 1.877333-69.12 1.109333-124.416h541.994667z" fill="#333333" p-id="24532"></path><path d="M333.056 963.882667Q426.666667 836.309333 426.666667 682.666667H341.333333q0 125.653333-77.056 230.784l68.778667 50.432zM594.730667 953.344Q640 829.866667 640 682.666667h-85.333333q0 132.053333-40.064 241.322666l80.128 29.354667z" fill="#333333" p-id="24533"></path></svg>
""",
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                  context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  BlendMode.srcIn),
                            ),
                            onPressed: () {
                              handleDiglogTap(HandleDiglogTapType.clean);
                            },
                          ),
                        ),
                        Zoom(
                          child: IconButton(
                            tooltip: "获取配置",
                            icon: SvgPicture.string(
                              r"""
<svg t="1758655940551" class="icon" viewBox="0 0 1028 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="23526" width="200" height="200"><path d="M1002.289973 8.914836c-12.795191-8.530127-34.12051-12.795191-46.915701-4.265064L25.590382 486.601972c-21.325319 12.795191-29.855446 38.385573-21.325318 59.710892 4.265064 8.530127 12.795191 17.060255 21.325318 21.325319L251.638759 682.794903c21.325319 8.530127 51.180765 0 59.710892-21.325319 8.530127-21.325319 0-46.915701-21.325318-59.710892l-145.012167-72.506083 656.819812-341.205097c-89.566338 110.891657-221.783313 268.699014-294.289396 349.735225-106.626593 123.686848-119.421784 221.783313-119.421784 302.819523v136.482039c0 25.590382 21.325319 46.915701 46.915701 46.915701 25.590382 0 46.915701-21.325319 46.915701-46.915701v-136.482039c0-63.975956 8.530127-136.482039 98.096465-243.108631 81.036211-93.831402 247.373695-298.55446 332.67497-400.915989l-85.301275 673.880066-204.723058-102.361529c-21.325319-8.530127-51.180765 0-59.710892 21.325319-8.530127 21.325319 0 46.915701 21.325319 59.710892l260.168886 132.216975c12.795191 8.530127 29.855446 8.530127 42.650637 0 12.795191-8.530127 21.325319-21.325319 25.590383-34.12051l115.15672-895.66338c-4.265064-17.060255-8.530127-34.12051-25.590382-42.650637z" fill="#474F5F" p-id="23527"></path></svg>
""",
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                  context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  BlendMode.srcIn),
                            ),
                            onPressed: () {
                              boop.selection();
                              handleDiglogTap(HandleDiglogTapType.kget);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: (!context.isDarkMode ? '#e2e7f1' : '#272727').$color,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _editingController,
                        maxLines: 32,
                        style: TextStyle(
                          color:
                              context.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: sourceHelpText,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void handleCleanCacheBefore(BuildContext ctx) {
    boop.warning();
    showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: const Text("将删除所有缓存, 包括视频源和一些设置"),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text(
              '我想想',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () {
              boop.selection();
              Get.back();
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Get.back();
              handleCleanCache();
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      context: ctx,
    );
  }

  void _handleCopyrightClick() async {
    boop.selection();
    _copyrightClickCount++;

    // 如果已经开启，点击一次即可关闭
    if (_showNsfwSetting) {
      EasyLoading.showSuccess("绅士模式已关闭");
      boop.success();
      await Future.delayed(Duration(milliseconds: 420));
      _showNsfwSetting = false;
      updateSetting(SettingsAllKey.showNsfwSetting, false);
      home.isNsfw = false;
      setState(() {});
      _copyrightClickCount = 0;
      return;
    }

    // 未开启状态下需要 10 次点击才能开启
    var countMap = {7: "三", 8: "二", 9: "一"};

    if (countMap.containsKey(_copyrightClickCount)) {
      String count = countMap[_copyrightClickCount]!;
      EasyLoading.showInfo("再点击$count次即可开启绅士模式");
      boop.warning();
    } else if (_copyrightClickCount >= 10) {
      EasyLoading.showSuccess("绅士模式已开启");
      boop.success();
      await Future.delayed(Duration(milliseconds: 420));
      _showNsfwSetting = true;
      updateSetting(SettingsAllKey.showNsfwSetting, true);
      home.isNsfw = true;
      setState(() {});
      _copyrightClickCount = 0;
    }
  }

  Widget leadingIcon(String icon, {double? width, double? height}) {
    return Builder(
      builder: (context) {
        return SvgPicture.string(
          icon,
          colorFilter: ColorFilter.mode(
            SettingsTheme.of(context).themeData.leadingIconsColor ??
                Colors.transparent,
            BlendMode.srcIn,
          ),
          width: width ?? 24,
          height: height ?? 24,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: WindowAppBar(
        title: Text(
          "设置",
          style: TextStyle(
            fontSize: 16,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [SizedBox.shrink()],
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(scrollbars: false),
        child: SettingsList(
          applicationType: ApplicationType.cupertino,
          lightTheme:
              SettingsThemeData(settingsListBackground: Colors.transparent),
          darkTheme:
              SettingsThemeData(settingsListBackground: Colors.transparent),
          sections: [
            SettingsSection(
              title: Text('常规设置'),
              tiles: <SettingsTile>[
                if (!autoDarkMode)
                  SettingsTile.switchTile(
                    onToggle: (value) {
                      isDark = value;
                      boop.success();
                    },
                    onPressed: (cx) {
                      isDark = !isDark;
                      boop.success();
                    },
                    initialValue: isDark,
                    // leading: Icon(Icons.settings_brightness),
                    leading: leadingIcon(r"""
<svg t="1758654524737" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="9044" width="200" height="200"><path d="M535.369874 104.082286l107.52 217.819428a54.857143 54.857143 0 0 0 41.398857 30.134857l240.566858 34.816a54.857143 54.857143 0 0 1 30.427428 93.842286l-173.933714 169.764572a54.857143 54.857143 0 0 0-15.872 48.566857l40.886857 238.884571a54.857143 54.857143 0 0 1-79.798857 57.856l-215.04-112.713143a54.857143 54.857143 0 0 0-51.2 0l-215.04 113.005715a54.857143 54.857143 0 0 1-79.798857-58.514286l41.179428-239.469714a54.857143 54.857143 0 0 0-15.945143-48.566858L16.787017 480.256A54.857143 54.857143 0 0 1 46.921874 386.413714l240.274286-34.816a54.857143 54.857143 0 0 0 41.398857-30.134857l107.812572-217.819428a54.857143 54.857143 0 0 1 98.742857 0z" fill="#404053" p-id="9045"></path></svg>
"""),
                    title: Text('暗色主题'),
                  ),
                SettingsTile.switchTile(
                  onToggle: (value) {
                    autoDarkMode = value;
                    boop.success();
                  },
                  onPressed: (cx) {
                    autoDarkMode = !autoDarkMode;
                    boop.success();
                  },
                  initialValue: autoDarkMode,
                  // leading: Icon(CupertinoIcons.moon_stars_fill),
                  leading: leadingIcon(r"""
<svg t="1758654465566" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="8017" width="200" height="200"><path d="M900.3008 597.2992a46.9504 46.9504 0 0 0-47.0016-46.8992H768a46.8992 46.8992 0 0 0-46.848 46.8992v256c0 25.9072 20.992 46.9504 46.848 46.9504h85.3504c25.9584 0 47.0016-20.992 47.0016-46.9504v-256z m-170.752-256V256a46.9504 46.9504 0 0 0-46.848-46.9504h-512A46.9504 46.9504 0 0 0 123.7504 256v298.6496a46.9504 46.9504 0 0 0 46.9504 46.9504H512a38.4 38.4 0 0 1 0 76.8h-46.8992v93.8496H512a38.4 38.4 0 0 1 0 76.8H298.6496a38.4 38.4 0 0 1 0-76.8h89.6V678.4h-217.6a123.8016 123.8016 0 0 1-123.6992-123.7504V256a123.7504 123.7504 0 0 1 123.7504-123.7504h512A123.8016 123.8016 0 0 1 806.2976 256v85.2992a38.4 38.4 0 0 1-76.8 0z m247.552 512a123.7504 123.7504 0 0 1-123.8016 123.7504H768a123.7504 123.7504 0 0 1-123.648-123.7504v-256a123.6992 123.6992 0 0 1 123.648-123.6992h85.3504a123.7504 123.7504 0 0 1 123.8016 123.6992v256z" p-id="8018"></path></svg>
""", width: 25, height: 25),
                  title: Text('跟随系统主题'),
                ),
                if (false)
                  // ignore: dead_code
                  SettingsTile.navigation(
                    leading: Icon(Icons.add_box),
                    // TODO(d1y): impl this
                    title: Text('解析线路管理'),
                    onPressed: (cx) {
                      EasyLoading.dismiss();
                      boop.selection();
                      Get.to(() => const ParseVipManagePageView());
                    },
                    value: SimpleTag(text: parseVipListWithText),
                  ),
                SettingsTile.navigation(
                  leading: Icon(
                    CupertinoIcons.cube_box,
                    size: 24,
                  ),
                  title: Text('视频源管理'),
                  onPressed: (cx) {
                    EasyLoading.dismiss();
                    boop.selection();
                    handleSourceHelp();
                  },
                  value: SimpleTag(text: mirrorLengthWithText),
                ),
                SettingsTile(
                  leading: Icon(CupertinoIcons.macwindow),
                  title: Text("播放器内核"),
                  onPressed: (cx) {
                    final RenderBox renderBox =
                        kVideoKernelBtnKey.currentContext!.findRenderObject()
                            as RenderBox;
                    final Offset btnPosition =
                        renderBox.localToGlobal(Offset.zero);
                    final Size btnSize = renderBox.size;
                    final double targetHeight = btnSize.height;
                    final Rect targetRect = Rect.fromLTWH(
                      btnPosition.dx - 6,
                      btnPosition.dy + 6,
                      btnSize.width,
                      targetHeight,
                    );
                    boop.selection();
                    showPullDownMenu(
                      context: cx,
                      items: _buildVideoKernel(),
                      position: targetRect,
                    );
                  },
                  trailing: PullDownButton(
                    key: kVideoKernelBtnKey,
                    menuOffset: 9,
                    itemBuilder: (cx) {
                      return _buildVideoKernel();
                    },
                    buttonBuilder: (cx, showMenu) {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          EasyLoading.dismiss();
                          boop.selection();
                          showMenu();
                        },
                        child: Text(_videoKernel.name),
                      );
                    },
                  ),
                ),
                SettingsTile.switchTile(
                  initialValue: _hapticFeedback,
                  onToggle: (flag) {
                    hapticFeedback = flag;
                  },
                  onPressed: (_) {
                    hapticFeedback = !hapticFeedback;
                  },
                  leading: leadingIcon(r"""
<svg t="1758088888195" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="6051" width="200" height="200"><path d="M104.732875 358.909911a83.272497 83.272497 0 0 0 0-74.579357L67.832442 210.425889A35.714533 35.714533 0 1 0 3.9184 242.318036l37.030182 73.956564a12.040648 12.040648 0 0 1 0 10.665315L14.557766 379.56585a83.272497 83.272497 0 0 0 0 74.579357l26.338917 52.625934a12.040648 12.040648 0 0 1 0 10.665315L14.557766 570.062391a83.272497 83.272497 0 0 0 0 74.579357l26.338917 52.625934a12.040648 12.040648 0 0 1 0 10.665315l-37.030182 73.956565a35.743078 35.743078 0 1 0 63.965941 31.918096l36.952333-73.930615a83.272497 83.272497 0 0 0 0-74.579357l-26.287018-52.599984a12.092547 12.092547 0 0 1 0-10.691265l26.287018-52.599985a83.272497 83.272497 0 0 0 0-74.579357l-26.338917-52.625934a12.040648 12.040648 0 0 1 0-10.665315zM631.121969 809.629761h-238.114189a35.706748 35.706748 0 1 0 0 71.413497h238.114189a35.706748 35.706748 0 0 0 0-71.413497zM1020.185398 781.889562l-36.952332-73.956565a11.88495 11.88495 0 0 1 0-10.665315l26.338916-52.625934a83.272497 83.272497 0 0 0 0-74.579357l-26.338916-52.625935a11.88495 11.88495 0 0 1 0-10.665315l26.338916-52.651884a83.272497 83.272497 0 0 0 0-74.579357l-26.338916-52.574035a11.88495 11.88495 0 0 1 0-10.665315l36.952332-73.982514a35.714533 35.714533 0 1 0-63.914041-31.892147l-36.952333 73.904665a83.428195 83.428195 0 0 0 0 74.579357l26.338917 52.625935a11.88495 11.88495 0 0 1 0 10.665315l-26.338917 52.677833a83.428195 83.428195 0 0 0 0 74.579357l26.338917 52.574035a11.936849 11.936849 0 0 1 0 10.691265l-26.338917 52.599985a83.428195 83.428195 0 0 0 0 74.579357l36.952333 73.930615a35.732698 35.732698 0 1 0 63.914041-31.944046z" p-id="6052"></path><path d="M828.858468 52.392387c-28.544639-28.544639-64.87418-41.000481-107.639239-46.709409-41.285928-5.682978-93.782114-5.682978-158.91579-5.682978h-100.477129c-65.107727 0-117.629862 0-158.863891 5.579179-42.868858 5.760827-79.016751 18.16477-107.639239 46.70941s-41.052381 64.87418-46.709409 107.639238c-5.52728 41.389727-5.52728 93.911862-5.527281 159.019589V705.156382c0 65.107727 0 117.629862 5.57918 158.915791 5.760827 42.868858 18.16477 78.964851 46.709409 107.639238s64.87418 40.948582 107.639239 46.70941c41.285928 5.52728 93.808064 5.52728 158.91579 5.52728h100.47713c65.107727 0 117.629862 0 158.91579-5.52728 42.868858-5.812726 78.964851-18.16477 107.639239-46.70941s41.000481-64.87418 46.709409-107.639238c5.52728-41.285928 5.52728-93.808064 5.52728-158.915791V318.947416c0-65.107727 0-117.629862-5.52728-158.91579-5.864626-42.868858-18.16477-78.964851-46.813208-107.639239z m-19.150858 650.143078c0 68.351436 0 116.020983-4.904488 151.987228-4.72284 34.980158-13.286232 53.482274-26.442716 66.664707s-31.710499 21.771775-66.664706 26.468665c-35.966245 4.826639-83.635792 4.904488-152.013178 4.904488h-95.235296c-68.351436 0-116.020983 0-151.961278-4.904488-34.980158-4.696891-53.482274-13.286232-66.690656-26.468665s-21.771775-31.684549-26.468666-66.612807c-4.800689-36.018144-4.904488-83.687692-4.904488-152.039128V321.568333c0-68.377385 0-116.098832 4.904488-151.961278 4.696891-35.006107 13.286232-53.482274 26.468666-66.664707s31.710499-21.771775 66.638757-26.494615c35.992195-4.800689 83.661742-4.904488 152.013177-4.904488h95.235296c68.377385 0 116.046932 0 152.013178 4.904488 34.954208 4.72284 53.430374 13.286232 66.612807 26.494615s21.771775 31.6586 26.494615 66.612808c4.852589 35.966245 4.904488 83.661742 4.904488 152.013177z" p-id="6053"></path></svg>
"""),
                  title: Text("震动反馈"),
                ),
                if (_showNsfwSetting)
                  SettingsTile.switchTile(
                    onToggle: updateNSFW,
                    onPressed: (cx) {
                      boop.selection();
                      updateNSFW(!showNSFW);
                    },
                    initialValue: home.isNsfw,
                    leading: leadingIcon(r"""
<svg t="1757687096526" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="7270" width="200" height="200"><path d="M624.298042 931.498418a80.895919 80.895919 0 0 1-58.026608 24.234642h-108.543892a80.895919 80.895919 0 0 1-58.026608-24.234642 34.133299 34.133299 0 0 0-48.469285 48.469285A150.186516 150.186516 0 0 0 457.727542 1023.999659h108.543892a150.869182 150.869182 0 0 0 106.495893-44.031956 34.133299 34.133299 0 0 0-48.469285-48.469285zM989.865677 477.866871h-76.799923L798.036535 74.411275A102.399898 102.399898 0 0 0 699.391301 0.000683h-64.170603a102.399898 102.399898 0 0 0-57.00261 17.066649l-47.103952 31.743969a34.133299 34.133299 0 0 1-37.887963 0L445.780888 17.067332a102.399898 102.399898 0 0 0-57.00261-17.066649H324.607675a102.399898 102.399898 0 0 0-98.645234 74.410592L110.933222 477.866871H34.133299a34.133299 34.133299 0 0 0 0 68.266599h955.732378a34.133299 34.133299 0 0 0 0-68.266599zM291.839708 93.184589a34.133299 34.133299 0 0 1 34.133299-24.917308h64.170603a34.133299 34.133299 0 0 1 19.114647 5.802661l47.445286 31.402635a102.399898 102.399898 0 0 0 113.322554 0l47.445286-31.402635a34.133299 34.133299 0 0 1 17.749315-5.802661h64.170603a34.133299 34.133299 0 0 1 34.133299 24.575975L803.15653 341.333675H220.842446zM181.930485 477.866871l19.45598-68.266598h621.226046l19.45598 68.266598zM887.465779 648.533367h-3.41333a91.477242 91.477242 0 0 0-89.087911-68.266598h-156.33051a91.818575 91.818575 0 0 0-88.746578 68.266598h-75.775924a91.818575 91.818575 0 0 0-88.746578-68.266598H229.034438a91.135909 91.135909 0 0 0-88.746578 68.266598H136.533197a34.133299 34.133299 0 0 0 0 68.266599v44.031956A92.501241 92.501241 0 0 0 229.034438 853.333163h115.370551a92.501241 92.501241 0 0 0 76.799923-41.301292L462.506204 750.933265a86.015914 86.015914 0 0 0 13.311987-34.133299h72.362594a81.919918 81.919918 0 0 0 13.65332 34.133299l40.959959 61.781272A91.818575 91.818575 0 0 0 679.593987 853.333163h115.370551A92.501241 92.501241 0 0 0 887.465779 760.831922V716.799966a34.133299 34.133299 0 0 0 0-68.266599z m-477.866189 50.517283a24.575975 24.575975 0 0 1-4.095996 13.65332l-40.959959 61.439939a24.917308 24.917308 0 0 1-20.138646 10.922655H229.034438a24.234642 24.234642 0 0 1-24.234643-24.234642v-88.063912a24.575975 24.575975 0 0 1 24.234643-24.234643h156.33051a24.234642 24.234642 0 0 1 24.234642 24.234643z m409.599591 61.781272a24.234642 24.234642 0 0 1-24.234643 24.234642h-115.370551a24.234642 24.234642 0 0 1-19.797313-10.581322l-41.301292-62.122605a22.86931 22.86931 0 0 1-4.095996-13.311987v-26.28264a24.234642 24.234642 0 0 1 24.234642-24.234643h156.33051a24.575975 24.575975 0 0 1 24.234643 24.234643z" fill="#0182DF" p-id="7271"></path></svg>
"""),
                    title: Text('绅士模式'),
                  ),
              ],
            ),
            SettingsSection(
              title: Text('其他设置'),
              tiles: <AbstractSettingsTile>[
                SettingsTile.navigation(
                  leading: leadingIcon(r"""
<svg t="1758656290975" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="25620" width="200" height="200"><path d="M944.725333 243.226667L532.608 6.133333c-12.368-8.176-28.853333-8.176-41.216 0L79.274667 243.226667C66.906667 247.306667 58.666667 263.664 58.666667 275.930667v470.096c0 16.352 8.24 28.618667 20.608 36.789333l412.117333 237.098667C499.637333 1024 503.76 1024 512 1024c8.245333 0 12.362667 0 20.608-4.085333l89.552-51.52a127.776 127.776 0 0 1-38.965333-71.866667l-29.984 17.098667v-380.165334l329.696-216.656v408.784l-38.976 22.229334c32.906667 4.437333 61.845333 21.376 81.882666 45.882666l18.912-10.885333c12.368-8.170667 20.608-20.437333 20.608-36.789333V275.930667c0-12.266667-8.24-28.618667-20.608-32.704z m-473.936 670.4l-329.701333-188.037334V353.594667l329.701333 179.866666v380.165334zM512 463.968L174.058667 280.016 512 87.888l304.970667 175.776L512 463.968z m184.314667 249.632h110.608v99.525333h-110.608v52.266667L581.333333 766.133333 696.314667 661.333333v52.266667z m143.370666 85.269333L954.666667 903.408 839.685333 1002.666667v-52.005334h-110.608v-99.52h110.608v-52.272z" p-id="25621"></path></svg>
"""),
                  title: Text('应用更新'),
                  onPressed: (cx) {
                    boop.selection();
                    showCupertinoModalBottomSheet(
                      context: cx,
                      builder: (_) => AutoUpdate(),
                    );
                  },
                ),
                if (false)
                  // ignore: dead_code
                  SettingsTile.navigation(
                    leading: Icon(CupertinoIcons.arrow_down_right_square_fill),
                    title: Text('视频源帮助'),
                    onPressed: (cx) {
                      boop.selection();
                      Get.to(() => const SourceHelpTable());
                    },
                  ),
                SettingsTile.navigation(
                  leading: leadingIcon(r"""
<svg t="1758539890582" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="7854" width="200" height="200"><path d="M279.779556 206.648889a57.571556 57.571556 0 1 1 57.571555 57.315555 56.888889 56.888889 0 0 1-57.571555-57.315555z m292.736 747.918222c0 0.967111-1.948444 1.948444-2.929778 1.948445l-97.578667-58.311112a3.555556 3.555556 0 0 1-0.995555-2.915555c8.803556-19.427556 97.592889-202.993778 87.836444-193.28a1243.022222 1243.022222 0 0 0-116.124444 139.861333l-26.339556 35.939556s-102.4-68.977778-134.656-111.701334c0-0.967111-0.995556-0.967111 0-1.934222 20.48-25.258667 129.777778-166.087111 129.777778-166.087111l-184.433778 110.734222h-2.929778c-8.789333-9.713778-70.257778-77.710222-88.789333-109.752889v-1.948444c17.564444-14.563556 117.091556-98.133333 117.091555-98.133333l-140.515555 49.536a3.598222 3.598222 0 0 1-2.929778-0.967111l-51.726222-97.137778a1.863111 1.863111 0 0 1 0.981333-2.915556c24.405333-4.835556 230.286222-47.573333 330.794667-116.622222 2.460444-1.692444 5.831111-1.28 7.808 0.981333l287.857778 286.535111c2.261333 1.962667 2.673778 5.319111 0.981333 7.779556a894.904889 894.904889 0 0 0-113.208889 328.291556l0.028445 0.099555z m199.111111-115.584a72.206222 72.206222 0 1 1-72.206223-71.879111 71.879111 71.879111 0 0 1 72.206223 71.879111z m55.608889-36.977778a38.855111 38.855111 0 1 1 38.926222-38.727111 39.054222 39.054222 0 0 1-39.025778 38.855111l0.113778-0.142222z m119.992888-630.371555L765.724444 353.251556c0 2.929778-0.995556 3.896889-0.995555 6.812444 41.002667 69.930667 40.021333 150.556444-19.498667 212.721778a4.736 4.736 0 0 1-6.826666 0L450.56 285.283556a4.664889 4.664889 0 0 1 0-6.798223c62.435556-59.249778 143.445333-59.249778 213.703111-19.427555 2.304 0.099556 4.622222-0.241778 6.826667-0.967111l182.471111-180.622223a66.432 66.432 0 1 1 93.667555 94.151112z" fill="#323233" p-id="7855"></path></svg>
"""),
                  title: Text('清除缓存'),
                  onPressed: handleCleanCacheBefore,
                ),
                SettingsTile.navigation(
                  leading: leadingIcon(kGithubIconSvg),
                  title: Text('开源协议'),
                  onPressed: (cx) {
                    boop.selection();
                    showCupertinoModalBottomSheet(
                      context: cx,
                      backgroundColor: Colors.transparent,
                      transitionBackgroundColor: Colors.transparent,
                      builder: (_) => SizedBox(
                        width: double.infinity,
                        height: Get.height * .72,
                        child: cupertinoLicensePage,
                      ),
                    );
                  },
                ),
                SettingsTile.navigation(
                  leading: SvgPicture.string(
                    r"""
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 256 256"><defs><linearGradient id="IconifyId19941a896f9bb1d3b1" x1="50%" x2="50%" y1="0%" y2="100%"><stop offset="0%" stop-color="#2AABEE"/><stop offset="100%" stop-color="#229ED9"/></linearGradient></defs><path fill="url(#IconifyId19941a896f9bb1d3b1)" d="M128 0C94.06 0 61.48 13.494 37.5 37.49A128.04 128.04 0 0 0 0 128c0 33.934 13.5 66.514 37.5 90.51C61.48 242.506 94.06 256 128 256s66.52-13.494 90.5-37.49c24-23.996 37.5-56.576 37.5-90.51s-13.5-66.514-37.5-90.51C194.52 13.494 161.94 0 128 0"/><path fill="#FFF" d="M57.94 126.648q55.98-24.384 74.64-32.152c35.56-14.786 42.94-17.354 47.76-17.441c1.06-.017 3.42.245 4.96 1.49c1.28 1.05 1.64 2.47 1.82 3.467c.16.996.38 3.266.2 5.038c-1.92 20.24-10.26 69.356-14.5 92.026c-1.78 9.592-5.32 12.808-8.74 13.122c-7.44.684-13.08-4.912-20.28-9.63c-11.26-7.386-17.62-11.982-28.56-19.188c-12.64-8.328-4.44-12.906 2.76-20.386c1.88-1.958 34.64-31.748 35.26-34.45c.08-.338.16-1.598-.6-2.262c-.74-.666-1.84-.438-2.64-.258c-1.14.256-19.12 12.152-54 35.686c-5.1 3.508-9.72 5.218-13.88 5.128c-4.56-.098-13.36-2.584-19.9-4.708c-8-2.606-14.38-3.984-13.82-8.41c.28-2.304 3.46-4.662 9.52-7.072"/></svg>
""",
                    width: 24,
                    height: 24,
                  ),
                  title: Text('小猫交流群'),
                  onPressed: (cx) {
                    boop.selection();
                    kTelegramGroup.openURL();
                  },
                ),
                Copyright(
                  onTap: () {
                    _handleCopyrightClick();
                  },
                ),
                BottomNavigationBarPlaceholder(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BottomNavigationBarPlaceholder extends AbstractSettingsTile {
  const BottomNavigationBarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: kDefaultAppBottomBarHeight + 24);
  }
}

class Copyright extends AbstractSettingsTile {
  const Copyright({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    var theme = SettingsTheme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.themeData.settingsSectionBackground,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          onTap?.call();
        },
        child: Builder(builder: (context) {
          var firstWriteYear = '2020';
          String currentYearString = DateTime.now().year.toString();
          var text = "© 小猫影视 ";
          text += "$firstWriteYear-$currentYearString ";
          // text += "$gitTag($gitCommit)";
          return HoverCursor(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                // textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: (Get.isDarkMode ? Colors.white : Colors.black)
                      .withValues(alpha: .42),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class SimpleTag extends StatelessWidget {
  const SimpleTag({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (context.isDarkMode ? Colors.white : Colors.black)
              .withValues(alpha: .42),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}

```

#### 📄 `lib/app\modules\home\views\source_help.dart`

```dart
import 'dart:async';
import 'dart:io';

import 'package:catmovie/app/widget/zoom.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/widget/k_error_stack.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/shared/manage.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:xi/xi.dart';

const kCatMovieSourceAPI =
    "https://cdn.jsdelivr.net/gh/waifu-project/v1@latest/x.json";

class SourceHelpTable extends StatefulWidget {
  const SourceHelpTable({super.key});

  @override
  createState() => _SourceHelpTableState();
}

class _SourceHelpTableState extends State<SourceHelpTable> {
  bool get showNSFW {
    return getSettingAsKeyIdent<bool>(SettingsAllKey.isNsfw);
  }

  final home = Get.find<HomeController>();

  Future<void> loadMirrorListApi() async {
    setState(() {
      _isLoadingFromAJAX = true;
    });
    try {
      var resp = await XHttp.dio.get(
        kCatMovieSourceAPI,
        options: $noCacheOption(),
      );
      late List<dynamic> list;
      if (resp.data is List) {
        list = resp.data;
      } else if (resp.data is Map<String, dynamic>) {
        var tmp = resp.data as Map<String, dynamic>;
        // 只要有这些 key 就都可以解析
        var keys = ["data", "list", "result", "items"];
        for (var key in keys) {
          if (tmp.containsKey(key)) {
            list = tmp[key];
            break;
          }
        }
      }
      List<AssetSourceItemJSONData> data = List.from(list).map((e) {
        return AssetSourceItemJSONData.fromJson(e as Map<String, dynamic>);
      }).toList();
      if (!showNSFW) {
        data = data.where((element) {
          return !(element.nsfw ?? true);
        }).toList();
      }
      setState(() {
        mirrors = data;
        _isLoadingFromAJAX = false;
        _loadingErrorStack = "";
      });
    } catch (e) {
      setState(() {
        _isLoadingFromAJAX = false;
        _loadingErrorStack = e.toString();
      });
    }
  }

  bool _isLoadingFromAJAX = false;

  String _loadingErrorStack = "";

  List<AssetSourceItemJSONData> mirrors = [];

  @override
  void initState() {
    super.initState();
    loadMirrorListApi();
  }

  String get playfulConfirmText {
    return "我知道了";
  }

  Future<void> handleCopyText(
      {AssetSourceItemJSONData? item, bool canCopyAll = false}) async {
    List<AssetSourceItemJSONData> actions = mirrors;
    if (!canCopyAll && item != null) actions = [item];
    var ctx = Get.context;
    if (ctx == null) return;
    await Future.forEach(actions, (AssetSourceItemJSONData element) {
      var msg = element.msg ?? "";
      Completer completer = Completer();
      if (msg.isEmpty) {
        completer.complete();
        return completer.future;
      }
      showEasyCupertinoDialog(
        content: Text(element.msg ?? ""),
        title: element.title,
        confirmText: playfulConfirmText,
        onDone: () {
          Get.back();
          completer.complete();
        },
      );
      return completer.future;
    });

    List<String> result = [];
    if (canCopyAll) {
      for (var element in actions) {
        var cx = element.url ?? "";
        if (cx.isNotEmpty) {
          result.add(cx);
        }
      }
    } else {
      var cx = actions[0].url ?? "";
      if (cx.isNotEmpty) {
        result.add(cx);
      }
    }
    if (result.isEmpty /* 内容为空 */) return;
    updateExtendMirrorList(result);
    showEasyCupertinoDialog(
      content: '已添加到本地(=^-ω-^=)! \n请到 设置->视频源管理 中手动获取配置(源)',
    );
  }

  void updateExtendMirrorList(List<String> result) {
    var old =
        getSettingAsKeyIdent<String>(SettingsAllKey.mirrorTextarea).trim();
    var lines = old.split('\n').where((element) {
      var cx = element.trim();
      return cx.isNotEmpty;
    }).toList();
    for (var element in result) {
      // 这里要去重
      if (!lines.contains(element)) {
        lines.add(element);
      }
    }
    var ext = lines.join("\n");
    updateSetting(SettingsAllKey.mirrorTextarea, ext);
  }

  String get _wrapperAjaxStatusLable {
    if (!_isLoadingFromAJAX) return "啥也没有";
    return "加载网络资源中";
  }

  /// 判断加载失败
  bool get _canLoadFail {
    return _loadingErrorStack.isNotEmpty && !_isLoadingFromAJAX;
  }

  /// 导入文件
  Future<void> handleImportFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'json',
        'txt',
      ],
    );

    if (result == null) {
      showEasyCupertinoDialog(
        content: "未选择文件 :(",
        confirmText: playfulConfirmText,
      );
      return;
    }
    List<File> files = result.paths.map((path) => File(path!)).toList();

    // ==========================
    var sourceKey = "source";
    var filenameKey = "filename";
    // ==========================

    var data = files
        .where((e) => !isBinaryAsFile(e))
        .toList()
        .map<Map<String, dynamic>>((item) {
          String filename = item.uri.pathSegments.last;
          return {
            sourceKey: item.readAsStringSync(),
            filenameKey: filename,
          };
        })
        .toList()
        .where((e) => verifyStringIsJSON(e[sourceKey] as String))
        .toList();
    if (data.isEmpty) {
      showEasyCupertinoDialog(
        content: "导入的文件格式错误 :(",
        confirmText: playfulConfirmText,
      );
      return;
    }
    var collData = <String, List<ISpiderAdapter>>{};
    for (var item in data) {
      String source = item[sourceKey] as String;
      String filename = item[filenameKey] as String;
      var easyParseData = SourceUtils.tryParseDynamic(source);
      if (easyParseData == null) continue;
      List<ISpiderAdapter> result = [];
      if (easyParseData is ISpiderAdapter) {
        result = [easyParseData];
      } else if (easyParseData is List) {
        var append = easyParseData
            .where((element) {
              return element != null;
            })
            .toList()
            .map((ele) {
              return ele as ISpiderAdapter;
            });
        result.addAll(append);
      }
      collData[filename] = result;
    }

    String easyMessage = "";
    List<ISpiderAdapter> stack = [];

    collData.forEach((k, v) async {
      int len = v.length;
      if (v.isNotEmpty) {
        stack.addAll(v);
        easyMessage += "$k中有$len个源\n";
      }
    });
    if (stack.isEmpty) {
      showEasyCupertinoDialog(
        content: "未导入源, 可能是JSON文件格式不对? :(",
        confirmText: playfulConfirmText,
      );
      return;
    } else {
      // 合并新源到现有源列表
      int oldLength = SpiderManage.extend.length;

      // 去重：移除已存在的源
      for (var newSource in stack) {
        bool exists = SpiderManage.extend
            .any((existing) => existing.meta.api == newSource.meta.api);
        if (!exists) {
          SpiderManage.extend.add(newSource);
        }
      }

      int diff = SpiderManage.extend.length - oldLength;
      if (diff > 0) {
        SpiderManage.saveToCache(SpiderManage.extend);
      }

      var diffMsg = "本次共合并$diff个源!";
      if (diff <= 0) {
        diffMsg = "本次未合并!没有新的源!";
      }
      easyMessage += '\n$diffMsg';
      showEasyCupertinoDialog(
        content: Column(
          spacing: 24,
          children: [
            const Icon(
              CupertinoIcons.hand_thumbsup,
              size: 51,
              color: CupertinoColors.systemBlue,
            ),
            Text(easyMessage),
          ],
        ),
        confirmText: "好耶ヾ(✿ﾟ▽ﾟ)ノ",
      );
    }
  }

  Widget get _errorWidget {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "// 需要科学上网",
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationColor: CupertinoColors.systemPink,
              color: CupertinoColors.systemPink,
              fontSize: 18,
            ),
          ),
          KErrorStack(
            msg: _loadingErrorStack,
          ),
        ],
      ),
    );
  }

  Widget get _mirrorEmptyStateWidget {
    return Center(
      child: Column(
        spacing: 24,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(builder: (context) {
            if (_isLoadingFromAJAX) {
              return const CircularProgressIndicator();
            }
            return const Icon(CupertinoIcons.zzz);
          }),
          Text(
            _wrapperAjaxStatusLable,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: context.isDarkMode ? Colors.white : Colors.black),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoEasyAppBar(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Zoom(child: const CupertinoNavigationBarBackButton()),
                  Text(
                    "o(-`д´- ｡)",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ),
                    child: Zoom(
                      child: CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        onPressed: handleImportFiles,
                        child: Row(
                          spacing: 3,
                          children: [
                            const Icon(
                              CupertinoIcons.arrow_down_square_fill,
                              color: CupertinoColors.white,
                            ),
                            Text(
                              "导入文件",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.copyWith(
                                    color: CupertinoColors.white,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider()
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CupertinoScrollbar(
                  child: Builder(
                    builder: (context) {
                      if (mirrors.isEmpty) {
                        if (_canLoadFail) {
                          return _errorWidget;
                        }
                        return _mirrorEmptyStateWidget;
                      }
                      return SmoothListView(
                        duration: kSmoothListViewDuration,
                        children: mirrors.map((item) {
                          return Zoom(
                            scaleRatio: .99,
                            child: CupertinoListTile(
                              title: Text(
                                item.title ?? "",
                                style: TextStyle(
                                  color: context.isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                handleCopyText(item: item);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  if (mirrors.isEmpty) {
                    if (_canLoadFail) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                        ),
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.all(12),
                          child: const Text("重新加载"),
                          onPressed: () {
                            loadMirrorListApi();
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                  return Zoom(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12,
                      ),
                      child: CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(24),
                        child: const Text("一键添加到本地"),
                        onPressed: () {
                          handleCopyText(canCopyAll: true);
                        },
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

void showEasyCupertinoDialog({
  String? title,
  dynamic content,
  VoidCallback? onDone,
  BuildContext? context,
  String? confirmText,
}) {
  Widget child = const SizedBox.shrink();
  String outputTitle = title ?? "提示";
  String outputConfrimText = confirmText ?? "确定";
  if (content is Widget) {
    child = content;
  } else if (content is String) {
    child = Text(content);
  }
  var ctx = Get.context as BuildContext;
  if (context != null) ctx = context;
  showCupertinoDialog(
    builder: (BuildContext context) => EasyShowModalWidget(
      content: child,
      title: outputTitle,
      onDone: onDone,
      confirmText: outputConfrimText,
    ),
    context: ctx,
  );
}

class EasyShowModalWidget extends StatelessWidget {
  const EasyShowModalWidget({
    super.key,
    this.onDone,
    required this.content,
    this.title = "提示",
    this.confirmText = "确定",
    this.confirmTextColor = Colors.red,
  });

  final VoidCallback? onDone;
  final String title;
  final Widget content;
  final String confirmText;
  final Color confirmTextColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Column(
        children: [
          Text(title),
        ],
      ),
      content: content,
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          child: Text(
            confirmText,
            style: TextStyle(
              color: confirmTextColor,
            ),
          ),
          onPressed: () {
            if (onDone != null) {
              onDone!();
            } else {
              Get.back();
            }
          },
        ),
      ],
    );
  }
}

```

#### 📄 `lib/app\modules\home\views\tv.dart`

```dart
import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/widget/k_body.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:tuple/tuple.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xi/xi.dart';

// 自动隐藏光标的持续时间
const kAutoHideCursorDuration = Duration(seconds: 3);

// 光标隐藏辅助类 - 使用全局变量跟踪光标状态
class CursorHelper {
  static bool _isCursorHidden = false;
  
  static void hideCursor() {
    _isCursorHidden = true;
  }
  
  static void showCursor() {
    _isCursorHidden = false;
  }
  
  static bool get isCursorHidden => _isCursorHidden;
}

// https://github.com/hoangnx2204/m3u_utils
class M3uUtils {
  static Tuple2<String, String> beautiProp(String propInput) {
    final String prop =
        propInput.replaceAll('"', '').replaceAll('\'', '').trim();
    final List<String> propSplit = prop.split('=');
    return Tuple2(propSplit.first, propSplit.sublist(1).join('='));
  }

  static Map<String, dynamic> parse(String m3u) {
    final Map<String, dynamic> output = {'items': [], 'total': 0};
    List<String> m3uSplit = m3u.split('#EXTINF:');
    final String title = m3uSplit.removeAt(0);
    final List<String> titleProps = title.split('\n').first.split(' ');
    for (String prop in titleProps) {
      if (prop.contains('=')) {
        prop = prop.replaceAll('"', '');
        prop = prop.replaceAll('\'', '');
        final data = prop.split('=');
        output.update(
          data.first.trim(),
          (_) => data.last.trim(),
          ifAbsent: () => data.last.trim(),
        );
      }
    }

    for (String part in m3uSplit) {
      final Map<String, dynamic> item = {'urls': []};
      final List<String> lines = part.split('\n');

      for (var line in lines) {
        final bool isMeta =
            RegExp(r'^[-,\d]').hasMatch(line) && line.contains(',');
        if (isMeta) {
          final List<String> lineSplit = line.split(',');
          final List<String> props = lineSplit.first.split(' ');
          final num duration = num.tryParse(props.removeAt(0)) ?? 0;
          final List<String> namedProps = props.join(" ").split('" ')
            ..removeWhere((element) => element.isEmpty);
          item.addAll({
            'name': lineSplit.lastOrNull?.trim() ?? '',
            'duration': duration,
            for (var prop in namedProps)
              beautiProp(prop).item1: beautiProp(prop).item2
          });
        } else {
          if (line.contains('://')) {
            item['urls'].add(line.trim());
          }
        }
      }
      output['items'].add(item);
    }
    output['total'] = (output['items'] as List).length;

    return output;
  }
}

int generateRandomInt(int length) {
  final random = Random();
  int min = pow(10, length - 1).toInt();
  int max = pow(10, length).toInt() - 1;
  return min + random.nextInt(max - min + 1);
}

class TabToggle extends Intent {}

// TODO(d1y): support dynamic color
final Color kActiveColor = Color(0xFF6750A4);

var scaffoldKey = GlobalKey<ScaffoldState>();

// TODO(d1y): support dynamic set wallpaper
// https://www.zichen.zone/archives/acg-api.html
final String kWallpaper = "https://www.dmoe.cc/random.php";

enum LiveSourceType {
  github,
  full,
}

/// [0] => 名称(如果类型是 Github, 则也为Repo链接)
/// [1] => 链接(如果类型是 Github, 则也为Repo-path)
/// [2] => 类型(不为Github则为全量链接)
/// [3] => 其他内容(可能包含分支等信息)
typedef LiveSourceLinkType
    = Tuple4<String, String, LiveSourceType, Map<String, String>>;

// TODO(d1y): support dynamic use live sources
final List<LiveSourceLinkType> kLiveSources = [
  // https://github.com/vbskycn/iptv
  Tuple4(
    "vbskycn/iptv",
    "tv/iptv4.m3u",
    LiveSourceType.github,
    {"branch": "master"},
  ),
  // https://github.com/kimwang1978/collect-tv-txt
  // 这个直播源好像不错🤔?
  Tuple4(
    "kimwang1978/collect-tv-txt",
    "bbxx_lite.m3u",
    LiveSourceType.github,
    {"branch": "main"},
  ),
  // https://github.com/Guovin/iptv-api
  Tuple4(
    "Guovin/iptv-api",
    "output/ipv4/result.m3u",
    LiveSourceType.github,
    {"branch": "gd"},
  ),
  // https://github.com/hujingguang/ChinaIPTV
  // TODO(d1y): 支持解析 m3u8
  // Tuple4(
  //   "hujingguang/ChinaIPTV",
  //   "cnTV_AutoUpdate.m3u8",
  //   LiveSourceType.github,
  //   {"branch": "main"},
  // ),
  // https://github.com/TianmuTNT/iptv
  Tuple4(
    "TianmuTNT/iptv",
    "iptv.m3u",
    LiveSourceType.github,
    {"branch": "main"},
  ),
  // https://github.com/mytv-android/China-TV-Live-M3U8
  Tuple4(
    "mytv-android/China-TV-Live-M3U8",
    "iptv.m3u",
    LiveSourceType.github,
    {"branch": "main"},
  ),
  // https://tv.iill.top
  // Tuple4("大葱直播(电视)", "https://tv.iill.top/m3u/Gather", LiveSourceType.full, {}),
  // Tuple4("大葱直播(网络)", "https://tv.iill.top/m3u/Live", LiveSourceType.full, {}),
  // https://iptv.hacks.tools
  // https://github.com/xfcjp/xfcjp.github.io
  // ↑↑↑↑↑↑ 这些怎么样?
];

var kVideoFits = LinkedHashMap<BoxFit, String>.from({
  BoxFit.contain: "适应",
  BoxFit.fill: "拉伸",
  BoxFit.cover: "填充",
});

class TV {
  const TV({
    required this.name,
    required this.url,
    required this.id,
    required this.logo,
    required this.groupName,
  });
  final int id;
  final String name;
  final String url;
  final String? logo;
  final String groupName;
}

class Group {
  final String name;
  final List<TV> tvs;

  Group({required this.name, this.tvs = const []});
  void addTV(String tvName, String tvUrl, {String? logo, int? id}) {
    var realId = id ?? generateRandomInt(6);
    var tv = TV(
      name: tvName,
      groupName: name,
      url: tvUrl,
      logo: logo,
      id: realId,
    );
    tvs.add(tv);
  }
}

class Groups {
  Map<String, List<TV>> tvs = {};
  void addTv(
    String groupName,
    String tvName,
    String tvUrl, {
    String? logo,
    int? id,
  }) {
    if (!tvs.containsKey(groupName)) {
      tvs[groupName] = [
        TV(
          name: tvName,
          groupName: groupName,
          url: tvUrl,
          logo: logo,
          id: id ?? generateRandomInt(6),
        )
      ];
    } else {
      tvs[groupName]!.add(
        TV(
          name: tvName,
          groupName: groupName,
          url: tvUrl,
          logo: logo,
          id: id ?? generateRandomInt(6),
        ),
      );
    }
  }

  void merge(Groups other) {
    for (var key in other.tvs.keys) {
      if (!tvs.containsKey(key)) {
        tvs[key] = other.tvs[key]!;
      } else {
        tvs[key]!.addAll(other.tvs[key]!);
      }
    }
  }

  List<String> get names => tvs.keys.toList();
}

class Loader {
  static final urlReg = RegExp(
      r'(((ht|f)tps?):\/\/)?([^!@#$%^&*?.\s-]([^!@#$%^&*?.\s]{0,63}[^!@#$%^&*?.\s])?\.)+[a-z]{2,6}\/?');

  static Groups parseM3u(String rawM3uTxt) {
    var groups = Groups();
    var map = M3uUtils.parse(rawM3uTxt);
    var items = map['items'] ?? [];
    for (var item in items) {
      int id = int.tryParse(item['tvg-id'] ?? "") ?? generateRandomInt(6);
      List<String> _url = (item['urls'] ?? [""]).cast<String>();
      if (_url.isEmpty) {
        _url.add("");
      }
      String url = _url[0];
      groups.addTv(
        item['group-title'] ?? "未分类",
        item['name'] ?? "",
        url,
        id: id,
        logo: item['tvg-logo'] ?? "",
      );
    }
    return groups;
  }

  static Groups parseTxt(String rawTxt) {
    var groups = Groups();
    var lines = rawTxt.split("\n");
    var currKey = "";
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        currKey = "";
        continue;
      }
      var cxx = line.split(",");
      if (!urlReg.hasMatch(line) && currKey.isEmpty) {
        currKey = cxx[0];
        continue;
      }
      if (currKey.isEmpty || cxx.length != 2) continue;
      groups.addTv(currKey, cxx[0], cxx[1]);
    }
    return groups;
  }
}

class LiveSource {
  final String name;
  final String url;
  final int id;
  LiveSource({
    required this.name,
    required this.url,
    required this.id,
  });
}

class LiveSourceGroups {
  /// 使用 https://ghproxy.link 加速
  final String _kGithubFastDomain = "https://ghfast.top";

  String _2url(LiveSourceLinkType cx, bool githubFast) {
    if (cx.item3 == LiveSourceType.github) {
      var map = cx.item4;
      String branch = map["branch"]!;
      var rawGithubUrl =
          "https://raw.githubusercontent.com/${cx.item1}/refs/heads/$branch/${cx.item2}";
      if (githubFast) return "$_kGithubFastDomain/$rawGithubUrl";
      return rawGithubUrl;
    }
    return cx.item2;
  }

  LiveSourceGroups.withInit() {
    for (var cx in kLiveSources) {
      add(cx.item1, _2url(cx, false));
    }
  }

  List<LiveSource> sources = [];

  Map<LiveSource, Groups> map = {};

  bool hasSource(LiveSource source) {
    return map.containsKey(source);
  }

  Groups? getGroups(LiveSource source) {
    return map[source];
  }

  void add(String name, String url) {
    sources.add(
      LiveSource(
        name: name,
        url: url,
        id: generateRandomInt(6),
      ),
    );
  }

  Future<bool> refreshSource(LiveSource source) async {
    try {
      var resp = await XHttp.dio.get<String>(
        source.url,
        // NOTE(d1y): 我想我们在这里不需要缓存!
        options: $noCacheOption(),
      );
      String body = resp.data ?? "";
      if (body.isEmpty) return false;
      late Groups groups;
      if (source.url.endsWith(".m3u")) {
        groups = Loader.parseM3u(body);
      } else {
        // TODO(d1y): support more format
        if (source.url.endsWith(".txt")) {
          groups = Loader.parseTxt(body);
        }
      }
      map[source] = groups;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

class TVUI extends StatefulWidget {
  const TVUI({super.key});

  @override
  State<TVUI> createState() => TVUIState();
}

class TVUIState extends State<TVUI>
    with AfterLayoutMixin<TVUI>, WindowListener {
  late final Player player = Player();
  late final controller = VideoController(player);
  final focusNode = FocusNode();

  Timer? _autoHideCursorTimer;

  void autoHideCursor() {
    if (!GetPlatform.isDesktop) return;
    _autoHideCursorTimer?.cancel();
    _autoHideCursorTimer = Timer(kAutoHideCursorDuration, () {
      CursorHelper.hideCursor();
    });
  }

  void hijackAutoHideCursor(dynamic _) {
    if (!GetPlatform.isDesktop) return;
    _autoHideCursorTimer?.cancel();
    CursorHelper.showCursor();
    bool hasDrawer = scaffoldKey.currentState?.hasDrawer ?? false;
    if (showVideoControls || hasDrawer) {
      return;
    }
    autoHideCursor();
  }

  final HomeController homeController = Get.find<HomeController>();

  LiveSourceGroups liveSourceGroups = LiveSourceGroups.withInit();

  LiveSource? currLiveSource;

  // TODO(d1y): 将这部分转移到 sourceGroups 里
  Groups groups = Groups();
  String currGroupName = "";
  String realURL = "";
  int currTVIdx = -1;

  BoxFit videoFit = kVideoFits.keys.first;

  bool showVideoControls = false;

  bool isMobileFullscreen = false;

  bool showPlayPauseIcon = false;
  Timer? _playPauseIconTimer;

  void _showPlayPauseIconForDuration(
      [Duration duration = const Duration(milliseconds: 800)]) {
    setState(() {
      showPlayPauseIcon = true;
    });
    _playPauseIconTimer?.cancel();
    _playPauseIconTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          showPlayPauseIcon = false;
        });
      }
    });
  }

  List<TV> get currTVS {
    if (groups.tvs.containsKey(currGroupName)) {
      return groups.tvs[currGroupName]!;
    }
    return [];
  }

  void playURL(String url, {isCloseDrawer = true, isWait = true}) async {
    if (url.isEmpty) return;
    realURL = url;
    setState(() {});
    player.open(Media(url));
    if (isCloseDrawer) {
      if (isWait) await Future.delayed(const Duration(milliseconds: 420));
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _playPauseIconTimer?.cancel();
    player.dispose().catchError((error) {
      debugPrint("player dispose error: $error");
    });
    if (GetPlatform.isDesktop) {
      CursorHelper.showCursor();
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void initState() {
    if (GetPlatform.isDesktop) {
      windowManager.addListener(this);
    }
    super.initState();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    initData();
    if (GetPlatform.isDesktop) CursorHelper.showCursor();
    focusNode.requestFocus();
  }

  @override
  void onWindowEnterFullScreen() {
    homeController.setBottomNavigationBar(false);
  }

  @override
  void onWindowLeaveFullScreen() {
    homeController.setBottomNavigationBar(true);
  }

  void initData() async {
    var isSuccess = await liveSourceGroups.refreshSource(
      liveSourceGroups.sources.first,
    );
    if (!isSuccess) return;
    selectLiveSourceGroup(liveSourceGroups.sources.first);
  }

  void resetCurrGroupState() {
    groups = Groups();
    currGroupName = "";
    realURL = "";
    currTVIdx = -1;
    setState(() {});
  }

  void selectLiveSourceGroup(LiveSource liveSource) async {
    resetCurrGroupState();
    currLiveSource = liveSource;
    setState(() {});
    late Groups realGroups;
    var _groups = liveSourceGroups.getGroups(liveSource);
    if (_groups == null) {
      var isSuccess = await liveSourceGroups.refreshSource(liveSource);
      if (!isSuccess) return;
      realGroups = liveSourceGroups.getGroups(liveSource)!;
    } else {
      realGroups = _groups;
    }
    groups = realGroups;
    setState(() {});
  }

  void toggleDrawer() {
    if (scaffoldKey.currentState?.hasDrawer ?? false) {
      scaffoldKey.currentState?.openDrawer();
    } else {
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  void _toggleMobileFullscreen() async {
    var orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      homeController.setBottomNavigationBar(false);
      isMobileFullscreen = true;
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      homeController.setBottomNavigationBar(true);
      isMobileFullscreen = false;
    }
    showVideoControls = false;
    setState(() {});
  }

  // NOTE(d1y): 在桌面端需要能够拖动窗口
  Widget _buildDesktopCTRL() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: CustomMoveWindow(
        child: SizedBox(
          width: double.infinity,
          height: 42,
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    bool isDesktop = context.mediaQuery.size.width >= 600;
    double width = currTVIdx >= 0 ? 480 : 240;
    if (context.mediaQuery.size.width < 600) {
      width = 600;
    }
    return Drawer(
      width: width,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: context.mediaQuery.padding.bottom,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.38)
                        : Colors.white.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.21),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(children: [
                        Expanded(
                          flex: isDesktop ? 6 : 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: SmoothListView.builder(
                                  duration: kSmoothListViewDuration,
                                  itemCount: groups.names.length,
                                  itemBuilder: (cx, idx) {
                                    var name = groups.names[idx];
                                    var isSelected = currGroupName == name;
                                    return Material(
                                      color: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                          vertical: 1,
                                        ).copyWith(
                                          top: idx == 0 ? 24 : 1,
                                        ),
                                        child: Zoom(
                                          child: ListTile(
                                            dense: true,
                                            selected: isSelected,
                                            selectedTileColor: kActiveColor,
                                            hoverColor: Colors.white
                                                .withValues(alpha: 0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            title: Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            onFocusChange: (flag) {
                                              currGroupName = name;
                                              currTVIdx = 0;
                                              setState(() {});
                                              if (currTVS.isNotEmpty) {
                                                playURL(currTVS[0].url);
                                              }
                                            },
                                            onTap: () {
                                              currGroupName = name;
                                              currTVIdx = 0;
                                              setState(() {});
                                              if (currTVS.isNotEmpty) {
                                                playURL(currTVS[0].url,
                                                    isCloseDrawer: false);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (!isDesktop)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                      bottom: 12, left: 12, right: 12),
                                  child: CupertinoButton.filled(
                                    sizeStyle: CupertinoButtonSize.small,
                                    color: '#3e3e3e'.$color,
                                    child: Text(
                                      "关闭",
                                      style: TextStyle(
                                        color: '#767579'.$color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      scaffoldKey.currentState?.closeDrawer();
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (currTVIdx >= 0)
                          Container(
                            width: 1,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: isDesktop ? 0.18 : .42),
                            ),
                          ),
                        if (currTVIdx >= 0)
                          Expanded(
                            flex: isDesktop ? 9 : 6,
                            child: SmoothListView.builder(
                              duration: kSmoothListViewDuration,
                              itemCount: currTVS.length,
                              itemBuilder: (cx, idx) {
                                var tv = currTVS[idx];
                                var isSelected = currTVIdx == idx;
                                return Material(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                      vertical: 3,
                                    ).copyWith(
                                      top: idx == 0 ? 24 : 1,
                                    ),
                                    child: Zoom(
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsets.only(left: 12),
                                        selected: isSelected,
                                        selectedTileColor: kActiveColor,
                                        hoverColor:
                                            Colors.white.withValues(alpha: 0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        title: Text(
                                          tv.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        leading: CachedNetworkImage(
                                          width: 48,
                                          height: double.infinity,
                                          imageUrl: tv.logo!,
                                          errorWidget: (_, __, ___) => Icon(
                                            Icons.live_tv,
                                            size: 32,
                                          ),
                                          placeholder: (_, __) => Center(
                                            child: CupertinoActivityIndicator(),
                                          ),
                                        ),
                                        onTap: () {
                                          currTVIdx = idx;
                                          setState(() {});
                                          playURL(tv.url);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSourceButton(PullDownMenuButtonBuilder button) {
    return Zoom(
      child: PullDownButton(
        buttonBuilder: button,
        itemBuilder: (cx) {
          return liveSourceGroups.sources.map((item) {
            var selected = currLiveSource == item;
            var name = item.name;
            String? subTitle;
            if (name.contains("/")) {
              var parts = name.split("/");
              name = parts[0];
              subTitle = parts[1];
            }
            return PullDownMenuItem.selectable(
              onTap: () {
                selectLiveSourceGroup(item);
              },
              selected: selected,
              title: name,
              subtitle: subTitle,
              icon: Icons.live_tv,
              iconColor: CupertinoColors.systemGreen.resolveFrom(context),
            );
          }).toList();
        },
      ),
    );
  }

  // https://pub.dev/packages/video_viewer
  Widget _buildVideoControls(VideoState state) {
    state.widget.controller.player.state.playing;
    bool isDesktop = GetPlatform.isDesktop;
    bool shouldShowTopControls = isDesktop || isMobileFullscreen;
    return Stack(
      children: [
        Center(
          child: StreamBuilder<bool>(
            stream: state.widget.controller.player.stream.buffering,
            initialData: state.widget.controller.player.state.buffering,
            builder: (_, cx) {
              var isNext = (cx.data ?? false) && !showPlayPauseIcon;
              return AnimatedOpacity(
                opacity: isNext ? 1 : 0,
                duration: const Duration(milliseconds: 210),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
        Center(
          child: AnimatedOpacity(
            opacity: showPlayPauseIcon ? 1 : 0,
            duration: const Duration(milliseconds: 210),
            child: PlayPauseAnimatedIcon(
              size: 52,
              playing: state.widget.controller.player.state.playing,
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (GetPlatform.isDesktop) {
                _autoHideCursorTimer?.cancel();
                CursorHelper.showCursor();
              }
              var next = !showVideoControls;
              showVideoControls = next;
              setState(() {});
              if (!next) {
                autoHideCursor();
              }
            },
            onDoubleTap: () async {
              if (GetPlatform.isDesktop) {
                _autoHideCursorTimer?.cancel();
                CursorHelper.showCursor();
              }
              _showPlayPauseIconForDuration();
              state.widget.controller.player.playOrPause();
              if (!showVideoControls) {
                autoHideCursor();
              }
            },
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerMove: hijackAutoHideCursor,
              onPointerHover: hijackAutoHideCursor,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
        if (shouldShowTopControls)
          AnimatedPositioned(
            right: 12,
            left: 12,
            top: showVideoControls ? 24 : -72,
            duration: const Duration(milliseconds: 210),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _buildNowLiveTV(),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                    _buildLiveSourceButton((_, showMenu) {
                      return CupertinoButton(
                        sizeStyle: CupertinoButtonSize.small,
                        color: Colors.black.withValues(alpha: .72),
                        borderRadius: BorderRadius.circular(24),
                        onPressed: showMenu,
                        child: Row(
                          spacing: 6,
                          children: [
                            Icon(CupertinoIcons.tv),
                            Text("播放源"),
                          ],
                        ),
                      );
                    }),
                    Zoom(
                      child: CupertinoButton(
                        sizeStyle: CupertinoButtonSize.small,
                        color: Colors.black.withValues(alpha: .72),
                        borderRadius: BorderRadius.circular(24),
                        child: Row(
                          spacing: 6,
                          children: [
                            Icon(CupertinoIcons.ellipsis_circle_fill),
                            Text("频道"),
                          ],
                        ),
                        onPressed: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ),
                    if (!isDesktop)
                      Zoom(
                        child: CupertinoButton(
                          sizeStyle: CupertinoButtonSize.small,
                          color: Colors.black.withValues(alpha: .72),
                          borderRadius: BorderRadius.circular(24),
                          onPressed: _toggleMobileFullscreen,
                          child: Row(
                            spacing: 4,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isMobileFullscreen 
                                ? Icons.close_fullscreen_rounded 
                                : Icons.open_in_full_rounded,
                                size: 18,
                              ),
                              if (!isMobileFullscreen) Text("全屏", style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    if (isDesktop)
                      Zoom(
                        child: CupertinoButton(
                          sizeStyle: CupertinoButtonSize.small,
                          color: Colors.black.withValues(alpha: .72),
                          borderRadius: BorderRadius.circular(24),
                          onPressed: () {
                            homeController.setBottomNavigationBar(
                              !homeController.showBottomNavigationBar,
                            );
                          },
                          child: Row(
                            spacing: 6,
                            children: [
                              Icon(Icons.open_in_full_rounded),
                              Text("半全屏"),
                            ],
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        AnimatedPositioned(
          left: 0,
          right: 0,
          bottom: showVideoControls ? 0 : -72,
          duration: const Duration(milliseconds: 210),
          child: Stack(
            children: [
              Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: .42),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.42),
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            child: Row(
                              spacing: 6,
                              children: [
                                Text("LIVE", style: TextStyle(color: Colors.white)),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    // 正常播放显示绿色, 播放失败显示红色
                                    color: state.widget.controller.player.state
                                            .playing
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 刷新
                          // IconButton(
                          //   icon: const Icon(Icons.refresh),
                          //   onPressed: () {
                          //     state.widget.controller.player.setRate(1.0);
                          //     state.widget.controller.player.setPitch(1.0);
                          //     state.widget.controller.player.setVolume(1.0);
                          //     state.widget.controller.player.setShuffle(false);
                          //     state.widget.controller.player.setPlaylistMode(
                          //       PlaylistMode.loop,
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                      Row(
                        children: [
                          // 音量
                          // https://pub.dev/packages/interactive_slider
                          // IconButton(
                          //   icon: const Icon(Icons.volume_up),
                          //   onPressed: () {
                          //     state.widget.controller.player.setVolume(
                          //       state.widget.controller.player.state.volume +
                          //           5.0,
                          //     );
                          //   },
                          // ),
                          // 上一个频道
                          // IconButton(
                          //   icon: const Icon(Icons.skip_previous),
                          //   onPressed: () {
                          //     state.widget.controller.player.previous();
                          //   },
                          // ),
                          // 播放/暂停
                          // IconButton(
                          //   icon: StreamBuilder<bool>(
                          //     stream:
                          //         state.widget.controller.player.stream.playing,
                          //     builder: (context, playing) => Icon(
                          //       (playing.data ?? false)
                          //           ? Icons.pause
                          //           : Icons.play_arrow,
                          //     ),
                          //   ),
                          //   onPressed: () {
                          //     state.widget.controller.player.playOrPause();
                          //   },
                          // ),
                          // 下一个频道
                          // IconButton(
                          //   icon: const Icon(Icons.skip_next),
                          //   onPressed: () {
                          //     state.widget.controller.player.next();
                          //   },
                          // ),
                          // 视频填充模式
                          Zoom(
                            child: IconButton(
                              icon: const Icon(
                                Icons.aspect_ratio,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                List<BoxFit> fits = kVideoFits.keys.toList();
                                int idx = fits.indexOf(videoFit);
                                idx = (idx + 1) % fits.length;
                                videoFit = fits[idx];
                                setState(() {});

                                var msg =
                                    "切换到${kVideoFits[videoFit] ?? '未知模式'}";
                                EasyLoading.showToast(
                                  msg,
                                  toastPosition:
                                      EasyLoadingToastPosition.bottom,
                                );
                              },
                            ),
                          ),
                          // 全屏
                          Zoom(
                            child: IconButton(
                              icon: Icon(
                                isMobileFullscreen 
                                  ? Icons.close_fullscreen 
                                  : Icons.fullscreen, 
                                color: Colors.white,
                              ),
                              onPressed: _toggleMobileFullscreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNowLiveTV() {
    return Builder(builder: (context) {
      if (currTVIdx < 0) {
        return const SizedBox.shrink();
      }
      var tv = currTVS[currTVIdx];
      return Container(
        decoration: BoxDecoration(
            color: '#313131'.$color.withValues(alpha: .42),
            border: Border.all(
              color: kActiveColor.withValues(alpha: .72),
              // color: '#27b2ff'.$color,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kActiveColor.withValues(alpha: .72),
                // color: '#27b2ff'.$color,
                blurRadius: 3,
                spreadRadius: 0,
                offset: Offset(0, 0),
              ),
            ]),
        clipBehavior: Clip.hardEdge,
        padding: EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 3,
        ),
        child: Row(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              width: 24,
              height: 24,
              imageUrl: tv.logo ?? "",
              errorWidget: (_, __, ___) => Icon(
                Icons.live_tv,
                size: 24,
              ),
              placeholder: (_, __) => Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
            Text(
              tv.name,
              style: TextStyle(
                color: '#27b2ff'.$color.withValues(alpha: .88),
              ),
            ),
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                // TODO(d1y): 动态获取播放状态, 正常为 green, 错误为 red
                color: '#03ff00'.$color,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBody() {
    bool isDesktop = GetPlatform.isDesktop;
    bool isSmallScreen = context.mediaQuery.size.width < 700;
    var bgWidget = Positioned.fill(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: NetworkImage(kWallpaper),
            fit: BoxFit.cover,
            opacity: .42,
          ),
        ),
      ),
    );
    return Positioned.fill(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: scaffoldKey,
        onDrawerChanged: (isOpened) {
          if (!isOpened) {
            focusNode.requestFocus();
          } else {
            if (GetPlatform.isDesktop) {
              _autoHideCursorTimer?.cancel();
              CursorHelper.showCursor();
            }
          }
        },
        drawer: _buildDrawer(),
        body: Shortcuts(
          shortcuts: {
            SingleActivator(LogicalKeyboardKey.keyS, meta: true): TabToggle()
          },
          child: Actions(
            actions: {
              TabToggle: CallbackAction<TabToggle>(
                onInvoke: (_) {
                  toggleDrawer();
                  return null;
                },
              ),
            },
            child: KeyboardListener(
              focusNode: focusNode,
              autofocus: true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: EdgeInsets.only(
                  bottom: homeController.showBottomNavigationBar && !isMobileFullscreen 
                    ? kDefaultAppBottomBarHeight 
                    : 0,
                ),
                child: Stack(
                  children: [
                    if (isDesktop && !isMobileFullscreen) bgWidget,
                    Positioned.fill(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: isMobileFullscreen ? 1 : 6,
                            child: Stack(
                              children: [
                                if (!isDesktop && !isMobileFullscreen) bgWidget,
                                Positioned.fill(
                                  child: Video(
                                    controller: controller,
                                    controls: _buildVideoControls,
                                    fit: videoFit,
                                    fill: Colors.black.withValues(alpha: .24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSmallScreen && !isMobileFullscreen)
                            Expanded(
                              flex: 9,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: '#313131'.$color,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        spacing: 12,
                                        children: [
                                          _buildLiveSourceButton(
                                              (cx, showMenu) {
                                            var name = "播放源";
                                            if (currLiveSource != null) {
                                              name = currLiveSource!.name;
                                            }
                                            return ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 142,
                                              ),
                                              child: CupertinoButton.filled(
                                                color: '#3e3e3e'.$color,
                                                sizeStyle:
                                                    CupertinoButtonSize.small,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                                onPressed: showMenu,
                                                child: Row(
                                                  spacing: 6,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        name,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: '#767579'.$color,
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      CupertinoIcons
                                                          .chevron_down,
                                                      color: '#8e8e92'.$color,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                          Zoom(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                maxWidth: 120,
                                              ),
                                              child: CupertinoButton.filled(
                                                color: '#3e3e3e'.$color,
                                                sizeStyle:
                                                    CupertinoButtonSize.medium,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Builder(builder: (context) {
                                                        var channelName =
                                                            currGroupName.isNotEmpty
                                                                ? currGroupName
                                                                : "全部频道";
                                                        if (currGroupName
                                                            .isNotEmpty) {
                                                          channelName +=
                                                              "(${currTVS.length})";
                                                        }
                                                        return Text(
                                                          channelName,
                                                          overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  '#767579'.$color),
                                                        );
                                                      }),
                                                    ),
                                                    Icon(
                                                        CupertinoIcons
                                                            .chevron_down,
                                                        color: '#8e8e92'.$color),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  toggleDrawer();
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: '#3a3a3a'.$color,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Builder(builder: (context) {
                                          var tvs = currTVS;
                                          if (tvs.isEmpty) {
                                            return Center(
                                              child: Column(
                                                spacing: 12,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .bubble_middle_bottom,
                                                    size: 66,
                                                    color: Colors.white,
                                                  ),
                                                  Text("请先选择频道 :)", style: TextStyle(color: Colors.white),),
                                                  SizedBox(
                                                    height: context.mediaQuery
                                                            .size.height *
                                                        .12,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return SmoothListView.builder(
                                            duration: kSmoothListViewDuration,
                                            itemCount: tvs.length,
                                            itemBuilder: (cx, idx) {
                                              var item = tvs[idx];
                                              var isSelected = currTVIdx == idx;
                                              return Material(
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: ListTile(
                                                    dense: true,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    onTap: () {
                                                      currTVIdx = idx;
                                                      setState(() {});
                                                      playURL(item.url);
                                                    },
                                                    selected: isSelected,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    selectedTileColor:
                                                        kActiveColor,
                                                    hoverColor: Colors.white
                                                        .withValues(
                                                            alpha: 0.42),
                                                    leading: CachedNetworkImage(
                                                      width: 80,
                                                      height: double.infinity,
                                                      imageUrl: item.logo ?? "",
                                                      errorWidget:
                                                          (_, __, ___) => Icon(
                                                        Icons.live_tv,
                                                        size: 48,
                                                      ),
                                                      placeholder: (_, __) =>
                                                          Center(
                                                        child:
                                                            CupertinoActivityIndicator(),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      item.name,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 28,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                    subtitle: Row(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: '#2a2a2a'
                                                                .$color,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical: 3,
                                                            horizontal: 12,
                                                          ),
                                                          child: Text(
                                                            item.groupName,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBody(),
        _buildDesktopCTRL(),
      ],
    );
  }
}

class PlayPauseAnimatedIcon extends StatefulWidget {
  final bool playing;
  final double size;
  final Color? color;
  const PlayPauseAnimatedIcon({
    super.key,
    required this.playing,
    this.size = 48,
    this.color,
  });

  @override
  State<PlayPauseAnimatedIcon> createState() => _PlayPauseAnimatedIconState();
}

class _PlayPauseAnimatedIconState extends State<PlayPauseAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.playing ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant PlayPauseAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing != oldWidget.playing) {
      if (widget.playing) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _controller,
      size: widget.size,
      color: widget.color,
    );
  }
}

```

##### 📂 lib/app\modules\play

###### 📂 lib/app\modules\play\bindings

#### 📄 `lib/app\modules\play\bindings\play_binding.dart`

```dart
import 'package:get/get.dart';

import '../controllers/play_controller.dart';

class PlayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlayController>(
      () => PlayController(),
    );
  }
}

```

###### 📂 lib/app\modules\play\controllers

#### 📄 `lib/app\modules\play\controllers\play_controller.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:catmovie/app/modules/play/views/chewie_view.dart';
import 'package:catmovie/app/modules/play/views/play_view.dart';
import 'package:catmovie/isar/schema/video_history_schema.dart';
import 'package:catmovie/utils/boop.dart';
// TODO: desktop_webview_window已替换为flutter_inappwebview
// import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/modules/home/views/source_help.dart';
import 'package:catmovie/app/modules/play/views/webview_view.dart';
import 'package:catmovie/shared/auto_injector.dart';
import 'package:media_kit/media_kit.dart';
import 'package:xi/xi.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:catmovie/shared/enum.dart';
// 使用新的WebView播放管理器
import 'package:catmovie/shared/webview_play_manager.dart';

// 延迟注入播放列表的时间
const kDelayExecInjectPlaylistJSCode = Duration(seconds: 1);

const _kWindowsWebviewRuntimeLink =
    "https://developer.microsoft.com/en-us/microsoft-edge/webview2";

/// 需要解析的链接集合
const _kNeedToParseDomains = [
  "www.iqiyi.com",
  "v.qq.com",
  "youku.com",
  "www.le.com",
  "mgtv.com",
  "sohu.com",
  "acfun.cn",
  "bilibili.com",
  "baofeng.com",
  "pptv.com",
  "1905.com",
  "miguvideo.com",
  'm.bilibili.com',
  'www.youku.com',
  'm.youku.com',
  'v.youku.com',
  'm.v.qq.com',
  'm.iqiyi.com',
  'm.mgtv.com',
  'www.mgtv.com',
  'm.tv.sohu.com',
  'm.1905.com',
  'm.pptv.com',
  'm.le.com'
];
const _kHttpPrefix = "http://";
const _kHttpsPrefix = "https://";

int getReversalIndex<T>(List<T> list, int realIndex) {
  if (realIndex < 0 || realIndex >= list.length) {
    return 0;
  }
  return list.length - 1 - realIndex;
}

/// 检测是否需要解析
bool checkDomainIsParse(String raw) {
  for (var i = 0; i < _kNeedToParseDomains.length; i++) {
    var curr = _kNeedToParseDomains[i];
    var p1 = _kHttpPrefix + curr;
    var p2 = _kHttpsPrefix + curr;
    var check = raw.startsWith(p1) || raw.startsWith(p2);
    if (check) return true;
  }
  return false;
}

/// 尽可能的拿到正确`url`
/// [str] 数据模板
///  => https://xx.com/1.m3u8$sdf
///  => https://xx.com/sdfsdf&sdf
String getPlayUrl(String str) {
  /// 标识符
  List<String> sybs = ["\$", "&"];

  /// 此处标识符是比对 `sdf` 的值, 如果值中有这些内容的话还是返回原值
  /// (因为有些源比较伤脑筋)
  /// (如果某个源在这种情况下还是返回了一个 `/` 那我就真无语了。。)
  List<String> idents = [".m3u8", "/"];

  for (var i = 0; i < sybs.length; i++) {
    String current = sybs[i];
    var tagOfIndex = str.lastIndexOf(current);
    if (tagOfIndex > -1) {
      var vData = str.substring(tagOfIndex, str.length);
      bool checkDataFake = idents.any((element) => vData.contains(element));
      if (!checkDataFake) return str.substring(0, tagOfIndex);
    }
  }
  return str;
}

String easyGenParseVipUrl(String raw, ParseIsarModel model) {
  String url = model.url;
  String result = '$url$raw';
  return result;
}

class PlayController extends GetxController {
  VideoDetail movieItem = Get.arguments;

  // 使用新的WebView播放管理器
  final WebViewPlayManager webViewPlayManager = WebViewPlayManager();

  HomeController home = Get.find<HomeController>();

  ISpiderAdapter get currentMovieInstance {
    var itemAs = home.currentMirrorItem;
    return itemAs;
  }

  PlayState playState = kEmptyPlayState;

  VideoHistoryIsarModel? historyContext;

  /// 是否为通用解析
  bool get bIsBaseMirrorMovie {
    return currentMovieInstance is MacCMSSpider;
  }

  /// 是否可以解析
  bool get canTryParseVip {
    var listTotal = home.parseVipList.length;
    var currIndex = home.currentBarIndex;
    var wrapperIf = listTotal >= 1 && currIndex >= 0;

    /// 通用扩展源才具备所谓的解析
    /// > 源包括 [ 自实现源, 通用扩展源 ]
    /// >> 自实现源不是继承的 `KBaseMirrorMovie`
    if (bIsBaseMirrorMovie) {
      /// NOTE: 当前实例有解析地址, 并且无边界情况
      var instance = currentMovieInstance as MacCMSSpider;
      var jiexiUrl = instance.jiexiUrl;
      bool next = jiexiUrl.isNotEmpty || wrapperIf;
      return next;
    }

    return wrapperIf;
  }

  bool _canShowPlayTips = false;

  int tabIndex = 0;

  void changeTabIndex(dynamic i) {
    tabIndex = i;
    update();
  }

  bool get canShowPlayTips {
    return _canShowPlayTips;
  }

  set canShowPlayTips(bool newVal) {
    _canShowPlayTips = newVal;
    update();
    updateSetting(SettingsAllKey.showPlayTips, newVal);
  }

  String playTips = "";

  // TODO(d1y): 不自己维护 HttpServer 实例, 而是直接使用
  // [webPlayerEmbedded] 中的 HttpServer 实例
  HttpServer? _httpServerContext;

  String url2Iframe(String realUrl, HttpServer server) {
    var type = getSettingAsKeyIdent<IWebPlayerEmbeddedType>(
      SettingsAllKey.webviewPlayType,
    );
    if (realUrl.endsWith(".m3u8")) {
      return webViewPlayManager.generatePlayerUrl(type, realUrl);
    }
    var port = server.port;
    return "http://localhost:$port/assets/iframe.html?url=$realUrl";
  }

  String decodeURLComponent(String raw) {
    return Uri.decodeComponent(raw);
  }

  String getIframeRealUrl(String url) {
    if (!url.contains("http://localhost")) return url;
    var u = Uri.parse(url);
    var realUrl = u.queryParameters["url"] ?? "";
    return decodeURLComponent(realUrl);
  }

  Future<String> injectPlaylistJSCode(
    List<VideoInfo> playlist,
    int withTop,
  ) async {
    String playlistJS = await rootBundle.loadString(
      'assets/data/playlist.js',
    );
    String appendEvalCode = "\nconst \$data = [\n";
    for (var item in playlist) {
      appendEvalCode += "{ title:`${item.name}`, url: `${item.url}` },";
    }
    appendEvalCode += "]\n";
    appendEvalCode += "setPlaylist(\$data)\n";
    var result = """
document.addEventListener('DOMContentLoaded', function() {
  const paddingTop = $withTop
  $playlistJS
  $appendEvalCode
})
""";
    return result;
  }

  void updatePlayState(int tabIndex, int index, realIndex, String epName) {
    playState = PlayState(tabIndex, index);
    changeTabIndex(tabIndex);
    if (historyContext != null) {
      updateHistory(tabIndex, realIndex, epName);
    } else {
      addHistory(tabIndex, realIndex, epName);
    }
    update();
  }

  void updateHistory(int tabIndex, int index, epName) async {
    historyContext!.ctx.pTabIndex = tabIndex;
    historyContext!.ctx.pIndex = index;
    historyContext!.ctx.pText = epName;
    isarInstance.writeTxnSync(() {
      videoHistoryAs.putSync(historyContext!);
    });
  }

  void addHistory(int tabIndex, int index, String epName) {
    var sourceContext = movieItem.getContext()!;
    var ctx = VideoHistoryContextIsardModel(
      title: movieItem.title,
      cover: movieItem.smallCoverImage,
      pTabIndex: tabIndex,
      pIndex: index,
      pText: epName,
      detailID: movieItem.id,
    );
    var history = VideoHistoryIsarModel(
      isNsfw: home.isNsfw,
      sid: sourceContext.id,
      sourceName: sourceContext.name,
      ctx: ctx,
    );
    isarInstance.writeTxnSync(() {
      videoHistoryAs.putSync(history);
      historyContext = history;
    });
  }

  Future<bool> playWithWebview(
    List<VideoInfo> playList,
    VideoInfo curr,
    String url,
    bool isUpSort,
  ) async {
    // 初始化HTTP服务器
    if (_httpServerContext == null ||
        !(await webViewPlayManager.checkRunning())) {
      _httpServerContext = await webViewPlayManager.initHttpServer(
        onMessage: (msg) {
          String value = jsonDecode(msg.value);
          // TODO: 处理消息
          debugPrint('收到消息: $value');
        },
      );
    }
    
    if (_httpServerContext == null) {
      EasyLoading.showError('无法启动HTTP服务器');
      return false;
    }

    // 转换URL为iframe格式
    url = url2Iframe(url, _httpServerContext!);
    debugPrint("webview url: $url");
    
    // 提取播放列表URL
    List<String> playlistUrls = playList.map((v) => v.url).toList();
    
    // 显示WebView窗口
    try {
      await webViewPlayManager.showWebView(
        url: url,
        title: "小猫影视 - ${curr.name}",
        context: Get.context!,
        playlist: playlistUrls,
        onUrlChanged: (newUrl) {
          var realUrl = getIframeRealUrl(newUrl);
          var currVideo = playList.firstWhereOrNull(
            (element) => element.url == realUrl,
          );
          if (currVideo != null) {
            var index = playList.indexOf(currVideo);
            var realIndex = getReversalIndex(playList, index);
            if (index >= 0) {
              updatePlayState(tabIndex, index, realIndex, currVideo.name);
            }
          }
        },
      );
      return true;
    } catch (e) {
      debugPrint('WebView播放失败: $e');
      EasyLoading.showError('播放失败: $e');
      return false;
    }
  }

  Future<String> parseIframe(String iframe) async {
    var closed = showLoading("正在解析iframe");
    List<String> result = [];
    var error = "";
    try {
      result = await home.currentMirrorItem.parseIframe(iframe);
    } catch (e) {
      error = e.toString();
      debugPrint("parseIframe error: $e");
    } finally {
      closed();
    }
    if (error.isNotEmpty) {
      EasyLoading.showError(error);
      return "";
    }
    if (result.isEmpty || result[0].isEmpty) {
      EasyLoading.showError("解析失败, 无法播放");
      return "";
    }
    debugPrint("parseIframe result: $result");
    // NOTE(d1y): 估计解析到不止一个, 该用哪一个呢!
    // 让用户选择播放哪一个?
    String url = result[0];
    return url;
  }

  Future<bool> handleTapPlayerButtom(
    VideoInfo curr,
    List<VideoInfo> playList,
    int tabIndex,
    VideoKernel videoKernel,
    Player? mediaKitPlayer,
    bool isUpSort,
    VideoDetail? context,
  ) async {
    var url = curr.url;
    url = getPlayUrl(url);

    /// NOTE: 解析条件
    /// - 通过比对 `_kNeedToParseDomains` 是否需要解析
    /// - 是否是通用扩展源(未完成!!)
    bool needParse = checkDomainIsParse(url);

    /// NOTE: 是否弹出无解析提示, 需同时具备:
    /// 1. 需要解析
    /// 2. 是否可以解析
    bool bWarnShowNotParse = needParse && !canTryParseVip;
    if (bWarnShowNotParse) {
      showEasyCupertinoDialog(
        title: '提示',
        content: '暂不支持需要解析的播放链接(无线路)',
        confirmText: '我知道了',
        onDone: () {
          Get.back();
        },
      );
      return false;
    }

    if (needParse) {
      var instance = currentMovieInstance as MacCMSSpider;

      /// !! 如果当前节点有解析接口优先使用
      /// > 反之将使用自用节点(即`解析线路管理`)
      /// !!!! TODO: 解析接口优先级暂无法控制
      if (instance.hasJiexiUrl) {
        url = instance.jiexiUrl + url;
      } else {
        var modelData = home.currentParseVipModelData;
        if (modelData != null) {
          url = easyGenParseVipUrl(url, modelData);
        }
      }
    }

    debugPrint("current play url is: $url");

    switch (videoKernel) {
      case VideoKernel.webview:
        if (GetPlatform.isDesktop) {
          return await playWithWebview(playList, curr, url, isUpSort);
        } else {
          if (GetPlatform.isAndroid) {
            if (curr.type == VideoType.iframe) {
              Get.to(
                () => const WebviewView(),
                arguments: url,
              );
            } else {
              Get.to(
                () => const ChewieView(),
                arguments: {
                  'url': url,
                  'cover': movieItem.smallCoverImage,
                },
              );
            }
          } else {
            if (curr.type == VideoType.iframe) {
              url = await parseIframe(url);
              if (url.isEmpty) return false;
            }
            url.openURL();
          }
        }
        break;
      case VideoKernel.iina:
        if (!GetPlatform.isMacOS) {
          EasyLoading.showError("该平台不支持 iina 播放");
          return false;
        }
        if (curr.type == VideoType.iframe) {
          url = await parseIframe(url);
          if (url.isEmpty) return false;
        }
        url.openToIINA();
        break;
      case VideoKernel.mediaKit:
        if (curr.type == VideoType.iframe) {
          url = await parseIframe(url);
          if (url.isEmpty) return false;
        }
        if (mediaKitPlayer == null) return false;
        var header = {
          "User-Agent":
              'Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1',
          "sec-ch-ua-platform": "macOS",
          'sec-ch-ua': '"Not=A?Brand";v="24", "Chromium";v="140"',
          'DNT': '1'
        };
        if (context != null) {
          var cx = context.getContext();
          if (cx != null) {
            // NOTE(d1y): 在一些源中, 如果不传递 Referer 则无法播放
            header['Referer'] = cx.api;
          }
        }
        mediaKitPlayer.open(Media(url, httpHeaders: header));
        break;
    }

    return true;
  }

  Future<void> loadAsset() async {
    var tips = await rootBundle.loadString('assets/data/play_tips.txt');
    playTips = tips;
    update();
  }

  void showPlayTips() {
    var ctx = Get.context;
    if (ctx == null) return;
    showCupertinoDialog(
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('免责提示'),
        content: Text(playTips),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text(
              '不再提醒',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () {
              canShowPlayTips = false;
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              '我知道了',
              style: TextStyle(color: Colors.blue),
            ),
          )
        ],
      ),
      context: ctx,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _canShowPlayTips = getSettingAsKeyIdent<bool>(SettingsAllKey.showPlayTips);
    update();
    if (canShowPlayTips) {
      Timer(const Duration(seconds: 2), () {
        showPlayTips();
        boop.warning();
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadAsset();
  }

  @override
  void onClose() {
    // 释放WebView播放管理器资源
    try {
      webViewPlayManager.dispose();
      _httpServerContext = null;
      debugPrint('WebView播放管理器已释放');
    } catch (e) {
      debugPrint('释放资源失败: $e');
    }
  }
}

```

###### 📂 lib/app\modules\play\views

#### 📄 `lib/app\modules\play\views\cast_screen.dart`

```dart
import 'dart:io';
import 'dart:ui';

import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

Map<String, DLNADevice> cacheDeviceList = {};

class CastScreen extends StatefulWidget {
  const CastScreen({
    super.key,
    required this.onTapDevice,
  });

  final ValueChanged<DLNADevice> onTapDevice;

  @override
  State<CastScreen> createState() => _CastScreenState();
}

class _CastScreenState extends State<CastScreen> {
  late DLNAManager searcher;
  late final DeviceManager m;
  Map<String, DLNADevice> deviceList = {};

  Future<void> init() async {
    m = await searcher.start(
      // Windows and Android do not support reusePort
      reusePort: !Platform.isWindows && !Platform.isAndroid,
    );
    m.devices.stream.listen((dlist) {
      dlist.forEach((key, value) {
        cacheDeviceList[key] = value;
      });
      setState(() {
        deviceList = cacheDeviceList;
      });
    });
    await _pullToRefresh();
  }

  Future _pullToRefresh() async {
    m.deviceList.forEach((key, value) {
      cacheDeviceList[key] = value;
    });
    setState(() {
      deviceList = cacheDeviceList;
    });
  }

  @override
  void initState() {
    super.initState();
    searcher = DLNAManager();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    searcher.stop();
  }

  Widget buildItem(String uri, DLNADevice device) {
    var textColor = context.isDarkMode ? Colors.white : Colors.black;
    final title = device.info.friendlyName;
    final subtitle = '$uri\r\n${device.info.deviceType}';
    final s = subtitle.toLowerCase();
    var icon = Icons.wifi;
    final support = s.contains("mediarenderer") ||
        s.contains("avtransport") ||
        s.contains('mediaserver');
    if (!support) {
      icon = Icons.router;
    }
    final card = Zoom(
      scaleRatio: .98,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: context.isDarkMode
                ? Colors.grey
                : Colors.grey.withValues(alpha: .12),
            width: .42,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: .24,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, bottom: 30),
              child: CircleAvatar(child: Icon(icon)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            subtitle,
                            softWrap: false,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onTapDevice(device);
        },
        child: card,
      ),
    );
  }

  Widget _body() {
    if (deviceList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final List<Widget> dlist = [];
    deviceList.forEach((uri, devi) {
      dlist.add(buildItem(uri, devi));
    });

    return SmoothListView(
      duration: kSmoothListViewDuration,
      children: dlist,
    );
  }

  @override
  Widget build(BuildContext context) {
    var textColor = context.isDarkMode ? Colors.white : Colors.black;
    return SizedBox(
      width: double.infinity,
      height: Get.height * .66,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: SizedBox.shrink(),
          ),
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        Icon(CupertinoIcons.tv_fill, color: textColor),
                        Text(
                          "投屏设备",
                          style: TextStyle(
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Expanded(child: _body()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

```

#### 📄 `lib/app\modules\play\views\chewie_view.dart`

```dart
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'custom_play.dart';

class ChewieView extends StatefulWidget {
  const ChewieView({super.key});

  @override
  createState() => _ChewieViewState();
}

class _ChewieViewState extends State<ChewieView> {
  late ChewieController chewieController;
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    initFetchUrl();
    init();
  }

  @override
  void dispose() {
    if (!chewieController.isFullScreen) {
      videoPlayerController.dispose();
      chewieController.dispose();
      super.dispose();
    }
  }

  bool initFetchUrl() {
    var args = Get.arguments ?? {};
    String url = args['url'] ?? "";
    // NOTE: 如果都没有播放地址就直接跳回到上一个页面
    if (url.isEmpty) {
      Get.back();
    }
    String cover = args['cover'] ?? "";
    if (url.isEmpty) {
      return false;
    }
    setState(() {
      playUrl = url;
      cover = cover;
    });
    return true;
  }

  String playUrl = "";
  String cover = "";

  void init() {
    setState(() {
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(playUrl),
      );
    });
    var controller = ChewieController(
      optionsTranslation: OptionsTranslation(
        playbackSpeedButtonText: '播放速度',
        cancelButtonText: "取消",
        subtitlesButtonText: "字幕",
      ),
      videoPlayerController: videoPlayerController,
      autoInitialize: true,
      autoPlay: true,
      fullScreenByDefault: true,
      showControls: true,
      showControlsOnInitialize: true,
      allowFullScreen: true,
      allowedScreenSleep: false,
      useRootNavigator: false,
      customControls: const CustomCupertinoControls(
        backgroundColor: Colors.black38,
        iconColor: Colors.white,
      ),
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      errorBuilder: errorBuilder,
      placeholder: placeholderWidget,
      additionalOptions: (_) => [
        OptionItem(
          onTap: (cx) async {
            Get.back();
            if (playUrl.isEmpty) return;
            await FlutterClipboard.copy(playUrl);
            if (GetPlatform.isAndroid) {
              Get.snackbar(
                "提示",
                "已复制到剪贴板",
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(
                  milliseconds: 1200,
                ),
              );
            }
          },
          iconData: CupertinoIcons.share,
          title: "复制视频链接",
        ),
      ],
    );

    bool isInit = true;

    setState(() {
      chewieController = controller;
      chewieController.addListener(() {
        var isFullScreen = chewieController.isFullScreen;
        if (isFullScreen && isInit) {
          chewieController.exitFullScreen();
          setState(() {
            isInit = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // XXX: `chewie` 实际上只支持 `Android` | `iOS`
      body: SafeArea(
        child: Chewie(
          controller: chewieController,
        ),
      ),
    );
  }

  Widget errorBuilder(BuildContext context, String errorMessage) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withValues(alpha: .42),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ).copyWith(
            bottom: 12,
          ),
          width: Get.width * .72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.bolt_slash_fill,
                    size: 88,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    "播放失败",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .72),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                color: CupertinoColors.systemRed,
                child: const Text("退出播放"),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get placeholderWidget {
    return Center(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black12,
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: Stack(
            children: [
              if (cover.isNotEmpty)
                Image.network(
                  cover,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

```

#### 📄 `lib/app\modules\play\views\custom_play.dart`

```dart
// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:chewie/src/animated_play_pause.dart';
import 'package:chewie/src/center_play_button.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/cupertino/cupertino_progress_bar.dart';
import 'package:chewie/src/cupertino/widgets/cupertino_options_dialog.dart';
import 'package:chewie/src/helpers/utils.dart';
import 'package:chewie/src/models/option_item.dart';
import 'package:chewie/src/models/subtitle_model.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CustomCupertinoControls extends StatefulWidget {
  const CustomCupertinoControls({
    required this.backgroundColor,
    required this.iconColor,
    this.showPlayButton = true,
    super.key,
  });

  final Color backgroundColor;
  final Color iconColor;
  final bool showPlayButton;

  @override
  State<StatefulWidget> createState() {
    return _CustomCupertinoControlsState();
  }
}

class _CustomCupertinoControlsState extends State<CustomCupertinoControls>
    with SingleTickerProviderStateMixin {
  late PlayerNotifier notifier;
  late VideoPlayerValue _latestValue;
  double? _latestVolume;
  Timer? _hideTimer;
  final marginSize = 5.0;
  Timer? _expandCollapseTimer;
  Timer? _initTimer;
  bool _dragging = false;
  Duration? _subtitlesPosition;
  bool _subtitleOn = false;
  Timer? _bufferingDisplayTimer;
  bool _displayBufferingIndicator = false;

  late VideoPlayerController controller;

  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    notifier = Provider.of<PlayerNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder!(
              context,
              chewieController.videoPlayerController.value.errorDescription!,
            )
          : const Center(
              child: Icon(
                CupertinoIcons.exclamationmark_circle,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    final backgroundColor = widget.backgroundColor;
    final iconColor = widget.iconColor;
    final orientation = MediaQuery.of(context).orientation;
    final barHeight = orientation == Orientation.portrait ? 30.0 : 47.0;
    final buttonPadding = orientation == Orientation.portrait ? 16.0 : 24.0;

    return MouseRegion(
      onHover: (_) => _cancelAndRestartTimer(),
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: notifier.hideStuff,
          child: Stack(
            children: [
              if (_displayBufferingIndicator)
                const Center(
                  child: CupertinoActivityIndicator(),
                )
              else
                _buildHitArea(),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildTopBar(
                    backgroundColor,
                    iconColor,
                    barHeight,
                    buttonPadding,
                  ),
                  const Spacer(),
                  if (_subtitleOn)
                    Transform.translate(
                      offset: Offset(
                        0.0,
                        notifier.hideStuff ? barHeight * 0.8 : 0.0,
                      ),
                      child: _buildSubtitles(chewieController.subtitle!),
                    ),
                  _buildBottomBar(backgroundColor, iconColor, barHeight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _expandCollapseTimer?.cancel();
    _initTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  GestureDetector _buildOptionsButton(
    Color iconColor,
    double barHeight,
  ) {
    final options = <OptionItem>[];

    if (chewieController.additionalOptions != null &&
        chewieController.additionalOptions!(context).isNotEmpty) {
      options.addAll(chewieController.additionalOptions!(context));
    }

    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        if (chewieController.optionsBuilder != null) {
          await chewieController.optionsBuilder!(context, options);
        } else {
          await showCupertinoModalPopup<OptionItem>(
            context: context,
            semanticsDismissible: true,
            useRootNavigator: chewieController.useRootNavigator,
            builder: (context) => CupertinoOptionsDialog(
              options: options,
              cancelButtonText:
                  chewieController.optionsTranslation?.cancelButtonText,
            ),
          );
          if (_latestValue.isPlaying) {
            _startHideTimer();
          }
        }
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 4.0, right: 8.0),
        margin: const EdgeInsets.only(right: 6.0),
        child: Icon(
          Icons.more_vert,
          color: iconColor,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildSubtitles(Subtitles subtitles) {
    if (!_subtitleOn) {
      return Container();
    }
    if (_subtitlesPosition == null) {
      return Container();
    }
    final currentSubtitle = subtitles.getByPosition(_subtitlesPosition!);
    if (currentSubtitle.isEmpty) {
      return Container();
    }

    if (chewieController.subtitleBuilder != null) {
      return chewieController.subtitleBuilder!(
        context,
        currentSubtitle.first!.text,
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: marginSize, right: marginSize),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0x96000000),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          currentSubtitle.first!.text.toString(),
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return SafeArea(
      bottom: chewieController.isFullScreen,
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.all(marginSize),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 10.0,
                sigmaY: 10.0,
              ),
              child: Container(
                height: barHeight,
                color: backgroundColor,
                child: chewieController.isLive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _buildPlayPause(controller, iconColor, barHeight),
                          _buildLive(iconColor),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          _buildSkipBack(iconColor, barHeight),
                          _buildPlayPause(controller, iconColor, barHeight),
                          _buildSkipForward(iconColor, barHeight),
                          _buildPosition(iconColor),
                          _buildProgressBar(),
                          _buildRemaining(iconColor),
                          _buildSubtitleToggle(iconColor, barHeight),
                          if (chewieController.allowPlaybackSpeedChanging)
                            _buildSpeedButton(controller, iconColor, barHeight),
                          if (chewieController.additionalOptions != null &&
                              chewieController
                                  .additionalOptions!(context).isNotEmpty)
                            _buildOptionsButton(iconColor, barHeight),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLive(Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        'LIVE',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  GestureDetector _buildExpandButton(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    List<IconData> actions = [
      CupertinoIcons.back,
    ];
    if (!chewieController.isFullScreen) {
      actions.add(CupertinoIcons.fullscreen);
    }
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0),
            child: Row(
              children: actions
                  .map((item) => Builder(builder: (context) {
                        bool isPopPage =
                            actions.length >= 2 && item == actions[0];
                        var action =
                            isPopPage ? () => Navigator.pop(context) : null;
                        return GestureDetector(
                          onTap: action,
                          child: Container(
                            height: barHeight,
                            padding: EdgeInsets.only(
                              left: buttonPadding,
                              right: buttonPadding,
                            ),
                            color: backgroundColor,
                            child: Center(
                              child: Icon(
                                item,
                                color: iconColor,
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      }))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHitArea() {
    final bool isFinished = _latestValue.position >= _latestValue.duration;
    final bool showPlayButton =
        widget.showPlayButton && !_latestValue.isPlaying && !_dragging;

    return GestureDetector(
      onTap: _latestValue.isPlaying
          ? _cancelAndRestartTimer
          : () {
              _hideTimer?.cancel();

              setState(() {
                notifier.hideStuff = false;
              });
            },
      child: CenterPlayButton(
        backgroundColor: widget.backgroundColor,
        iconColor: widget.iconColor,
        isFinished: isFinished,
        isPlaying: controller.value.isPlaying,
        show: showPlayButton,
        onPressed: _playPause,
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0),
            child: Container(
              color: backgroundColor,
              child: Container(
                height: barHeight,
                padding: EdgeInsets.only(
                  left: buttonPadding,
                  right: buttonPadding,
                ),
                child: Icon(
                  _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: iconColor,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: AnimatedPlayPause(
          color: widget.iconColor,
          playing: controller.value.isPlaying,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color iconColor) {
    final position = _latestValue.duration - _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        '-${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  Widget _buildSubtitleToggle(Color iconColor, double barHeight) {
    //if don't have subtitle hiden button
    if (chewieController.subtitle?.isEmpty ?? true) {
      return Container();
    }
    return GestureDetector(
      onTap: _subtitleToggle,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(right: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
          Icons.subtitles,
          color: _subtitleOn ? iconColor : Colors.grey[700],
          size: 16.0,
        ),
      ),
    );
  }

  void _subtitleToggle() {
    setState(() {
      _subtitleOn = !_subtitleOn;
    });
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipBack,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
          CupertinoIcons.gobackward_15,
          color: iconColor,
          size: 18.0,
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipForward,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          CupertinoIcons.goforward_15,
          color: iconColor,
          size: 18.0,
        ),
      ),
    );
  }

  GestureDetector _buildSpeedButton(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        final chosenSpeed = await showCupertinoModalPopup<double>(
          context: context,
          semanticsDismissible: true,
          useRootNavigator: chewieController.useRootNavigator,
          builder: (context) => _PlaybackSpeedDialog(
            speeds: chewieController.playbackSpeeds,
            selected: _latestValue.playbackSpeed,
          ),
        );

        if (chosenSpeed != null) {
          controller.setPlaybackSpeed(chosenSpeed);
        }

        if (_latestValue.isPlaying) {
          _startHideTimer();
        }
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewY(0.0)
            ..rotateX(math.pi)
            ..rotateZ(math.pi * 0.8),
          child: Icon(
            Icons.speed,
            color: iconColor,
            size: 18.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return Container(
      height: barHeight,
      margin: EdgeInsets.only(
        top: marginSize,
        right: marginSize,
        left: marginSize,
      ),
      child: Row(
        children: <Widget>[
          if (chewieController.allowFullScreen)
            _buildExpandButton(
              backgroundColor,
              iconColor,
              barHeight,
              buttonPadding,
            ),
          const Spacer(),
          if (chewieController.allowMuting)
            _buildMuteButton(
              controller,
              backgroundColor,
              iconColor,
              barHeight,
              buttonPadding,
            ),
        ],
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();

    setState(() {
      notifier.hideStuff = false;

      _startHideTimer();
    });
  }

  Future<void> _initialize() async {
    _subtitleOn = chewieController.subtitle?.isNotEmpty ?? false;
    controller.addListener(_updateState);

    _updateState();

    if (controller.value.isPlaying || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          notifier.hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    if (!controller.value.isInitialized) {
      // debugPrint("初始化失败, 无法播放");
      return;
    }
    setState(() {
      notifier.hideStuff = true;

      chewieController.toggleFullScreen();
      _expandCollapseTimer = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: CupertinoVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: chewieController.cupertinoProgressColors ??
              ChewieProgressColors(
                playedColor: const Color.fromARGB(
                  120,
                  255,
                  255,
                  255,
                ),
                handleColor: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ),
                bufferedColor: const Color.fromARGB(
                  60,
                  255,
                  255,
                  255,
                ),
                backgroundColor: const Color.fromARGB(
                  20,
                  255,
                  255,
                  255,
                ),
              ),
        ),
      ),
    );
  }

  void _playPause() {
    final isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        notifier.hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration.zero);
          }
          controller.play();
        }
      }
    });
  }

  void _skipBack() {
    _cancelAndRestartTimer();
    final beginning = Duration.zero.inMilliseconds;
    final skip =
        (_latestValue.position - const Duration(seconds: 15)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.max(skip, beginning)));
  }

  void _skipForward() {
    _cancelAndRestartTimer();
    final end = _latestValue.duration.inMilliseconds;
    final skip =
        (_latestValue.position + const Duration(seconds: 15)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.min(skip, end)));
  }

  void _startHideTimer() {
    final hideControlsTimer = chewieController.hideControlsTimer.isNegative
        ? ChewieController.defaultHideControlsTimer
        : chewieController.hideControlsTimer;
    _hideTimer = Timer(hideControlsTimer, () {
      setState(() {
        notifier.hideStuff = true;
      });
    });
  }

  void _bufferingTimerTimeout() {
    _displayBufferingIndicator = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _updateState() {
    if (!mounted) return;

    // display the progress bar indicator only after the buffering delay if it has been set
    if (chewieController.progressIndicatorDelay != null) {
      if (controller.value.isBuffering) {
        _bufferingDisplayTimer ??= Timer(
          chewieController.progressIndicatorDelay!,
          _bufferingTimerTimeout,
        );
      } else {
        _bufferingDisplayTimer?.cancel();
        _bufferingDisplayTimer = null;
        _displayBufferingIndicator = false;
      }
    } else {
      _displayBufferingIndicator = controller.value.isBuffering;
    }

    setState(() {
      _latestValue = controller.value;
      _subtitlesPosition = controller.value.position;
    });
  }
}

class _PlaybackSpeedDialog extends StatelessWidget {
  const _PlaybackSpeedDialog({
    required List<double> speeds,
    required double selected,
  })  : _speeds = speeds,
        _selected = selected;

  final List<double> _speeds;
  final double _selected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoActionSheet(
      actions: _speeds
          .map(
            (e) => CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop(e);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (e == _selected)
                    Icon(Icons.check, size: 20.0, color: selectedColor),
                  Text(e.toString()),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

```

#### 📄 `lib/app\modules\play\views\play_view.dart`

```dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:aurora/aurora.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/modules/home/views/tv.dart';
import 'package:catmovie/app/modules/play/controllers/play_controller.dart';
import 'package:catmovie/app/modules/play/views/cast_screen.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:catmovie/isar/schema/video_history_schema.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:catmovie/shared/env.dart';
import 'package:catmovie/utils/boop.dart';
import 'package:clipboard/clipboard.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/modules/home/controllers/home_controller.dart';
import 'package:catmovie/app/modules/home/views/parse_vip_manage.dart';
import 'package:catmovie/app/widget/window_appbar.dart';
import 'package:catmovie/widget/simple_html/flutter_html.dart';
import 'package:isar_community/isar.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:simple/x.dart';
import 'package:tuple/tuple.dart';
import 'package:xi/xi.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as path;

enum PlaylistSort { down, up }

List<String> kDescEmptyList = [
  "暂无简介",
  "无简介",
];

extension PlaylistSortExt on PlaylistSort {
  String get name {
    if (this == PlaylistSort.down) return "正序";
    return "倒序";
  }

  IconData get icon {
    if (this == PlaylistSort.down) return CupertinoIcons.sort_down;
    return CupertinoIcons.sort_up;
  }
}

class PlayState extends Equatable {
  const PlayState(this.tabIndex, this.index);
  final int tabIndex;
  final int index;

  @override
  List<Object?> get props => [tabIndex, index];
}

PlayState kEmptyPlayState = const PlayState(-1, -1);

class PlayView extends StatefulWidget {
  const PlayView({super.key});

  @override
  State<PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> with AfterLayoutMixin {
  final PlayController play = Get.find<PlayController>();
  final HomeController home = Get.find<HomeController>();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  Player? player;
  late VideoController controller;

  VideoKernel videoKernel = VideoKernel.webview;

  bool get canBeShowParseVipButton {
    return home.parseVipList.isNotEmpty;
  }

  double get screenHeight {
    var ret = MediaQuery.of(context).size.height;
    return ret;
  }

  List<Videos> playlist = [];

  final double offsetSize = 12;
  final coverHeightScale = .48;

  PlaylistSort playlistSort = PlaylistSort.down;

  BoxFit mediaKitFit = kVideoFits.keys.first;

  bool get playlistIsEmpty {
    bool allEmpty = playlist.length == 1 && playlist[0].datas.isEmpty;
    return playlist.isEmpty || allEmpty;
  }

  int get playListGridCount {
    double screenWidth = context.mediaQuery.size.width;
    double minCardWidth = 188;
    double spacing = 5;
    int count = ((screenWidth + spacing) / (minCardWidth + spacing)).floor();
    count = count.clamp(1, 6);
    return count;
  }

  int get _bufferSize {
    var mb = 125; // 125MB
    if (GetPlatform.isDesktop) {
      mb = 1024; // 1GB
    }
    return mb * 1024 * 1024;
  }

  Future<String> _tempPath() async {
    var dir = await getTemporaryDirectory();
    return path.join(dir.path, "video_cache");
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    focusNode.requestFocus();
    videoKernel = getSettingAsKeyIdent<VideoKernel>(SettingsAllKey.videoKernel);
    if (videoKernel.isMediaKit) {
      MPVLogLevel logLevel = MPVLogLevel.info;
      if (CMEnv.isDebug) {
        debugPrint("video log level is debug");
        logLevel = MPVLogLevel.debug;
      }
      player = Player(
        configuration: PlayerConfiguration(
          bufferSize: _bufferSize,
          osc: false,
          logLevel: logLevel,
        ),
      );
      controller = VideoController(player!);
      if (player!.platform is NativePlayer) {
        var pp = player!.platform as NativePlayer;
        var temp = await _tempPath();
        debugPrint("video cache dir is $temp");
        pp.setProperty("demuxer-cache-dir", temp);
      }
    }
    playlist = play.movieItem.videos;
    loadHistory();
    if (mounted) setState(() {});
  }

  void loadHistory() {
    var item = play.movieItem;
    var cx = item.getContext()!;
    play.historyContext = videoHistoryAs
        .filter()
        .isNsfwEqualTo(home.isNsfw)
        .sidEqualTo(cx.id)
        .ctx((cx) {
      return cx.detailIDEqualTo(item.id);
    }).findFirstSync();
    if (play.historyContext == null) return;
    var tabIndex = play.historyContext!.ctx.pTabIndex;
    var index = play.historyContext!.ctx.pIndex;
    debugPrint("load history t: $tabIndex, i: $index");
    if (tabIndex <= -1 || index <= -1) return;
    if (videoKernel.isMediaKit) {
      handlePlay(tabIndex, index);
    }
  }

  @override
  void dispose() {
    player?.dispose().catchError((error) {
      debugPrint("player dispose error: $error");
    });
    super.dispose();
  }

  // NOTE(d1y): 是否显示封面(只在未播放过时展示)
  var showVideoCover = true;

  Future<void> handlePlay(int tabIndex, int index) async {
    var realPlaylist = playlist[tabIndex].datas;
    var curr = playlist[tabIndex].datas[index];
    var isUpSort = playlistSort == PlaylistSort.up;
    var isOk = await play.handleTapPlayerButtom(
      curr,
      realPlaylist,
      tabIndex,
      videoKernel,
      player,
      isUpSort,
      play.movieItem,
    );
    if (!isOk) {
      boop.error();
      return;
    }
    boop.success();
    var realIndex = index;
    if (isUpSort) {
      realIndex = getReversalIndex(realPlaylist, index);
    }
    showVideoCover = false;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 124), () {
      play.updatePlayState(tabIndex, index, realIndex, curr.name);
    });
  }

  void handleSortPlaylist() {
    if (playlistSort == PlaylistSort.down) {
      playlistSort = PlaylistSort.up;
    } else {
      playlistSort = PlaylistSort.down;
    }
    playlist.asMap().forEach((idx, item) {
      playlist[idx].datas = item.datas.reversed.toList();
    });
    var idx = getReversalIndex(playlist[0].datas, play.playState.index);
    // play.playState = kEmptyPlayState;
    play.playState = PlayState(play.playState.tabIndex, idx);
    play.update();
    EasyLoading.showToast(
      "切换到${playlistSort.name}",
      toastPosition: EasyLoadingToastPosition.bottom,
    );
    setState(() {});
  }

  Widget _buildCoverImage() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: play.movieItem.smallCoverImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child:
                          Container(color: Colors.white.withValues(alpha: .12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: play.movieItem.smallCoverImage,
              fit: BoxFit.contain,
            ),
          )
        ],
      ),
    );
  }

  double lastScrollOffset = 0;

  void showMediaKitPlaylist() {
    var fw = context.mediaQuery.size.width;
    var w = fw * .32;
    if (w >= 320) w = 320;
    var list = playlist[play.tabIndex].datas;
    Get.dialog(
      useSafeArea: false,
      MediaKitPlaylist(
        width: w,
        list: list,
        sort: playlistSort,
        index: play.playState.index,
        restoreOffset: lastScrollOffset,
        onScroll: (offset) {
          lastScrollOffset = offset;
        },
        onTap: (index) {
          handlePlay(play.tabIndex, index);
          Get.back();
        },
        onSortTap: () {
          handleSortPlaylist();
        },
      ),
    );
  }

  Widget _buildMediaKit() {
    Widget boxFitView = MaterialDesktopCustomButton(
      onPressed: () {
        List<BoxFit> fits = kVideoFits.keys.toList();
        int idx = fits.indexOf(mediaKitFit);
        idx = (idx + 1) % fits.length;
        mediaKitFit = fits[idx];
        setState(() {});
        var msg = "切换到${kVideoFits[mediaKitFit] ?? '未知模式'}";
        EasyLoading.showToast(
          msg,
          toastPosition: EasyLoadingToastPosition.bottom,
        );
      },
      icon: Opacity(
        opacity: .88,
        child: const Icon(Icons.aspect_ratio, size: 23),
      ),
    );
    Widget videoView = Video(
      fit: mediaKitFit,
      fill: Colors.black,
      controller: controller,
      onEnterFullscreen: () async {
        await defaultEnterNativeFullscreen();
        // workaround: 在 iOS 上全屏之后播放会暂停
        if (GetPlatform.isIOS) {
          Future.delayed(const Duration(milliseconds: 88), () {
            controller.player.pause();
            controller.player.play();
          });
        }
      },
      onExitFullscreen: () async {
        await defaultExitNativeFullscreen();
        if (GetPlatform.isIOS) {
          SystemChrome.setPreferredOrientations(
            [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
          );
        }
      },
    );
    var topButtonBar = [
      CupertinoNavigationBarBackButton(
        color: Colors.white,
        previousPageTitle: "返回",
      ),
      const Spacer(),
      MaterialDesktopCustomButton(
        onPressed: showMediaKitPlaylist,
        icon: Row(
          spacing: 6,
          children: [
            Icon(CupertinoIcons.ellipsis_circle_fill),
            Text("播放列表", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    ];
    if (GetPlatform.isDesktop) {
      var bottomButtonBar = [
        MaterialDesktopSkipPreviousButton(),
        MaterialDesktopPlayOrPauseButton(),
        MaterialDesktopSkipNextButton(),
        MaterialDesktopVolumeButton(),
        MaterialDesktopPositionIndicator(),
        Spacer(),
        boxFitView,
        MaterialDesktopFullscreenButton(),
      ];
      videoView = MaterialDesktopVideoControlsTheme(
        normal: MaterialDesktopVideoControlsThemeData(
          bottomButtonBar: bottomButtonBar,
        ),
        fullscreen: MaterialDesktopVideoControlsThemeData(
          topButtonBar: topButtonBar,
          bottomButtonBar: bottomButtonBar,
          // TODO(d1y): add playlist shortcut
          keyboardShortcuts: {
            // // cmd-s
            // const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            //     showMediaKitPlaylist,
            // // cmd-t
            // const SingleActivator(LogicalKeyboardKey.keyT, control: true):
            //     showMediaKitPlaylist,
          },
        ),
        child: videoView,
      );
    } else {
      var bottomButtonBar = [
        MaterialPositionIndicator(),
        Spacer(),
        boxFitView,
        MaterialFullscreenButton(),
      ];
      videoView = MaterialVideoControlsTheme(
        normal: MaterialVideoControlsThemeData(
          seekBarMargin: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          bottomButtonBarMargin: EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 12,
          ),
          seekGesture: true,
          seekOnDoubleTap: true,
          speedUpOnLongPress: true,
          bottomButtonBar: bottomButtonBar,
        ),
        fullscreen: MaterialVideoControlsThemeData(
          seekBarMargin: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          bottomButtonBarMargin: EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 12,
          ),
          seekGesture: true,
          seekOnDoubleTap: true,
          speedUpOnLongPress: true,
          topButtonBar: topButtonBar,
          bottomButtonBar: bottomButtonBar,
        ),
        child: videoView,
      );
    }
    return Positioned.fill(child: videoView);
  }

  Widget _oneView(bool isLargeScreen) {
    return Stack(
      children: [
        if (videoKernel.isMediaKit)
          _buildMediaKit()
        else
          Positioned.fill(child: _buildCoverImage()),
      ],
    );
  }

  Widget _twoView(bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWithDesc,
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ).copyWith(top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "播放列表",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!playlistIsEmpty &&
                      playlist[play.tabIndex].datas.length >= 2)
                    IconButton(
                      tooltip: playlistSort.name,
                      onPressed: handleSortPlaylist,
                      icon: Transform.rotate(
                        angle: playlistSort == PlaylistSort.up ? math.pi : 0,
                        child: SvgPicture.string(
                          r"""
                      <svg t="1758649652025" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="8688" width="200" height="200"><path d="M301.696 164.544c-27.776 0-51.2 24-54.464 55.808l-0.384 7.424v452.416L175.872 598.528c-20.48-23.488-53.312-24.64-75.008-2.624-21.696 22.016-24.832 59.712-7.104 86.08l4.544 5.888 164.608 189.632c1.536 1.792 3.2 3.456 4.928 5.056l-4.928-5.12a53.312 53.312 0 0 0 29.12 17.536l1.536 0.32a30.592 30.592 0 0 0 3.456 0.448l1.472 0.128 1.344 0.064 1.92 0.064 1.792-0.128h1.408c0.512 0 0.96 0 1.472-0.128L301.696 896a50.88 50.88 0 0 0 38.784-18.56l164.672-189.568 4.48-5.888c17.728-26.368 14.656-64-7.04-86.08-21.76-22.016-54.592-20.864-75.072 2.624l-70.912 81.664v-452.48c0-34.816-24.576-63.168-54.912-63.168z m365.76 601.92l-5.76 0.32a49.792 49.792 0 0 0-42.88 52.736 49.408 49.408 0 0 0 48.64 47.232h243.84l5.696-0.384c25.6-3.136 44.416-26.24 42.88-52.736a49.408 49.408 0 0 0-48.64-47.168h-243.84zM588.544 465.856a49.792 49.792 0 0 0-42.88 52.736 49.408 49.408 0 0 0 48.64 47.232h316.992l5.696-0.384c25.6-3.136 44.416-26.24 42.88-52.736a49.408 49.408 0 0 0-48.64-47.232H594.368l-5.76 0.384zM521.152 164.544l-5.76 0.384a49.792 49.792 0 0 0-42.88 52.736 49.408 49.408 0 0 0 48.64 47.232h390.144l5.696-0.384c25.6-3.136 44.416-26.24 42.88-52.736a49.408 49.408 0 0 0-48.64-47.232H521.216z" fill="#333333" p-id="8689"></path></svg>
                      """,
                          width: 21,
                          height: 21,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            context.isDarkMode ? Colors.white : Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  if (playlist.length > 1)
                    IconButton(
                      tooltip: "播放源",
                      onPressed: () {
                        showCupertinoModalBottomSheet(
                            context: context,
                            builder: (_) {
                              return SizedBox(
                                width: double.infinity,
                                height: context.mediaQuery.size.height * .72,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    spacing: 12,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            spacing: 6,
                                            children: [
                                              SvgPicture.string(
                                                r"""
<svg t="1758651075092" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="19790" width="200" height="200"><path d="M384.31 162.15c8.82 0 16 7.18 16 16v224c0 8.82-7.18 16-16 16h-224c-8.82 0-16-7.18-16-16v-224c0-8.82 7.18-16 16-16h224m0-64h-224c-44.18 0-80 35.82-80 80v224c0 44.18 35.82 80 80 80h224c44.18 0 80-35.82 80-80v-224c0-44.18-35.82-80-80-80zM383.79 607.69c8.82 0 16 7.18 16 16v224c0 8.82-7.18 16-16 16h-224c-8.82 0-16-7.18-16-16v-224c0-8.82 7.18-16 16-16h224m0-64h-224c-44.18 0-80 35.82-80 80v224c0 44.18 35.82 80 80 80h224c44.18 0 80-35.82 80-80v-224c0-44.18-35.82-80-80-80zM860.1 608c8.82 0 16 7.18 16 16v224c0 8.82-7.18 16-16 16h-224c-8.82 0-16-7.18-16-16V624c0-8.82 7.18-16 16-16h224m0-64h-224c-44.18 0-80 35.82-80 80v224c0 44.18 35.82 80 80 80h224c44.18 0 80-35.82 80-80V624c0-44.18-35.82-80-80-80zM912.21 113H585.22c-17.67 0-32 14.33-32 32s14.33 32 32 32h326.99c17.67 0 32-14.33 32-32s-14.32-32-32-32zM912.21 404H585.22c-17.67 0-32 14.33-32 32s14.33 32 32 32h326.99c17.67 0 32-14.33 32-32s-14.32-32-32-32zM910.18 258.5H583.19c-17.67 0-32 14.33-32 32s14.33 32 32 32h326.99c17.67 0 32-14.33 32-32s-14.32-32-32-32z" p-id="19791"></path><path d="M717 822.41c-12.14 0-24.3-4.19-34.02-12.6l-0.85-0.73-41.6-41.39c-12.53-12.46-12.58-32.73-0.12-45.25 12.46-12.53 32.73-12.58 45.25-0.12l31.88 31.72 90.49-79.12c13.3-11.63 33.52-10.28 45.15 3.03 11.63 13.3 10.28 33.52-3.03 45.15l-98.91 86.48c-9.7 8.54-21.96 12.83-34.24 12.83z m-7.89-61c-0.02 0.02-0.04 0.03-0.05 0.05l0.05-0.05z" p-id="19792"></path></svg>
""",
                                                width: 24,
                                                height: 24,
                                                colorFilter: ColorFilter.mode(
                                                  context.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              Text(
                                                "选择播放源",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon: Icon(Icons.close),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                          child: SizedBox(
                                        width: double.infinity,
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            alignment: WrapAlignment.start,
                                            spacing: 9,
                                            runSpacing: 12,
                                            children: playlist
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int index = entry.key;
                                              var item = entry.value;
                                              var isCurr =
                                                  index == play.tabIndex;
                                              return HoverCursor(
                                                child: CupertinoButton.filled(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 6,
                                                    horizontal: 12,
                                                  ),
                                                  color: isCurr
                                                      ? (context.isDarkMode
                                                              ? "#f1f1f1"
                                                              : "#0f0f0f")
                                                          .$color
                                                      : (context.isDarkMode
                                                              ? '#272727'
                                                              : "#e2e8f0")
                                                          .$color,
                                                  child: Text(item.title,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: isCurr
                                                            ? (context
                                                                    .isDarkMode
                                                                ? Colors.black
                                                                : Colors.white)
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .labelLarge!
                                                                .color,
                                                      )),
                                                  onPressed: () {
                                                    if (index !=
                                                        play.tabIndex) {
                                                      play.changeTabIndex(
                                                          index);
                                                      boop.selection();
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon: SvgPicture.string(
                        r"""
<svg t="1758648418740" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="5908" width="200" height="200"><path d="M487 347.43C487 424.512 424.512 487 347.43 487H237.57C160.488 487 98 424.512 98 347.43V237.57C98 160.488 160.488 98 237.57 98h109.86C424.512 98 487 160.488 487 237.57v109.86zM487 786.43C487 863.512 424.512 926 347.43 926H237.57C160.488 926 98 863.512 98 786.43V676.57C98 599.488 160.488 537 237.57 537h109.86C424.512 537 487 599.488 487 676.57v109.86zM926 347.43C926 424.512 863.512 487 786.43 487H676.57C599.488 487 537 424.512 537 347.43V237.57C537 160.488 599.488 98 676.57 98h109.86C863.512 98 926 160.488 926 237.57v109.86zM730.7 533.6c-107.861 0-195.3 87.439-195.3 195.3s87.439 195.3 195.3 195.3S926 836.761 926 728.9s-87.439-195.3-195.3-195.3z m0 309.734c-63.2 0-114.435-51.234-114.435-114.434S667.5 614.465 730.7 614.465 845.134 665.7 845.134 728.9 793.9 843.334 730.7 843.334z" fill="#666666" p-id="5909"></path></svg>
""",
                        width: 21,
                        height: 21,
                        colorFilter: ColorFilter.mode(
                          (context.isDarkMode ? Colors.white : Colors.black),
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.cover,
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: offsetSize),
            child: Builder(builder: (context) {
              if (playlistIsEmpty) {
                return emptyPlaylistWidget;
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLargeScreen ? 2 : playListGridCount,
                  mainAxisExtent: 48,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: playlist[play.tabIndex].datas.length,
                itemBuilder: (context, index) {
                  var curr = playlist[play.tabIndex].datas[index];
                  String playUrl = curr.url;
                  var isCast =
                      curr.type == VideoType.m3u8 || curr.type == VideoType.mp4;
                  return Builder(builder: (menuContext) {
                    return PullDownButton(
                      itemBuilder: (context) {
                        return [
                          PullDownMenuItem(
                            onTap: () async {
                              await FlutterClipboard.copy(
                                playUrl,
                              );
                              EasyLoading.showToast(
                                "复制链接成功",
                                maskType: EasyLoadingMaskType.none,
                              );
                            },
                            title: '复制链接',
                            icon: CupertinoIcons.doc_on_clipboard,
                          ),
                          if (isCast)
                            PullDownMenuItem(
                              title: '投屏播放',
                              subtitle: '仅支持局域网里的设备',
                              onTap: () {
                                showCupertinoModalBottomSheet(
                                    context: context,
                                    backgroundColor: (context.isDarkMode
                                            ? Colors.black
                                            : Colors.white)
                                        .withValues(alpha: .88),
                                    builder: (
                                      BuildContext context,
                                    ) {
                                      return CastScreen(
                                        onTapDevice: (cx) async {
                                          try {
                                            await cx.setUrl(playUrl);
                                            await cx.play();
                                            // TODO: 支持控制远程DLNA设备
                                            if (!context.mounted) {
                                              return;
                                            }
                                            Navigator.of(context).pop();
                                            EasyLoading.showToast(
                                              "即将开始投屏播放",
                                              toastPosition:
                                                  EasyLoadingToastPosition
                                                      .bottom,
                                              duration:
                                                  Duration(milliseconds: 240),
                                            );
                                          } catch (e) {
                                            EasyLoading.showToast(
                                              "播放失败",
                                              toastPosition:
                                                  EasyLoadingToastPosition
                                                      .bottom,
                                              duration:
                                                  Duration(milliseconds: 240),
                                            );
                                          }
                                        },
                                      );
                                    });
                              },
                              icon: CupertinoIcons.tv,
                            ),
                        ];
                      },
                      buttonBuilder: (context, showMenu) {
                        return HoverCursor(
                          child: CupertinoButton.filled(
                            color: (context.isDarkMode ? '#222222' : '#f4e8f8')
                                .$color,
                            padding: EdgeInsets.zero,
                            child: Builder(builder: (cx) {
                              var text = curr.name;
                              var ps = play.playState;
                              var lastedPlay = ps.tabIndex == play.tabIndex &&
                                  index == ps.index;
                              var textColor = context.isDarkMode
                                  ? Colors.white
                                  : Colors.black;
                              if (lastedPlay) {
                                text += "\n(上次播放)";
                                textColor = Color(0xFF6750A4);
                              }
                              return Text(
                                text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                            onPressed: () {
                              boop.selection();
                              handlePlay(
                                play.tabIndex,
                                index,
                              );
                            },
                            onLongPress: () {
                              showMenu();
                              boop.success();
                            },
                          ),
                        );
                      },
                    );
                  });
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _realBodyView() {
    var width = context.mediaQuery.size.width;
    var height = context.mediaQuery.size.height;
    var isPad = (width / height) > 1.38; // 宽高比大于 1.38 认为是 Pad(大屏)
    var isLargeScreen = width > 720 && isPad;
    var one = isLargeScreen ? 16 : 9;
    var two = isLargeScreen ? 9 : 16;
    var sep = Container(
      width: 1,
      height: double.infinity,
      color: (context.isDarkMode ? Colors.white : Colors.black)
          .withValues(alpha: .12),
    );
    Widget body = Flex(
      direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
      children: [
        Expanded(flex: one, child: _oneView(isLargeScreen)),
        if (isLargeScreen) sep,
        Expanded(flex: two, child: _twoView(isLargeScreen)),
      ],
    );
    double topbarHeight = GetPlatform.isDesktop ? 56 : 48;
    return Stack(
      children: [
        Positioned.fill(
          top: topbarHeight,
          child: body,
        ),
        Positioned(
          left: 0,
          top: 0,
          width: width,
          height: topbarHeight,
          child: MoveWindow(
            child: Container(
              decoration: BoxDecoration(
                color: (context.isDarkMode ? '#141218' : "#fef7ff").$color,
              ),
              padding: EdgeInsets.only(
                top: GetPlatform.isDesktop ? 12 : 0,
                left: 6,
                right: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12)
                                .copyWith(right: 24),
                            child: Row(
                              spacing: 6,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.back, size: 24),
                                Expanded(
                                  child: Text(
                                    play.movieItem.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            color: context.isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 120,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              var ps = play.playState;
                              if (ps == kEmptyPlayState) {
                                EasyLoading.dismiss();
                                Get.back();
                                return;
                              }
                              var curr = playlist[ps.tabIndex].datas[ps.index];
                              EasyLoading.dismiss();
                              Get.back(
                                result: Tuple2(play.playState, curr.name),
                              );
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: SizedBox.expand(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canBeShowParseVipButton)
                    Zoom(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                        ),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.collections, size: 16),
                            SizedBox(width: 6.0),
                            Text(
                              "解析源",
                              style: TextStyle(fontSize: 14.0),
                            ),
                            SizedBox(width: 2.0),
                          ],
                        ),
                        onPressed: () {
                          Get.to(() => const ParseVipManagePageView());
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayController>(
      builder: (play) => Scaffold(
        body: Shortcuts(
          shortcuts: {
            // esc
            const SingleActivator(LogicalKeyboardKey.escape):
                const DismissIntent(),
            // backspace
            const SingleActivator(LogicalKeyboardKey.backspace):
                const DismissIntent(),
            // enter
            const SingleActivator(LogicalKeyboardKey.enter):
                const ActivateIntent(),
            // ctrl-p
            const SingleActivator(LogicalKeyboardKey.keyP, control: true):
                ScrollUpIntent(),
            // ctrl-n
            const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                ScrollDownIntent(),
            // // cmd-shift-[
            // const SingleActivator(LogicalKeyboardKey.braceLeft /* { */,
            //     meta: true, shift: true): TabSwitchLeftIntent(),
            // // cmd-shift-]
            // const SingleActivator(LogicalKeyboardKey.braceRight /* } */,
            //     meta: true, shift: true): TabSwitchRightIntent(),
          },
          child: Actions(
            actions: {
              DismissIntent: CallbackAction<DismissIntent>(
                onInvoke: (_) {
                  Get.back();
                  return null;
                },
              ),
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  // 如果只有一集的话, 敲击 `enter` 键自动播放
                  var cx = playlist[play.tabIndex].datas;
                  if (cx.length == 1) {
                    handlePlay(play.tabIndex, 0);
                  }
                  return null;
                },
              ),
              ScrollUpIntent: CallbackAction<ScrollUpIntent>(
                onInvoke: (_) {
                  scrollUp(scrollController);
                  return null;
                },
              ),
              ScrollDownIntent: CallbackAction<ScrollDownIntent>(
                onInvoke: (_) {
                  scrollDown(scrollController);
                  return null;
                },
              ),
            },
            child: Focus(
              autofocus: true,
              focusNode: focusNode,
              child: SafeArea(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Aurora(
                          size: 88,
                          colors: [
                            Color(0xffc2e59c).withValues(alpha: .24),
                            Color(0xff64b3f4).withValues(alpha: .24)
                          ],
                          blur: 88,
                        ),
                      ),
                      Positioned.fill(child: _realBodyView()),
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

  final Style _textOncelineStyle = Style(
    textOverflow: TextOverflow.ellipsis,
    maxLines: 1,
    fontSize: const FontSize(
      12,
    ),
    height: 24,
  );

  final List<String> _textIncludeTags = [
    "p",
    "span",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "pre",
  ];

  Map<String, Style> get _shortDescStyleWithHTML {
    Map<String, Style> map = {};
    for (var ele in _textIncludeTags) {
      map[ele] = _textOncelineStyle;
    }
    return map;
  }

  Widget _buildWithShortDesc(String desc) {
    String humanDesc = desc.trim();
    if (humanDesc.isEmpty) return const SizedBox.shrink();
    // NOTE: 不是标签,实际上不是很严谨!!
    if (humanDesc[0] != '<') {
      return Text(
        humanDesc,
        maxLines: 1,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 12,
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
      );
    }
    return Html(
      data: humanDesc,
      style: _shortDescStyleWithHTML,
    );
  }

  Widget get _buildWithDesc {
    var desc = play.movieItem.desc;
    if (desc.isEmpty ||
        kDescEmptyList.contains(desc) ||
        desc == play.movieItem.title) {
      return SizedBox.shrink();
      // return Container(
      //   margin: const EdgeInsets.symmetric(
      //     horizontal: 12,
      //     vertical: 9,
      //   ),
      //   child: const Text('暂无简介~'),
      // );
    }
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        dense: true,
        initiallyExpanded: false,
        subtitle: _buildWithShortDesc(desc),
        title: Text(
          '查看简介',
          style: TextStyle(
            fontSize: 18,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * .33,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Html(
                  data: desc,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get emptyPlaylistWidget {
    return Center(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.tornado,
            size: 42,
            color: CupertinoColors.systemBlue,
          ),
          Text(
            "暂无播放链接",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class MediaKitPlaylist extends StatefulWidget {
  const MediaKitPlaylist({
    super.key,
    required this.width,
    required this.list,
    required this.sort,
    required this.index,
    required this.restoreOffset,
    this.onTap,
    this.onSortTap,
    this.onScroll,
    this.lateShowDuration = const Duration(milliseconds: 240),
  });

  final double width;
  final List<VideoInfo> list;
  final PlaylistSort sort;
  final int index;
  final ValueChanged<int>? onTap;
  final VoidCallback? onSortTap;
  final ValueChanged<double>? onScroll;
  final double restoreOffset;
  final Duration lateShowDuration;

  @override
  State<MediaKitPlaylist> createState() => _MediaKitPlaylistState();
}

class _MediaKitPlaylistState extends State<MediaKitPlaylist>
    with AfterLayoutMixin {
  PlaylistSort sort = PlaylistSort.down;
  List<VideoInfo> list = [];
  int index = -1;

  ScrollController controller = ScrollController();

  bool show = false;

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    show = true;
    sort = widget.sort;
    index = widget.index;
    list = widget.list;
    setState(() {});
    controller.addListener(() {
      var offset = controller.offset;
      widget.onScroll?.call(offset);
    });
    restoreScrollPosition();
  }

  void restoreScrollPosition() {
    var offset = widget.restoreOffset;
    controller.jumpTo(offset);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleSortPlaylist() {
    sort = sort == PlaylistSort.down ? PlaylistSort.up : PlaylistSort.down;
    list = list.reversed.toList();
    index = getReversalIndex(list, index);
    if (mounted) setState(() {});
    widget.onSortTap?.call();
  }

  Widget _buildRealBody() {
    return Container(
      width: widget.width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .72),
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            if (GetPlatform.isDesktop)
              Positioned.fill(
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withValues(alpha: 0.38)
                            : Colors.white.withValues(alpha: 0.24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.21),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 3,
                          children: [
                            Text(
                              "选集",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            Opacity(
                              opacity: .68,
                              child: Text(
                                "(共${list.length}集)",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: handleSortPlaylist,
                          icon: Row(
                            spacing: 6,
                            children: [
                              Icon(sort.icon, color: Colors.white),
                              Text(
                                sort.name,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 6,
                      ),
                      children: list.map((item) {
                        var currIndex = list.indexOf(item);
                        var isCurr = currIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 9,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Colors.grey.withValues(
                                    alpha: isCurr ? .88 : .24,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              dense: true,
                              mouseCursor: SystemMouseCursors.click,
                              selected: isCurr,
                              selectedTileColor: kActiveColor,
                              hoverColor: Colors.white.withValues(alpha: 0.24),
                              title: Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                index = currIndex;
                                if (mounted) setState(() {});
                                widget.onTap?.call(currIndex);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: GestureDetector(
              onTap: () {
                show = false;
                if (mounted) setState(() {});
                Get.back();
              },
            ),
          ),
        ),
        AnimatedPositioned(
          top: 0,
          right: show ? 0 : -widget.width,
          bottom: 0,
          duration: widget.lateShowDuration,
          curve: Curves.easeInOut,
          width: widget.width,
          child: _buildRealBody(),
        ),
      ],
    );
  }
}

```

#### 📄 `lib/app\modules\play\views\webview_view.dart`

```dart
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:catmovie/utils/screen_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewView extends StatefulWidget {
  const WebviewView({super.key});

  @override
  createState() => _WebviewViewState();
}

class _WebviewViewState extends State<WebviewView> {
  final url = Get.arguments;

  late final WebViewController controller;

  @override
  void initState() {
    WakelockPlus.enable();
    execScreenDirction(ScreenDirction.x);
    init();
    super.initState();
  }

  void init() {
    // https://github.com/flutter/packages/blob/853c6773177a32be019c55c2ff45c9908196dadd/packages/webview_flutter/webview_flutter/example/lib/simple_example.dart#L27C5-L48C40
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(url));
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
    execScreenDirction(ScreenDirction.y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black38,
        ),
        margin: const EdgeInsets.symmetric(vertical: 9),
        child: IconButton(
          icon: const BackButtonIcon(),
          color: Colors.white,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: WebViewWidget(controller: controller),
    );
  }
}

```

#### 📂 lib/app\routes

#### 📄 `lib/app\routes\app_pages.dart`

```dart
// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import 'package:catmovie/app/modules/home/bindings/home_binding.dart';
import 'package:catmovie/app/modules/home/views/home_view.dart';
import 'package:catmovie/app/modules/play/bindings/play_binding.dart';
import 'package:catmovie/app/modules/play/views/play_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PLAY,
      page: () => const PlayView(),
      binding: PlayBinding(),
    ),
  ];
}

```

#### 📄 `lib/app\routes\app_routes.dart`

```dart
// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const PLAY = _Paths.PLAY;
}

abstract class _Paths {
  static const HOME = '/home';
  static const PLAY = '/play';
}

```

#### 📂 lib/app\shared

#### 📄 `lib/app\shared\bus.dart`

```dart
import 'package:event_bus/event_bus.dart';

@Deprecated("不建议使用")
class SettingEvent {
  bool nsfw;

  SettingEvent({this.nsfw = false});
}

class ShowNsfwSettingEvent {
  bool flag;
  ShowNsfwSettingEvent(this.flag);
}

EventBus $bus = EventBus();

```

#### 📄 `lib/app\shared\mirror_category.dart`

```dart
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/isar/schema/category_schema.dart';
import 'package:catmovie/utils/once.dart';
import 'package:flutter/widgets.dart';
import 'package:isar_community/isar.dart';
import 'package:xi/xi.dart';

/// NOTE(d1y): 获取分类最大尝试次数(3次)
const kMirrorCategoryTryCountMax = 3;

class CacheWithCategory {
  CacheWithCategory._internal();
  factory CacheWithCategory() => _instance;
  static final CacheWithCategory _instance = CacheWithCategory._internal();

  Map<String, List<SourceSpiderQueryCategory>> stacks = {};

  final Map<String, SourceSpiderQueryCategory> _lastUsedMap = {};

  void setLastUsed(String key, SourceSpiderQueryCategory category) {
    _lastUsedMap[key] = category;
  }

  SourceSpiderQueryCategory? getLastUsed(String key) {
    return _lastUsedMap[key];
  }

  void cleanupLastUsed() {
    _lastUsedMap.clear();
  }

  //===============================
  /// 标记一个最大数📌的请求分类池
  Map<String, int> fetchCounter = {};
  bool fetchCountAlreadyMax(String key) {
    int count = fetchCounter[key] ?? 0;
    return count >= kMirrorCategoryTryCountMax;
  }

  void fetchCountPP(String key) {
    int count = fetchCounter[key] ?? 0;
    fetchCounter[key] = count + 1;
  }

  void cleanCounter() {
    fetchCounter = {};
  }
  //===============================

  VoidCallback? _init;

  void init() async {
    _init ??= once(() {
      debugPrint("init sources category(OK)");
      var list = categoryAs.where().findAllSync();
      for (var item in list) {
        stacks[item.sid] = item.toRealCategories();
      }
    });
    _init!();
  }

  void clean() {
    stacks = {};
    isarInstance.writeTxnSync(() {
      categoryAs.clearSync();
    });
  }

  void put(String key, List<SourceSpiderQueryCategory> data) {
    stacks[key] = data;
    isarInstance.writeTxnSync(() {
      var categories = data.map((item) {
        var category = Category();
        category.id = item.id;
        category.name = item.name;
        return category;
      }).toList();
      var model = categoryAs.filter().sidEqualTo(key).findFirstSync();
      if (model == null) {
        categoryAs.putSync(CategoryIsarModel(sid: key, categories: categories));
        return;
      }
      model.categories = categories;
      categoryAs.putSync(model);
    });
  }

  List<SourceSpiderQueryCategory> data(String key) {
    return stacks[key] ?? [];
  }

  bool has(String key) {
    var stack = stacks[key];
    if (stack == null) return false;
    return stack.isNotEmpty;
  }
}

```

#### 📄 `lib/app\shared\mirror_status_stack.dart`

```dart
import 'package:catmovie/shared/manage.dart';
import 'package:xi/xi.dart';

class MirrorStatusStack {
  MirrorStatusStack._internal();
  factory MirrorStatusStack() => _instance;
  static final MirrorStatusStack _instance = MirrorStatusStack._internal();

  final Map<String, bool> _stacks = {};

  Map<String, bool> get getStacks => _stacks;

  final List<ISpiderAdapter> _datas = SpiderManage.extend;

  bool? getStack(String stack) {
    return _stacks[stack];
  }

  void pushStatus(String sourceKey, bool status, {bool canSave = false}) {
    _stacks[sourceKey] = status;
    if (canSave) {
      flash();
    }
  }

  void flash() {
    List<SourceMeta> data = _datas.map((e) {
      bool status = e.meta.status;
      String id = e.meta.id;
      bool? bStatus = getStack(id);
      if (bStatus != null) {
        status = bStatus;
      }
      return SourceMeta(
        id: id,
        name: e.meta.name,
        type: e.meta.type,
        api: e.meta.api,
        logo: e.meta.logo,
        desc: e.meta.desc,
        isNsfw: e.meta.isNsfw,
        status: status,
        extra: e.meta.extra,
      );
    }).toList();
    SpiderManage.mergeSpiderFromMeta(data);
  }

  void clean() {
    _stacks.clear();
  }
}

```

#### 📂 lib/app\widget

#### 📄 `lib/app\widget\helper.dart`

```dart
// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget kErrorImage = ClipRRect(
  borderRadius: BorderRadius.circular(8.0),
  child: const DecoratedBox(
    decoration: BoxDecoration(
      color: CupertinoColors.black,
    ),
    child: Center(
      child: Column(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 42,
            color: Colors.white,
          ),
          Text("加载失败", style: TextStyle(color: Colors.white))
        ],
      ),
    ),
  ),
);

```

#### 📄 `lib/app\widget\k_body.dart`

```dart
import 'package:flutter/cupertino.dart';

/// [BottomAppBar] 中定义的常量, 没有暴露出来
/// ```dart
/// final BottomAppBarThemeData defaults = isMaterial3
/// ? _BottomAppBarDefaultsM3(context) // 这里默认是80(_BottomAppBarDefaultsM3)
/// : _BottomAppBarDefaultsM2(context);
/// ```
double kDefaultAppBottomBarHeight = 80;

class KBody extends StatelessWidget {
  final Widget child;

  final EdgeInsets? padding;
  const KBody({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsetsGeometry.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child),
          SizedBox(height: kDefaultAppBottomBarHeight),
        ],
      ),
    );
  }
}

```

#### 📄 `lib/app\widget\k_empty_mirror.dart`

```dart
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

```

#### 📄 `lib/app\widget\k_error_stack.dart`

```dart
import 'package:flutter/material.dart';

/// 错误栈最大行数
const int kErrorStackMaxLine = 12;

/// 错误栈展示 `widget`
class KErrorStack extends StatelessWidget {
  const KErrorStack({
    super.key,
    this.msg = "",
    this.maxLine,
  });

  final String msg;

  final int? maxLine;

  int get _maxLine => maxLine ?? kErrorStackMaxLine;

  @override
  Widget build(BuildContext context) {
    if (msg.isEmpty) return const SizedBox.shrink();
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          msg,
          maxLines: _maxLine,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

```

#### 📄 `lib/app\widget\k_pagination.dart`

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum KPaginationActionButtonDirection {
  /// 左边
  l,

  /// 右边
  r
}

typedef KPaginationActionCallback = void Function(
  KPaginationActionButtonDirection type,
);

typedef KPaginationInputChangeCallback = void Function(
  int value,
);

class KPaginationActionButton extends StatelessWidget {
  KPaginationActionButton({
    super.key,
    this.direction = KPaginationActionButtonDirection.l,
    this.disable = false,
    required this.onTap,
  });

  final KPaginationActionButtonDirection direction;
  final bool disable;
  final VoidCallback onTap;

  bool get isLeft => direction == KPaginationActionButtonDirection.l;

  String get directionStr {
    if (isLeft) return "上一页";
    return "下一页";
  }

  double get boxOpacity {
    return disable ? .3 : 1;
  }

  final List<IconData> _icons = [
    CupertinoIcons.left_chevron,
    CupertinoIcons.right_chevron
  ];

  @override
  Widget build(BuildContext context) {
    Color borderColor = context.isDarkMode ? Colors.white : Colors.black;
    Color textColor = context.isDarkMode ? Colors.white : Colors.black;

    List<Widget> children = [
      Text(
        directionStr,
        style: TextStyle(
          fontSize: 9,
          color: textColor,
        ),
      ),
    ];
    int index = 0;
    if (!isLeft) index = 1;
    IconData icon = _icons[index];
    children.insert(
      index,
      Icon(
        icon,
        size: 15,
      ),
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: boxOpacity,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class KPagination extends StatefulWidget {
  final KPaginationActionCallback onActionTap;

  final bool turnL;

  final bool turnR;

  final VoidCallback onJumpTap;

  final TextEditingController textEditingController;

  const KPagination({
    super.key,
    required this.onActionTap,
    required this.onJumpTap,
    required this.textEditingController,
    this.turnL = true,
    this.turnR = true,
  });

  @override
  createState() => _KPaginationState();
}

class _KPaginationState extends State<KPagination> {
  TextEditingController get textEditingController =>
      widget.textEditingController;

  int get outputTextValue {
    var text = textEditingController.text;
    return int.parse(text);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant KPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              KPaginationActionButton(
                disable: !widget.turnL,
                onTap: () {
                  if (widget.turnL) {
                    widget.onActionTap(KPaginationActionButtonDirection.l);
                  }
                },
              ),
              const SizedBox(
                width: 6,
              ),
              KPaginationActionButton(
                disable: !widget.turnR,
                direction: KPaginationActionButtonDirection.r,
                onTap: () {
                  if (widget.turnR) {
                    widget.onActionTap(KPaginationActionButtonDirection.r);
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 66,
                child: CupertinoTextField(
                  controller: textEditingController,
                  textAlign: TextAlign.center,

                  /// 怕不是要上天, 一个分页给爷整个几千页?
                  maxLength: 4,

                  /// The content entered must be a number!!
                  /// link: https://stackoverflow.com/a/49578197
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,

                  padding: EdgeInsets.zero,
                  strutStyle: const StrutStyle(
                    forceStrutHeight: true,
                  ),
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    widget.onJumpTap();
                  },
                  child: const Text(
                    "点击跳转",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

```

#### 📄 `lib/app\widget\k_tag.dart`

```dart
import 'package:flutter/material.dart';

/// [KTag] 事件触发类型
enum KTagTapEventType {
  /// 内容 [content]
  content,

  /// 右边 [action]
  action,
}

typedef KTapOnTap = void Function(KTagTapEventType type);

class KTag extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  final EdgeInsetsGeometry padding;

  final Color backgroundColor;

  final Widget child;

  final KTapOnTap onTap;

  const KTag({
    super.key,
    this.padding = const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 15,
    ),
    this.margin = const EdgeInsets.fromLTRB(0, 0, 8, 6),
    this.backgroundColor = Colors.black26,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: backgroundColor,
      ),
      padding: padding,
      margin: margin,
      child: Row(
        spacing: 3,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              onTap(KTagTapEventType.content);
            },
            child: child,
          ),
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              onTap(KTagTapEventType.action);
            },
            child: const Icon(
              Icons.close,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}

```

#### 📄 `lib/app\widget\k_title_bar.dart`

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KTitleBar extends StatelessWidget {
  final String title;

  const KTitleBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
              Container(
                height: 4,
                color: Colors.black,
                width: 82,
              ),
            ],
          ),
          const Row(
            children: [
              Text(
                "全部",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Icon(CupertinoIcons.arrow_right_circle),
            ],
          )
        ],
      ),
    );
  }
}

```

#### 📄 `lib/app\widget\mac.dart`

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef MacwindowctlEvent = void Function(MacwindowctlAction);

enum MacwindowctlAction {
  /// 关闭
  close,

  /// 最小化
  minimize,

  /// 最大化
  maximize,
}

class Macwindowctl extends StatefulWidget {
  final bool? focused;

  final double? buttonSize;

  final double? blurSize;

  final MacwindowctlEvent? onHover;

  final MacwindowctlEvent? onExit;

  final MacwindowctlEvent? onClick;

  final bool? buttonReverse;

  const Macwindowctl({
    super.key,
    this.buttonReverse,
    this.onClick,
    this.onExit,
    this.onHover,
    this.focused,
    this.buttonSize,
    this.blurSize,
  });

  @override
  createState() => _MacwindowctlState();
}

class _MacwindowctlState extends State<Macwindowctl> {
  bool onHoverFlag = false;

  List<Map<String, dynamic>> _actions = [
    {
      "icon": CupertinoIcons.xmark,
      "action": MacwindowctlAction.close,
      "color": Colors.red[400],
    },
    {
      "icon": CupertinoIcons.minus,
      "action": MacwindowctlAction.minimize,
      "color": Colors.yellow[400],
    },
    {
      "icon": CupertinoIcons.arrow_down_right_arrow_up_left,
      "action": MacwindowctlAction.maximize,
      "color": Colors.green[400],
    }
  ];

  Map<String, dynamic> _getButtonItem(MacwindowctlAction action) {
    var tmp = _actions.where((element) => element["action"] == action).toList();
    return tmp[0];
  }

  @override
  Widget build(BuildContext context) {
    if (!!(widget.buttonReverse ?? false)) {
      setState(() {
        _actions = [
          _getButtonItem(MacwindowctlAction.minimize),
          _getButtonItem(MacwindowctlAction.maximize),
          _getButtonItem(MacwindowctlAction.close),
        ];
      });
    } else {
      setState(() {
        _actions = [
          _getButtonItem(MacwindowctlAction.close),
          _getButtonItem(MacwindowctlAction.minimize),
          _getButtonItem(MacwindowctlAction.maximize),
        ];
      });
    }
    return Row(
      children: [
        ..._actions.map((item) => GestureDetector(
              onTap: () {
                if (widget.onClick != null && mounted) {
                  widget.onClick!(item["action"] as MacwindowctlAction);
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onHover: (event) {
                  if (widget.onHover != null && mounted) {
                    widget.onHover!(item["action"] as MacwindowctlAction);
                  }
                  setState(() {
                    onHoverFlag = true;
                  });
                },
                onExit: (event) {
                  if (widget.onExit != null && mounted) {
                    widget.onExit!(item["action"] as MacwindowctlAction);
                  }
                  setState(() {
                    onHoverFlag = false;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(
                    right: 6.0,
                  ),
                  width: widget.buttonSize,
                  height: widget.buttonSize,
                  decoration: BoxDecoration(
                    color: (widget.focused ?? false)
                        ? item["color"]
                        : Colors.black26,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.blurSize != null &&
                                widget.blurSize! > 0 &&
                                (widget.focused ?? false))
                            ? item["color"]
                            : Colors.transparent,
                        offset: const Offset(1, 1),
                        blurRadius: widget.blurSize == null
                            ? 0
                            : (widget.blurSize ?? 0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      item["icon"],
                      color: onHoverFlag ? Colors.black87 : Colors.transparent,
                      size: (widget.buttonSize ?? 12) * .75,
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

```

#### 📄 `lib/app\widget\movie_card_item.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catmovie/app/widget/helper.dart';

class MovieCardItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String note;
  final VoidCallback onTap;

  const MovieCardItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Zoom(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Column(
            spacing: 9,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) =>
                              DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  (context.isDarkMode ? '#1c1c1e' : "#f0f0f0")
                                      .$color,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.progress,
                              ),
                            ),
                          ),
                          errorWidget: (context, error, stackTrace) =>
                              kErrorImage,
                        ),
                      ),
                      if (note.isNotEmpty)
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: 6,
                              right: 6,
                              left: 6,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Align(
                                  alignment: Alignment.bottomRight,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.bottomRight,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth * .88,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: .72),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          note,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

```

#### 📄 `lib/app\widget\window_appbar.dart`

```dart
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mac.dart';

double kMacPaddingTop = 16;

class MoveWindow extends StatelessWidget {
  const MoveWindow({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        if (GetPlatform.isDesktop) {
          appWindow.startDragging();
        }
      },
      onDoubleTap: () {
        if (GetPlatform.isDesktop) {
          appWindow.maximizeOrRestore();
        }
      },
      child: child ?? Container(),
    );
  }
}

class CustomMoveWindow extends StatelessWidget {
  final Widget? child;
  const CustomMoveWindow({
    super.key,
    this.child,
  });
  @override
  Widget build(BuildContext context) {
    if (child == null) return const MoveWindow();
    return MoveWindow(
      child: child,
    );
  }
}

class CupertinoEasyAppBar extends StatefulWidget
    implements ObstructingPreferredSizeWidget {
  const CupertinoEasyAppBar({
    super.key,
    this.backgroundColor,
    this.child,
    this.parentContext,
  });

  final Color? backgroundColor;
  final Widget? child;
  final BuildContext? parentContext;

  @override
  bool shouldFullyObstruct(BuildContext context) {
    var cx = parentContext ?? context;
    Color? easy = CupertinoDynamicColor.maybeResolve(
      this.backgroundColor,
      cx,
    );
    Color? themeOf = CupertinoTheme.of(context).barBackgroundColor;
    final Color backgroundColor = easy ?? themeOf;
    int px = (backgroundColor.a * 255.0).round() & 0xff;
    return px == 0xFF;
  }

  @override
  Size get preferredSize {
    double calc = kToolbarHeight;
    if (GetPlatform.isMacOS) {
      calc += kMacPaddingTop;
    }
    return Size.fromHeight(calc);
  }

  @override
  State<CupertinoEasyAppBar> createState() => _CupertinoEasyAppBarState();
}

class _CupertinoEasyAppBarState extends State<CupertinoEasyAppBar> {
  Widget get _child {
    Widget? child = widget.child;
    if (child == null) return const SizedBox.shrink();
    Widget target = child;
    if (GetPlatform.isMacOS) {
      target = Padding(
        padding: EdgeInsets.only(
          top: kMacPaddingTop,
        ),
        child: child,
      );
    }
    if (GetPlatform.isMobile) {
      target = Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: target,
      );
    }
    return MoveWindow(child: target);
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: _child);
  }
}

class WindowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WindowAppBar({
    super.key,
    this.toolBarHeigth,
    this.title,
    this.iosBackStyle = false,
    this.actions = const [],
    this.centerTitle = false,
  });

  final bool iosBackStyle;

  final bool centerTitle;

  final Widget? title;

  bool get isSupport {
    return GetPlatform.isDesktop;
  }

  final double? toolBarHeigth;

  final List<Widget> actions;

  double get _macosPaddingHeight {
    return GetPlatform.isMacOS ? kMacPaddingTop : 0;
  }

  /// [bar] 的高度
  double get barHeigth {
    if (toolBarHeigth != null) return toolBarHeigth as double;
    return kToolbarHeight + _macosPaddingHeight;
  }

  Widget titleWidget(Color purueColor) {
    var cx = Get.context;
    if (cx == null) {
      return BackButton(
        color: purueColor,
      );
    }
    if (title != null) {
      return DefaultTextStyle(
        style: Theme.of(cx).appBarTheme.titleTextStyle ?? const TextStyle(),
        child: title as Widget,
      );
    }
    if (iosBackStyle) {
      return CupertinoNavigationBarBackButton(
        color: purueColor,
        onPressed: () => Get.back(),
      );
    }
    return BackButton(
      color: purueColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color purueColor = context.isDarkMode ? Colors.blue : Colors.white;

    List<Widget> childrens = [
      titleWidget(purueColor),
      IconTheme(
        data: Theme.of(context).primaryIconTheme,
        child: Row(
          children: actions,
        ),
      )
    ];
    if (centerTitle) {
      childrens.insert(
        0,
        const Text(''),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: CustomMoveWindow(
        child: PreferredSize(
          preferredSize: preferredSize,
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.only(
              top: _top,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: childrens,
                  ),
                ),
                if (GetPlatform.isDesktop && !GetPlatform.isMacOS)
                  SizedBox(width: 6),
                if (GetPlatform.isDesktop && !GetPlatform.isMacOS)
                  Macwindowctl(
                    buttonSize: 12,
                    blurSize: 24,
                    focused: true,
                    buttonReverse: true,
                    onClick: (action) {
                      switch (action) {
                        case MacwindowctlAction.close:
                          appWindow.close();
                          break;
                        case MacwindowctlAction.maximize:
                          appWindow.maximizeOrRestore();
                          break;
                        case MacwindowctlAction.minimize:
                          appWindow.minimize();
                          break;
                        default:
                      }
                    },
                  ),
                SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _top {
    var h = MediaQuery.of(Get.context!).padding.top;
    return h + _macosPaddingHeight;
  }

  @override
  Size get preferredSize => Size.fromHeight(barHeigth);
}

```

#### 📄 `lib/app\widget\zoom.dart`

```dart
import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';

class HoverCursor extends StatelessWidget {
  const HoverCursor({
    super.key,
    required this.child,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
  });

  final Widget child;
  final HitTestBehavior hitTestBehavior;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      hitTestBehavior: hitTestBehavior,
      child: child,
    );
  }
}

class Zoom extends StatelessWidget {
  const Zoom({
    super.key,
    required this.child,
    this.onTap,
    this.scaleRatio = 0.965,
    this.highlightColor = Colors.transparent,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleRatio;
  final Color highlightColor;
  final HitTestBehavior hitTestBehavior;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      hitTestBehavior: hitTestBehavior,
      child: BounceTapper(
        shrinkScaleFactor: scaleRatio,
        onTap: onTap,
        highlightColor: highlightColor,
        child: child,
      ),
    );
  }
}

```

### 📂 lib/builtin

#### 📄 `lib/builtin\README.md`

```markdown
# 内建源
```

#### 📂 lib/builtin\maccms

#### 📄 `lib/builtin\maccms\maccms.dart`

```dart
import 'package:xi/xi.dart';

List<MacCMSSpider> list$ = [];

```

### 📂 lib/isar

#### 📄 `lib/isar\repo.dart`

```dart
import 'package:catmovie/isar/schema/category_schema.dart';
import 'package:catmovie/isar/schema/video_history_schema.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:catmovie/isar/schema/history_schema.dart';
import 'package:catmovie/isar/schema/mirror_schema.dart';
import 'package:catmovie/isar/schema/parse_schema.dart';
import 'package:catmovie/isar/schema/settings_schema.dart';
import 'package:path_provider/path_provider.dart';

// isar auto generated *.g.dart do you want add .gitignore?
// link: https://www.reddit.com/r/FlutterDev/comments/kazxo0/do_you_add_gdart_files_to_gitignore
// I don't like these makefiles (ーー゛)
// the code copy by ChatGPT

class IsarRepository {
  late Isar _isar;

  static final IsarRepository _instance = IsarRepository._internal();

  factory IsarRepository() {
    return _instance;
  }

  IsarRepository._internal() {
    init();
  }

  void safeWrite(VoidCallback fn) {
    isar.writeTxnSync(() async => fn());
  }

  void safeRead(VoidCallback fn) {
    isar.txn(() async => fn);
  }

  List<CollectionSchema<dynamic>> get schemas => [
        SettingsIsarModelSchema,
        HistoryIsarModelSchema,
        ParseIsarModelSchema,
        MirrorIsarModelSchema,
        VideoHistoryIsarModelSchema,
        CategoryIsarModelSchema,
      ];

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      schemas,
      directory: dir.path,
      maxSizeMiB: 512,
    );
    _initDB(_isar);
  }

  @Deprecated("调试模式, 后续请删除")
  void fake(Isar isar) {
    isar.writeTxnSync(() {
      isar.settingsIsarModels.clearSync();
    });
  }

  void _initDB(Isar isar) {
    // _fake(isar);
    if (isar.settingsIsarModels.countSync() <= 0) {
      debugPrint("[logger] 初始化设置");
      var defaultSetting = SettingsIsarModel();
      // if (defaultSetting.mirrorTextarea.isEmpty) {
      //   defaultSetting.mirrorTextarea =
      //       "https://cdn.jsdelivr.net/gh/waifu-project/v1@latest/yoyo.json";
      // }
      isar.writeTxnSync(() {
        isar.settingsIsarModels.putSync(defaultSetting);
      });
    }
  }

  Isar get isar => _isar;
}

extension IsarRepositoryModelHelp on IsarRepository {
  IsarCollection<SettingsIsarModel> get settingAs => _isar.settingsIsarModels;

  /// use the instance need init!!!
  /// maybe get fail(nill)
  SettingsIsarModel get settingsSingleModel => settingAs.getSync(1)!;
}

```

#### 📂 lib/isar\schema

#### 📄 `lib/isar\schema\category_schema.dart`

```dart
import 'package:isar_community/isar.dart';
import 'package:xi/interface.dart';

part 'category_schema.g.dart';

@embedded
class Category {
  late String name;
  late String id;
  SourceSpiderQueryCategory toRealCategory() {
    return SourceSpiderQueryCategory(name, id);
  }
}

@Collection()
class CategoryIsarModel {
  CategoryIsarModel({
    required this.sid,
    required this.categories,
  });

  Id id = Isar.autoIncrement;

  @Index()
  String sid;

  late List<Category> categories;

  List<SourceSpiderQueryCategory> toRealCategories() {
    return categories.map((e) => e.toRealCategory()).toList();
  }
}

```

#### 📄 `lib/isar\schema\category_schema.g.dart`

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCategoryIsarModelCollection on Isar {
  IsarCollection<CategoryIsarModel> get categoryIsarModels => this.collection();
}

const CategoryIsarModelSchema = CollectionSchema(
  name: r'CategoryIsarModel',
  id: -7763797637460357684,
  properties: {
    r'categories': PropertySchema(
      id: 0,
      name: r'categories',
      type: IsarType.objectList,
      target: r'Category',
    ),
    r'sid': PropertySchema(
      id: 1,
      name: r'sid',
      type: IsarType.string,
    )
  },
  estimateSize: _categoryIsarModelEstimateSize,
  serialize: _categoryIsarModelSerialize,
  deserialize: _categoryIsarModelDeserialize,
  deserializeProp: _categoryIsarModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'sid': IndexSchema(
      id: 3962831672660911250,
      name: r'sid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'Category': CategorySchema},
  getId: _categoryIsarModelGetId,
  getLinks: _categoryIsarModelGetLinks,
  attach: _categoryIsarModelAttach,
  version: '3.3.2',
);

int _categoryIsarModelEstimateSize(
  CategoryIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.categories.length * 3;
  {
    final offsets = allOffsets[Category]!;
    for (var i = 0; i < object.categories.length; i++) {
      final value = object.categories[i];
      bytesCount += CategorySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.sid.length * 3;
  return bytesCount;
}

void _categoryIsarModelSerialize(
  CategoryIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<Category>(
    offsets[0],
    allOffsets,
    CategorySchema.serialize,
    object.categories,
  );
  writer.writeString(offsets[1], object.sid);
}

CategoryIsarModel _categoryIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CategoryIsarModel(
    categories: reader.readObjectList<Category>(
          offsets[0],
          CategorySchema.deserialize,
          allOffsets,
          Category(),
        ) ??
        [],
    sid: reader.readString(offsets[1]),
  );
  object.id = id;
  return object;
}

P _categoryIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<Category>(
            offset,
            CategorySchema.deserialize,
            allOffsets,
            Category(),
          ) ??
          []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _categoryIsarModelGetId(CategoryIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _categoryIsarModelGetLinks(
    CategoryIsarModel object) {
  return [];
}

void _categoryIsarModelAttach(
    IsarCollection<dynamic> col, Id id, CategoryIsarModel object) {
  object.id = id;
}

extension CategoryIsarModelQueryWhereSort
    on QueryBuilder<CategoryIsarModel, CategoryIsarModel, QWhere> {
  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CategoryIsarModelQueryWhere
    on QueryBuilder<CategoryIsarModel, CategoryIsarModel, QWhereClause> {
  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterWhereClause>
      sidEqualTo(String sid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sid',
        value: [sid],
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterWhereClause>
      sidNotEqualTo(String sid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sid',
              lower: [],
              upper: [sid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sid',
              lower: [sid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sid',
              lower: [sid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sid',
              lower: [],
              upper: [sid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CategoryIsarModelQueryFilter
    on QueryBuilder<CategoryIsarModel, CategoryIsarModel, QFilterCondition> {
  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      categoriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      categoriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      categoriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      categoriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      categoriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      categoriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categories',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sid',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      sidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sid',
        value: '',
      ));
    });
  }
}

extension CategoryIsarModelQueryObject
    on QueryBuilder<CategoryIsarModel, CategoryIsarModel, QFilterCondition> {
  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterFilterCondition>
      categoriesElement(FilterQuery<Category> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'categories');
    });
  }
}

extension CategoryIsarModelQueryLinks
    on QueryBuilder<CategoryIsarModel, CategoryIsarModel, QFilterCondition> {}

extension CategoryIsarModelQuerySortBy
    on QueryBuilder<CategoryIsarModel, CategoryIsarModel, QSortBy> {
  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterSortBy> sortBySid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.asc);
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterSortBy>
      sortBySidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.desc);
    });
  }
}

extension CategoryIsarModelQuerySortThenBy
    on QueryBuilder<CategoryIsarModel, CategoryIsarModel, QSortThenBy> {
  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterSortBy> thenBySid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.asc);
    });
  }

  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QAfterSortBy>
      thenBySidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.desc);
    });
  }
}

extension CategoryIsarModelQueryWhereDistinct
    on QueryBuilder<CategoryIsarModel, CategoryIsarModel, QDistinct> {
  QueryBuilder<CategoryIsarModel, CategoryIsarModel, QDistinct> distinctBySid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sid', caseSensitive: caseSensitive);
    });
  }
}

extension CategoryIsarModelQueryProperty
    on QueryBuilder<CategoryIsarModel, CategoryIsarModel, QQueryProperty> {
  QueryBuilder<CategoryIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CategoryIsarModel, List<Category>, QQueryOperations>
      categoriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categories');
    });
  }

  QueryBuilder<CategoryIsarModel, String, QQueryOperations> sidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sid');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CategorySchema = Schema(
  name: r'Category',
  id: 5751694338128944171,
  properties: {
    r'id': PropertySchema(
      id: 0,
      name: r'id',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _categoryEstimateSize,
  serialize: _categorySerialize,
  deserialize: _categoryDeserialize,
  deserializeProp: _categoryDeserializeProp,
);

int _categoryEstimateSize(
  Category object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _categorySerialize(
  Category object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.id);
  writer.writeString(offsets[1], object.name);
}

Category _categoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Category();
  object.id = reader.readString(offsets[0]);
  object.name = reader.readString(offsets[1]);
  return object;
}

P _categoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CategoryQueryFilter
    on QueryBuilder<Category, Category, QFilterCondition> {
  QueryBuilder<Category, Category, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension CategoryQueryObject
    on QueryBuilder<Category, Category, QFilterCondition> {}

```

#### 📄 `lib/isar\schema\history_schema.dart`

```dart
import 'package:isar_community/isar.dart';

part 'history_schema.g.dart';

@Collection()
class HistoryIsarModel {
  Id id = Isar.autoIncrement;

  @Index()
  late bool isNsfw;
  late String content;

  HistoryIsarModel(this.isNsfw, this.content);
}

```

#### 📄 `lib/isar\schema\history_schema.g.dart`

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHistoryIsarModelCollection on Isar {
  IsarCollection<HistoryIsarModel> get historyIsarModels => this.collection();
}

const HistoryIsarModelSchema = CollectionSchema(
  name: r'HistoryIsarModel',
  id: 3749409577964447223,
  properties: {
    r'content': PropertySchema(
      id: 0,
      name: r'content',
      type: IsarType.string,
    ),
    r'isNsfw': PropertySchema(
      id: 1,
      name: r'isNsfw',
      type: IsarType.bool,
    )
  },
  estimateSize: _historyIsarModelEstimateSize,
  serialize: _historyIsarModelSerialize,
  deserialize: _historyIsarModelDeserialize,
  deserializeProp: _historyIsarModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'isNsfw': IndexSchema(
      id: 3014435295683206251,
      name: r'isNsfw',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isNsfw',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _historyIsarModelGetId,
  getLinks: _historyIsarModelGetLinks,
  attach: _historyIsarModelAttach,
  version: '3.3.2',
);

int _historyIsarModelEstimateSize(
  HistoryIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.content.length * 3;
  return bytesCount;
}

void _historyIsarModelSerialize(
  HistoryIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.content);
  writer.writeBool(offsets[1], object.isNsfw);
}

HistoryIsarModel _historyIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HistoryIsarModel(
    reader.readBool(offsets[1]),
    reader.readString(offsets[0]),
  );
  object.id = id;
  return object;
}

P _historyIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _historyIsarModelGetId(HistoryIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _historyIsarModelGetLinks(HistoryIsarModel object) {
  return [];
}

void _historyIsarModelAttach(
    IsarCollection<dynamic> col, Id id, HistoryIsarModel object) {
  object.id = id;
}

extension HistoryIsarModelQueryWhereSort
    on QueryBuilder<HistoryIsarModel, HistoryIsarModel, QWhere> {
  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterWhere> anyIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isNsfw'),
      );
    });
  }
}

extension HistoryIsarModelQueryWhere
    on QueryBuilder<HistoryIsarModel, HistoryIsarModel, QWhereClause> {
  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterWhereClause>
      isNsfwEqualTo(bool isNsfw) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isNsfw',
        value: [isNsfw],
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterWhereClause>
      isNsfwNotEqualTo(bool isNsfw) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [],
              upper: [isNsfw],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [isNsfw],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [isNsfw],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [],
              upper: [isNsfw],
              includeUpper: false,
            ));
      }
    });
  }
}

extension HistoryIsarModelQueryFilter
    on QueryBuilder<HistoryIsarModel, HistoryIsarModel, QFilterCondition> {
  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterFilterCondition>
      isNsfwEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNsfw',
        value: value,
      ));
    });
  }
}

extension HistoryIsarModelQueryObject
    on QueryBuilder<HistoryIsarModel, HistoryIsarModel, QFilterCondition> {}

extension HistoryIsarModelQueryLinks
    on QueryBuilder<HistoryIsarModel, HistoryIsarModel, QFilterCondition> {}

extension HistoryIsarModelQuerySortBy
    on QueryBuilder<HistoryIsarModel, HistoryIsarModel, QSortBy> {
  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy>
      sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy>
      sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy>
      sortByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.asc);
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy>
      sortByIsNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.desc);
    });
  }
}

extension HistoryIsarModelQuerySortThenBy
    on QueryBuilder<HistoryIsarModel, HistoryIsarModel, QSortThenBy> {
  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy>
      thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy>
      thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy>
      thenByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.asc);
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QAfterSortBy>
      thenByIsNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.desc);
    });
  }
}

extension HistoryIsarModelQueryWhereDistinct
    on QueryBuilder<HistoryIsarModel, HistoryIsarModel, QDistinct> {
  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryIsarModel, HistoryIsarModel, QDistinct>
      distinctByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNsfw');
    });
  }
}

extension HistoryIsarModelQueryProperty
    on QueryBuilder<HistoryIsarModel, HistoryIsarModel, QQueryProperty> {
  QueryBuilder<HistoryIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HistoryIsarModel, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<HistoryIsarModel, bool, QQueryOperations> isNsfwProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNsfw');
    });
  }
}

```

#### 📄 `lib/isar\schema\mirror_schema.dart`

```dart
import 'package:isar_community/isar.dart';
import 'package:catmovie/shared/enum.dart';
import 'package:xi/xi.dart';

part 'mirror_schema.g.dart';

@embedded
class MirrorExtraJS {
  late String category;
  late String home;
  late String search;
  late String detail;
  late String parseIframe;
}

@embedded
class MirrorExtra {
  String? jiexiUrl;
  bool? gfw;
  int? searchLimit;
  String? template;
  MirrorExtraJS? js;
}

@collection
class MirrorIsarModel {
  MirrorIsarModel({
    required this.api,
    required this.name,
    required this.logo,
    required this.desc,
    required this.nsfw,
    required this.status,
    required this.sid,
    required this.type,
    required this.extra,
  });

  Id id = Isar.autoIncrement;

  @Index()
  late String sid;

  late String name;
  String logo = "";
  String desc = "";

  bool nsfw = false;

  late String api;

  @Enumerated(EnumType.ordinal)
  MirrorStatus status = MirrorStatus.unknow;

  @Enumerated(EnumType.ordinal)
  late SourceType type;

  late MirrorExtra extra;
}

```

#### 📄 `lib/isar\schema\mirror_schema.g.dart`

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mirror_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMirrorIsarModelCollection on Isar {
  IsarCollection<MirrorIsarModel> get mirrorIsarModels => this.collection();
}

const MirrorIsarModelSchema = CollectionSchema(
  name: r'MirrorIsarModel',
  id: -583302468344542477,
  properties: {
    r'api': PropertySchema(
      id: 0,
      name: r'api',
      type: IsarType.string,
    ),
    r'desc': PropertySchema(
      id: 1,
      name: r'desc',
      type: IsarType.string,
    ),
    r'extra': PropertySchema(
      id: 2,
      name: r'extra',
      type: IsarType.object,
      target: r'MirrorExtra',
    ),
    r'logo': PropertySchema(
      id: 3,
      name: r'logo',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'nsfw': PropertySchema(
      id: 5,
      name: r'nsfw',
      type: IsarType.bool,
    ),
    r'sid': PropertySchema(
      id: 6,
      name: r'sid',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 7,
      name: r'status',
      type: IsarType.byte,
      enumMap: _MirrorIsarModelstatusEnumValueMap,
    ),
    r'type': PropertySchema(
      id: 8,
      name: r'type',
      type: IsarType.byte,
      enumMap: _MirrorIsarModeltypeEnumValueMap,
    )
  },
  estimateSize: _mirrorIsarModelEstimateSize,
  serialize: _mirrorIsarModelSerialize,
  deserialize: _mirrorIsarModelDeserialize,
  deserializeProp: _mirrorIsarModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'sid': IndexSchema(
      id: 3962831672660911250,
      name: r'sid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'MirrorExtra': MirrorExtraSchema,
    r'MirrorExtraJS': MirrorExtraJSSchema
  },
  getId: _mirrorIsarModelGetId,
  getLinks: _mirrorIsarModelGetLinks,
  attach: _mirrorIsarModelAttach,
  version: '3.3.2',
);

int _mirrorIsarModelEstimateSize(
  MirrorIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.api.length * 3;
  bytesCount += 3 + object.desc.length * 3;
  bytesCount += 3 +
      MirrorExtraSchema.estimateSize(
          object.extra, allOffsets[MirrorExtra]!, allOffsets);
  bytesCount += 3 + object.logo.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.sid.length * 3;
  return bytesCount;
}

void _mirrorIsarModelSerialize(
  MirrorIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.api);
  writer.writeString(offsets[1], object.desc);
  writer.writeObject<MirrorExtra>(
    offsets[2],
    allOffsets,
    MirrorExtraSchema.serialize,
    object.extra,
  );
  writer.writeString(offsets[3], object.logo);
  writer.writeString(offsets[4], object.name);
  writer.writeBool(offsets[5], object.nsfw);
  writer.writeString(offsets[6], object.sid);
  writer.writeByte(offsets[7], object.status.index);
  writer.writeByte(offsets[8], object.type.index);
}

MirrorIsarModel _mirrorIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MirrorIsarModel(
    api: reader.readString(offsets[0]),
    desc: reader.readString(offsets[1]),
    extra: reader.readObjectOrNull<MirrorExtra>(
          offsets[2],
          MirrorExtraSchema.deserialize,
          allOffsets,
        ) ??
        MirrorExtra(),
    logo: reader.readString(offsets[3]),
    name: reader.readString(offsets[4]),
    nsfw: reader.readBool(offsets[5]),
    sid: reader.readString(offsets[6]),
    status:
        _MirrorIsarModelstatusValueEnumMap[reader.readByteOrNull(offsets[7])] ??
            MirrorStatus.available,
    type: _MirrorIsarModeltypeValueEnumMap[reader.readByteOrNull(offsets[8])] ??
        SourceType.maccms,
  );
  object.id = id;
  return object;
}

P _mirrorIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<MirrorExtra>(
            offset,
            MirrorExtraSchema.deserialize,
            allOffsets,
          ) ??
          MirrorExtra()) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (_MirrorIsarModelstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MirrorStatus.available) as P;
    case 8:
      return (_MirrorIsarModeltypeValueEnumMap[reader.readByteOrNull(offset)] ??
          SourceType.maccms) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MirrorIsarModelstatusEnumValueMap = {
  'available': 0,
  'unavailable': 1,
  'unknow': 2,
};
const _MirrorIsarModelstatusValueEnumMap = {
  0: MirrorStatus.available,
  1: MirrorStatus.unavailable,
  2: MirrorStatus.unknow,
};
const _MirrorIsarModeltypeEnumValueMap = {
  'maccms': 0,
  'universal': 1,
};
const _MirrorIsarModeltypeValueEnumMap = {
  0: SourceType.maccms,
  1: SourceType.universal,
};

Id _mirrorIsarModelGetId(MirrorIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mirrorIsarModelGetLinks(MirrorIsarModel object) {
  return [];
}

void _mirrorIsarModelAttach(
    IsarCollection<dynamic> col, Id id, MirrorIsarModel object) {
  object.id = id;
}

extension MirrorIsarModelQueryWhereSort
    on QueryBuilder<MirrorIsarModel, MirrorIsarModel, QWhere> {
  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MirrorIsarModelQueryWhere
    on QueryBuilder<MirrorIsarModel, MirrorIsarModel, QWhereClause> {
  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterWhereClause> sidEqualTo(
      String sid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sid',
        value: [sid],
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterWhereClause>
      sidNotEqualTo(String sid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sid',
              lower: [],
              upper: [sid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sid',
              lower: [sid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sid',
              lower: [sid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sid',
              lower: [],
              upper: [sid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MirrorIsarModelQueryFilter
    on QueryBuilder<MirrorIsarModel, MirrorIsarModel, QFilterCondition> {
  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'api',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'api',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'api',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'api',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'api',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'api',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'api',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'api',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'api',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      apiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'api',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'desc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'desc',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desc',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      descIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'desc',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'logo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'logo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logo',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      logoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logo',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      nsfwEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nsfw',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sid',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      sidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sid',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      statusEqualTo(MirrorStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      statusGreaterThan(
    MirrorStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      statusLessThan(
    MirrorStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      statusBetween(
    MirrorStatus lower,
    MirrorStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      typeEqualTo(SourceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      typeGreaterThan(
    SourceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      typeLessThan(
    SourceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition>
      typeBetween(
    SourceType lower,
    SourceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MirrorIsarModelQueryObject
    on QueryBuilder<MirrorIsarModel, MirrorIsarModel, QFilterCondition> {
  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterFilterCondition> extra(
      FilterQuery<MirrorExtra> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'extra');
    });
  }
}

extension MirrorIsarModelQueryLinks
    on QueryBuilder<MirrorIsarModel, MirrorIsarModel, QFilterCondition> {}

extension MirrorIsarModelQuerySortBy
    on QueryBuilder<MirrorIsarModel, MirrorIsarModel, QSortBy> {
  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortByApi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'api', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortByApiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'api', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      sortByDescDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortByLogo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logo', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      sortByLogoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logo', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortByNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nsfw', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      sortByNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nsfw', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortBySid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortBySidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MirrorIsarModelQuerySortThenBy
    on QueryBuilder<MirrorIsarModel, MirrorIsarModel, QSortThenBy> {
  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenByApi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'api', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenByApiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'api', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      thenByDescDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenByLogo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logo', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      thenByLogoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logo', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenByNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nsfw', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      thenByNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nsfw', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenBySid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenBySidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MirrorIsarModelQueryWhereDistinct
    on QueryBuilder<MirrorIsarModel, MirrorIsarModel, QDistinct> {
  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QDistinct> distinctByApi(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'api', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QDistinct> distinctByDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'desc', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QDistinct> distinctByLogo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QDistinct> distinctByNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nsfw');
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QDistinct> distinctBySid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorIsarModel, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension MirrorIsarModelQueryProperty
    on QueryBuilder<MirrorIsarModel, MirrorIsarModel, QQueryProperty> {
  QueryBuilder<MirrorIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MirrorIsarModel, String, QQueryOperations> apiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'api');
    });
  }

  QueryBuilder<MirrorIsarModel, String, QQueryOperations> descProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'desc');
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorExtra, QQueryOperations> extraProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extra');
    });
  }

  QueryBuilder<MirrorIsarModel, String, QQueryOperations> logoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logo');
    });
  }

  QueryBuilder<MirrorIsarModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MirrorIsarModel, bool, QQueryOperations> nsfwProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nsfw');
    });
  }

  QueryBuilder<MirrorIsarModel, String, QQueryOperations> sidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sid');
    });
  }

  QueryBuilder<MirrorIsarModel, MirrorStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<MirrorIsarModel, SourceType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MirrorExtraJSSchema = Schema(
  name: r'MirrorExtraJS',
  id: 79548965625048232,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'detail': PropertySchema(
      id: 1,
      name: r'detail',
      type: IsarType.string,
    ),
    r'home': PropertySchema(
      id: 2,
      name: r'home',
      type: IsarType.string,
    ),
    r'parseIframe': PropertySchema(
      id: 3,
      name: r'parseIframe',
      type: IsarType.string,
    ),
    r'search': PropertySchema(
      id: 4,
      name: r'search',
      type: IsarType.string,
    )
  },
  estimateSize: _mirrorExtraJSEstimateSize,
  serialize: _mirrorExtraJSSerialize,
  deserialize: _mirrorExtraJSDeserialize,
  deserializeProp: _mirrorExtraJSDeserializeProp,
);

int _mirrorExtraJSEstimateSize(
  MirrorExtraJS object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.detail.length * 3;
  bytesCount += 3 + object.home.length * 3;
  bytesCount += 3 + object.parseIframe.length * 3;
  bytesCount += 3 + object.search.length * 3;
  return bytesCount;
}

void _mirrorExtraJSSerialize(
  MirrorExtraJS object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeString(offsets[1], object.detail);
  writer.writeString(offsets[2], object.home);
  writer.writeString(offsets[3], object.parseIframe);
  writer.writeString(offsets[4], object.search);
}

MirrorExtraJS _mirrorExtraJSDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MirrorExtraJS();
  object.category = reader.readString(offsets[0]);
  object.detail = reader.readString(offsets[1]);
  object.home = reader.readString(offsets[2]);
  object.parseIframe = reader.readString(offsets[3]);
  object.search = reader.readString(offsets[4]);
  return object;
}

P _mirrorExtraJSDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MirrorExtraJSQueryFilter
    on QueryBuilder<MirrorExtraJS, MirrorExtraJS, QFilterCondition> {
  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'detail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'detail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detail',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      detailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'detail',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition> homeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'home',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      homeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'home',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      homeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'home',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition> homeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'home',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      homeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'home',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      homeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'home',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      homeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'home',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition> homeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'home',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      homeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'home',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      homeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'home',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parseIframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parseIframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parseIframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parseIframe',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parseIframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parseIframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parseIframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parseIframe',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parseIframe',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      parseIframeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parseIframe',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'search',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'search',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'search',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'search',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'search',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'search',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'search',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'search',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'search',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtraJS, MirrorExtraJS, QAfterFilterCondition>
      searchIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'search',
        value: '',
      ));
    });
  }
}

extension MirrorExtraJSQueryObject
    on QueryBuilder<MirrorExtraJS, MirrorExtraJS, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MirrorExtraSchema = Schema(
  name: r'MirrorExtra',
  id: -6623016017036416783,
  properties: {
    r'gfw': PropertySchema(
      id: 0,
      name: r'gfw',
      type: IsarType.bool,
    ),
    r'jiexiUrl': PropertySchema(
      id: 1,
      name: r'jiexiUrl',
      type: IsarType.string,
    ),
    r'js': PropertySchema(
      id: 2,
      name: r'js',
      type: IsarType.object,
      target: r'MirrorExtraJS',
    ),
    r'searchLimit': PropertySchema(
      id: 3,
      name: r'searchLimit',
      type: IsarType.long,
    ),
    r'template': PropertySchema(
      id: 4,
      name: r'template',
      type: IsarType.string,
    )
  },
  estimateSize: _mirrorExtraEstimateSize,
  serialize: _mirrorExtraSerialize,
  deserialize: _mirrorExtraDeserialize,
  deserializeProp: _mirrorExtraDeserializeProp,
);

int _mirrorExtraEstimateSize(
  MirrorExtra object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.jiexiUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.js;
    if (value != null) {
      bytesCount += 3 +
          MirrorExtraJSSchema.estimateSize(
              value, allOffsets[MirrorExtraJS]!, allOffsets);
    }
  }
  {
    final value = object.template;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _mirrorExtraSerialize(
  MirrorExtra object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.gfw);
  writer.writeString(offsets[1], object.jiexiUrl);
  writer.writeObject<MirrorExtraJS>(
    offsets[2],
    allOffsets,
    MirrorExtraJSSchema.serialize,
    object.js,
  );
  writer.writeLong(offsets[3], object.searchLimit);
  writer.writeString(offsets[4], object.template);
}

MirrorExtra _mirrorExtraDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MirrorExtra();
  object.gfw = reader.readBoolOrNull(offsets[0]);
  object.jiexiUrl = reader.readStringOrNull(offsets[1]);
  object.js = reader.readObjectOrNull<MirrorExtraJS>(
    offsets[2],
    MirrorExtraJSSchema.deserialize,
    allOffsets,
  );
  object.searchLimit = reader.readLongOrNull(offsets[3]);
  object.template = reader.readStringOrNull(offsets[4]);
  return object;
}

P _mirrorExtraDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<MirrorExtraJS>(
        offset,
        MirrorExtraJSSchema.deserialize,
        allOffsets,
      )) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MirrorExtraQueryFilter
    on QueryBuilder<MirrorExtra, MirrorExtra, QFilterCondition> {
  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> gfwIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gfw',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> gfwIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gfw',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> gfwEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gfw',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      jiexiUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'jiexiUrl',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      jiexiUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'jiexiUrl',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> jiexiUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jiexiUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      jiexiUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jiexiUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      jiexiUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jiexiUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> jiexiUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jiexiUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      jiexiUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jiexiUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      jiexiUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jiexiUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      jiexiUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jiexiUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> jiexiUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jiexiUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      jiexiUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jiexiUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      jiexiUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jiexiUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> jsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'js',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> jsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'js',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      searchLimitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'searchLimit',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      searchLimitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'searchLimit',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      searchLimitEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      searchLimitGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      searchLimitLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      searchLimitBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      templateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'template',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      templateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'template',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> templateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      templateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      templateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> templateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'template',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      templateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      templateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      templateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> templateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'template',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      templateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'template',
        value: '',
      ));
    });
  }

  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition>
      templateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'template',
        value: '',
      ));
    });
  }
}

extension MirrorExtraQueryObject
    on QueryBuilder<MirrorExtra, MirrorExtra, QFilterCondition> {
  QueryBuilder<MirrorExtra, MirrorExtra, QAfterFilterCondition> js(
      FilterQuery<MirrorExtraJS> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'js');
    });
  }
}

```

#### 📄 `lib/isar\schema\parse_schema.dart`

```dart
import 'dart:convert';

import 'package:isar_community/isar.dart';

part 'parse_schema.g.dart';

@Collection()
class ParseIsarModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String url;

  ParseIsarModel(this.name, this.url);

  factory ParseIsarModel.fromJson(Map<String, dynamic> json) {
    return ParseIsarModel(json['name'] ?? "", json['url'] ?? "");
  }
}

dynamic movieParseModelFromJson(String json) {
  var map = jsonDecode(json);
  var name = map['name'] ?? "";
  var url = map['url'] ?? "";
  return ParseIsarModel(name, url);
}

```

#### 📄 `lib/isar\schema\parse_schema.g.dart`

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parse_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetParseIsarModelCollection on Isar {
  IsarCollection<ParseIsarModel> get parseIsarModels => this.collection();
}

const ParseIsarModelSchema = CollectionSchema(
  name: r'ParseIsarModel',
  id: 2328721110623403073,
  properties: {
    r'name': PropertySchema(
      id: 0,
      name: r'name',
      type: IsarType.string,
    ),
    r'url': PropertySchema(
      id: 1,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _parseIsarModelEstimateSize,
  serialize: _parseIsarModelSerialize,
  deserialize: _parseIsarModelDeserialize,
  deserializeProp: _parseIsarModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _parseIsarModelGetId,
  getLinks: _parseIsarModelGetLinks,
  attach: _parseIsarModelAttach,
  version: '3.3.2',
);

int _parseIsarModelEstimateSize(
  ParseIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _parseIsarModelSerialize(
  ParseIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
  writer.writeString(offsets[1], object.url);
}

ParseIsarModel _parseIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ParseIsarModel(
    reader.readString(offsets[0]),
    reader.readString(offsets[1]),
  );
  object.id = id;
  return object;
}

P _parseIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _parseIsarModelGetId(ParseIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _parseIsarModelGetLinks(ParseIsarModel object) {
  return [];
}

void _parseIsarModelAttach(
    IsarCollection<dynamic> col, Id id, ParseIsarModel object) {
  object.id = id;
}

extension ParseIsarModelQueryWhereSort
    on QueryBuilder<ParseIsarModel, ParseIsarModel, QWhere> {
  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ParseIsarModelQueryWhere
    on QueryBuilder<ParseIsarModel, ParseIsarModel, QWhereClause> {
  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ParseIsarModelQueryFilter
    on QueryBuilder<ParseIsarModel, ParseIsarModel, QFilterCondition> {
  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension ParseIsarModelQueryObject
    on QueryBuilder<ParseIsarModel, ParseIsarModel, QFilterCondition> {}

extension ParseIsarModelQueryLinks
    on QueryBuilder<ParseIsarModel, ParseIsarModel, QFilterCondition> {}

extension ParseIsarModelQuerySortBy
    on QueryBuilder<ParseIsarModel, ParseIsarModel, QSortBy> {
  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension ParseIsarModelQuerySortThenBy
    on QueryBuilder<ParseIsarModel, ParseIsarModel, QSortThenBy> {
  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension ParseIsarModelQueryWhereDistinct
    on QueryBuilder<ParseIsarModel, ParseIsarModel, QDistinct> {
  QueryBuilder<ParseIsarModel, ParseIsarModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParseIsarModel, ParseIsarModel, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension ParseIsarModelQueryProperty
    on QueryBuilder<ParseIsarModel, ParseIsarModel, QQueryProperty> {
  QueryBuilder<ParseIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ParseIsarModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ParseIsarModel, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}

```

#### 📄 `lib/isar\schema\settings_schema.dart`

```dart
import 'package:isar_community/isar.dart';
import 'package:catmovie/shared/enum.dart';
// TODO: webplayer_embedded已移除，使用占位符
// import 'package:webplayer_embedded/webplayer_embedded.dart';

part 'settings_schema.g.dart';

@Collection(inheritance: false)
class SettingsIsarModel {
  Id id = Isar.autoIncrement;

  /// 主题
  @Enumerated(EnumType.ordinal)
  SystemThemeMode themeMode = SystemThemeMode.system;

  /// 播放器内核
  @Enumerated(EnumType.ordinal)
  VideoKernel videoKernel = VideoKernel.mediaKit;

  /// 是否开启成人模式
  bool isNSFW = false;

  /// 当前源
  int mirrorIndex = 0;

  String mirrorTextarea = "";

  /// 显示播放前的提示(告知用户不要相信广告!)
  bool showPlayTips = true;

  /// 启动时是否显示引导页面
  bool onBoardingShowed = false;

  /// 震动反馈
  bool hapticFeedback = true;

  /// 是否显示绅士模式设置（通过点击 Copyright 10次解锁）
  bool showNsfwSetting = false;

  @Enumerated(EnumType.ordinal)
  IWebPlayerEmbeddedType webviewPlayType = IWebPlayerEmbeddedType.p2pHLS;
}

```

#### 📄 `lib/isar\schema\settings_schema.g.dart`

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsIsarModelCollection on Isar {
  IsarCollection<SettingsIsarModel> get settingsIsarModels => this.collection();
}

const SettingsIsarModelSchema = CollectionSchema(
  name: r'SettingsIsarModel',
  id: 8715387425811400240,
  properties: {
    r'hapticFeedback': PropertySchema(
      id: 0,
      name: r'hapticFeedback',
      type: IsarType.bool,
    ),
    r'isNSFW': PropertySchema(
      id: 1,
      name: r'isNSFW',
      type: IsarType.bool,
    ),
    r'mirrorIndex': PropertySchema(
      id: 2,
      name: r'mirrorIndex',
      type: IsarType.long,
    ),
    r'mirrorTextarea': PropertySchema(
      id: 3,
      name: r'mirrorTextarea',
      type: IsarType.string,
    ),
    r'onBoardingShowed': PropertySchema(
      id: 4,
      name: r'onBoardingShowed',
      type: IsarType.bool,
    ),
    r'showNsfwSetting': PropertySchema(
      id: 5,
      name: r'showNsfwSetting',
      type: IsarType.bool,
    ),
    r'showPlayTips': PropertySchema(
      id: 6,
      name: r'showPlayTips',
      type: IsarType.bool,
    ),
    r'themeMode': PropertySchema(
      id: 7,
      name: r'themeMode',
      type: IsarType.byte,
      enumMap: _SettingsIsarModelthemeModeEnumValueMap,
    ),
    r'videoKernel': PropertySchema(
      id: 8,
      name: r'videoKernel',
      type: IsarType.byte,
      enumMap: _SettingsIsarModelvideoKernelEnumValueMap,
    ),
    r'webviewPlayType': PropertySchema(
      id: 9,
      name: r'webviewPlayType',
      type: IsarType.byte,
      enumMap: _SettingsIsarModelwebviewPlayTypeEnumValueMap,
    )
  },
  estimateSize: _settingsIsarModelEstimateSize,
  serialize: _settingsIsarModelSerialize,
  deserialize: _settingsIsarModelDeserialize,
  deserializeProp: _settingsIsarModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _settingsIsarModelGetId,
  getLinks: _settingsIsarModelGetLinks,
  attach: _settingsIsarModelAttach,
  version: '3.3.2',
);

int _settingsIsarModelEstimateSize(
  SettingsIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mirrorTextarea.length * 3;
  return bytesCount;
}

void _settingsIsarModelSerialize(
  SettingsIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.hapticFeedback);
  writer.writeBool(offsets[1], object.isNSFW);
  writer.writeLong(offsets[2], object.mirrorIndex);
  writer.writeString(offsets[3], object.mirrorTextarea);
  writer.writeBool(offsets[4], object.onBoardingShowed);
  writer.writeBool(offsets[5], object.showNsfwSetting);
  writer.writeBool(offsets[6], object.showPlayTips);
  writer.writeByte(offsets[7], object.themeMode.index);
  writer.writeByte(offsets[8], object.videoKernel.index);
  writer.writeByte(offsets[9], object.webviewPlayType.index);
}

SettingsIsarModel _settingsIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsIsarModel();
  object.hapticFeedback = reader.readBool(offsets[0]);
  object.id = id;
  object.isNSFW = reader.readBool(offsets[1]);
  object.mirrorIndex = reader.readLong(offsets[2]);
  object.mirrorTextarea = reader.readString(offsets[3]);
  object.onBoardingShowed = reader.readBool(offsets[4]);
  object.showNsfwSetting = reader.readBool(offsets[5]);
  object.showPlayTips = reader.readBool(offsets[6]);
  object.themeMode = _SettingsIsarModelthemeModeValueEnumMap[
          reader.readByteOrNull(offsets[7])] ??
      SystemThemeMode.system;
  object.videoKernel = _SettingsIsarModelvideoKernelValueEnumMap[
          reader.readByteOrNull(offsets[8])] ??
      VideoKernel.webview;
  object.webviewPlayType = _SettingsIsarModelwebviewPlayTypeValueEnumMap[
          reader.readByteOrNull(offsets[9])] ??
      IWebPlayerEmbeddedType.p2pHLS;
  return object;
}

P _settingsIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (_SettingsIsarModelthemeModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SystemThemeMode.system) as P;
    case 8:
      return (_SettingsIsarModelvideoKernelValueEnumMap[
              reader.readByteOrNull(offset)] ??
          VideoKernel.webview) as P;
    case 9:
      return (_SettingsIsarModelwebviewPlayTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          IWebPlayerEmbeddedType.p2pHLS) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingsIsarModelthemeModeEnumValueMap = {
  'system': 0,
  'light': 1,
  'dark': 2,
};
const _SettingsIsarModelthemeModeValueEnumMap = {
  0: SystemThemeMode.system,
  1: SystemThemeMode.light,
  2: SystemThemeMode.dark,
};
const _SettingsIsarModelvideoKernelEnumValueMap = {
  'webview': 0,
  'mediaKit': 1,
  'iina': 2,
};
const _SettingsIsarModelvideoKernelValueEnumMap = {
  0: VideoKernel.webview,
  1: VideoKernel.mediaKit,
  2: VideoKernel.iina,
};
const _SettingsIsarModelwebviewPlayTypeEnumValueMap = {
  'p2pHLS': 0,
  'hls': 1,
  'dash': 2,
};
const _SettingsIsarModelwebviewPlayTypeValueEnumMap = {
  0: IWebPlayerEmbeddedType.p2pHLS,
  1: IWebPlayerEmbeddedType.hls,
  2: IWebPlayerEmbeddedType.dash,
};

Id _settingsIsarModelGetId(SettingsIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settingsIsarModelGetLinks(
    SettingsIsarModel object) {
  return [];
}

void _settingsIsarModelAttach(
    IsarCollection<dynamic> col, Id id, SettingsIsarModel object) {
  object.id = id;
}

extension SettingsIsarModelQueryWhereSort
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QWhere> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsIsarModelQueryWhere
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QWhereClause> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettingsIsarModelQueryFilter
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QFilterCondition> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      hapticFeedbackEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hapticFeedback',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      isNSFWEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNSFW',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mirrorIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mirrorIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mirrorIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mirrorIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mirrorTextarea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mirrorTextarea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mirrorTextarea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mirrorTextarea',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mirrorTextarea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mirrorTextarea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mirrorTextarea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mirrorTextarea',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mirrorTextarea',
        value: '',
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      mirrorTextareaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mirrorTextarea',
        value: '',
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      onBoardingShowedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onBoardingShowed',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      showNsfwSettingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showNsfwSetting',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      showPlayTipsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showPlayTips',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      themeModeEqualTo(SystemThemeMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      themeModeGreaterThan(
    SystemThemeMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      themeModeLessThan(
    SystemThemeMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      themeModeBetween(
    SystemThemeMode lower,
    SystemThemeMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      videoKernelEqualTo(VideoKernel value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoKernel',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      videoKernelGreaterThan(
    VideoKernel value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoKernel',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      videoKernelLessThan(
    VideoKernel value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoKernel',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      videoKernelBetween(
    VideoKernel lower,
    VideoKernel upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoKernel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      webviewPlayTypeEqualTo(IWebPlayerEmbeddedType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'webviewPlayType',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      webviewPlayTypeGreaterThan(
    IWebPlayerEmbeddedType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'webviewPlayType',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      webviewPlayTypeLessThan(
    IWebPlayerEmbeddedType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'webviewPlayType',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      webviewPlayTypeBetween(
    IWebPlayerEmbeddedType lower,
    IWebPlayerEmbeddedType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'webviewPlayType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettingsIsarModelQueryObject
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QFilterCondition> {}

extension SettingsIsarModelQueryLinks
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QFilterCondition> {}

extension SettingsIsarModelQuerySortBy
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QSortBy> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByHapticFeedback() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticFeedback', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByHapticFeedbackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticFeedback', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByIsNSFW() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNSFW', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByIsNSFWDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNSFW', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByMirrorIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mirrorIndex', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByMirrorIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mirrorIndex', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByMirrorTextarea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mirrorTextarea', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByMirrorTextareaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mirrorTextarea', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByOnBoardingShowed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onBoardingShowed', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByOnBoardingShowedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onBoardingShowed', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByShowNsfwSetting() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNsfwSetting', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByShowNsfwSettingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNsfwSetting', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByShowPlayTips() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPlayTips', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByShowPlayTipsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPlayTips', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByVideoKernel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoKernel', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByVideoKernelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoKernel', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByWebviewPlayType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webviewPlayType', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByWebviewPlayTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webviewPlayType', Sort.desc);
    });
  }
}

extension SettingsIsarModelQuerySortThenBy
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QSortThenBy> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByHapticFeedback() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticFeedback', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByHapticFeedbackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticFeedback', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByIsNSFW() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNSFW', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByIsNSFWDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNSFW', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByMirrorIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mirrorIndex', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByMirrorIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mirrorIndex', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByMirrorTextarea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mirrorTextarea', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByMirrorTextareaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mirrorTextarea', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByOnBoardingShowed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onBoardingShowed', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByOnBoardingShowedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onBoardingShowed', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByShowNsfwSetting() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNsfwSetting', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByShowNsfwSettingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNsfwSetting', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByShowPlayTips() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPlayTips', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByShowPlayTipsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPlayTips', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByVideoKernel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoKernel', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByVideoKernelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoKernel', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByWebviewPlayType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webviewPlayType', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByWebviewPlayTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webviewPlayType', Sort.desc);
    });
  }
}

extension SettingsIsarModelQueryWhereDistinct
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByHapticFeedback() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hapticFeedback');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByIsNSFW() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNSFW');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByMirrorIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mirrorIndex');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByMirrorTextarea({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mirrorTextarea',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByOnBoardingShowed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onBoardingShowed');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByShowNsfwSetting() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showNsfwSetting');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByShowPlayTips() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showPlayTips');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByVideoKernel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoKernel');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByWebviewPlayType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'webviewPlayType');
    });
  }
}

extension SettingsIsarModelQueryProperty
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QQueryProperty> {
  QueryBuilder<SettingsIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SettingsIsarModel, bool, QQueryOperations>
      hapticFeedbackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hapticFeedback');
    });
  }

  QueryBuilder<SettingsIsarModel, bool, QQueryOperations> isNSFWProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNSFW');
    });
  }

  QueryBuilder<SettingsIsarModel, int, QQueryOperations> mirrorIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mirrorIndex');
    });
  }

  QueryBuilder<SettingsIsarModel, String, QQueryOperations>
      mirrorTextareaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mirrorTextarea');
    });
  }

  QueryBuilder<SettingsIsarModel, bool, QQueryOperations>
      onBoardingShowedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onBoardingShowed');
    });
  }

  QueryBuilder<SettingsIsarModel, bool, QQueryOperations>
      showNsfwSettingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showNsfwSetting');
    });
  }

  QueryBuilder<SettingsIsarModel, bool, QQueryOperations>
      showPlayTipsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showPlayTips');
    });
  }

  QueryBuilder<SettingsIsarModel, SystemThemeMode, QQueryOperations>
      themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }

  QueryBuilder<SettingsIsarModel, VideoKernel, QQueryOperations>
      videoKernelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoKernel');
    });
  }

  QueryBuilder<SettingsIsarModel, IWebPlayerEmbeddedType, QQueryOperations>
      webviewPlayTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'webviewPlayType');
    });
  }
}

```

#### 📄 `lib/isar\schema\video_history_schema.dart`

```dart
import 'package:isar_community/isar.dart';

part 'video_history_schema.g.dart';

@embedded
class VideoHistoryContextIsardModel {
  VideoHistoryContextIsardModel({
    this.title = "",
    this.cover = "",
    this.pTabIndex = -1,
    this.pIndex = -1,
    this.pText = "",
    this.detailID = "",
  });

  /// 标题
  late String title;

  /// 封面
  late String cover;

  /// 播放列表当前Tab
  late int pTabIndex;

  /// 播放列表索引
  /// 如果被排序过这里的索引就不对了, 必须改为ID才正确
  late int pIndex;

  /// 播放列表文本
  late String pText;

  // TODO(d1y): impl this
  /// 总时长
  // late double duration;
  /// 播放进度
  // late double playProgress;

  /// 详情ID
  late String detailID;
}

@collection
class VideoHistoryIsarModel {
  VideoHistoryIsarModel({
    required this.isNsfw,
    required this.sid,
    required this.sourceName,
    required this.ctx,
  });

  Id id = Isar.autoIncrement;

  @Index()
  bool isNsfw;

  /// 源id
  String sid;

  /// 源名称
  /// > 通过 sid 去查名称太麻烦了
  String sourceName;

  VideoHistoryContextIsardModel ctx;
}

```

#### 📄 `lib/isar\schema\video_history_schema.g.dart`

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_history_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVideoHistoryIsarModelCollection on Isar {
  IsarCollection<VideoHistoryIsarModel> get videoHistoryIsarModels =>
      this.collection();
}

const VideoHistoryIsarModelSchema = CollectionSchema(
  name: r'VideoHistoryIsarModel',
  id: -729306225533589148,
  properties: {
    r'ctx': PropertySchema(
      id: 0,
      name: r'ctx',
      type: IsarType.object,
      target: r'VideoHistoryContextIsardModel',
    ),
    r'isNsfw': PropertySchema(
      id: 1,
      name: r'isNsfw',
      type: IsarType.bool,
    ),
    r'sid': PropertySchema(
      id: 2,
      name: r'sid',
      type: IsarType.string,
    ),
    r'sourceName': PropertySchema(
      id: 3,
      name: r'sourceName',
      type: IsarType.string,
    )
  },
  estimateSize: _videoHistoryIsarModelEstimateSize,
  serialize: _videoHistoryIsarModelSerialize,
  deserialize: _videoHistoryIsarModelDeserialize,
  deserializeProp: _videoHistoryIsarModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'isNsfw': IndexSchema(
      id: 3014435295683206251,
      name: r'isNsfw',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isNsfw',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'VideoHistoryContextIsardModel': VideoHistoryContextIsardModelSchema
  },
  getId: _videoHistoryIsarModelGetId,
  getLinks: _videoHistoryIsarModelGetLinks,
  attach: _videoHistoryIsarModelAttach,
  version: '3.3.2',
);

int _videoHistoryIsarModelEstimateSize(
  VideoHistoryIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      VideoHistoryContextIsardModelSchema.estimateSize(
          object.ctx, allOffsets[VideoHistoryContextIsardModel]!, allOffsets);
  bytesCount += 3 + object.sid.length * 3;
  bytesCount += 3 + object.sourceName.length * 3;
  return bytesCount;
}

void _videoHistoryIsarModelSerialize(
  VideoHistoryIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObject<VideoHistoryContextIsardModel>(
    offsets[0],
    allOffsets,
    VideoHistoryContextIsardModelSchema.serialize,
    object.ctx,
  );
  writer.writeBool(offsets[1], object.isNsfw);
  writer.writeString(offsets[2], object.sid);
  writer.writeString(offsets[3], object.sourceName);
}

VideoHistoryIsarModel _videoHistoryIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VideoHistoryIsarModel(
    ctx: reader.readObjectOrNull<VideoHistoryContextIsardModel>(
          offsets[0],
          VideoHistoryContextIsardModelSchema.deserialize,
          allOffsets,
        ) ??
        VideoHistoryContextIsardModel(),
    isNsfw: reader.readBool(offsets[1]),
    sid: reader.readString(offsets[2]),
    sourceName: reader.readString(offsets[3]),
  );
  object.id = id;
  return object;
}

P _videoHistoryIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectOrNull<VideoHistoryContextIsardModel>(
            offset,
            VideoHistoryContextIsardModelSchema.deserialize,
            allOffsets,
          ) ??
          VideoHistoryContextIsardModel()) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _videoHistoryIsarModelGetId(VideoHistoryIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _videoHistoryIsarModelGetLinks(
    VideoHistoryIsarModel object) {
  return [];
}

void _videoHistoryIsarModelAttach(
    IsarCollection<dynamic> col, Id id, VideoHistoryIsarModel object) {
  object.id = id;
}

extension VideoHistoryIsarModelQueryWhereSort
    on QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QWhere> {
  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterWhere>
      anyIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isNsfw'),
      );
    });
  }
}

extension VideoHistoryIsarModelQueryWhere on QueryBuilder<VideoHistoryIsarModel,
    VideoHistoryIsarModel, QWhereClause> {
  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterWhereClause>
      isNsfwEqualTo(bool isNsfw) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isNsfw',
        value: [isNsfw],
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterWhereClause>
      isNsfwNotEqualTo(bool isNsfw) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [],
              upper: [isNsfw],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [isNsfw],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [isNsfw],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [],
              upper: [isNsfw],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VideoHistoryIsarModelQueryFilter on QueryBuilder<
    VideoHistoryIsarModel, VideoHistoryIsarModel, QFilterCondition> {
  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> isNsfwEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNsfw',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
          QAfterFilterCondition>
      sidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
          QAfterFilterCondition>
      sidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sid',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sid',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sourceNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sourceNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sourceNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sourceNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sourceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sourceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
          QAfterFilterCondition>
      sourceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
          QAfterFilterCondition>
      sourceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sourceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceName',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> sourceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceName',
        value: '',
      ));
    });
  }
}

extension VideoHistoryIsarModelQueryObject on QueryBuilder<
    VideoHistoryIsarModel, VideoHistoryIsarModel, QFilterCondition> {
  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel,
      QAfterFilterCondition> ctx(FilterQuery<VideoHistoryContextIsardModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'ctx');
    });
  }
}

extension VideoHistoryIsarModelQueryLinks on QueryBuilder<VideoHistoryIsarModel,
    VideoHistoryIsarModel, QFilterCondition> {}

extension VideoHistoryIsarModelQuerySortBy
    on QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QSortBy> {
  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      sortByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.asc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      sortByIsNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.desc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      sortBySid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.asc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      sortBySidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.desc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      sortBySourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.asc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      sortBySourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.desc);
    });
  }
}

extension VideoHistoryIsarModelQuerySortThenBy
    on QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QSortThenBy> {
  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      thenByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.asc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      thenByIsNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.desc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      thenBySid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.asc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      thenBySidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sid', Sort.desc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      thenBySourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.asc);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QAfterSortBy>
      thenBySourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.desc);
    });
  }
}

extension VideoHistoryIsarModelQueryWhereDistinct
    on QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QDistinct> {
  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QDistinct>
      distinctByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNsfw');
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QDistinct>
      distinctBySid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryIsarModel, QDistinct>
      distinctBySourceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceName', caseSensitive: caseSensitive);
    });
  }
}

extension VideoHistoryIsarModelQueryProperty on QueryBuilder<
    VideoHistoryIsarModel, VideoHistoryIsarModel, QQueryProperty> {
  QueryBuilder<VideoHistoryIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VideoHistoryIsarModel, VideoHistoryContextIsardModel,
      QQueryOperations> ctxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ctx');
    });
  }

  QueryBuilder<VideoHistoryIsarModel, bool, QQueryOperations> isNsfwProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNsfw');
    });
  }

  QueryBuilder<VideoHistoryIsarModel, String, QQueryOperations> sidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sid');
    });
  }

  QueryBuilder<VideoHistoryIsarModel, String, QQueryOperations>
      sourceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceName');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const VideoHistoryContextIsardModelSchema = Schema(
  name: r'VideoHistoryContextIsardModel',
  id: -4047546311886285685,
  properties: {
    r'cover': PropertySchema(
      id: 0,
      name: r'cover',
      type: IsarType.string,
    ),
    r'detailID': PropertySchema(
      id: 1,
      name: r'detailID',
      type: IsarType.string,
    ),
    r'pIndex': PropertySchema(
      id: 2,
      name: r'pIndex',
      type: IsarType.long,
    ),
    r'pTabIndex': PropertySchema(
      id: 3,
      name: r'pTabIndex',
      type: IsarType.long,
    ),
    r'pText': PropertySchema(
      id: 4,
      name: r'pText',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 5,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _videoHistoryContextIsardModelEstimateSize,
  serialize: _videoHistoryContextIsardModelSerialize,
  deserialize: _videoHistoryContextIsardModelDeserialize,
  deserializeProp: _videoHistoryContextIsardModelDeserializeProp,
);

int _videoHistoryContextIsardModelEstimateSize(
  VideoHistoryContextIsardModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cover.length * 3;
  bytesCount += 3 + object.detailID.length * 3;
  bytesCount += 3 + object.pText.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _videoHistoryContextIsardModelSerialize(
  VideoHistoryContextIsardModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cover);
  writer.writeString(offsets[1], object.detailID);
  writer.writeLong(offsets[2], object.pIndex);
  writer.writeLong(offsets[3], object.pTabIndex);
  writer.writeString(offsets[4], object.pText);
  writer.writeString(offsets[5], object.title);
}

VideoHistoryContextIsardModel _videoHistoryContextIsardModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VideoHistoryContextIsardModel(
    cover: reader.readStringOrNull(offsets[0]) ?? "",
    detailID: reader.readStringOrNull(offsets[1]) ?? "",
    pIndex: reader.readLongOrNull(offsets[2]) ?? -1,
    pTabIndex: reader.readLongOrNull(offsets[3]) ?? -1,
    pText: reader.readStringOrNull(offsets[4]) ?? "",
    title: reader.readStringOrNull(offsets[5]) ?? "",
  );
  return object;
}

P _videoHistoryContextIsardModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? -1) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? -1) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? "") as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension VideoHistoryContextIsardModelQueryFilter on QueryBuilder<
    VideoHistoryContextIsardModel,
    VideoHistoryContextIsardModel,
    QFilterCondition> {
  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> coverEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cover',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> coverGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cover',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> coverLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cover',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> coverBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cover',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> coverStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cover',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> coverEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cover',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
          QAfterFilterCondition>
      coverContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cover',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
          QAfterFilterCondition>
      coverMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cover',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> coverIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cover',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> coverIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cover',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> detailIDEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detailID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> detailIDGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'detailID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> detailIDLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'detailID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> detailIDBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'detailID',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> detailIDStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'detailID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> detailIDEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'detailID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
          QAfterFilterCondition>
      detailIDContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'detailID',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
          QAfterFilterCondition>
      detailIDMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'detailID',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> detailIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detailID',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> detailIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'detailID',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTabIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pTabIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTabIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pTabIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTabIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pTabIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTabIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pTabIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
          QAfterFilterCondition>
      pTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
          QAfterFilterCondition>
      pTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pText',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> pTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pText',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoHistoryContextIsardModel, VideoHistoryContextIsardModel,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension VideoHistoryContextIsardModelQueryObject on QueryBuilder<
    VideoHistoryContextIsardModel,
    VideoHistoryContextIsardModel,
    QFilterCondition> {}

```

### 📂 lib/shared

#### 📄 `lib/shared\auto_injector.dart`

```dart
import 'package:auto_injector/auto_injector.dart';
// TODO: WebView播放功能已重构，不再需要自动注入
// import 'package:catmovie/shared/webplayer_placeholder.dart';

final autoInjector = AutoInjector();

void registerAutoInjector() {
  // TODO: 添加其他需要自动注入的服务
  // autoInjector.addSingleton(WebPlayerEmbedded.new);
  autoInjector.commit();
}

```

#### 📄 `lib/shared\enum.dart`

```dart
/// 主题(颜色)模式
enum SystemThemeMode {
  /// 系统自动
  system,

  /// 亮色
  light,

  /// 暗色
  dark,
}

enum VideoKernel {
  webview,
  mediaKit,
  /// macos 专属
  iina,
}

extension  VideoKernelExtension on VideoKernel {
  bool get isWebview => this == VideoKernel.webview;
  bool get isMediaKit => this == VideoKernel.mediaKit;
  bool get isIina => this == VideoKernel.iina;

  String get name {
    switch (this) {
      case VideoKernel.webview:
        return "Webview";
      case VideoKernel.mediaKit:
        return "MediaKit";
      case VideoKernel.iina:
        return "IINA";
    }
  }
}

extension SystemThemeModeExtension on SystemThemeMode {
  bool get isSytem => this == SystemThemeMode.system;
  bool get isLight => this == SystemThemeMode.light;
  bool get isDark => this == SystemThemeMode.dark;

  String get name {
    switch (this) {
      case SystemThemeMode.system:
        return "系统自动";
      case SystemThemeMode.light:
        return "亮色";
      case SystemThemeMode.dark:
        return "暗色";
    }
  }
}

enum SettingsAllKey {
  /// 主题
  themeMode,
  /// 播放器内核
  videoKernel,
  /// 是否开启成人模式
  isNsfw,
  /// 当前源(索引)
  mirrorIndex,
  /// 源链接(textarea)
  mirrorTextarea,
  /// 是否已经提示过免责声明
  showPlayTips,
  /// webview 启动的服务类型
  webviewPlayType,
  /// 首次启动
  onBoardingShowed,
  /// 震动反馈
  hapticFeedback,
  /// 是否显示绅士模式设置
  showNsfwSetting,
}

/// 镜像源状态
enum MirrorStatus {
  /// 可用
  available,

  /// 不可用
  unavailable,

  /// 未知领域
  unknow
}

// TODO: 临时替代webplayer_embedded中的枚举
enum IWebPlayerEmbeddedType {
  p2pHLS,
  hls,
  dash,
}

```

#### 📄 `lib/shared\env.dart`

```dart
import 'dart:io';

class CMEnvs {
  static String debug = "CM_DEBUG";
  static String fullHttpLog = "CM_FULL_HTTP_LOG";
}

class CMEnv {
  static bool _isTrue(String? env) {
    if (env == null) return false;
    return env == "true" || env == "1";
  }

  static bool get isDebug {
    String env = Platform.environment[CMEnvs.debug] ?? "false";
    return _isTrue(env);
  }

  static bool get enableFullHttpLog {
    String env = Platform.environment[CMEnvs.fullHttpLog] ?? "false";
    return _isTrue(env);
  }
}

```

#### 📄 `lib/shared\manage.dart`

```dart
import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/builtin/maccms/maccms.dart';
import 'package:xi/xi.dart';
import 'package:catmovie/isar/repo.dart';
import 'package:catmovie/isar/schema/mirror_schema.dart';
import 'package:catmovie/shared/enum.dart';

class SpiderManage {
  SpiderManage._internal();

  /// 扩展的源
  static List<ISpiderAdapter> extend = [];

  /// 内建支持的源
  /// 一般是需要自己去实现的源
  static List<ISpiderAdapter> builtin = list$;

  /// 合并之后的数据
  static List<ISpiderAdapter> get data {
    return [...extend, ...builtin];
  }

  /// 初始化
  static Future<void> init() async {
    final data = IsarRepository().mirrorAs.where(distinct: false).findAllSync();
    var result = data.map((item) {
      Map<String, dynamic> extraMap = {
        'jiexiUrl': item.extra.jiexiUrl ?? '',
        'gfw': item.extra.gfw ?? false,
      };

      // 添加 searchLimit
      if (item.extra.searchLimit != null) {
        extraMap['searchLimit'] = item.extra.searchLimit;
      }

      // 添加 template
      if (item.extra.template != null) {
        extraMap['template'] = item.extra.template;
      }

      // 如果有 JS 配置，添加到 extra 中
      if (item.extra.js != null) {
        extraMap['js'] = {
          'category': item.extra.js!.category,
          'home': item.extra.js!.home,
          'search': item.extra.js!.search,
          'detail': item.extra.js!.detail,
          'parseIframe': item.extra.js!.parseIframe,
        };
      }

      var meta = SourceMeta(
        id: item.sid,
        name: item.name,
        type: item.type,
        api: item.api,
        logo: item.logo,
        desc: item.desc,
        status: item.status == MirrorStatus.available,
        isNsfw: item.nsfw,
        extra: extraMap,
      );

      switch (item.type) {
        case SourceType.universal:
          return UniversalSpider(meta);
        case SourceType.maccms:
        default:
          return MacCMSSpider(meta);
      }
    }).toList();
    extend = result;
  }

  /// 添加源
  ///
  /// 返回 false 可能是源已经存在过
  static bool addItem(ISpiderAdapter item) {
    var wasAdd = true;
    var isExist = [...extend, ...builtin].any(($item) {
      // Check for duplicate by API URL
      return $item.meta.api == item.meta.api;
    });

    if (isExist) {
      wasAdd = false;
    } else {
      extend.add(item);
    }

    if (wasAdd) {
      saveToCache(extend);
    }
    return wasAdd;
  }

  /// 删除单个源
  static void removeItem(ISpiderAdapter item) {
    extend.remove(item);
    saveToCache(extend);
  }

  /// 删除 [List<String> id] 中的源
  static void remoteItemFromIDS(List<String> id) {
    extend.removeWhere((e) => id.contains(e.meta.id));
    saveToCache(extend);
  }

  /// 导出文件
  ///
  /// [full] 是否全量导出(nsfw 是否导出)
  static String export({bool full = false}) {
    List<Map<String, dynamic>> to = extend.map(
      (e) {
        return {
          "name": e.meta.name,
          "logo": e.meta.logo,
          "desc": e.meta.desc,
          "nsfw": e.meta.isNsfw,
          "api": e.meta.api,
          "id": e.meta.id,
          "status": e.meta.status,
          "type": e.meta.type.name,
          "extra": e.meta.extra,
        };
      },
    ).toList();
    if (!full) {
      to = to.where((element) {
        return !(element['nsfw'] ?? false);
      }).toList();
    }
    String result = jsonEncode(to);
    return result;
  }

  /// 删除不可用源
  /// [kvHash] 映射的缓存
  /// 返回被删除的 [List<String> ids]
  static List<String> removeUnavailable(Map<String, bool> kvHash) {
    List<String> result = [];
    List<SourceMeta> newData = extend
        .map((e) {
          String id = e.meta.id;
          bool status = kvHash[id] ?? e.meta.status;
          return SourceMeta(
            id: id,
            name: e.meta.name,
            type: e.meta.type,
            api: e.meta.api,
            logo: e.meta.logo,
            desc: e.meta.desc,
            isNsfw: e.meta.isNsfw,
            status: status,
            extra: e.meta.extra,
          );
        })
        .toList()
        .where((item) {
          String id = item.id;
          bool status = item.status;
          if (!status) {
            result.add(id);
          }
          return status;
        })
        .toList();
    extend.removeWhere((e) => result.contains(e.meta.id));
    mergeSpiderFromMeta(newData);
    return result;
  }

  /// 删除所有源
  static void cleanAll({bool saveToCahe = false}) {
    extend = [];
    if (saveToCahe) {
      mergeSpiderFromMeta([]);
    }
  }

  /// 保存缓存
  /// [该方法只可用来保存第三方源]
  /// 适用于所有 ISpiderAdapter 实现
  static void saveToCache(List<ISpiderAdapter> saves) {
    List<SourceMeta> to = saves.map((e) => e.meta).toList();
    mergeSpiderFromMeta(to);
  }

  static void mergeSpiderFromMeta(List<SourceMeta> data) {
    var output = data.map((item) {
      var extra = MirrorExtra()
      ..jiexiUrl = item.extra['jiexiUrl']
      ..gfw = item.extra['gfw']
      ..searchLimit = item.extra['searchLimit']
      ..template = item.extra['template'];

      // 如果有 JS 配置，保存到 MirrorExtra 中
      if (item.extra.containsKey('js') && item.extra['js'] is Map) {
        var jsMap = item.extra['js'] as Map<String, dynamic>;
        String category = "";
        var _category = jsMap['category'];
        if (_category is String) {
          category = _category;
        } else if (_category is List) {
          category = jsonEncode(_category);
        }
        extra.js = MirrorExtraJS()
          ..category = category
          ..home = jsMap['home'] ?? ''
          ..search = jsMap['search'] ?? ''
          ..detail = jsMap['detail'] ?? ''
          ..parseIframe = jsMap['parseIframe'] ?? '';
      }

      return MirrorIsarModel(
        sid: item.id,
        name: item.name,
        logo: item.logo,
        api: item.api,
        desc: item.desc,
        nsfw: item.isNsfw,
        status: item.status ? MirrorStatus.available : MirrorStatus.unavailable,
        type: item.type,
        extra: extra,
      );
    }).toList();
    IsarRepository().safeWrite(() {
      IsarRepository().mirrorAs.clearSync();
      IsarRepository().mirrorAs.putAllSync(output);
    });
  }
}

```

#### 📄 `lib/shared\webplayer_placeholder.dart`

```dart
import 'dart:io';
import 'package:catmovie/shared/enum.dart';

// TODO: 这是webplayer_embedded的临时占位符实现
// 后续需要使用flutter_inappwebview或其他方案完整实现
class WebPlayerEmbedded {
  static final WebPlayerEmbedded _instance = WebPlayerEmbedded._internal();
  
  factory WebPlayerEmbedded() {
    return _instance;
  }
  
  WebPlayerEmbedded._internal();
  
  /// 检查服务器是否运行
  Future<bool> checkRunning() async {
    // TODO: 实现实际的检查逻辑
    return false;
  }
  
  /// 创建HTTP服务器
  Future<HttpServer?> createServer({
    required Function(dynamic) onMessage,
  }) async {
    // TODO: 实现实际的服务器创建逻辑
    try {
      final server = await HttpServer.bind('localhost', 0);
      return server;
    } catch (e) {
      print('创建服务器失败: $e');
      return null;
    }
  }
  
  /// 生成播放器URL
  String generatePlayerUrl(IWebPlayerEmbeddedType type, String url) {
    // TODO: 实现实际的URL生成逻辑
    return url;
  }
  
  /// 释放资源
  void dispose() {
    // TODO: 实现实际的资源释放逻辑
  }
}

```

#### 📄 `lib/shared\webview_play_manager.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:xi/xi.dart';
import 'package:catmovie/shared/enum.dart';

/// WebView播放管理器
/// 使用flutter_inappwebview替代desktop_webview_window和webplayer_embedded
class WebViewPlayManager {
  static final WebViewPlayManager _instance = WebViewPlayManager._internal();
  
  factory WebViewPlayManager() {
    return _instance;
  }
  
  WebViewPlayManager._internal();
  
  InAppWebViewController? _controller;
  HttpServer? _httpServer;
  bool _isInitialized = false;
  
  /// 消息回调
  Function(dynamic)? onMessageCallback;
  
  /// 初始化HTTP服务器
  Future<HttpServer?> initHttpServer({
    required Function(dynamic) onMessage,
  }) async {
    if (_httpServer != null) {
      return _httpServer;
    }
    
    try {
      onMessageCallback = onMessage;
      _httpServer = await HttpServer.bind('localhost', 0);
      debugPrint('HTTP服务器启动成功，端口: ${_httpServer!.port}');
      
      // 监听请求
      _httpServer!.listen((HttpRequest request) {
        _handleRequest(request);
      });
      
      return _httpServer;
    } catch (e) {
      debugPrint('创建HTTP服务器失败: $e');
      return null;
    }
  }
  
  /// 处理HTTP请求
  void _handleRequest(HttpRequest request) {
    String path = request.uri.path;
    
    // 提供iframe.html页面
    if (path == '/assets/iframe.html') {
      String url = request.uri.queryParameters['url'] ?? '';
      String html = _generateIframeHtml(url);
      
      request.response.headers.contentType = ContentType.html;
      request.response.write(html);
      request.response.close();
    } else {
      request.response.statusCode = 404;
      request.response.close();
    }
  }
  
  /// 生成iframe HTML页面
  String _generateIframeHtml(String videoUrl) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>视频播放</title>
  <style>
    body, html {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #000;
    }
    #video-container {
      width: 100%;
      height: 100%;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    iframe {
      width: 100%;
      height: 100%;
      border: none;
    }
    video {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }
  </style>
</head>
<body>
  <div id="video-container">
    <video id="player" controls autoplay></video>
  </div>
  
  <script>
    var currentVideoUrl = '$videoUrl';
    var player = document.getElementById('player');
    
    // 设置视频源
    function setVideoSource(url) {
      currentVideoUrl = url;
      player.src = url;
      player.play();
    }
    
    // 初始化
    if (currentVideoUrl) {
      setVideoSource(currentVideoUrl);
    }
    
    // 暴露给Flutter的方法
    window.setActiveWithPlaylist = function(url) {
      setVideoSource(url);
    };
    
    window.setActionText = function(text) {
      console.log('当前播放: ' + text);
    };
    
    // 监听视频事件
    player.addEventListener('play', function() {
      console.log('视频开始播放');
    });
    
    player.addEventListener('pause', function() {
      console.log('视频暂停');
    });
    
    player.addEventListener('error', function(e) {
      console.error('视频播放错误:', e);
    });
  </script>
</body>
</html>
''';
  }
  
  /// 生成播放器URL
  String generatePlayerUrl(IWebPlayerEmbeddedType type, String url) {
    // 对于m3u8等格式，直接返回URL，由video标签处理
    return url;
  }
  
  /// 检查服务器是否运行
  Future<bool> checkRunning() async {
    return _httpServer != null;
  }
  
  /// 创建并显示WebView窗口
  Future<void> showWebView({
    required String url,
    required String title,
    required BuildContext context,
    List<String>? playlist,
    Function(String)? onUrlChanged,
  }) async {
    if (!_isInitialized) {
      await _initialize();
    }
    
    // 在对话框中显示WebView
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  useHybridComposition: true,
                  safeBrowsingEnabled: false,
                ),
                onWebViewCreated: (controller) {
                  _controller = controller;
                  debugPrint('WebView创建成功');
                  
                  // 注入播放列表脚本
                  if (playlist != null && playlist.isNotEmpty) {
                    _injectPlaylistScript(playlist);
                  }
                },
                onLoadStart: (controller, url) {
                  debugPrint('开始加载: $url');
                },
                onLoadStop: (controller, url) async {
                  debugPrint('加载完成: $url');
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    debugPrint('页面加载完成');
                  }
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  String newUrl = navigationAction.request.url?.toString() ?? '';
                  debugPrint('URL变更: $newUrl');
                  
                  // 通知URL变更
                  if (onUrlChanged != null) {
                    onUrlChanged(newUrl);
                  }
                  
                  return NavigationActionPolicy.ALLOW;
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint('WebView Console: ${consoleMessage.message}');
                },
              ),
              // 关闭按钮
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    dispose();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 注入播放列表脚本
  void _injectPlaylistScript(List<String> playlist) {
    if (_controller == null) return;
    
    String script = '''
      window.playlist = ${jsonEncode(playlist)};
      window.setActiveWithPlaylist = function(url) {
        console.log('切换到: ' + url);
      };
      window.setActionText = function(text) {
        console.log('当前: ' + text);
      };
    ''';
    
    _controller!.evaluateJavascript(source: script);
  }
  
  /// 执行JavaScript
  Future<dynamic> evaluateJavaScript(String javascript) async {
    if (_controller == null) return null;
    return await _controller!.evaluateJavascript(source: javascript);
  }
  
  /// 初始化
  Future<void> _initialize() async {
    if (!kIsWeb && Platform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
    _isInitialized = true;
  }
  
  /// 释放资源
  void dispose() {
    _controller?.dispose();
    _controller = null;
    
    if (_httpServer != null) {
      try {
        _httpServer!.close();
        _httpServer = null;
        debugPrint('HTTP服务器已关闭');
      } catch (e) {
        debugPrint('关闭HTTP服务器失败: $e');
      }
    }
    
    _isInitialized = false;
    onMessageCallback = null;
  }
}

```

### 📂 lib/utils

#### 📄 `lib/utils\boop.dart`

```dart
// https://pub.dev/packages/haptic_feedback
// https://github.com/istornz/flutter_gaimon

import 'package:catmovie/shared/enum.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:catmovie/app/extension.dart';

class Boop {
  late bool canVibrate;

  bool enabled = true;

  bool setEnabled(bool value) {
    if (value == enabled) return false;
    updateSetting(SettingsAllKey.hapticFeedback, value);
    enabled = value;
    return true;
  }

  Future<bool> init() async {
    canVibrate = await Haptics.canVibrate();
    return canVibrate;
  }

  Future<void> call(HapticsType type, {bool force = false}) async {
    if ((!canVibrate || !enabled) && !force) return;
    await Haptics.vibrate(type);
  }

  Future<void> selection() async {
    await call(HapticsType.selection);
  }

  Future<void> success() async {
    await call(HapticsType.success);
  }

  Future<void> warning() async {
    await call(HapticsType.warning);
  }

  Future<void> error() async {
    await call(HapticsType.error);
  }
}

var boop = Boop();

```

#### 📄 `lib/utils\once.dart`

```dart
import 'package:flutter/cupertino.dart';

VoidCallback once(VoidCallback cb) {
  var exec = false;
  return () {
    if (exec) return;
    exec = true;
    cb();
  };
}

ValueChanged<T> onceWithValue<T>(ValueChanged<T> cb) {
  var exec = false;
  return (T value) {
    if (exec) return;
    exec = true;
    cb(value);
  };
}
```

#### 📄 `lib/utils\screen_helper.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 屏幕方向
enum ScreenDirction {
  /// 横屏
  x,

  /// 竖屏
  y
}

/// 切换屏幕方向
/// [action] 操作的方向
/// [beforeTime] 在执行该操作时, 猜测若有其他异步操作, 会卡死 `Flutter Engine`
void execScreenDirction(
  ScreenDirction action, [
  beforeTime = const Duration(seconds: 1),
]) {
  /// 为避免卡死, 在开发模式下不执行操作
  if (kReleaseMode) {
    Future.delayed(beforeTime, () {
      switch (action) {
        case ScreenDirction.x:
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ]);
          break;
        case ScreenDirction.y:
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
          break;
        default:
      }
      SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    });
  }
}

```

### 📂 lib/widget

#### 📄 `lib/widget\flutter_custom_license_page.dart`

```dart
// The lib copy by: https://github.com/theswerd/flutter_custom_license_page

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart' hide Flow;

/// A page that shows licenses for software used by the application.
///
/// To show a [CustomLicensePage], use [showCustomLicensePage].
/// The licenses shown on the [CustomLicensePage] are those returned by the
/// [LicenseRegistry] API, which can be used to add more licenses to the list.
class CustomLicensePage extends StatefulWidget {
  const CustomLicensePage(this.builder, {super.key});

  final Widget Function(BuildContext, AsyncSnapshot<LicenseData>) builder;

  @override
  createState() => _CustomLicensePageState();
}

class _CustomLicensePageState extends State<CustomLicensePage> {
  final ValueNotifier<int> selectedId = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LicenseData>(
      future: licenses,
      builder: widget.builder,
    );
  }

  final Future<LicenseData> licenses = LicenseRegistry.licenses
      .fold<LicenseData>(
        LicenseData(),
        (LicenseData prev, LicenseEntry license) => prev..addLicense(license),
      )
      .then((LicenseData licenseData) => licenseData..sortPackages());
}

/// This is a collection of licenses and the packages to which they apply.
/// [packageLicenseBindings] records the m+:n+ relationship between the license
/// and packages as a map of package names to license indexes.
class LicenseData {
  final List<LicenseEntry> licenses = <LicenseEntry>[];
  final Map<String, List<int>> packageLicenseBindings = <String, List<int>>{};
  final List<String> packages = <String>[];

  // Special treatment for the first package since it should be the package
  // for delivered application.
  String firstPackage = "";

  void addLicense(LicenseEntry entry) {
    // Before the license can be added, we must first record the packages to
    // which it belongs.
    for (final String package in entry.packages) {
      _addPackage(package);
      // Bind this license to the package using the next index value. This
      // creates a contract that this license must be inserted at this same
      // index value.
      packageLicenseBindings[package]!.add(licenses.length);
    }
    licenses.add(entry); // Completion of the contract above.
  }

  /// Add a package and initialise package license binding. This is a no-op if
  /// the package has been seen before.
  void _addPackage(String package) {
    if (!packageLicenseBindings.containsKey(package)) {
      packageLicenseBindings[package] = <int>[];
      firstPackage;
      packages.add(package);
    }
  }

  /// Sort the packages using some comparison method, or by the default manner,
  /// which is to put the application package first, followed by every other
  /// package in case-insensitive alphabetical order.
  void sortPackages([int Function(String a, String b)? compare]) {
    packages.sort(compare ??
        (String a, String b) {
          // Based on how LicenseRegistry currently behaves, the first package
          // returned is the end user application license. This should be
          // presented first in the list. So here we make sure that first package
          // remains at the front regardless of alphabetical sorting.
          if (a == firstPackage) {
            return -1;
          }
          if (b == firstPackage) {
            return 1;
          }
          return a.toLowerCase().compareTo(b.toLowerCase());
        });
  }
}

```

#### 📂 lib/widget\simple_html

#### 📄 `lib/widget\simple_html\custom_render.dart`

```dart
import 'package:collection/collection.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './src/utils.dart';

import 'html_parser.dart';
import 'src/interactable_element.dart';
import 'src/layout_element.dart';
import 'src/replaced_element.dart';
import 'src/styled_element.dart';
import 'style.dart';

typedef CustomRenderMatcher = bool Function(RenderContext context);

CustomRenderMatcher tagMatcher(String tag) => (context) {
      return context.tree.element?.localName == tag;
    };

CustomRenderMatcher blockElementMatcher() => (context) {
      return context.tree.style.display == Display.BLOCK &&
          (context.tree.children.isNotEmpty ||
              context.tree.element?.localName == "hr");
    };

CustomRenderMatcher listElementMatcher() => (context) {
      return context.tree.style.display == Display.LIST_ITEM;
    };

CustomRenderMatcher replacedElementMatcher() => (context) {
      return context.tree is ReplacedElement;
    };

CustomRenderMatcher dataUriMatcher(
        {String? encoding = 'base64', String? mime}) =>
    (context) {
      if (context.tree.element?.attributes == null ||
          _src(context.tree.element!.attributes.cast()) == null) {
        return false;
      }
      final dataUri = _dataUriFormat
          .firstMatch(_src(context.tree.element!.attributes.cast())!);
      return dataUri != null &&
          dataUri.namedGroup('mime') != "image/svg+xml" &&
          (mime == null || dataUri.namedGroup('mime') == mime) &&
          (encoding == null || dataUri.namedGroup('encoding') == ';$encoding');
    };

CustomRenderMatcher networkSourceMatcher({
  List<String> schemas = const ["https", "http"],
  List<String>? domains,
  String? extension,
}) =>
    (context) {
      if (context.tree.element?.attributes.cast() == null ||
          _src(context.tree.element!.attributes.cast()) == null) {
        return false;
      }
      try {
        final src = Uri.parse(_src(context.tree.element!.attributes.cast())!);
        return schemas.contains(src.scheme) &&
            (domains == null || domains.contains(src.host)) &&
            (extension == null || src.path.endsWith(".$extension"));
      } catch (e) {
        return false;
      }
    };

CustomRenderMatcher assetUriMatcher() => (context) =>
    context.tree.element?.attributes.cast() != null &&
    _src(context.tree.element!.attributes.cast()) != null &&
    _src(context.tree.element!.attributes.cast())!.startsWith("asset:") &&
    !_src(context.tree.element!.attributes.cast())!.endsWith(".svg");

CustomRenderMatcher textContentElementMatcher() => (context) {
      return context.tree is TextContentElement;
    };

CustomRenderMatcher interactableElementMatcher() => (context) {
      return context.tree is InteractableElement;
    };

CustomRenderMatcher layoutElementMatcher() => (context) {
      return context.tree is LayoutElement;
    };

CustomRenderMatcher verticalAlignMatcher() => (context) {
      return context.tree.style.verticalAlign != null &&
          context.tree.style.verticalAlign != VerticalAlign.BASELINE;
    };

CustomRenderMatcher fallbackMatcher() => (context) {
      return true;
    };

class CustomRender {
  final InlineSpan Function(RenderContext, List<InlineSpan> Function())?
      inlineSpan;
  final Widget Function(RenderContext, List<InlineSpan> Function())? widget;

  CustomRender.inlineSpan({
    required this.inlineSpan,
  }) : widget = null;

  CustomRender.widget({
    required this.widget,
  }) : inlineSpan = null;
}

class SelectableCustomRender extends CustomRender {
  final TextSpan Function(RenderContext, List<TextSpan> Function()) textSpan;

  SelectableCustomRender.fromTextSpan({
    required this.textSpan,
  }) : super.inlineSpan(inlineSpan: null);
}

CustomRender blockElementRender({Style? style, List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(inlineSpan: (context, buildChildren) {
      if (context.parser.selectable) {
        return TextSpan(
          style: context.style.generateTextStyle(),
          children: (children as List<TextSpan>?) ??
              context.tree.children
                  .expandIndexed((i, childTree) => [
                        if (childTree.style.display == Display.BLOCK &&
                            i > 0 &&
                            context.tree.children[i - 1] is ReplacedElement)
                          const TextSpan(text: "\n"),
                        context.parser.parseTree(context, childTree),
                        if (i != context.tree.children.length - 1 &&
                            childTree.style.display == Display.BLOCK &&
                            childTree.element?.localName != "html" &&
                            childTree.element?.localName != "body")
                          const TextSpan(text: "\n"),
                      ])
                  .toList(),
        );
      }
      return WidgetSpan(
          child: ContainerSpan(
        parseKey: context.key,
        newContext: context,
        style: style ?? context.tree.style,
        shrinkWrap: context.parser.shrinkWrap,
        children: children ??
            context.tree.children
                .expandIndexed((i, childTree) => [
                      if (context.parser.shrinkWrap &&
                          childTree.style.display == Display.BLOCK &&
                          i > 0 &&
                          context.tree.children[i - 1] is ReplacedElement)
                        const TextSpan(text: "\n"),
                      context.parser.parseTree(context, childTree),
                      if (i != context.tree.children.length - 1 &&
                          childTree.style.display == Display.BLOCK &&
                          childTree.element?.localName != "html" &&
                          childTree.element?.localName != "body")
                        const TextSpan(text: "\n"),
                    ])
                .toList(),
      ));
    });

CustomRender listElementRender(
        {Style? style, Widget? child, List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => WidgetSpan(
              child: ContainerSpan(
                parseKey: context.key,
                newContext: context,
                style: style ?? context.tree.style,
                shrinkWrap: context.parser.shrinkWrap,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  textDirection:
                      style?.direction ?? context.tree.style.direction,
                  children: [
                    (style?.listStylePosition ??
                                context.tree.style.listStylePosition) ==
                            ListStylePosition.OUTSIDE
                        ? Padding(
                            padding: style?.padding?.nonNegative ??
                                context.tree.style.padding?.nonNegative ??
                                EdgeInsets.only(
                                    left: (style?.direction ??
                                                context.tree.style.direction) !=
                                            TextDirection.rtl
                                        ? 10.0
                                        : 0.0,
                                    right: (style?.direction ??
                                                context.tree.style.direction) ==
                                            TextDirection.rtl
                                        ? 10.0
                                        : 0.0),
                            child: style?.markerContent ??
                                context.style.markerContent)
                        : const SizedBox(height: 0, width: 0),
                    const Text("\u0020",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.w400)),
                    Expanded(
                        child: Padding(
                            padding: (style?.listStylePosition ??
                                        context.tree.style.listStylePosition) ==
                                    ListStylePosition.INSIDE
                                ? EdgeInsets.only(
                                    left: (style?.direction ??
                                                context.tree.style.direction) !=
                                            TextDirection.rtl
                                        ? 10.0
                                        : 0.0,
                                    right: (style?.direction ??
                                                context.tree.style.direction) ==
                                            TextDirection.rtl
                                        ? 10.0
                                        : 0.0)
                                : EdgeInsets.zero,
                            child: StyledText(
                              textSpan: TextSpan(
                                children: _getListElementChildren(
                                    style?.listStylePosition ??
                                        context.tree.style.listStylePosition,
                                    buildChildren)
                                  ..insertAll(
                                      0,
                                      context.tree.style.listStylePosition ==
                                              ListStylePosition.INSIDE
                                          ? [
                                              WidgetSpan(
                                                  alignment:
                                                      PlaceholderAlignment
                                                          .middle,
                                                  child: style?.markerContent ??
                                                      context.style
                                                          .markerContent ??
                                                      const SizedBox(
                                                          height: 0, width: 0))
                                            ]
                                          : []),
                                style: style?.generateTextStyle() ??
                                    context.style.generateTextStyle(),
                              ),
                              style: style ?? context.style,
                              renderContext: context,
                            )))
                  ],
                ),
              ),
            ));

CustomRender replacedElementRender(
        {PlaceholderAlignment? alignment,
        TextBaseline? baseline,
        Widget? child}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => WidgetSpan(
              alignment:
                  alignment ?? (context.tree as ReplacedElement).alignment,
              baseline: baseline ?? TextBaseline.alphabetic,
              child:
                  child ?? (context.tree as ReplacedElement).toWidget(context)!,
            ));

CustomRender textContentElementRender({String? text}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => TextSpan(
              style: context.style.generateTextStyle(),
              text: (text ?? (context.tree as TextContentElement).text)
                  ?.transformed(context.tree.style.textTransform),
            ));

CustomRender base64ImageRender() =>
    CustomRender.widget(widget: (context, buildChildren) {
      final decodedImage = base64.decode(
          _src(context.tree.element!.attributes.cast())!
              .split("base64,")[1]
              .trim());
      precacheImage(
        MemoryImage(decodedImage),
        context.buildContext,
        onError: (exception, StackTrace? stackTrace) {
          context.parser.onImageError?.call(exception, stackTrace);
        },
      );
      final widget = Image.memory(
        decodedImage,
        frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return Text(_alt(context.tree.element!.attributes.cast()) ?? "",
                style: context.style.generateTextStyle());
          }
          return child;
        },
      );
      return Builder(
          key: context.key,
          builder: (buildContext) {
            return GestureDetector(
              child: widget,
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(
                    _src(context.tree.element!.attributes.cast())!
                        .split("base64,")[1]
                        .trim(),
                    context,
                    context.tree.element!.attributes.cast(),
                    context.tree.element);
              },
            );
          });
    });

CustomRender assetImageRender({
  double? width,
  double? height,
}) =>
    CustomRender.widget(widget: (context, buildChildren) {
      final assetPath = _src(context.tree.element!.attributes.cast())!
          .replaceFirst('asset:', '');
      final widget = Image.asset(
        assetPath,
        width: width ?? _width(context.tree.element!.attributes.cast()),
        height: height ?? _height(context.tree.element!.attributes.cast()),
        frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return Text(_alt(context.tree.element!.attributes.cast()) ?? "",
                style: context.style.generateTextStyle());
          }
          return child;
        },
      );
      return Builder(
          key: context.key,
          builder: (buildContext) {
            return GestureDetector(
              child: widget,
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(
                    assetPath,
                    context,
                    context.tree.element!.attributes.cast(),
                    context.tree.element);
              },
            );
          });
    });

CustomRender networkImageRender({
  Map<String, String>? headers,
  String Function(String?)? mapUrl,
  double? width,
  double? height,
  Widget Function(String?)? altWidget,
  Widget Function()? loadingWidget,
}) =>
    CustomRender.widget(widget: (context, buildChildren) {
      final src = mapUrl?.call(_src(context.tree.element!.attributes.cast())) ??
          _src(context.tree.element!.attributes.cast())!;
      Completer<Size> completer = Completer();
      if (context.parser.cachedImageSizes[src] != null) {
        completer.complete(context.parser.cachedImageSizes[src]);
      } else {
        Image image = Image.network(src, frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            if (!completer.isCompleted) {
              completer.completeError("error");
            }
            return child;
          } else {
            return child;
          }
        });

        ImageStreamListener? listener;
        listener =
            ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
          var myImage = imageInfo.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          if (!completer.isCompleted) {
            context.parser.cachedImageSizes[src] = size;
            completer.complete(size);
            image.image
                .resolve(const ImageConfiguration())
                .removeListener(listener!);
          }
        }, onError: (object, stacktrace) {
          if (!completer.isCompleted) {
            completer.completeError(object);
            image.image
                .resolve(const ImageConfiguration())
                .removeListener(listener!);
          }
        });

        image.image.resolve(const ImageConfiguration()).addListener(listener);
      }
      final attributes =
          context.tree.element!.attributes.cast<String, String>();
      final widget = FutureBuilder<Size>(
        future: completer.future,
        initialData: context.parser.cachedImageSizes[src],
        builder: (BuildContext buildContext, AsyncSnapshot<Size> snapshot) {
          if (snapshot.hasData) {
            return Container(
              constraints: BoxConstraints(
                  maxWidth: width ?? _width(attributes) ?? snapshot.data!.width,
                  maxHeight:
                      (width ?? _width(attributes) ?? snapshot.data!.width) /
                          _aspectRatio(attributes, snapshot)),
              child: AspectRatio(
                aspectRatio: _aspectRatio(attributes, snapshot),
                child: Image.network(
                  src,
                  headers: headers,
                  width: width ?? _width(attributes) ?? snapshot.data!.width,
                  height: height ?? _height(attributes),
                  frameBuilder: (ctx, child, frame, _) {
                    if (frame == null) {
                      return altWidget?.call(_alt(attributes)) ??
                          Text(_alt(attributes) ?? "",
                              style: context.style.generateTextStyle());
                    }
                    return child;
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return altWidget
                    ?.call(_alt(context.tree.element!.attributes.cast())) ??
                Text(_alt(context.tree.element!.attributes.cast()) ?? "",
                    style: context.style.generateTextStyle());
          } else {
            return loadingWidget?.call() ?? const CircularProgressIndicator();
          }
        },
      );
      return Builder(
          key: context.key,
          builder: (buildContext) {
            return GestureDetector(
              child: widget,
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(
                    src,
                    context,
                    context.tree.element!.attributes.cast(),
                    context.tree.element);
              },
            );
          });
    });

CustomRender interactableElementRender({List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => TextSpan(
              children: children ??
                  (context.tree as InteractableElement)
                      .children
                      .map((tree) => context.parser.parseTree(context, tree))
                      .map((childSpan) {
                    return _getInteractableChildren(
                        context,
                        context.tree as InteractableElement,
                        childSpan,
                        context.style
                            .generateTextStyle()
                            .merge(childSpan.style));
                  }).toList(),
            ));

CustomRender layoutElementRender({Widget? child}) => CustomRender.inlineSpan(
    inlineSpan: (context, buildChildren) => WidgetSpan(
          child: child ?? (context.tree as LayoutElement).toWidget(context)!,
        ));

CustomRender verticalAlignRender(
        {double? verticalOffset, Style? style, List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => WidgetSpan(
              child: Transform.translate(
                key: context.key,
                offset: Offset(
                    0, verticalOffset ?? _getVerticalOffset(context.tree)),
                child: StyledText(
                  textSpan: TextSpan(
                    style: style?.generateTextStyle() ??
                        context.style.generateTextStyle(),
                    children: children ?? buildChildren.call(),
                  ),
                  style: context.style,
                  renderContext: context,
                ),
              ),
            ));

CustomRender fallbackRender({Style? style, List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => TextSpan(
              style: style?.generateTextStyle() ??
                  context.style.generateTextStyle(),
              children: context.tree.children
                  .expand((tree) => [
                        context.parser.parseTree(context, tree),
                        if (tree.style.display == Display.BLOCK &&
                            tree.element?.parent?.localName != "th" &&
                            tree.element?.parent?.localName != "td" &&
                            tree.element?.localName != "html" &&
                            tree.element?.localName != "body")
                          const TextSpan(text: "\n"),
                      ])
                  .toList(),
            ));

final Map<CustomRenderMatcher, CustomRender> defaultRenders = {
  blockElementMatcher(): blockElementRender(),
  listElementMatcher(): listElementRender(),
  textContentElementMatcher(): textContentElementRender(),
  dataUriMatcher(): base64ImageRender(),
  assetUriMatcher(): assetImageRender(),
  networkSourceMatcher(): networkImageRender(),
  replacedElementMatcher(): replacedElementRender(),
  interactableElementMatcher(): interactableElementRender(),
  layoutElementMatcher(): layoutElementRender(),
  verticalAlignMatcher(): verticalAlignRender(),
  fallbackMatcher(): fallbackRender(),
};

List<InlineSpan> _getListElementChildren(
    ListStylePosition? position, Function() buildChildren) {
  List<InlineSpan> children = buildChildren.call();
  if (position == ListStylePosition.INSIDE) {
    const tabSpan = WidgetSpan(
      child: Text("\t",
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w400)),
    );
    children.insert(0, tabSpan);
  }
  return children;
}

InlineSpan _getInteractableChildren(RenderContext context,
    InteractableElement tree, InlineSpan childSpan, TextStyle childStyle) {
  if (childSpan is TextSpan) {
    return TextSpan(
      text: childSpan.text,
      children: childSpan.children
          ?.map((e) => _getInteractableChildren(
              context, tree, e, childStyle.merge(childSpan.style)))
          .toList(),
      style: context.style.generateTextStyle().merge(childSpan.style == null
          ? childStyle
          : childStyle.merge(childSpan.style)),
      semanticsLabel: childSpan.semanticsLabel,
      recognizer: TapGestureRecognizer()
        ..onTap = context.parser.internalOnAnchorTap != null
            ? () => context.parser.internalOnAnchorTap!(
                tree.href, context, tree.attributes, tree.element)
            : null,
    );
  } else {
    return WidgetSpan(
      child: MultipleTapGestureDetector(
        onTap: context.parser.internalOnAnchorTap != null
            ? () => context.parser.internalOnAnchorTap!(
                tree.href, context, tree.attributes, tree.element)
            : null,
        child: GestureDetector(
          key: context.key,
          onTap: context.parser.internalOnAnchorTap != null
              ? () => context.parser.internalOnAnchorTap!(
                  tree.href, context, tree.attributes, tree.element)
              : null,
          child: (childSpan as WidgetSpan).child,
        ),
      ),
    );
  }
}

final _dataUriFormat = RegExp(
    "^(?<scheme>data):(?<mime>image/[\\w+-.]+)(?<encoding>;base64)?,(?<data>.*)");

double _getVerticalOffset(StyledElement tree) {
  switch (tree.style.verticalAlign) {
    case VerticalAlign.SUB:
      return tree.style.fontSize!.size! / 2.5;
    case VerticalAlign.SUPER:
      return tree.style.fontSize!.size! / -2.5;
    default:
      return 0;
  }
}

String? _src(Map<String, String> attributes) {
  return attributes["src"];
}

String? _alt(Map<String, String> attributes) {
  return attributes["alt"];
}

double? _height(Map<String, String> attributes) {
  final heightString = attributes["height"];
  return heightString == null
      ? heightString as double?
      : double.tryParse(heightString);
}

double? _width(Map<String, String> attributes) {
  final widthString = attributes["width"];
  return widthString == null
      ? widthString as double?
      : double.tryParse(widthString);
}

double _aspectRatio(
    Map<String, String> attributes, AsyncSnapshot<Size> calculated) {
  final heightString = attributes["height"];
  final widthString = attributes["width"];
  if (heightString != null && widthString != null) {
    final height = double.tryParse(heightString);
    final width = double.tryParse(widthString);
    return height == null || width == null
        ? calculated.data!.aspectRatio
        : width / height;
  }
  return calculated.data!.aspectRatio;
}

extension ClampedEdgeInsets on EdgeInsetsGeometry {
  EdgeInsetsGeometry get nonNegative =>
      clamp(EdgeInsets.zero, const EdgeInsets.all(double.infinity));
}

```

#### 📄 `lib/widget\simple_html\flutter_html.dart`

```dart
library flutter_html;

import 'package:flutter/material.dart';
import './custom_render.dart';
import './html_parser.dart';
import './src/html_elements.dart';
import './style.dart';
import 'package:html/dom.dart' as dom;

export './custom_render.dart';
//export render context api
export './html_parser.dart';
//export render context api
//export src for advanced custom render uses (e.g. casting context.tree)
export './src/anchor.dart';
export './src/interactable_element.dart';
export './src/layout_element.dart';
export './src/replaced_element.dart';
export './src/styled_element.dart';
//export style api
export './style.dart';

class Html extends StatefulWidget {
  /// The `Html` widget takes HTML as input and displays a RichText
  /// tree of the parsed HTML content.
  ///
  /// **Attributes**
  /// **data** *required* takes in a String of HTML data (required only for `Html` constructor).
  /// **document** *required* takes in a Document of HTML data (required only for `Html.fromDom` constructor).
  ///
  /// **onLinkTap** This function is called whenever a link (`<a href>`)
  /// is tapped.
  /// **customRender** This function allows you to return your own widgets
  /// for existing or custom HTML tags.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/All-About-customRender) for more info.
  ///
  /// **onImageError** This is called whenever an image fails to load or
  /// display on the page.
  ///
  /// **shrinkWrap** This makes the Html widget take up only the width it
  /// needs and no more.
  ///
  /// **onImageTap** This is called whenever an image is tapped.
  ///
  /// **tagsList** Tag names in this array will be the only tags rendered. By default all supported HTML tags are rendered.
  ///
  /// **style** Pass in the style information for the Html here.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/Style) for more info.
  Html({
    super.key,
    GlobalKey? anchorKey,
    required this.data,
    this.onLinkTap,
    this.onAnchorTap,
    this.customRenders = const {},
    this.onCssParseError,
    this.onImageError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
  })  : documentElement = null,
        assert(data != null),
        _anchorKey = anchorKey ?? GlobalKey();

  Html.fromDom({
    super.key,
    GlobalKey? anchorKey,
    @required dom.Document? document,
    this.onLinkTap,
    this.onAnchorTap,
    this.customRenders = const {},
    this.onCssParseError,
    this.onImageError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
  })  : data = null,
        assert(document != null),
        documentElement = document!.documentElement,
        _anchorKey = anchorKey ?? GlobalKey();

  Html.fromElement({
    super.key,
    GlobalKey? anchorKey,
    @required this.documentElement,
    this.onLinkTap,
    this.onAnchorTap,
    this.customRenders = const {},
    this.onCssParseError,
    this.onImageError,
    this.shrinkWrap = false,
    this.onImageTap,
    this.tagsList = const [],
    this.style = const {},
  })  : data = null,
        assert(documentElement != null),
        _anchorKey = anchorKey ?? GlobalKey();

  /// A unique key for this Html widget to ensure uniqueness of anchors
  final GlobalKey _anchorKey;

  /// The HTML data passed to the widget as a String
  final String? data;

  /// The HTML data passed to the widget as a pre-processed [dom.Element]
  final dom.Element? documentElement;

  /// A function that defines what to do when a link is tapped
  final OnTap? onLinkTap;

  /// A function that defines what to do when an anchor link is tapped. When this value is set,
  /// the default anchor behaviour is overwritten.
  final OnTap? onAnchorTap;

  /// A function that defines what to do when CSS fails to parse
  final OnCssParseError? onCssParseError;

  /// A function that defines what to do when an image errors
  final ImageErrorListener? onImageError;

  /// A parameter that should be set when the HTML widget is expected to be
  /// flexible
  final bool shrinkWrap;

  /// A function that defines what to do when an image is tapped
  final OnTap? onImageTap;

  /// A list of HTML tags that are the only tags that are rendered. By default, this list is empty and all supported HTML tags are rendered.
  final List<String> tagsList;

  /// Either return a custom widget for specific node types or return null to
  /// fallback to the default rendering.
  final Map<CustomRenderMatcher, CustomRender> customRenders;

  /// An API that allows you to override the default style for any HTML element
  final Map<String, Style> style;

  static List<String> get tags => List<String>.from(STYLED_ELEMENTS)
    ..addAll(INTERACTABLE_ELEMENTS)
    ..addAll(REPLACED_ELEMENTS)
    ..addAll(LAYOUT_ELEMENTS)
    ..addAll(TABLE_CELL_ELEMENTS)
    ..addAll(TABLE_DEFINITION_ELEMENTS);
  // ..addAll(EXTERNAL_ELEMENTS);

  @override
  State<StatefulWidget> createState() => _HtmlState();
}

class _HtmlState extends State<Html> {
  late dom.Element documentElement;

  @override
  void initState() {
    super.initState();
    documentElement = widget.data != null
        ? HtmlParser.parseHTML(widget.data!)
        : widget.documentElement!;
  }

  @override
  void didUpdateWidget(Html oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.data != null && oldWidget.data != widget.data) ||
        oldWidget.documentElement != widget.documentElement) {
      documentElement = widget.data != null
          ? HtmlParser.parseHTML(widget.data!)
          : widget.documentElement!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.shrinkWrap ? null : MediaQuery.of(context).size.width,
      child: HtmlParser(
        parseKey: widget._anchorKey,
        htmlData: documentElement,
        onLinkTap: widget.onLinkTap,
        onAnchorTap: widget.onAnchorTap,
        onImageTap: widget.onImageTap,
        onCssParseError: widget.onCssParseError,
        onImageError: widget.onImageError,
        shrinkWrap: widget.shrinkWrap,
        selectable: false,
        style: widget.style,
        customRenders: {}
          ..addAll(widget.customRenders)
          ..addAll(defaultRenders),
        tagsList: widget.tagsList.isEmpty ? Html.tags : widget.tagsList,
      ),
    );
  }
}

class SelectableHtml extends StatefulWidget {
  /// The `SelectableHtml` widget takes HTML as input and displays a RichText
  /// tree of the parsed HTML content (which is selectable)
  ///
  /// **Attributes**
  /// **data** *required* takes in a String of HTML data (required only for `Html` constructor).
  /// **documentElement** *required* takes in a Element of HTML data (required only for `Html.fromDom` and `Html.fromElement` constructor).
  ///
  /// **onLinkTap** This function is called whenever a link (`<a href>`)
  /// is tapped.
  ///
  /// **onAnchorTap** This function is called whenever an anchor (#anchor-id)
  /// is tapped.
  ///
  /// **tagsList** Tag names in this array will be the only tags rendered. By default, all tags that support selectable content are rendered.
  ///
  /// **style** Pass in the style information for the Html here.
  /// See [its wiki page](https://github.com/Sub6Resources/flutter_html/wiki/Style) for more info.
  ///
  /// **PLEASE NOTE**
  ///
  /// There are a few caveats due to Flutter [#38474](https://github.com/flutter/flutter/issues/38474):
  ///
  /// 1. The list of tags that can be rendered is significantly reduced.
  /// Key omissions include no support for images/video/audio, table, and ul/ol because they all require widgets and `WidgetSpan`s.
  ///
  /// 2. No support for `customRender`, `customImageRender`, `onImageError`, `onImageTap`, `onMathError`, and `navigationDelegateForIframe`.
  ///
  /// 3. Styling support is significantly reduced. Only text-related styling works
  /// (e.g. bold or italic), while container related styling (e.g. borders or padding/margin)
  /// do not work because we can't use the `ContainerSpan` class (it needs an enclosing `WidgetSpan`).

  SelectableHtml({
    super.key,
    GlobalKey? anchorKey,
    required this.data,
    this.onLinkTap,
    this.onAnchorTap,
    this.onCssParseError,
    this.shrinkWrap = false,
    this.style = const {},
    this.customRenders = const {},
    this.tagsList = const [],
    this.selectionControls,
    this.scrollPhysics,
  })  : documentElement = null,
        assert(data != null),
        _anchorKey = anchorKey ?? GlobalKey();

  SelectableHtml.fromDom({
    super.key,
    GlobalKey? anchorKey,
    @required dom.Document? document,
    this.onLinkTap,
    this.onAnchorTap,
    this.onCssParseError,
    this.shrinkWrap = false,
    this.style = const {},
    this.customRenders = const {},
    this.tagsList = const [],
    this.selectionControls,
    this.scrollPhysics,
  })  : data = null,
        assert(document != null),
        documentElement = document!.documentElement,
        _anchorKey = anchorKey ?? GlobalKey();

  SelectableHtml.fromElement({
    super.key,
    GlobalKey? anchorKey,
    @required this.documentElement,
    this.onLinkTap,
    this.onAnchorTap,
    this.onCssParseError,
    this.shrinkWrap = false,
    this.style = const {},
    this.customRenders = const {},
    this.tagsList = const [],
    this.selectionControls,
    this.scrollPhysics,
  })  : data = null,
        assert(documentElement != null),
        _anchorKey = anchorKey ?? GlobalKey();

  /// A unique key for this Html widget to ensure uniqueness of anchors
  final GlobalKey _anchorKey;

  /// The HTML data passed to the widget as a String
  final String? data;

  /// The HTML data passed to the widget as a pre-processed [dom.Element]
  final dom.Element? documentElement;

  /// A function that defines what to do when a link is tapped
  final OnTap? onLinkTap;

  /// A function that defines what to do when an anchor link is tapped. When this value is set,
  /// the default anchor behaviour is overwritten.
  final OnTap? onAnchorTap;

  /// A function that defines what to do when CSS fails to parse
  final OnCssParseError? onCssParseError;

  /// A parameter that should be set when the HTML widget is expected to be
  /// flexible
  final bool shrinkWrap;

  /// A list of HTML tags that are the only tags that are rendered. By default, this list is empty and all supported HTML tags are rendered.
  final List<String> tagsList;

  /// An API that allows you to override the default style for any HTML element
  final Map<String, Style> style;

  /// Custom Selection controls allows you to override default toolbar and build custom toolbar
  /// options
  final TextSelectionControls? selectionControls;

  /// Allows you to override the default scrollPhysics for [SelectableText.rich]
  final ScrollPhysics? scrollPhysics;

  /// Either return a custom widget for specific node types or return null to
  /// fallback to the default rendering.
  final Map<CustomRenderMatcher, SelectableCustomRender> customRenders;

  static List<String> get tags => List<String>.from(SELECTABLE_ELEMENTS);

  @override
  State<StatefulWidget> createState() => _SelectableHtmlState();
}

class _SelectableHtmlState extends State<SelectableHtml> {
  late final dom.Element documentElement;

  @override
  void initState() {
    super.initState();
    documentElement = widget.data != null
        ? HtmlParser.parseHTML(widget.data!)
        : widget.documentElement!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.shrinkWrap ? null : MediaQuery.of(context).size.width,
      child: HtmlParser(
        parseKey: widget._anchorKey,
        htmlData: documentElement,
        onLinkTap: widget.onLinkTap,
        onAnchorTap: widget.onAnchorTap,
        onImageTap: null,
        onCssParseError: widget.onCssParseError,
        onImageError: null,
        shrinkWrap: widget.shrinkWrap,
        selectable: true,
        style: widget.style,
        customRenders: {}
          ..addAll(widget.customRenders)
          ..addAll(defaultRenders),
        tagsList:
            widget.tagsList.isEmpty ? SelectableHtml.tags : widget.tagsList,
        selectionControls: widget.selectionControls,
        scrollPhysics: widget.scrollPhysics,
      ),
    );
  }
}

```

#### 📄 `lib/widget\simple_html\html_parser.dart`

```dart
import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:csslib/parser.dart' as cssparser;
import 'package:csslib/visitor.dart' as css;
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;

import 'flutter_html.dart';
import 'src/css_parser.dart';
import 'src/html_elements.dart';
import 'src/utils.dart';
import './src/extension.dart';

typedef OnTap = void Function(
  String? url,
  RenderContext context,
  Map<String, String> attributes,
  dom.Element? element,
);
typedef OnCssParseError = String? Function(
  String css,
  List<cssparser.Message> errors,
);

class HtmlParser extends StatelessWidget {
  final Key? parseKey;
  final dom.Element htmlData;
  final OnTap? onLinkTap;
  final OnTap? onAnchorTap;
  final OnTap? onImageTap;
  final OnCssParseError? onCssParseError;
  final ImageErrorListener? onImageError;
  final bool shrinkWrap;
  final bool selectable;

  final Map<String, Style> style;
  final Map<CustomRenderMatcher, CustomRender> customRenders;
  final List<String> tagsList;
  final OnTap? internalOnAnchorTap;
  final Html? root;
  final TextSelectionControls? selectionControls;
  final ScrollPhysics? scrollPhysics;

  final Map<String, Size> cachedImageSizes = {};

  HtmlParser({
    required this.parseKey,
    required this.htmlData,
    required this.onLinkTap,
    required this.onAnchorTap,
    required this.onImageTap,
    required this.onCssParseError,
    required this.onImageError,
    required this.shrinkWrap,
    required this.selectable,
    required this.style,
    required this.customRenders,
    required this.tagsList,
    this.root,
    this.selectionControls,
    this.scrollPhysics,
  })  : internalOnAnchorTap = onAnchorTap ??
            (parseKey != null
                ? _handleAnchorTap(parseKey, onLinkTap)
                : onLinkTap),
        super(key: parseKey);

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, List<css.Expression>>> declarations =
        _getExternalCssDeclarations(
            htmlData.getElementsByTagName("style"), onCssParseError);
    StyledElement lexedTree = lexDomTree(
      htmlData,
      customRenders.keys.toList(),
      tagsList,
      context,
      this,
    );
    StyledElement? externalCssStyledTree;
    if (declarations.isNotEmpty) {
      externalCssStyledTree = _applyExternalCss(declarations, lexedTree);
    }
    StyledElement inlineStyledTree =
        _applyInlineStyles(externalCssStyledTree ?? lexedTree, onCssParseError);
    StyledElement customStyledTree =
        _applyCustomStyles(style, inlineStyledTree);
    StyledElement cascadedStyledTree = _cascadeStyles(style, customStyledTree);
    StyledElement cleanedTree = cleanTree(cascadedStyledTree);
    InlineSpan parsedTree = parseTree(
      RenderContext(
        buildContext: context,
        parser: this,
        tree: cleanedTree,
        style: cleanedTree.style,
      ),
      cleanedTree,
    );

    // This is the final scaling that assumes any other StyledText instances are
    // using textScaleFactor = 1.0 (which is the default). This ensures the correct
    // scaling is used, but relies on https://github.com/flutter/flutter/pull/59711
    // to wrap everything when larger accessibility fonts are used.
    if (selectable) {
      return StyledText.selectable(
        textSpan: parsedTree as TextSpan,
        style: cleanedTree.style,
        textScaler: MediaQuery.of(context).textScaler,
        renderContext: RenderContext(
          buildContext: context,
          parser: this,
          tree: cleanedTree,
          style: cleanedTree.style,
        ),
        selectionControls: selectionControls,
        scrollPhysics: scrollPhysics,
      );
    }
    return StyledText(
      textSpan: parsedTree,
      style: cleanedTree.style,
      textScaler: MediaQuery.of(context).textScaler,
      renderContext: RenderContext(
        buildContext: context,
        parser: this,
        tree: cleanedTree,
        style: cleanedTree.style,
      ),
    );
  }

  /// [parseHTML] converts a string of HTML to a DOM element using the dart `html` library.
  static dom.Element parseHTML(String data) {
    return htmlparser.parse(data).documentElement!;
  }

  /// [parseCss] converts a string of CSS to a CSS stylesheet using the dart `csslib` library.
  static css.StyleSheet parseCss(String data) {
    return cssparser.parse(data);
  }

  /// [lexDomTree] converts a DOM document to a simplified tree of [StyledElement]s.
  static StyledElement lexDomTree(
    dom.Element html,
    List<CustomRenderMatcher> customRenderMatchers,
    List<String> tagsList,
    BuildContext context,
    HtmlParser parser,
  ) {
    StyledElement tree = StyledElement(
      name: "[Tree Root]",
      children: <StyledElement>[],
      node: html,
      style: Style.fromTextStyle(Theme.of(context).textTheme.bodyMedium!),
    );

    for (var node in html.nodes) {
      tree.children.add(_recursiveLexer(
        node,
        customRenderMatchers,
        tagsList,
        context,
        parser,
      ));
    }

    return tree;
  }

  /// [_recursiveLexer] is the recursive worker function for [lexDomTree].
  ///
  /// It runs the parse functions of every type of
  /// element and returns a [StyledElement] tree representing the element.
  static StyledElement _recursiveLexer(
    dom.Node node,
    List<CustomRenderMatcher> customRenderMatchers,
    List<String> tagsList,
    BuildContext context,
    HtmlParser parser,
  ) {
    List<StyledElement> children = <StyledElement>[];

    for (var childNode in node.nodes) {
      children.add(_recursiveLexer(
        childNode,
        customRenderMatchers,
        tagsList,
        context,
        parser,
      ));
    }

    if (node is dom.Element) {
      if (!tagsList.contains(node.localName)) {
        return EmptyContentElement();
      }
      if (STYLED_ELEMENTS.contains(node.localName)) {
        return parseStyledElement(node, children);
      } else if (INTERACTABLE_ELEMENTS.contains(node.localName)) {
        return parseInteractableElement(node, children);
      } else if (REPLACED_ELEMENTS.contains(node.localName)) {
        return parseReplacedElement(node, children);
      } else if (LAYOUT_ELEMENTS.contains(node.localName)) {
        return parseLayoutElement(node, children);
      } else if (TABLE_CELL_ELEMENTS.contains(node.localName)) {
        return parseTableCellElement(node, children);
      } else if (TABLE_DEFINITION_ELEMENTS.contains(node.localName)) {
        return parseTableDefinitionElement(node, children);
      } else {
        final StyledElement tree = parseStyledElement(node, children);
        for (final entry in customRenderMatchers) {
          if (entry.call(
            RenderContext(
              buildContext: context,
              parser: parser,
              tree: tree,
              style:
                  Style.fromTextStyle(Theme.of(context).textTheme.bodyMedium!),
            ),
          )) {
            return tree;
          }
        }
        return EmptyContentElement();
      }
    } else if (node is dom.Text) {
      return TextContentElement(
          text: node.text, style: Style(), element: node.parent, node: node);
    } else {
      return EmptyContentElement();
    }
  }

  static Map<String, Map<String, List<css.Expression>>>
      _getExternalCssDeclarations(
          List<dom.Element> styles, OnCssParseError? errorHandler) {
    String fullCss = "";
    for (final e in styles) {
      fullCss = fullCss + e.innerHtml;
    }
    if (fullCss.isNotEmpty) {
      final declarations = parseExternalCss(fullCss, errorHandler);
      return declarations;
    } else {
      return {};
    }
  }

  static StyledElement _applyExternalCss(
      Map<String, Map<String, List<css.Expression>>> declarations,
      StyledElement tree) {
    declarations.forEach((key, style) {
      try {
        if (tree.matchesSelector(key)) {
          tree.style = tree.style.merge(declarationsToStyle(style));
        }
      } catch (_) {}
    });

    for (var e in tree.children) {
      _applyExternalCss(declarations, e);
    }

    return tree;
  }

  static StyledElement _applyInlineStyles(
      StyledElement tree, OnCssParseError? errorHandler) {
    if (tree.attributes.containsKey("style")) {
      final newStyle = inlineCssToStyle(tree.attributes['style'], errorHandler);
      if (newStyle != null) {
        tree.style = tree.style.merge(newStyle);
      }
    }

    for (var e in tree.children) {
      _applyInlineStyles(e, errorHandler);
    }
    return tree;
  }

  /// [applyCustomStyles] applies the [Style] objects passed into the [Html]
  /// widget onto the [StyledElement] tree, no cascading of styles is done at this point.
  static StyledElement _applyCustomStyles(
      Map<String, Style> style, StyledElement tree) {
    style.forEach((key, style) {
      try {
        if (tree.matchesSelector(key)) {
          tree.style = tree.style.merge(style);
        }
      } catch (_) {}
    });
    for (var e in tree.children) {
      _applyCustomStyles(style, e);
    }

    return tree;
  }

  /// [_cascadeStyles] cascades all of the inherited styles down the tree, applying them to each
  /// child that doesn't specify a different style.
  static StyledElement _cascadeStyles(
      Map<String, Style> style, StyledElement tree) {
    for (var child in tree.children) {
      child.style = tree.style.copyOnlyInherited(child.style);
      _cascadeStyles(style, child);
    }

    return tree;
  }

  /// [cleanTree] optimizes the [StyledElement] tree so all [BlockElement]s are
  /// on the first level, redundant levels are collapsed, empty elements are
  /// removed, and specialty elements are processed.
  static StyledElement cleanTree(StyledElement tree) {
    tree = _processInternalWhitespace(tree);
    tree = _processInlineWhitespace(tree);
    tree = _removeEmptyElements(tree);
    tree = _processListCharacters(tree);
    tree = _processBeforesAndAfters(tree);
    tree = _collapseMargins(tree);
    tree = _processFontSize(tree);
    return tree;
  }

  /// [parseTree] converts a tree of [StyledElement]s to an [InlineSpan] tree.
  ///
  /// [parseTree] is responsible for handling the [customRenders] parameter and
  /// deciding what different `Style.display` options look like as Widgets.
  InlineSpan parseTree(RenderContext context, StyledElement tree) {
    // Merge this element's style into the context so that children
    // inherit the correct style
    RenderContext newContext = RenderContext(
      buildContext: context.buildContext,
      parser: this,
      tree: tree,
      style: context.style.copyOnlyInherited(tree.style),
      key: AnchorKey.of(parseKey, tree),
    );

    for (final entry in customRenders.keys) {
      if (entry.call(newContext)) {
        buildChildren() =>
            tree.children.map((tree) => parseTree(newContext, tree)).toList();
        if (newContext.parser.selectable &&
            customRenders[entry] is SelectableCustomRender) {
          selectableBuildChildren() => tree.children
              .map((tree) => parseTree(newContext, tree) as TextSpan)
              .toList();
          return (customRenders[entry] as SelectableCustomRender)
              .textSpan
              .call(newContext, selectableBuildChildren);
        }
        if (newContext.parser.selectable) {
          return customRenders[entry]!
              .inlineSpan!
              .call(newContext, buildChildren) as TextSpan;
        }
        if (customRenders[entry]?.inlineSpan != null) {
          return customRenders[entry]!
              .inlineSpan!
              .call(newContext, buildChildren);
        }
        return WidgetSpan(
          child: ContainerSpan(
            newContext: newContext,
            style: tree.style,
            shrinkWrap: newContext.parser.shrinkWrap,
            child:
                customRenders[entry]!.widget!.call(newContext, buildChildren),
          ),
        );
      }
    }
    return const WidgetSpan(child: SizedBox(height: 0, width: 0));
  }

  static OnTap _handleAnchorTap(Key key, OnTap? onLinkTap) => (String? url,
          RenderContext context,
          Map<String, String> attributes,
          dom.Element? element) {
        if (url?.startsWith("#") == true) {
          final anchorContext =
              AnchorKey.forId(key, url!.substring(1))?.currentContext;
          if (anchorContext != null) {
            Scrollable.ensureVisible(anchorContext);
          }
          return;
        }
        onLinkTap?.call(url, context, attributes, element);
      };

  /// [processWhitespace] removes unnecessary whitespace from the StyledElement tree.
  ///
  /// The criteria for determining which whitespace is replaceable is outlined
  /// at https://www.w3.org/TR/css-text-3/
  /// and summarized at https://medium.com/@patrickbrosset/when-does-white-space-matter-in-html-b90e8a7cdd33
  static StyledElement _processInternalWhitespace(StyledElement tree) {
    if ((tree.style.whiteSpace ?? WhiteSpace.NORMAL) == WhiteSpace.PRE) {
      // Preserve this whitespace
    } else if (tree is TextContentElement) {
      tree.text = _removeUnnecessaryWhitespace(tree.text!);
    } else {
      tree.children.forEach(_processInternalWhitespace);
    }
    return tree;
  }

  /// [_processInlineWhitespace] is responsible for removing redundant whitespace
  /// between and among inline elements. It does so by creating a boolean [Context]
  /// and passing it to the [_processInlineWhitespaceRecursive] function.
  static StyledElement _processInlineWhitespace(StyledElement tree) {
    tree = _processInlineWhitespaceRecursive(tree, Context(false));
    return tree;
  }

  /// [_processInlineWhitespaceRecursive] analyzes the whitespace between and among different
  /// inline elements, and replaces any instance of two or more spaces with a single space, according
  /// to the w3's HTML whitespace processing specification linked to above.
  static StyledElement _processInlineWhitespaceRecursive(
    StyledElement tree,
    Context<bool> keepLeadingSpace,
  ) {
    if (tree is TextContentElement) {
      /// initialize indices to negative numbers to make conditionals a little easier
      int textIndex = -1;
      int elementIndex = -1;

      /// initialize parent after to a whitespace to account for elements that are
      /// the last child in the list of elements
      String parentAfterText = " ";

      /// find the index of the text in the current tree
      if ((tree.element?.nodes.length ?? 0) >= 1) {
        textIndex =
            tree.element?.nodes.indexWhere((element) => element == tree.node) ??
                -1;
      }

      /// get the parent nodes
      dom.NodeList? parentNodes = tree.element?.parent?.nodes;

      /// find the index of the tree itself in the parent nodes
      if ((parentNodes?.length ?? 0) >= 1) {
        elementIndex =
            parentNodes?.indexWhere((element) => element == tree.element) ?? -1;
      }

      /// if the tree is any node except the last node in the node list and the
      /// next node in the node list is a text node, then get its text. Otherwise
      /// the next node will be a [dom.Element], so keep unwrapping that until
      /// we get the underlying text node, and finally get its text.
      if (elementIndex < (parentNodes?.length ?? 1) - 1 &&
          parentNodes?[elementIndex + 1] is dom.Text) {
        parentAfterText = parentNodes?[elementIndex + 1].text ?? " ";
      } else if (elementIndex < (parentNodes?.length ?? 1) - 1) {
        var parentAfter = parentNodes?[elementIndex + 1];
        while (parentAfter is dom.Element) {
          if (parentAfter.nodes.isNotEmpty) {
            parentAfter = parentAfter.nodes.first;
          } else {
            break;
          }
        }
        parentAfterText = parentAfter?.text ?? " ";
      }

      /// If the text is the first element in the current tree node list, it
      /// starts with a whitespace, it isn't a line break, either the
      /// whitespace is unnecessary or it is a block element, and either it is
      /// first element in the parent node list or the previous element
      /// in the parent node list ends with a whitespace, delete it.
      ///
      /// We should also delete the whitespace at any point in the node list
      /// if the previous element is a <br> because that tag makes the element
      /// act like a block element.
      if (textIndex < 1 &&
          tree.text!.startsWith(' ') &&
          tree.element?.localName != "br" &&
          (!keepLeadingSpace.data || tree.style.display == Display.BLOCK) &&
          (elementIndex < 1 ||
              (elementIndex >= 1 &&
                  parentNodes?[elementIndex - 1] is dom.Text &&
                  parentNodes![elementIndex - 1].text!.endsWith(" ")))) {
        tree.text = tree.text!.replaceFirst(' ', '');
      } else if (textIndex >= 1 &&
          tree.text!.startsWith(' ') &&
          tree.element?.nodes[textIndex - 1] is dom.Element &&
          (tree.element?.nodes[textIndex - 1] as dom.Element).localName ==
              "br") {
        tree.text = tree.text!.replaceFirst(' ', '');
      }

      /// If the text is the last element in the current tree node list, it isn't
      /// a line break, and the next text node starts with a whitespace,
      /// update the [Context] to signify to that next text node whether it should
      /// keep its whitespace. This is based on whether the current text ends with a
      /// whitespace.
      if (textIndex == (tree.element?.nodes.length ?? 1) - 1 &&
          tree.element?.localName != "br" &&
          parentAfterText.startsWith(' ')) {
        keepLeadingSpace.data = !tree.text!.endsWith(' ');
      }
    }

    for (var e in tree.children) {
      _processInlineWhitespaceRecursive(e, keepLeadingSpace);
    }

    return tree;
  }

  /// [removeUnnecessaryWhitespace] removes "unnecessary" white space from the given String.
  ///
  /// The steps for removing this whitespace are as follows:
  /// (1) Remove any whitespace immediately preceding or following a newline.
  /// (2) Replace all newlines with a space
  /// (3) Replace all tabs with a space
  /// (4) Replace any instances of two or more spaces with a single space.
  static String _removeUnnecessaryWhitespace(String text) {
    return text
        .replaceAll(RegExp(" *(?=\n)"), "\n")
        .replaceAll(RegExp("(?:\n) *"), "\n")
        .replaceAll("\n", " ")
        .replaceAll("\t", " ")
        .replaceAll(RegExp(" {2,}"), " ");
  }

  /// [processListCharacters] adds list characters to the front of all list items.
  ///
  /// The function uses the [_processListCharactersRecursive] function to do most of its work.
  static StyledElement _processListCharacters(StyledElement tree) {
    final olStack = ListQueue<Context>();
    tree = _processListCharactersRecursive(tree, olStack);
    return tree;
  }

  /// [_processListCharactersRecursive] uses a Stack of integers to properly number and
  /// bullet all list items according to the [ListStyleType] they have been given.
  static StyledElement _processListCharactersRecursive(
      StyledElement tree, ListQueue<Context> olStack) {
    tree.style.listStylePosition ??= ListStylePosition.OUTSIDE;
    if (tree.name == 'ol' &&
        tree.style.listStyleType != null &&
        tree.style.listStyleType!.type == "marker") {
      switch (tree.style.listStyleType!) {
        case ListStyleType.LOWER_LATIN:
        case ListStyleType.LOWER_ALPHA:
        case ListStyleType.UPPER_LATIN:
        case ListStyleType.UPPER_ALPHA:
          olStack.add(Context<String>('a'));
          if ((tree.attributes['start'] != null
                  ? int.tryParse(tree.attributes['start']!)
                  : null) !=
              null) {
            var start = int.tryParse(tree.attributes['start']!) ?? 1;
            var x = 1;
            while (x < start) {
              olStack.last.data = olStack.last.data.toString().nextLetter();
              x++;
            }
          }
          break;
        default:
          olStack.add(Context<int>((tree.attributes['start'] != null
                  ? int.tryParse(tree.attributes['start'] ?? "") ?? 1
                  : 1) -
              1));
          break;
      }
    } else if (tree.style.display == Display.LIST_ITEM &&
        tree.style.listStyleType != null &&
        tree.style.listStyleType!.type == "widget") {
      tree.style.markerContent = tree.style.listStyleType!.widget!;
    } else if (tree.style.display == Display.LIST_ITEM &&
        tree.style.listStyleType != null &&
        tree.style.listStyleType!.type == "image") {
      tree.style.markerContent = Image.network(tree.style.listStyleType!.text);
    } else if (tree.style.display == Display.LIST_ITEM &&
        tree.style.listStyleType != null) {
      String marker = "";
      switch (tree.style.listStyleType!) {
        case ListStyleType.NONE:
          break;
        case ListStyleType.CIRCLE:
          marker = '○';
          break;
        case ListStyleType.SQUARE:
          marker = '■';
          break;
        case ListStyleType.DISC:
          marker = '•';
          break;
        case ListStyleType.DECIMAL:
          if (olStack.isEmpty) {
            olStack.add(Context<int>((tree.attributes['start'] != null
                    ? int.tryParse(tree.attributes['start'] ?? "") ?? 1
                    : 1) -
                1));
          }
          olStack.last.data += 1;
          marker = '${olStack.last.data}.';
          break;
        case ListStyleType.LOWER_LATIN:
        case ListStyleType.LOWER_ALPHA:
          if (olStack.isEmpty) {
            olStack.add(Context<String>('a'));
            if ((tree.attributes['start'] != null
                    ? int.tryParse(tree.attributes['start']!)
                    : null) !=
                null) {
              var start = int.tryParse(tree.attributes['start']!) ?? 1;
              var x = 1;
              while (x < start) {
                olStack.last.data = olStack.last.data.toString().nextLetter();
                x++;
              }
            }
          }
          marker = "${olStack.last.data}.";
          olStack.last.data = olStack.last.data.toString().nextLetter();
          break;
        case ListStyleType.UPPER_LATIN:
        case ListStyleType.UPPER_ALPHA:
          if (olStack.isEmpty) {
            olStack.add(Context<String>('a'));
            if ((tree.attributes['start'] != null
                    ? int.tryParse(tree.attributes['start']!)
                    : null) !=
                null) {
              var start = int.tryParse(tree.attributes['start']!) ?? 1;
              var x = 1;
              while (x < start) {
                olStack.last.data = olStack.last.data.toString().nextLetter();
                x++;
              }
            }
          }
          marker = "${olStack.last.data.toString().toUpperCase()}.";
          olStack.last.data = olStack.last.data.toString().nextLetter();
          break;
        case ListStyleType.LOWER_ROMAN:
          if (olStack.isEmpty) {
            olStack.add(Context<int>((tree.attributes['start'] != null
                    ? int.tryParse(tree.attributes['start'] ?? "") ?? 1
                    : 1) -
                1));
          }
          olStack.last.data += 1;
          if (olStack.last.data <= 0) {
            marker = '${olStack.last.data}.';
          } else {
            marker =
                "${(olStack.last.data as int).toRomanNumeralString()!.toLowerCase()}.";
          }
          break;
        case ListStyleType.UPPER_ROMAN:
          if (olStack.isEmpty) {
            olStack.add(Context<int>((tree.attributes['start'] != null
                    ? int.tryParse(tree.attributes['start'] ?? "") ?? 1
                    : 1) -
                1));
          }
          olStack.last.data += 1;
          if (olStack.last.data <= 0) {
            marker = '${olStack.last.data}.';
          } else {
            marker = "${(olStack.last.data as int).toRomanNumeralString()!}.";
          }
          break;
      }
      tree.style.markerContent = Text(
        marker,
        textAlign: TextAlign.right,
        style: tree.style.generateTextStyle(),
      );
    }

    for (var e in tree.children) {
      _processListCharactersRecursive(e, olStack);
    }

    if (tree.name == 'ol') {
      olStack.removeLast();
    }

    return tree;
  }

  /// [_processBeforesAndAfters] adds text content to the beginning and end of
  /// the list of the trees children according to the `before` and `after` Style
  /// properties.
  static StyledElement _processBeforesAndAfters(StyledElement tree) {
    if (tree.style.before != null) {
      tree.children.insert(
          0,
          TextContentElement(
              text: tree.style.before,
              style: tree.style
                  .copyWith(beforeAfterNull: true, display: Display.INLINE)));
    }
    if (tree.style.after != null) {
      tree.children.add(TextContentElement(
          text: tree.style.after,
          style: tree.style
              .copyWith(beforeAfterNull: true, display: Display.INLINE)));
    }

    tree.children.forEach(_processBeforesAndAfters);

    return tree;
  }

  /// [collapseMargins] follows the specifications at https://www.w3.org/TR/CSS21/box.html#collapsing-margins
  /// for collapsing margins of block-level boxes. This prevents the doubling of margins between
  /// boxes, and makes for a more correct rendering of the html content.
  ///
  /// Paraphrased from the CSS specification:
  /// Margins are collapsed if both belong to vertically-adjacent box edges, i.e form one of the following pairs:
  /// (1) Top margin of a box and top margin of its first in-flow child
  /// (2) Bottom margin of a box and top margin of its next in-flow following sibling
  /// (3) Bottom margin of a last in-flow child and bottom margin of its parent (if the parent's height is not explicit)
  /// (4) Top and Bottom margins of a box with a height of zero or no in-flow children.
  static StyledElement _collapseMargins(StyledElement tree) {
    //Short circuit if we've reached a leaf of the tree
    if (tree.children.isEmpty) {
      // Handle case (4) from above.
      if ((tree.style.height ?? 0) == 0) {
        tree.style.margin = EdgeInsets.zero;
      }
      return tree;
    }

    //Collapsing should be depth-first.
    tree.children.forEach(_collapseMargins);

    //The root boxes do not collapse.
    if (tree.name == '[Tree Root]' || tree.name == 'html') {
      return tree;
    }

    // Handle case (1) from above.
    // Top margins cannot collapse if the element has padding
    if ((tree.style.padding?.top ?? 0) == 0) {
      final parentTop = tree.style.margin?.top ?? 0;
      final firstChildTop = tree.children.first.style.margin?.top ?? 0;
      final newOuterMarginTop = max(parentTop, firstChildTop);

      // Set the parent's margin
      if (tree.style.margin == null) {
        tree.style.margin = EdgeInsets.only(top: newOuterMarginTop);
      } else {
        tree.style.margin = tree.style.margin!.copyWith(top: newOuterMarginTop);
      }

      // And remove the child's margin
      if (tree.children.first.style.margin == null) {
        tree.children.first.style.margin = EdgeInsets.zero;
      } else {
        tree.children.first.style.margin =
            tree.children.first.style.margin!.copyWith(top: 0);
      }
    }

    // Handle case (3) from above.
    // Bottom margins cannot collapse if the element has padding
    if ((tree.style.padding?.bottom ?? 0) == 0) {
      final parentBottom = tree.style.margin?.bottom ?? 0;
      final lastChildBottom = tree.children.last.style.margin?.bottom ?? 0;
      final newOuterMarginBottom = max(parentBottom, lastChildBottom);

      // Set the parent's margin
      if (tree.style.margin == null) {
        tree.style.margin = EdgeInsets.only(bottom: newOuterMarginBottom);
      } else {
        tree.style.margin =
            tree.style.margin!.copyWith(bottom: newOuterMarginBottom);
      }

      // And remove the child's margin
      if (tree.children.last.style.margin == null) {
        tree.children.last.style.margin = EdgeInsets.zero;
      } else {
        tree.children.last.style.margin =
            tree.children.last.style.margin!.copyWith(bottom: 0);
      }
    }

    // Handle case (2) from above.
    if (tree.children.length > 1) {
      for (int i = 1; i < tree.children.length; i++) {
        final previousSiblingBottom =
            tree.children[i - 1].style.margin?.bottom ?? 0;
        final thisTop = tree.children[i].style.margin?.top ?? 0;
        final newInternalMargin = max(previousSiblingBottom, thisTop) / 2;

        if (tree.children[i - 1].style.margin == null) {
          tree.children[i - 1].style.margin =
              EdgeInsets.only(bottom: newInternalMargin);
        } else {
          tree.children[i - 1].style.margin = tree.children[i - 1].style.margin!
              .copyWith(bottom: newInternalMargin);
        }

        if (tree.children[i].style.margin == null) {
          tree.children[i].style.margin =
              EdgeInsets.only(top: newInternalMargin);
        } else {
          tree.children[i].style.margin =
              tree.children[i].style.margin!.copyWith(top: newInternalMargin);
        }
      }
    }

    return tree;
  }

  /// [removeEmptyElements] recursively removes empty elements.
  ///
  /// An empty element is any [EmptyContentElement], any empty [TextContentElement],
  /// or any block-level [TextContentElement] that contains only whitespace and doesn't follow
  /// a block element or a line break.
  static StyledElement _removeEmptyElements(StyledElement tree) {
    List<StyledElement> toRemove = <StyledElement>[];
    bool lastChildBlock = true;
    tree.children.forEachIndexed((index, child) {
      if (child is EmptyContentElement || child is EmptyLayoutElement) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          ((tree.name == "body" &&
                  (index == 0 ||
                      index + 1 == tree.children.length ||
                      tree.children[index - 1].style.display == Display.BLOCK ||
                      tree.children[index + 1].style.display ==
                          Display.BLOCK)) ||
              tree.name == "ul") &&
          child.text!.replaceAll(' ', '').isEmpty) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          child.text!.isEmpty &&
          child.style.whiteSpace != WhiteSpace.PRE) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          child.style.whiteSpace != WhiteSpace.PRE &&
          tree.style.display == Display.BLOCK &&
          child.text!.isEmpty &&
          lastChildBlock) {
        toRemove.add(child);
      } else if (child.style.display == Display.NONE) {
        toRemove.add(child);
      } else {
        _removeEmptyElements(child);
      }

      // This is used above to check if the previous element is a block element or a line break.
      lastChildBlock = (child.style.display == Display.BLOCK ||
          child.style.display == Display.LIST_ITEM ||
          (child is TextContentElement && child.text == '\n'));
    });
    tree.children.removeWhere((element) => toRemove.contains(element));

    return tree;
  }

  /// [_processFontSize] changes percent-based font sizes (negative numbers in this implementation)
  /// to pixel-based font sizes.
  static StyledElement _processFontSize(StyledElement tree) {
    double? parentFontSize = tree.style.fontSize?.size ?? FontSize.medium.size;

    for (var child in tree.children) {
      if ((child.style.fontSize?.size ?? parentFontSize)! < 0) {
        child.style.fontSize =
            FontSize(parentFontSize! * -child.style.fontSize!.size!);
      }

      _processFontSize(child);
    }
    return tree;
  }
}

/// The [RenderContext] is available when parsing the tree. It contains information
/// about the [BuildContext] of the `Html` widget, contains the configuration available
/// in the [HtmlParser], and contains information about the [Style] of the current
/// tree root.
class RenderContext {
  final BuildContext buildContext;
  final HtmlParser parser;
  final StyledElement tree;
  final Style style;
  final AnchorKey? key;

  RenderContext({
    required this.buildContext,
    required this.parser,
    required this.tree,
    required this.style,
    this.key,
  });
}

/// A [ContainerSpan] is a widget with an [InlineSpan] child or children.
///
/// A [ContainerSpan] can have a border, background color, height, width, padding, and margin
/// and can represent either an INLINE or BLOCK-level element.
class ContainerSpan extends StatelessWidget {
  final AnchorKey? parseKey;
  final Widget? child;
  final List<InlineSpan>? children;
  final Style style;
  final RenderContext newContext;
  final bool shrinkWrap;

  const ContainerSpan({
    this.parseKey,
    this.child,
    this.children,
    required this.style,
    required this.newContext,
    this.shrinkWrap = false,
  }) : super(key: parseKey);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: style.border,
        color: style.backgroundColor,
      ),
      height: style.height,
      width: style.width,
      padding: style.padding?.nonNegative,
      margin: style.margin?.nonNegative,
      alignment: shrinkWrap ? null : style.alignment,
      child: child ??
          StyledText(
            textSpan: TextSpan(
              style: newContext.style.generateTextStyle(),
              children: children,
            ),
            style: newContext.style,
            renderContext: newContext,
          ),
    );
  }
}

class StyledText extends StatelessWidget {
  final InlineSpan textSpan;
  final Style style;
  final TextScaler textScaler;
  final RenderContext renderContext;
  final AnchorKey? parseKey;
  final bool _selectable;
  final TextSelectionControls? selectionControls;
  final ScrollPhysics? scrollPhysics;

  const StyledText({
    required this.textSpan,
    required this.style,
    this.textScaler = const TextScaler.linear(1.0),
    required this.renderContext,
    this.parseKey,
    this.selectionControls,
    this.scrollPhysics,
  })  : _selectable = false,
        super(key: parseKey);

  const StyledText.selectable({
    required TextSpan this.textSpan,
    required this.style,
    this.textScaler = const TextScaler.linear(1.0),
    required this.renderContext,
    this.parseKey,
    this.selectionControls,
    this.scrollPhysics,
  })  : _selectable = true,
        super(key: parseKey);

  @override
  Widget build(BuildContext context) {
    if (_selectable) {
      return SelectableText.rich(
        textSpan as TextSpan,
        style: style.generateTextStyle(),
        textAlign: style.textAlign,
        textDirection: style.direction,
        textScaler: textScaler,
        maxLines: style.maxLines,
        selectionControls: selectionControls,
        scrollPhysics: scrollPhysics,
      );
    }
    return SizedBox(
      width: consumeExpandedBlock(style.display, renderContext),
      child: Text.rich(
        textSpan,
        style: style.generateTextStyle(),
        textAlign: style.textAlign,
        textDirection: style.direction,
        textScaler: textScaler,
        maxLines: style.maxLines,
        overflow: style.textOverflow,
      ),
    );
  }

  double? consumeExpandedBlock(Display? display, RenderContext context) {
    if ((display == Display.BLOCK || display == Display.LIST_ITEM) &&
        !renderContext.parser.shrinkWrap) {
      return double.infinity;
    }
    return null;
  }
}

extension IterateLetters on String {
  String nextLetter() {
    String s = toLowerCase();
    if (s == "z") {
      return String.fromCharCode(s.codeUnitAt(0) - 25) +
          String.fromCharCode(s.codeUnitAt(0) - 25); // AA or aa
    } else {
      var lastChar = s.substring(s.length - 1);
      var sub = s.substring(0, s.length - 1);
      if (lastChar == "z") {
        // If a string of length > 1 ends in Z/z,
        // increment the string (excluding the last Z/z) recursively,
        // and append A/a (depending on casing) to it
        return '${sub.nextLetter()}a';
      } else {
        // (take till last char) append with (increment last char)
        return sub + String.fromCharCode(lastChar.codeUnitAt(0) + 1);
      }
    }
  }
}

```

#### 📄 `lib/widget\simple_html\README.md`

```markdown
# simple html

The package copy by:
https://github.com/Sub6Resources/flutter_html

I made a custom, not using:

> Using these tags will have some dependencie...

- audio
- iframe
- img
- math
- svg
- table
- video
```

#### 📄 `lib/widget\simple_html\style.dart`

```dart
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import 'html_parser.dart';
import 'src/css_parser.dart';

///This class represents all the available CSS attributes
///for this package.
class Style {
  /// CSS attribute "`background-color`"
  ///
  /// Inherited: no,
  /// Default: Colors.transparent,
  Color? backgroundColor;

  /// CSS attribute "`color`"
  ///
  /// Inherited: yes,
  /// Default: unspecified,
  Color? color;

  /// CSS attribute "`direction`"
  ///
  /// Inherited: yes,
  /// Default: TextDirection.ltr,
  TextDirection? direction;

  /// CSS attribute "`display`"
  ///
  /// Inherited: no,
  /// Default: unspecified,
  Display? display;

  /// CSS attribute "`font-family`"
  ///
  /// Inherited: yes,
  /// Default: Theme.of(context).style.textTheme.body1.fontFamily
  String? fontFamily;

  /// The list of font families to fall back on when a glyph cannot be found in default font family.
  ///
  /// Inherited: yes,
  /// Default: null
  List<String>? fontFamilyFallback;

  /// CSS attribute "`font-feature-settings`"
  ///
  /// Inherited: yes,
  /// Default: normal
  List<FontFeature>? fontFeatureSettings;

  /// CSS attribute "`font-size`"
  ///
  /// Inherited: yes,
  /// Default: FontSize.medium
  FontSize? fontSize;

  /// CSS attribute "`font-style`"
  ///
  /// Inherited: yes,
  /// Default: FontStyle.normal,
  FontStyle? fontStyle;

  /// CSS attribute "`font-weight`"
  ///
  /// Inherited: yes,
  /// Default: FontWeight.normal,
  FontWeight? fontWeight;

  /// CSS attribute "`height`"
  ///
  /// Inherited: no,
  /// Default: Unspecified (null),
  double? height;

  /// CSS attribute "`letter-spacing`"
  ///
  /// Inherited: yes,
  /// Default: normal (0),
  double? letterSpacing;

  /// CSS attribute "`list-style-type`"
  ///
  /// Inherited: yes,
  /// Default: ListStyleType.DISC
  ListStyleType? listStyleType;

  /// CSS attribute "`list-style-position`"
  ///
  /// Inherited: yes,
  /// Default: ListStylePosition.OUTSIDE
  ListStylePosition? listStylePosition;

  /// CSS attribute "`padding`"
  ///
  /// Inherited: no,
  /// Default: EdgeInsets.zero
  EdgeInsets? padding;

  /// CSS attribute "`margin`"
  ///
  /// Inherited: no,
  /// Default: EdgeInsets.zero
  EdgeInsets? margin;

  /// CSS attribute "`text-align`"
  ///
  /// Inherited: yes,
  /// Default: TextAlign.start,
  TextAlign? textAlign;

  /// CSS attribute "`text-decoration`"
  ///
  /// Inherited: no,
  /// Default: TextDecoration.none,
  TextDecoration? textDecoration;

  /// CSS attribute "`text-decoration-color`"
  ///
  /// Inherited: no,
  /// Default: Current color
  Color? textDecorationColor;

  /// CSS attribute "`text-decoration-style`"
  ///
  /// Inherited: no,
  /// Default: TextDecorationStyle.solid,
  TextDecorationStyle? textDecorationStyle;

  /// Loosely based on CSS attribute "`text-decoration-thickness`"
  ///
  /// Uses a percent modifier based on the font size.
  ///
  /// Inherited: no,
  /// Default: 1.0 (specified by font size)
  double? textDecorationThickness;

  /// CSS attribute "`text-shadow`"
  ///
  /// Inherited: yes,
  /// Default: none,
  List<Shadow>? textShadow;

  /// CSS attribute "`vertical-align`"
  ///
  /// Inherited: no,
  /// Default: VerticalAlign.BASELINE,
  VerticalAlign? verticalAlign;

  /// CSS attribute "`white-space`"
  ///
  /// Inherited: yes,
  /// Default: WhiteSpace.NORMAL,
  WhiteSpace? whiteSpace;

  /// CSS attribute "`width`"
  ///
  /// Inherited: no,
  /// Default: unspecified (null)
  double? width;

  /// CSS attribute "`word-spacing`"
  ///
  /// Inherited: yes,
  /// Default: normal (0)
  double? wordSpacing;

  /// CSS attribute "`line-height`"
  ///
  /// Supported values: double values
  ///
  /// Unsupported values: normal, 80%, ..
  ///
  /// Inherited: no,
  /// Default: Unspecified (null),
  LineHeight? lineHeight;

  String? before;
  String? after;
  Border? border;
  Alignment? alignment;
  Widget? markerContent;

  /// MaxLine
  ///
  ///
  ///
  ///
  int? maxLines;

  /// TextOverflow
  ///
  ///
  ///
  ///
  TextOverflow? textOverflow;

  TextTransform? textTransform;

  Style({
    this.backgroundColor = Colors.transparent,
    this.color,
    this.direction,
    this.display,
    this.fontFamily,
    this.fontFamilyFallback,
    this.fontFeatureSettings,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.height,
    this.lineHeight,
    this.letterSpacing,
    this.listStyleType,
    this.listStylePosition,
    this.padding,
    this.margin,
    this.textAlign,
    this.textDecoration,
    this.textDecorationColor,
    this.textDecorationStyle,
    this.textDecorationThickness,
    this.textShadow,
    this.verticalAlign,
    this.whiteSpace,
    this.width,
    this.wordSpacing,
    this.before,
    this.after,
    this.border,
    this.alignment,
    this.markerContent,
    this.maxLines,
    this.textOverflow,
    this.textTransform = TextTransform.none,
  }) {
    if (alignment == null &&
        (display == Display.BLOCK || display == Display.LIST_ITEM)) {
      alignment = Alignment.centerLeft;
    }
  }

  static Map<String, Style> fromThemeData(ThemeData theme) => {
        'h1': Style.fromTextStyle(theme.textTheme.displayLarge!),
        'h2': Style.fromTextStyle(theme.textTheme.displayMedium!),
        'h3': Style.fromTextStyle(theme.textTheme.displaySmall!),
        'h4': Style.fromTextStyle(theme.textTheme.headlineMedium!),
        'h5': Style.fromTextStyle(theme.textTheme.headlineSmall!),
        'h6': Style.fromTextStyle(theme.textTheme.titleLarge!),
        'body': Style.fromTextStyle(theme.textTheme.bodyMedium!),
      };

  static Map<String, Style> fromCss(
      String css, OnCssParseError? onCssParseError) {
    final declarations = parseExternalCss(css, onCssParseError);
    Map<String, Style> styleMap = {};
    declarations.forEach((key, value) {
      styleMap[key] = declarationsToStyle(value);
    });
    return styleMap;
  }

  TextStyle generateTextStyle() {
    return TextStyle(
      backgroundColor: backgroundColor,
      color: color,
      decoration: textDecoration,
      decorationColor: textDecorationColor,
      decorationStyle: textDecorationStyle,
      decorationThickness: textDecorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontFeatures: fontFeatureSettings,
      fontSize: fontSize?.size,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      shadows: textShadow,
      wordSpacing: wordSpacing,
      height: lineHeight?.size ?? 1.0,
    );
  }

  @override
  String toString() {
    return "Style";
  }

  Style merge(Style other) {
    return copyWith(
      backgroundColor: other.backgroundColor,
      color: other.color,
      direction: other.direction,
      display: other.display,
      fontFamily: other.fontFamily,
      fontFamilyFallback: other.fontFamilyFallback,
      fontFeatureSettings: other.fontFeatureSettings,
      fontSize: other.fontSize,
      fontStyle: other.fontStyle,
      fontWeight: other.fontWeight,
      height: other.height,
      lineHeight: other.lineHeight,
      letterSpacing: other.letterSpacing,
      listStyleType: other.listStyleType,
      listStylePosition: other.listStylePosition,
      padding: other.padding,
      margin: other.margin,
      textAlign: other.textAlign,
      textDecoration: other.textDecoration,
      textDecorationColor: other.textDecorationColor,
      textDecorationStyle: other.textDecorationStyle,
      textDecorationThickness: other.textDecorationThickness,
      textShadow: other.textShadow,
      verticalAlign: other.verticalAlign,
      whiteSpace: other.whiteSpace,
      width: other.width,
      wordSpacing: other.wordSpacing,
      before: other.before,
      after: other.after,
      border: other.border,
      alignment: other.alignment,
      markerContent: other.markerContent,
      maxLines: other.maxLines,
      textOverflow: other.textOverflow,
      textTransform: other.textTransform,
    );
  }

  Style copyOnlyInherited(Style child) {
    FontSize? finalFontSize = child.fontSize != null
        ? fontSize != null && child.fontSize?.units == "em"
            ? FontSize(child.fontSize!.size! * fontSize!.size!)
            : child.fontSize
        : fontSize != null && fontSize!.size! < 0
            ? FontSize.percent(100)
            : fontSize;
    LineHeight? finalLineHeight = child.lineHeight != null
        ? child.lineHeight?.units == "length"
            ? LineHeight(child.lineHeight!.size! /
                (finalFontSize == null ? 14 : finalFontSize.size!) *
                1.2)
            : child.lineHeight
        : lineHeight;
    return child.copyWith(
      backgroundColor: child.backgroundColor != Colors.transparent
          ? child.backgroundColor
          : backgroundColor,
      color: child.color ?? color,
      direction: child.direction ?? direction,
      display: display == Display.NONE ? display : child.display,
      fontFamily: child.fontFamily ?? fontFamily,
      fontFamilyFallback: child.fontFamilyFallback ?? fontFamilyFallback,
      fontFeatureSettings: child.fontFeatureSettings ?? fontFeatureSettings,
      fontSize: finalFontSize,
      fontStyle: child.fontStyle ?? fontStyle,
      fontWeight: child.fontWeight ?? fontWeight,
      lineHeight: finalLineHeight,
      letterSpacing: child.letterSpacing ?? letterSpacing,
      listStyleType: child.listStyleType ?? listStyleType,
      listStylePosition: child.listStylePosition ?? listStylePosition,
      textAlign: child.textAlign ?? textAlign,
      textDecoration: TextDecoration.combine([
        child.textDecoration ?? TextDecoration.none,
        textDecoration ?? TextDecoration.none
      ]),
      textShadow: child.textShadow ?? textShadow,
      whiteSpace: child.whiteSpace ?? whiteSpace,
      wordSpacing: child.wordSpacing ?? wordSpacing,
      maxLines: child.maxLines ?? maxLines,
      textOverflow: child.textOverflow ?? textOverflow,
      textTransform: child.textTransform ?? textTransform,
    );
  }

  Style copyWith({
    Color? backgroundColor,
    Color? color,
    TextDirection? direction,
    Display? display,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    List<FontFeature>? fontFeatureSettings,
    FontSize? fontSize,
    FontStyle? fontStyle,
    FontWeight? fontWeight,
    double? height,
    LineHeight? lineHeight,
    double? letterSpacing,
    ListStyleType? listStyleType,
    ListStylePosition? listStylePosition,
    EdgeInsets? padding,
    EdgeInsets? margin,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
    Color? textDecorationColor,
    TextDecorationStyle? textDecorationStyle,
    double? textDecorationThickness,
    List<Shadow>? textShadow,
    VerticalAlign? verticalAlign,
    WhiteSpace? whiteSpace,
    double? width,
    double? wordSpacing,
    String? before,
    String? after,
    Border? border,
    Alignment? alignment,
    Widget? markerContent,
    int? maxLines,
    TextOverflow? textOverflow,
    TextTransform? textTransform,
    bool? beforeAfterNull,
  }) {
    return Style(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      color: color ?? this.color,
      direction: direction ?? this.direction,
      display: display ?? this.display,
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      fontFeatureSettings: fontFeatureSettings ?? this.fontFeatureSettings,
      fontSize: fontSize ?? this.fontSize,
      fontStyle: fontStyle ?? this.fontStyle,
      fontWeight: fontWeight ?? this.fontWeight,
      height: height ?? this.height,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      listStyleType: listStyleType ?? this.listStyleType,
      listStylePosition: listStylePosition ?? this.listStylePosition,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      textAlign: textAlign ?? this.textAlign,
      textDecoration: textDecoration ?? this.textDecoration,
      textDecorationColor: textDecorationColor ?? this.textDecorationColor,
      textDecorationStyle: textDecorationStyle ?? this.textDecorationStyle,
      textDecorationThickness:
          textDecorationThickness ?? this.textDecorationThickness,
      textShadow: textShadow ?? this.textShadow,
      verticalAlign: verticalAlign ?? this.verticalAlign,
      whiteSpace: whiteSpace ?? this.whiteSpace,
      width: width ?? this.width,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      before: beforeAfterNull == true ? null : before ?? this.before,
      after: beforeAfterNull == true ? null : after ?? this.after,
      border: border ?? this.border,
      alignment: alignment ?? this.alignment,
      markerContent: markerContent ?? this.markerContent,
      maxLines: maxLines ?? this.maxLines,
      textOverflow: textOverflow ?? this.textOverflow,
      textTransform: textTransform ?? this.textTransform,
    );
  }

  Style.fromTextStyle(TextStyle textStyle) {
    backgroundColor = textStyle.backgroundColor;
    color = textStyle.color;
    textDecoration = textStyle.decoration;
    textDecorationColor = textStyle.decorationColor;
    textDecorationStyle = textStyle.decorationStyle;
    textDecorationThickness = textStyle.decorationThickness;
    fontFamily = textStyle.fontFamily;
    fontFamilyFallback = textStyle.fontFamilyFallback;
    fontFeatureSettings = textStyle.fontFeatures;
    fontSize = FontSize(textStyle.fontSize);
    fontStyle = textStyle.fontStyle;
    fontWeight = textStyle.fontWeight;
    letterSpacing = textStyle.letterSpacing;
    textShadow = textStyle.shadows;
    wordSpacing = textStyle.wordSpacing;
    lineHeight = LineHeight(textStyle.height ?? 1.2);
    textTransform = TextTransform.none;
  }
}

enum Display {
  BLOCK,
  INLINE,
  INLINE_BLOCK,
  LIST_ITEM,
  NONE,
}

class FontSize {
  final double? size;
  final String units;

  const FontSize(this.size, {this.units = ""});

  /// A percentage of the parent style's font size.
  factory FontSize.percent(double percent) {
    return FontSize(percent / -100.0, units: "%");
  }

  factory FontSize.em(double? em) {
    return FontSize(em, units: "em");
  }

  factory FontSize.rem(double rem) {
    return FontSize(rem * 16 - 2, units: "rem");
  }
  // These values are calculated based off of the default (`medium`)
  // being 14px.
  //
  // Negative values are computed during parsing to be a percentage of
  // the parent style's font size.
  static const xxSmall = FontSize(7.875);
  static const xSmall = FontSize(8.75);
  static const small = FontSize(11.375);
  static const medium = FontSize(14.0);
  static const large = FontSize(15.75);
  static const xLarge = FontSize(21.0);
  static const xxLarge = FontSize(28.0);
  static const smaller = FontSize(-0.83);
  static const larger = FontSize(-1.2);
}

class LineHeight {
  final double? size;
  final String units;

  const LineHeight(this.size, {this.units = ""});

  factory LineHeight.percent(double percent) {
    return LineHeight(percent / 100.0 * 1.2, units: "%");
  }

  factory LineHeight.em(double em) {
    return LineHeight(em * 1.2, units: "em");
  }

  factory LineHeight.rem(double rem) {
    return LineHeight(rem * 1.2, units: "rem");
  }

  factory LineHeight.number(double num) {
    return LineHeight(num * 1.2, units: "number");
  }

  static const normal = LineHeight(1.2);
}

class ListStyleType {
  final String text;
  final String type;
  final Widget? widget;

  const ListStyleType(this.text, {this.type = "marker", this.widget});

  factory ListStyleType.fromImage(String url) =>
      ListStyleType(url, type: "image");

  factory ListStyleType.fromWidget(Widget widget) =>
      ListStyleType("", widget: widget, type: "widget");

  static const LOWER_ALPHA = ListStyleType("LOWER_ALPHA");
  static const UPPER_ALPHA = ListStyleType("UPPER_ALPHA");
  static const LOWER_LATIN = ListStyleType("LOWER_LATIN");
  static const UPPER_LATIN = ListStyleType("UPPER_LATIN");
  static const CIRCLE = ListStyleType("CIRCLE");
  static const DISC = ListStyleType("DISC");
  static const DECIMAL = ListStyleType("DECIMAL");
  static const LOWER_ROMAN = ListStyleType("LOWER_ROMAN");
  static const UPPER_ROMAN = ListStyleType("UPPER_ROMAN");
  static const SQUARE = ListStyleType("SQUARE");
  static const NONE = ListStyleType("NONE");
}

enum ListStylePosition {
  OUTSIDE,
  INSIDE,
}

enum TextTransform {
  uppercase,
  lowercase,
  capitalize,
  none,
}

enum VerticalAlign {
  BASELINE,
  SUB,
  SUPER,
}

enum WhiteSpace {
  NORMAL,
  PRE,
}

```

##### 📂 lib/widget\simple_html\src

#### 📄 `lib/widget\simple_html\src\anchor.dart`

```dart
import 'package:flutter/widgets.dart';

import 'styled_element.dart';

class AnchorKey extends GlobalKey {
  static final Set<AnchorKey> _registry = <AnchorKey>{};

  final Key parentKey;
  final String id;

  const AnchorKey._(this.parentKey, this.id) : super.constructor();

  static AnchorKey? of(Key? parentKey, StyledElement? id) {
    final key = forId(parentKey, id?.elementId);
    if (key == null || _registry.contains(key)) {
      // Invalid id or already created a key with this id: silently ignore
      return null;
    }
    _registry.add(key);
    return key;
  }

  static AnchorKey? forId(Key? parentKey, String? id) {
    if (parentKey == null || id == null || id.isEmpty || id == "[[No ID]]") {
      return null;
    }

    return AnchorKey._(parentKey, id);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnchorKey &&
          runtimeType == other.runtimeType &&
          parentKey == other.parentKey &&
          id == other.id;

  @override
  int get hashCode => parentKey.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'AnchorKey{parentKey: $parentKey, id: #$id}';
  }
}

```

#### 📄 `lib/widget\simple_html\src\css_parser.dart`

```dart
import 'package:collection/collection.dart';
import 'package:csslib/visitor.dart' as css;
import 'package:csslib/parser.dart' as cssparser;
import 'package:flutter/material.dart';

import '../html_parser.dart';
import '../style.dart';
import 'utils.dart';

Style declarationsToStyle(Map<String, List<css.Expression>> declarations) {
  Style style = Style();
  declarations.forEach((property, value) {
    if (value.isNotEmpty) {
      switch (property) {
        case 'background-color':
          style.backgroundColor =
              ExpressionMapping.expressionToColor(value.first) ??
                  style.backgroundColor;
          break;
        case 'border':
          List<css.LiteralTerm?>? borderWidths =
              value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.width], so make sure to remove those before passing it to [ExpressionMapping]
          borderWidths.removeWhere((element) =>
              element == null ||
              (element.text != "thin" &&
                  element.text != "medium" &&
                  element.text != "thick" &&
                  element is! css.LengthTerm &&
                  element is! css.PercentageTerm &&
                  element is! css.EmTerm &&
                  element is! css.RemTerm &&
                  element is! css.NumberTerm));
          List<css.Expression?>? borderColors = value
              .where((element) =>
                  ExpressionMapping.expressionToColor(element) != null)
              .toList();
          List<css.LiteralTerm?>? potentialStyles =
              value.whereType<css.LiteralTerm>().toList();

          /// Currently doesn't matter, as Flutter only supports "solid" or "none", but may support more in the future.
          List<String> possibleBorderValues = [
            "dotted",
            "dashed",
            "solid",
            "double",
            "groove",
            "ridge",
            "inset",
            "outset",
            "none",
            "hidden"
          ];

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere((element) =>
              element == null || !possibleBorderValues.contains(element.text));
          List<css.LiteralTerm?>? borderStyles = potentialStyles;
          style.border = ExpressionMapping.expressionToBorder(
              borderWidths, borderStyles, borderColors);
          break;
        case 'border-left':
          List<css.LiteralTerm?>? borderWidths =
              value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.width], so make sure to remove those before passing it to [ExpressionMapping]
          borderWidths.removeWhere((element) =>
              element == null ||
              (element.text != "thin" &&
                  element.text != "medium" &&
                  element.text != "thick" &&
                  element is! css.LengthTerm &&
                  element is! css.PercentageTerm &&
                  element is! css.EmTerm &&
                  element is! css.RemTerm &&
                  element is! css.NumberTerm));
          css.LiteralTerm? borderWidth =
              borderWidths.firstWhereOrNull((element) => element != null);
          css.Expression? borderColor = value.firstWhereOrNull((element) =>
              ExpressionMapping.expressionToColor(element) != null);
          List<css.LiteralTerm?>? potentialStyles =
              value.whereType<css.LiteralTerm>().toList();

          /// Currently doesn't matter, as Flutter only supports "solid" or "none", but may support more in the future.
          List<String> possibleBorderValues = [
            "dotted",
            "dashed",
            "solid",
            "double",
            "groove",
            "ridge",
            "inset",
            "outset",
            "none",
            "hidden"
          ];

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere((element) =>
              element == null || !possibleBorderValues.contains(element.text));
          css.LiteralTerm? borderStyle = potentialStyles.firstOrNull;
          Border newBorder = Border(
            left: style.border?.left.copyWith(
                  width: ExpressionMapping.expressionToBorderWidth(borderWidth),
                  style: ExpressionMapping.expressionToBorderStyle(borderStyle),
                  color: ExpressionMapping.expressionToColor(borderColor),
                ) ??
                BorderSide(
                  width: ExpressionMapping.expressionToBorderWidth(borderWidth),
                  style: ExpressionMapping.expressionToBorderStyle(borderStyle),
                  color: ExpressionMapping.expressionToColor(borderColor) ??
                      Colors.black,
                ),
            right: style.border?.right ?? BorderSide.none,
            top: style.border?.top ?? BorderSide.none,
            bottom: style.border?.bottom ?? BorderSide.none,
          );
          style.border = newBorder;
          break;
        case 'border-right':
          List<css.LiteralTerm?>? borderWidths =
              value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.width], so make sure to remove those before passing it to [ExpressionMapping]
          borderWidths.removeWhere((element) =>
              element == null ||
              (element.text != "thin" &&
                  element.text != "medium" &&
                  element.text != "thick" &&
                  element is! css.LengthTerm &&
                  element is! css.PercentageTerm &&
                  element is! css.EmTerm &&
                  element is! css.RemTerm &&
                  element is! css.NumberTerm));
          css.LiteralTerm? borderWidth =
              borderWidths.firstWhereOrNull((element) => element != null);
          css.Expression? borderColor = value.firstWhereOrNull((element) =>
              ExpressionMapping.expressionToColor(element) != null);
          List<css.LiteralTerm?>? potentialStyles =
              value.whereType<css.LiteralTerm>().toList();

          /// Currently doesn't matter, as Flutter only supports "solid" or "none", but may support more in the future.
          List<String> possibleBorderValues = [
            "dotted",
            "dashed",
            "solid",
            "double",
            "groove",
            "ridge",
            "inset",
            "outset",
            "none",
            "hidden"
          ];

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere((element) =>
              element == null || !possibleBorderValues.contains(element.text));
          css.LiteralTerm? borderStyle = potentialStyles.firstOrNull;
          Border newBorder = Border(
            left: style.border?.left ?? BorderSide.none,
            right: style.border?.right.copyWith(
                  width: ExpressionMapping.expressionToBorderWidth(borderWidth),
                  style: ExpressionMapping.expressionToBorderStyle(borderStyle),
                  color: ExpressionMapping.expressionToColor(borderColor),
                ) ??
                BorderSide(
                  width: ExpressionMapping.expressionToBorderWidth(borderWidth),
                  style: ExpressionMapping.expressionToBorderStyle(borderStyle),
                  color: ExpressionMapping.expressionToColor(borderColor) ??
                      Colors.black,
                ),
            top: style.border?.top ?? BorderSide.none,
            bottom: style.border?.bottom ?? BorderSide.none,
          );
          style.border = newBorder;
          break;
        case 'border-top':
          List<css.LiteralTerm?>? borderWidths =
              value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.width], so make sure to remove those before passing it to [ExpressionMapping]
          borderWidths.removeWhere((element) =>
              element == null ||
              (element.text != "thin" &&
                  element.text != "medium" &&
                  element.text != "thick" &&
                  element is! css.LengthTerm &&
                  element is! css.PercentageTerm &&
                  element is! css.EmTerm &&
                  element is! css.RemTerm &&
                  element is! css.NumberTerm));
          css.LiteralTerm? borderWidth =
              borderWidths.firstWhereOrNull((element) => element != null);
          css.Expression? borderColor = value.firstWhereOrNull((element) =>
              ExpressionMapping.expressionToColor(element) != null);
          List<css.LiteralTerm?>? potentialStyles =
              value.whereType<css.LiteralTerm>().toList();

          /// Currently doesn't matter, as Flutter only supports "solid" or "none", but may support more in the future.
          List<String> possibleBorderValues = [
            "dotted",
            "dashed",
            "solid",
            "double",
            "groove",
            "ridge",
            "inset",
            "outset",
            "none",
            "hidden"
          ];

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere((element) =>
              element == null || !possibleBorderValues.contains(element.text));
          css.LiteralTerm? borderStyle = potentialStyles.firstOrNull;
          Border newBorder = Border(
            left: style.border?.left ?? BorderSide.none,
            right: style.border?.right ?? BorderSide.none,
            top: style.border?.top.copyWith(
                  width: ExpressionMapping.expressionToBorderWidth(borderWidth),
                  style: ExpressionMapping.expressionToBorderStyle(borderStyle),
                  color: ExpressionMapping.expressionToColor(borderColor),
                ) ??
                BorderSide(
                  width: ExpressionMapping.expressionToBorderWidth(borderWidth),
                  style: ExpressionMapping.expressionToBorderStyle(borderStyle),
                  color: ExpressionMapping.expressionToColor(borderColor) ??
                      Colors.black,
                ),
            bottom: style.border?.bottom ?? BorderSide.none,
          );
          style.border = newBorder;
          break;
        case 'border-bottom':
          List<css.LiteralTerm?>? borderWidths =
              value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.width], so make sure to remove those before passing it to [ExpressionMapping]
          borderWidths.removeWhere((element) =>
              element == null ||
              (element.text != "thin" &&
                  element.text != "medium" &&
                  element.text != "thick" &&
                  element is! css.LengthTerm &&
                  element is! css.PercentageTerm &&
                  element is! css.EmTerm &&
                  element is! css.RemTerm &&
                  element is! css.NumberTerm));
          css.LiteralTerm? borderWidth =
              borderWidths.firstWhereOrNull((element) => element != null);
          css.Expression? borderColor = value.firstWhereOrNull((element) =>
              ExpressionMapping.expressionToColor(element) != null);
          List<css.LiteralTerm?>? potentialStyles =
              value.whereType<css.LiteralTerm>().toList();

          /// Currently doesn't matter, as Flutter only supports "solid" or "none", but may support more in the future.
          List<String> possibleBorderValues = [
            "dotted",
            "dashed",
            "solid",
            "double",
            "groove",
            "ridge",
            "inset",
            "outset",
            "none",
            "hidden"
          ];

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere((element) =>
              element == null || !possibleBorderValues.contains(element.text));
          css.LiteralTerm? borderStyle = potentialStyles.firstOrNull;
          Border newBorder = Border(
            left: style.border?.left ?? BorderSide.none,
            right: style.border?.right ?? BorderSide.none,
            top: style.border?.top ?? BorderSide.none,
            bottom: style.border?.bottom.copyWith(
                  width: ExpressionMapping.expressionToBorderWidth(borderWidth),
                  style: ExpressionMapping.expressionToBorderStyle(borderStyle),
                  color: ExpressionMapping.expressionToColor(borderColor),
                ) ??
                BorderSide(
                  width: ExpressionMapping.expressionToBorderWidth(borderWidth),
                  style: ExpressionMapping.expressionToBorderStyle(borderStyle),
                  color: ExpressionMapping.expressionToColor(borderColor) ??
                      Colors.black,
                ),
          );
          style.border = newBorder;
          break;
        case 'color':
          style.color =
              ExpressionMapping.expressionToColor(value.first) ?? style.color;
          break;
        case 'direction':
          style.direction =
              ExpressionMapping.expressionToDirection(value.first);
          break;
        case 'display':
          style.display = ExpressionMapping.expressionToDisplay(value.first);
          break;
        case 'line-height':
          style.lineHeight =
              ExpressionMapping.expressionToLineHeight(value.first);
          break;
        case 'font-family':
          style.fontFamily =
              ExpressionMapping.expressionToFontFamily(value.first) ??
                  style.fontFamily;
          break;
        case 'font-feature-settings':
          style.fontFeatureSettings =
              ExpressionMapping.expressionToFontFeatureSettings(value);
          break;
        case 'font-size':
          style.fontSize =
              ExpressionMapping.expressionToFontSize(value.first) ??
                  style.fontSize;
          break;
        case 'font-style':
          style.fontStyle =
              ExpressionMapping.expressionToFontStyle(value.first);
          break;
        case 'font-weight':
          style.fontWeight =
              ExpressionMapping.expressionToFontWeight(value.first);
          break;
        case 'list-style':
          css.LiteralTerm? position = value.firstWhereOrNull((e) =>
              e is css.LiteralTerm &&
              (e.text == "outside" || e.text == "inside")) as css.LiteralTerm?;
          css.UriTerm? image =
              value.firstWhereOrNull((e) => e is css.UriTerm) as css.UriTerm?;
          css.LiteralTerm? type = value.firstWhereOrNull((e) =>
              e is css.LiteralTerm &&
              e.text != "outside" &&
              e.text != "inside") as css.LiteralTerm?;
          if (position != null) {
            switch (position.text) {
              case 'outside':
                style.listStylePosition = ListStylePosition.OUTSIDE;
                break;
              case 'inside':
                style.listStylePosition = ListStylePosition.INSIDE;
                break;
            }
          }
          if (image != null) {
            style.listStyleType =
                ExpressionMapping.expressionToListStyleType(image) ??
                    style.listStyleType;
          } else if (type != null) {
            style.listStyleType =
                ExpressionMapping.expressionToListStyleType(type) ??
                    style.listStyleType;
          }
          break;
        case 'list-style-image':
          if (value.first is css.UriTerm) {
            style.listStyleType = ExpressionMapping.expressionToListStyleType(
                    value.first as css.UriTerm) ??
                style.listStyleType;
          }
          break;
        case 'list-style-position':
          if (value.first is css.LiteralTerm) {
            switch ((value.first as css.LiteralTerm).text) {
              case 'outside':
                style.listStylePosition = ListStylePosition.OUTSIDE;
                break;
              case 'inside':
                style.listStylePosition = ListStylePosition.INSIDE;
                break;
            }
          }
          break;
        case 'height':
          style.height =
              ExpressionMapping.expressionToPaddingLength(value.first) ??
                  style.height;
          break;
        case 'list-style-type':
          if (value.first is css.LiteralTerm) {
            style.listStyleType = ExpressionMapping.expressionToListStyleType(
                    value.first as css.LiteralTerm) ??
                style.listStyleType;
          }
          break;
        case 'margin':
          List<css.LiteralTerm>? marginLengths =
              value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for margin length, so make sure to remove those before passing it to [ExpressionMapping]
          marginLengths.removeWhere((element) =>
              element is! css.LengthTerm &&
              element is! css.EmTerm &&
              element is! css.RemTerm &&
              element is! css.NumberTerm);
          List<double?> margin =
              ExpressionMapping.expressionToPadding(marginLengths);
          style.margin = (style.margin ?? EdgeInsets.zero).copyWith(
            left: margin[0],
            right: margin[1],
            top: margin[2],
            bottom: margin[3],
          );
          break;
        case 'margin-left':
          style.margin = (style.margin ?? EdgeInsets.zero).copyWith(
              left: ExpressionMapping.expressionToPaddingLength(value.first));
          break;
        case 'margin-right':
          style.margin = (style.margin ?? EdgeInsets.zero).copyWith(
              right: ExpressionMapping.expressionToPaddingLength(value.first));
          break;
        case 'margin-top':
          style.margin = (style.margin ?? EdgeInsets.zero).copyWith(
              top: ExpressionMapping.expressionToPaddingLength(value.first));
          break;
        case 'margin-bottom':
          style.margin = (style.margin ?? EdgeInsets.zero).copyWith(
              bottom: ExpressionMapping.expressionToPaddingLength(value.first));
          break;
        case 'padding':
          List<css.LiteralTerm>? paddingLengths =
              value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for padding length, so make sure to remove those before passing it to [ExpressionMapping]
          paddingLengths.removeWhere((element) =>
              element is! css.LengthTerm &&
              element is! css.EmTerm &&
              element is! css.RemTerm &&
              element is! css.NumberTerm);
          List<double?> padding =
              ExpressionMapping.expressionToPadding(paddingLengths);
          style.padding = (style.padding ?? EdgeInsets.zero).copyWith(
            left: padding[0],
            right: padding[1],
            top: padding[2],
            bottom: padding[3],
          );
          break;
        case 'padding-left':
          style.padding = (style.padding ?? EdgeInsets.zero).copyWith(
              left: ExpressionMapping.expressionToPaddingLength(value.first));
          break;
        case 'padding-right':
          style.padding = (style.padding ?? EdgeInsets.zero).copyWith(
              right: ExpressionMapping.expressionToPaddingLength(value.first));
          break;
        case 'padding-top':
          style.padding = (style.padding ?? EdgeInsets.zero).copyWith(
              top: ExpressionMapping.expressionToPaddingLength(value.first));
          break;
        case 'padding-bottom':
          style.padding = (style.padding ?? EdgeInsets.zero).copyWith(
              bottom: ExpressionMapping.expressionToPaddingLength(value.first));
          break;
        case 'text-align':
          style.textAlign =
              ExpressionMapping.expressionToTextAlign(value.first);
          break;
        case 'text-decoration':
          List<css.LiteralTerm?>? textDecorationList =
              value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [textDecorationList], so make sure to remove those before passing it to [ExpressionMapping]
          textDecorationList.removeWhere((element) =>
              element == null ||
              (element.text != "none" &&
                  element.text != "overline" &&
                  element.text != "underline" &&
                  element.text != "line-through"));
          List<css.Expression?>? nullableList = value;
          css.Expression? textDecorationColor;
          textDecorationColor = nullableList.firstWhereOrNull((element) =>
              element is css.HexColorTerm || element is css.FunctionTerm);
          List<css.LiteralTerm?>? potentialStyles =
              value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [textDecorationStyle], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere((element) =>
              element == null ||
              (element.text != "solid" &&
                  element.text != "double" &&
                  element.text != "dashed" &&
                  element.text != "dotted" &&
                  element.text != "wavy"));
          css.LiteralTerm? textDecorationStyle =
              potentialStyles.isNotEmpty ? potentialStyles.last : null;
          style.textDecoration =
              ExpressionMapping.expressionToTextDecorationLine(
                  textDecorationList);
          if (textDecorationColor != null) {
            style.textDecorationColor =
                ExpressionMapping.expressionToColor(textDecorationColor) ??
                    style.textDecorationColor;
          }
          if (textDecorationStyle != null) {
            style.textDecorationStyle =
                ExpressionMapping.expressionToTextDecorationStyle(
                    textDecorationStyle);
          }
          break;
        case 'text-decoration-color':
          style.textDecorationColor =
              ExpressionMapping.expressionToColor(value.first) ??
                  style.textDecorationColor;
          break;
        case 'text-decoration-line':
          List<css.LiteralTerm?>? textDecorationList =
              value.whereType<css.LiteralTerm>().toList();
          style.textDecoration =
              ExpressionMapping.expressionToTextDecorationLine(
                  textDecorationList);
          break;
        case 'text-decoration-style':
          style.textDecorationStyle =
              ExpressionMapping.expressionToTextDecorationStyle(
                  value.first as css.LiteralTerm);
          break;
        case 'text-shadow':
          style.textShadow = ExpressionMapping.expressionToTextShadow(value);
          break;
        case 'text-transform':
          final val = (value.first as css.LiteralTerm).text;
          if (val == 'uppercase') {
            style.textTransform = TextTransform.uppercase;
          } else if (val == 'lowercase') {
            style.textTransform = TextTransform.lowercase;
          } else if (val == 'capitalize') {
            style.textTransform = TextTransform.capitalize;
          } else {
            style.textTransform = TextTransform.none;
          }
          break;
        case 'width':
          style.width =
              ExpressionMapping.expressionToPaddingLength(value.first) ??
                  style.width;
          break;
      }
    }
  });
  return style;
}

Style? inlineCssToStyle(String? inlineStyle, OnCssParseError? errorHandler) {
  var errors = <cssparser.Message>[];
  final sheet = cssparser.parse("*{$inlineStyle}", errors: errors);
  if (errors.isEmpty) {
    final declarations = DeclarationVisitor().getDeclarations(sheet);
    return declarationsToStyle(declarations["*"]!);
  } else if (errorHandler != null) {
    String? newCss = errorHandler.call(inlineStyle ?? "", errors);
    if (newCss != null) {
      return inlineCssToStyle(newCss, errorHandler);
    }
  }
  return null;
}

Map<String, Map<String, List<css.Expression>>> parseExternalCss(
    String css, OnCssParseError? errorHandler) {
  var errors = <cssparser.Message>[];
  final sheet = cssparser.parse(css, errors: errors);
  if (errors.isEmpty) {
    return DeclarationVisitor().getDeclarations(sheet);
  } else if (errorHandler != null) {
    String? newCss = errorHandler.call(css, errors);
    if (newCss != null) {
      return parseExternalCss(newCss, errorHandler);
    }
  }
  return {};
}

class DeclarationVisitor extends css.Visitor {
  final Map<String, Map<String, List<css.Expression>>> _result = {};
  final Map<String, List<css.Expression>> _properties = {};
  late String _selector;
  late String _currentProperty;

  Map<String, Map<String, List<css.Expression>>> getDeclarations(
      css.StyleSheet sheet) {
    for (var element in sheet.topLevels) {
      if (element.span != null) {
        _selector = element.span!.text;
        element.visit(this);
        if (_result[_selector] != null) {
          _properties.forEach((key, value) {
            if (_result[_selector]![key] != null) {
              _result[_selector]![key]!
                  .addAll(List<css.Expression>.from(value));
            } else {
              _result[_selector]![key] = List<css.Expression>.from(value);
            }
          });
        } else {
          _result[_selector] =
              Map<String, List<css.Expression>>.from(_properties);
        }
        _properties.clear();
      }
    }
    return _result;
  }

  @override
  void visitDeclaration(css.Declaration node) {
    _currentProperty = node.property;
    _properties[_currentProperty] = <css.Expression>[];
    node.expression!.visit(this);
  }

  @override
  void visitExpressions(css.Expressions node) {
    if (_properties[_currentProperty] != null) {
      _properties[_currentProperty]!.addAll(node.expressions);
    } else {
      _properties[_currentProperty] = node.expressions;
    }
  }
}

//Mapping functions
class ExpressionMapping {
  static Border expressionToBorder(
      List<css.Expression?>? borderWidths,
      List<css.LiteralTerm?>? borderStyles,
      List<css.Expression?>? borderColors) {
    CustomBorderSide left = CustomBorderSide();
    CustomBorderSide top = CustomBorderSide();
    CustomBorderSide right = CustomBorderSide();
    CustomBorderSide bottom = CustomBorderSide();
    if (borderWidths != null && borderWidths.isNotEmpty) {
      top.width = expressionToBorderWidth(borderWidths.first);
      if (borderWidths.length == 4) {
        right.width = expressionToBorderWidth(borderWidths[1]);
        bottom.width = expressionToBorderWidth(borderWidths[2]);
        left.width = expressionToBorderWidth(borderWidths.last);
      }
      if (borderWidths.length == 3) {
        left.width = expressionToBorderWidth(borderWidths[1]);
        right.width = expressionToBorderWidth(borderWidths[1]);
        bottom.width = expressionToBorderWidth(borderWidths.last);
      }
      if (borderWidths.length == 2) {
        bottom.width = expressionToBorderWidth(borderWidths.first);
        left.width = expressionToBorderWidth(borderWidths.last);
        right.width = expressionToBorderWidth(borderWidths.last);
      }
      if (borderWidths.length == 1) {
        bottom.width = expressionToBorderWidth(borderWidths.first);
        left.width = expressionToBorderWidth(borderWidths.first);
        right.width = expressionToBorderWidth(borderWidths.first);
      }
    }
    if (borderStyles != null && borderStyles.isNotEmpty) {
      top.style = expressionToBorderStyle(borderStyles.first);
      if (borderStyles.length == 4) {
        right.style = expressionToBorderStyle(borderStyles[1]);
        bottom.style = expressionToBorderStyle(borderStyles[2]);
        left.style = expressionToBorderStyle(borderStyles.last);
      }
      if (borderStyles.length == 3) {
        left.style = expressionToBorderStyle(borderStyles[1]);
        right.style = expressionToBorderStyle(borderStyles[1]);
        bottom.style = expressionToBorderStyle(borderStyles.last);
      }
      if (borderStyles.length == 2) {
        bottom.style = expressionToBorderStyle(borderStyles.first);
        left.style = expressionToBorderStyle(borderStyles.last);
        right.style = expressionToBorderStyle(borderStyles.last);
      }
      if (borderStyles.length == 1) {
        bottom.style = expressionToBorderStyle(borderStyles.first);
        left.style = expressionToBorderStyle(borderStyles.first);
        right.style = expressionToBorderStyle(borderStyles.first);
      }
    }
    if (borderColors != null && borderColors.isNotEmpty) {
      top.color = expressionToColor(borderColors.first);
      if (borderColors.length == 4) {
        right.color = expressionToColor(borderColors[1]);
        bottom.color = expressionToColor(borderColors[2]);
        left.color = expressionToColor(borderColors.last);
      }
      if (borderColors.length == 3) {
        left.color = expressionToColor(borderColors[1]);
        right.color = expressionToColor(borderColors[1]);
        bottom.color = expressionToColor(borderColors.last);
      }
      if (borderColors.length == 2) {
        bottom.color = expressionToColor(borderColors.first);
        left.color = expressionToColor(borderColors.last);
        right.color = expressionToColor(borderColors.last);
      }
      if (borderColors.length == 1) {
        bottom.color = expressionToColor(borderColors.first);
        left.color = expressionToColor(borderColors.first);
        right.color = expressionToColor(borderColors.first);
      }
    }
    return Border(
        top: BorderSide(
            width: top.width,
            color: top.color ?? Colors.black,
            style: top.style),
        right: BorderSide(
            width: right.width,
            color: right.color ?? Colors.black,
            style: right.style),
        bottom: BorderSide(
            width: bottom.width,
            color: bottom.color ?? Colors.black,
            style: bottom.style),
        left: BorderSide(
            width: left.width,
            color: left.color ?? Colors.black,
            style: left.style));
  }

  static double expressionToBorderWidth(css.Expression? value) {
    if (value is css.NumberTerm) {
      return double.tryParse(value.text) ?? 1.0;
    } else if (value is css.PercentageTerm) {
      return (double.tryParse(value.text) ?? 400) / 100;
    } else if (value is css.EmTerm) {
      return double.tryParse(value.text) ?? 1.0;
    } else if (value is css.RemTerm) {
      return double.tryParse(value.text) ?? 1.0;
    } else if (value is css.LengthTerm) {
      return double.tryParse(
              value.text.replaceAll(RegExp(r'\s+(\d+\.\d+)\s+'), '')) ??
          1.0;
    } else if (value is css.LiteralTerm) {
      switch (value.text) {
        case "thin":
          return 2.0;
        case "medium":
          return 4.0;
        case "thick":
          return 6.0;
      }
    }
    return 4.0;
  }

  static BorderStyle expressionToBorderStyle(css.LiteralTerm? value) {
    if (value != null && value.text != "none" && value.text != "hidden") {
      return BorderStyle.solid;
    }
    return BorderStyle.none;
  }

  static Color? expressionToColor(css.Expression? value) {
    if (value != null) {
      if (value is css.HexColorTerm) {
        return stringToColor(value.text);
      } else if (value is css.FunctionTerm) {
        if (value.text == 'rgba' || value.text == 'rgb') {
          return rgbOrRgbaToColor(value.span!.text);
        } else if (value.text == 'hsla' || value.text == 'hsl') {
          return hslToRgbToColor(value.span!.text);
        }
      } else if (value is css.LiteralTerm) {
        return namedColorToColor(value.text);
      }
    }
    return null;
  }

  static TextDirection expressionToDirection(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch (value.text) {
        case "ltr":
          return TextDirection.ltr;
        case "rtl":
          return TextDirection.rtl;
      }
    }
    return TextDirection.ltr;
  }

  static Display expressionToDisplay(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch (value.text) {
        case 'block':
          return Display.BLOCK;
        case 'inline-block':
          return Display.INLINE_BLOCK;
        case 'inline':
          return Display.INLINE;
        case 'list-item':
          return Display.LIST_ITEM;
        case 'none':
          return Display.NONE;
      }
    }
    return Display.INLINE;
  }

  static List<FontFeature> expressionToFontFeatureSettings(
      List<css.Expression> value) {
    List<FontFeature> fontFeatures = [];
    for (int i = 0; i < value.length; i++) {
      css.Expression exp = value[i];
      if (exp is css.LiteralTerm) {
        if (exp.text != "on" &&
            exp.text != "off" &&
            exp.text != "1" &&
            exp.text != "0") {
          if (i < value.length - 1) {
            css.Expression nextExp = value[i + 1];
            if (nextExp is css.LiteralTerm &&
                (nextExp.text == "on" ||
                    nextExp.text == "off" ||
                    nextExp.text == "1" ||
                    nextExp.text == "0")) {
              fontFeatures.add(FontFeature(exp.text,
                  nextExp.text == "on" || nextExp.text == "1" ? 1 : 0));
            } else {
              fontFeatures.add(FontFeature.enable(exp.text));
            }
          } else {
            fontFeatures.add(FontFeature.enable(exp.text));
          }
        }
      }
    }
    List<FontFeature> finalFontFeatures = fontFeatures.toSet().toList();
    return finalFontFeatures;
  }

  static FontSize? expressionToFontSize(css.Expression value) {
    if (value is css.NumberTerm) {
      return FontSize(double.tryParse(value.text));
    } else if (value is css.PercentageTerm) {
      return FontSize.percent(double.tryParse(value.text)!);
    } else if (value is css.EmTerm) {
      return FontSize.em(double.tryParse(value.text));
    } else if (value is css.RemTerm) {
      return FontSize.rem(double.tryParse(value.text)!);
    } else if (value is css.LengthTerm) {
      return FontSize(double.tryParse(
          value.text.replaceAll(RegExp(r'\s+(\d+\.\d+)\s+'), '')));
    } else if (value is css.LiteralTerm) {
      switch (value.text) {
        case "xx-small":
          return FontSize.xxSmall;
        case "x-small":
          return FontSize.xSmall;
        case "small":
          return FontSize.small;
        case "medium":
          return FontSize.medium;
        case "large":
          return FontSize.large;
        case "x-large":
          return FontSize.xLarge;
        case "xx-large":
          return FontSize.xxLarge;
      }
    }
    return null;
  }

  static FontStyle expressionToFontStyle(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch (value.text) {
        case "italic":
        case "oblique":
          return FontStyle.italic;
      }
      return FontStyle.normal;
    }
    return FontStyle.normal;
  }

  static FontWeight expressionToFontWeight(css.Expression value) {
    if (value is css.NumberTerm) {
      switch (value.text) {
        case "100":
          return FontWeight.w100;
        case "200":
          return FontWeight.w200;
        case "300":
          return FontWeight.w300;
        case "400":
          return FontWeight.w400;
        case "500":
          return FontWeight.w500;
        case "600":
          return FontWeight.w600;
        case "700":
          return FontWeight.w700;
        case "800":
          return FontWeight.w800;
        case "900":
          return FontWeight.w900;
      }
    } else if (value is css.LiteralTerm) {
      switch (value.text) {
        case "bold":
          return FontWeight.bold;
        case "bolder":
          return FontWeight.w900;
        case "lighter":
          return FontWeight.w200;
      }
      return FontWeight.normal;
    }
    return FontWeight.normal;
  }

  static String? expressionToFontFamily(css.Expression value) {
    if (value is css.LiteralTerm) return value.text;
    return null;
  }

  static LineHeight expressionToLineHeight(css.Expression value) {
    if (value is css.NumberTerm) {
      return LineHeight.number(double.tryParse(value.text)!);
    } else if (value is css.PercentageTerm) {
      return LineHeight.percent(double.tryParse(value.text)!);
    } else if (value is css.EmTerm) {
      return LineHeight.em(double.tryParse(value.text)!);
    } else if (value is css.RemTerm) {
      return LineHeight.rem(double.tryParse(value.text)!);
    } else if (value is css.LengthTerm) {
      return LineHeight(
          double.tryParse(
              value.text.replaceAll(RegExp(r'\s+(\d+\.\d+)\s+'), '')),
          units: "length");
    }
    return LineHeight.normal;
  }

  static ListStyleType? expressionToListStyleType(css.LiteralTerm value) {
    if (value is css.UriTerm) {
      return ListStyleType.fromImage(value.text);
    }
    switch (value.text) {
      case 'disc':
        return ListStyleType.DISC;
      case 'circle':
        return ListStyleType.CIRCLE;
      case 'decimal':
        return ListStyleType.DECIMAL;
      case 'lower-alpha':
        return ListStyleType.LOWER_ALPHA;
      case 'lower-latin':
        return ListStyleType.LOWER_LATIN;
      case 'lower-roman':
        return ListStyleType.LOWER_ROMAN;
      case 'square':
        return ListStyleType.SQUARE;
      case 'upper-alpha':
        return ListStyleType.UPPER_ALPHA;
      case 'upper-latin':
        return ListStyleType.UPPER_LATIN;
      case 'upper-roman':
        return ListStyleType.UPPER_ROMAN;
      case 'none':
        return ListStyleType.NONE;
    }
    return null;
  }

  static List<double?> expressionToPadding(List<css.Expression>? lengths) {
    double? left;
    double? right;
    double? top;
    double? bottom;
    if (lengths != null && lengths.isNotEmpty) {
      top = expressionToPaddingLength(lengths.first);
      if (lengths.length == 4) {
        right = expressionToPaddingLength(lengths[1]);
        bottom = expressionToPaddingLength(lengths[2]);
        left = expressionToPaddingLength(lengths.last);
      }
      if (lengths.length == 3) {
        left = expressionToPaddingLength(lengths[1]);
        right = expressionToPaddingLength(lengths[1]);
        bottom = expressionToPaddingLength(lengths.last);
      }
      if (lengths.length == 2) {
        bottom = expressionToPaddingLength(lengths.first);
        left = expressionToPaddingLength(lengths.last);
        right = expressionToPaddingLength(lengths.last);
      }
      if (lengths.length == 1) {
        bottom = expressionToPaddingLength(lengths.first);
        left = expressionToPaddingLength(lengths.first);
        right = expressionToPaddingLength(lengths.first);
      }
    }
    return [left, right, top, bottom];
  }

  static double? expressionToPaddingLength(css.Expression value) {
    if (value is css.NumberTerm) {
      return double.tryParse(value.text);
    } else if (value is css.EmTerm) {
      return double.tryParse(value.text);
    } else if (value is css.RemTerm) {
      return double.tryParse(value.text);
    } else if (value is css.LengthTerm) {
      return double.tryParse(
          value.text.replaceAll(RegExp(r'\s+(\d+\.\d+)\s+'), ''));
    }
    return null;
  }

  static TextAlign expressionToTextAlign(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch (value.text) {
        case "center":
          return TextAlign.center;
        case "left":
          return TextAlign.left;
        case "right":
          return TextAlign.right;
        case "justify":
          return TextAlign.justify;
        case "end":
          return TextAlign.end;
        case "start":
          return TextAlign.start;
      }
    }
    return TextAlign.start;
  }

  static TextDecoration expressionToTextDecorationLine(
      List<css.LiteralTerm?> value) {
    List<TextDecoration> decorationList = [];
    for (css.LiteralTerm? term in value) {
      if (term != null) {
        switch (term.text) {
          case "overline":
            decorationList.add(TextDecoration.overline);
            break;
          case "underline":
            decorationList.add(TextDecoration.underline);
            break;
          case "line-through":
            decorationList.add(TextDecoration.lineThrough);
            break;
          default:
            decorationList.add(TextDecoration.none);
            break;
        }
      }
    }
    if (decorationList.contains(TextDecoration.none)) {
      decorationList = [TextDecoration.none];
    }
    return TextDecoration.combine(decorationList);
  }

  static TextDecorationStyle expressionToTextDecorationStyle(
      css.LiteralTerm value) {
    switch (value.text) {
      case "wavy":
        return TextDecorationStyle.wavy;
      case "dotted":
        return TextDecorationStyle.dotted;
      case "dashed":
        return TextDecorationStyle.dashed;
      case "double":
        return TextDecorationStyle.double;
      default:
        return TextDecorationStyle.solid;
    }
  }

  static List<Shadow> expressionToTextShadow(List<css.Expression> value) {
    List<Shadow> shadow = [];
    List<int> indices = [];
    List<List<css.Expression>> valueList = [];
    for (css.Expression e in value) {
      if (e is css.OperatorComma) {
        indices.add(value.indexOf(e));
      }
    }
    indices.add(value.length);
    int previousIndex = 0;
    for (int i in indices) {
      valueList.add(value.sublist(previousIndex, i));
      previousIndex = i + 1;
    }
    for (List<css.Expression> list in valueList) {
      css.Expression? offsetX;
      css.Expression? offsetY;
      css.Expression? blurRadius;
      css.Expression? color;
      int expressionIndex = 0;
      for (var element in list) {
        if (element is css.HexColorTerm || element is css.FunctionTerm) {
          color = element;
        } else if (expressionIndex == 0) {
          offsetX = element;
          expressionIndex++;
        } else if (expressionIndex++ == 1) {
          offsetY = element;
          expressionIndex++;
        } else {
          blurRadius = element;
        }
      }
      RegExp nonNumberRegex = RegExp(r'\s+(\d+\.\d+)\s+');
      if (offsetX is css.LiteralTerm && offsetY is css.LiteralTerm) {
        if (color != null &&
            ExpressionMapping.expressionToColor(color) != null) {
          shadow.add(Shadow(
            color: expressionToColor(color)!,
            offset: Offset(
                double.tryParse((offsetX).text.replaceAll(nonNumberRegex, ''))!,
                double.tryParse(
                    (offsetY).text.replaceAll(nonNumberRegex, ''))!),
            blurRadius: (blurRadius is css.LiteralTerm)
                ? double.tryParse(
                    (blurRadius).text.replaceAll(nonNumberRegex, ''))!
                : 0.0,
          ));
        } else {
          shadow.add(Shadow(
            offset: Offset(
                double.tryParse((offsetX).text.replaceAll(nonNumberRegex, ''))!,
                double.tryParse(
                    (offsetY).text.replaceAll(nonNumberRegex, ''))!),
            blurRadius: (blurRadius is css.LiteralTerm)
                ? double.tryParse(
                    (blurRadius).text.replaceAll(nonNumberRegex, ''))!
                : 0.0,
          ));
        }
      }
    }
    List<Shadow> finalShadows = shadow.toSet().toList();
    return finalShadows;
  }

  static Color stringToColor(String cx) {
    var text = cx.replaceFirst('#', '');
    if (text.length == 3) {
      text = text.replaceAllMapped(RegExp(r"[a-f]|\d", caseSensitive: false),
          (match) => '${match.group(0)}${match.group(0)}');
    }
    if (text.length > 6) {
      text = "0x$text";
    } else {
      text = "0xFF$text";
    }
    return Color(int.parse(text));
  }

  static Color? rgbOrRgbaToColor(String text) {
    final rgbaText = text.replaceAll(')', '').replaceAll(' ', '');
    try {
      final rgbaValues =
          rgbaText.split(',').map((value) => double.parse(value)).toList();
      if (rgbaValues.length == 4) {
        return Color.fromRGBO(
          rgbaValues[0].toInt(),
          rgbaValues[1].toInt(),
          rgbaValues[2].toInt(),
          rgbaValues[3],
        );
      } else if (rgbaValues.length == 3) {
        return Color.fromRGBO(
          rgbaValues[0].toInt(),
          rgbaValues[1].toInt(),
          rgbaValues[2].toInt(),
          1.0,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Color hslToRgbToColor(String text) {
    final hslText = text.replaceAll(')', '').replaceAll(' ', '');
    final hslValues = hslText.split(',').toList();
    List<double?> parsedHsl = [];
    for (var element in hslValues) {
      if (element.contains("%") &&
          double.tryParse(element.replaceAll("%", "")) != null) {
        parsedHsl.add(double.tryParse(element.replaceAll("%", ""))! * 0.01);
      } else {
        if (element != hslValues.first &&
            (double.tryParse(element) == null ||
                double.tryParse(element)! > 1)) {
          parsedHsl.add(null);
        } else {
          parsedHsl.add(double.tryParse(element));
        }
      }
    }
    if (parsedHsl.length == 4 && !parsedHsl.contains(null)) {
      return HSLColor.fromAHSL(
              parsedHsl.last!, parsedHsl.first!, parsedHsl[1]!, parsedHsl[2]!)
          .toColor();
    } else if (parsedHsl.length == 3 && !parsedHsl.contains(null)) {
      return HSLColor.fromAHSL(
              1.0, parsedHsl.first!, parsedHsl[1]!, parsedHsl.last!)
          .toColor();
    } else {
      return Colors.black;
    }
  }

  static Color? namedColorToColor(String text) {
    String namedColor = namedColors.keys.firstWhere(
        (element) => element.toLowerCase() == text.toLowerCase(),
        orElse: () => "");
    if (namedColor != "") {
      return stringToColor(namedColors[namedColor]!);
    } else {
      return null;
    }
  }
}

```

#### 📄 `lib/widget\simple_html\src\extension.dart`

```dart
/// [RomanNumeralsType] enumerates the 3 major types of Roman numerals
/// supported.
///
/// [RomanNumeralsType.common] is the form most used in the modern
/// day for years, clock faces, etc.
enum RomanNumeralsType { apostrophus, common, vinculum }

/// [RomanNumeralsConfig] is the base class that defines the behavior for
/// all of the descendent classes and should not be used directly.
class RomanNumeralsConfig {
  final RomanNumeralsType configType;
  final String? nulla;

  const RomanNumeralsConfig(
      {this.configType = RomanNumeralsType.common, this.nulla});
}

/// Use [ApostrophusRomanNumeralsConfig] to use special symbols from
/// the Roman era for 500, 1,000; 5,000; 10,000; 50,000; 100,000, and
/// 1,000,000 - these are ⅠↃ, ⅭⅠↃ, ⅠↃↃ, ⅭⅭⅠↃↃ, ⅠↃↃↃ, ⅭⅭⅭⅠↃↃↃ, CCCCIↃↃↃↃ.
/// Maximum value: 3,999,999.
///
/// Note: we do not use Unicode Ⅽ/216D (which matches Ↄ - 2183 better)
/// or Ⅰ/2160, as they are too similar to C and I, and can cause confusion.
class ApostrophusRomanNumeralsConfig extends RomanNumeralsConfig {
  final bool compact;

  const ApostrophusRomanNumeralsConfig({this.compact = false, super.nulla})
      : super(configType: RomanNumeralsType.apostrophus);
}

/// The [CompactApostrophusRomanNumeralsConfig] form of
/// [ApostrophusRomanNumeralsConfig] uses single characters for each
/// value instead of multiple. 500 will use D. The other characters
/// are ↀ, ↁ, ↂ, ↇ, and ↈ.
/// Maximum value: 399,999.
class CompactApostrophusRomanNumeralsConfig
    extends ApostrophusRomanNumeralsConfig {
  const CompactApostrophusRomanNumeralsConfig({super.nulla})
      : super(compact: true);
}

/// Use [CommonRomanNumeralsConfig] for the common MDCLXVI style.
/// Maximum value: 3,999 / MMMCMXCIX.
///
/// [CommonRomanNumeralsConfig] is the default configuration.
class CommonRomanNumeralsConfig extends RomanNumeralsConfig {
  const CommonRomanNumeralsConfig({super.nulla})
      : super(configType: RomanNumeralsType.common);
}

/// Use [VinculumRomanNumeralsConfig] for the extended style similar
/// to the the common MDCLXVI style.
/// Maximum value: 3,999,999 / M̅M̅M̅C̅M̅X̅C̅MX̅CMXCIX.
///
/// The rules are similar to [CommonRomanNumeralsConfig] style, but
/// M acts like I in the least position, and beyond M, each character
/// is reused with a line overtop multipling each by 1,000. These are
/// V̅, X̅, L̅, C̅, D̅, and M̅. I̅ is not used, but M is preffered for 1,000.
class VinculumRomanNumeralsConfig extends RomanNumeralsConfig {
  const VinculumRomanNumeralsConfig({super.nulla})
      : super(configType: RomanNumeralsType.vinculum);
}

/// The [RomanNumerals] class is used solely to store the default
/// Roman numerals configuration, [RomansNumeralsConfig.common]. You
/// can change this early in runtime so that you don't have to keep
/// passing the config to every method call. See [RomansNumeralsConfig].
class RomanNumerals {
  static RomanNumeralsConfig romanNumeralsConfig =
      const CommonRomanNumeralsConfig();
}

final _sharedRomanNumbersToLetters = {
  1: 'I',
  4: 'IV',
  5: 'V',
  9: 'IX',
  10: 'X',
  40: 'XL',
  50: 'L',
  90: 'XC',
  100: 'C',
  400: 'CD',
  500: 'D',
  900: 'CM',
};

final _compactApostrophusRomanNumbersToLetters = {
  1: 'I',
  4: 'IV',
  5: 'V',
  9: 'IX',
  10: 'X',
  40: 'XL',
  50: 'L',
  90: 'XC',
  100: 'C',
  400: 'CCCC',
  500: 'D',
  900: 'Cↀ',
  1000: 'ↀ',
  4000: 'ↀↁ',
  5000: 'ↁ',
  9000: 'ↀↂ',
  10000: 'ↂ',
  40000: 'ↂↇ',
  50000: 'ↇ',
  90000: 'ↂↈ',
  100000: 'ↈ'
};

final _apostrophusRomanNumbersToLetters = {
  1: 'I',
  4: 'IV',
  5: 'V',
  9: 'IX',
  10: 'X',
  40: 'XL',
  50: 'L',
  90: 'XC',
  100: 'C',
  400: 'CCCC',
  500: 'IↃ',
  900: 'CCIↃ',
  1000: 'CIↃ',
  4000: 'CIↃIↃↃ',
  5000: 'IↃↃ',
  9000: 'CIↃCCIↃↃ',
  10000: 'CCIↃↃ',
  40000: 'CCIↃↃIↃↃↃ',
  50000: 'IↃↃↃ',
  90000: 'CCIↃↃCCCIↃↃↃ',
  100000: 'CCCIↃↃↃ',
  400000: 'CCCIↃↃↃIↃↃↃↃ',
  500000: 'IↃↃↃↃ',
  900000: 'CCCIↃↃↃCCCCIↃↃↃↃ',
  1000000: 'CCCCIↃↃↃↃ'
};

final _commonRomanNumbersToLetters = {1000: 'M'};

// \u{0304} - combining macron
// \u{0305} - combining overline
// Prefer the overline here, as the ancestry of the "line over the number"
// called "vinculum" comes from mathematics, whereas the macron is a
// diacritical mark.
final _vinculumRomanNumbersToLetters = {
  1000: 'M',
  4000: 'MV\u{0305}',
  5000: 'V\u{0305}',
  9000: 'MX\u{0305}',
  10000: 'X\u{0305}',
  40000: 'X\u{0305}L\u{0305}',
  50000: 'L\u{0305}',
  90000: 'X\u{0305}C\u{0305}',
  100000: 'C\u{0305}',
  400000: 'C\u{0305}D\u{0305}',
  500000: 'D\u{0305}',
  900000: 'C\u{0305}M\u{0305}',
  1000000: 'M\u{0305}',
};

extension RomanNumeralsInt on int {
  /// Confirms or disconfirms a valid Roman numeral value. This
  /// may change for the same [int] depending on the [RomanNumeralsConfig].
  bool isValidRomanNumeralValue({RomanNumeralsConfig? config}) {
    config ??= RomanNumerals.romanNumeralsConfig;

    // no negative number support
    if (this < 0) {
      return false;
    }

    // If nulla is not specified, we don't support zero.
    if (config.nulla == null && this == 0) {
      return false;
    }

    // Check the maximum values.
    switch (config.configType) {
      case RomanNumeralsType.common:
        return !(this > 3999);
      case RomanNumeralsType.apostrophus:
        final aConfig = config as ApostrophusRomanNumeralsConfig;
        if (aConfig.compact) {
          return !(this > 399999);
        } else {
          return !(this > 3999999);
        }
      case RomanNumeralsType.vinculum:
        return !(this > 3999999);
    }
  }

  /// Create Roman numeral [String] from this [int]. Rules for creation are read
  /// from the optional [config].
  String? toRomanNumeralString({RomanNumeralsConfig? config}) {
    config ??= RomanNumerals.romanNumeralsConfig;

    if (!isValidRomanNumeralValue(config: config)) {
      return null;
    }

    // Handle zero with a special case.
    final nulla = config.nulla;
    if (this == 0) {
      if (nulla != null) {
        return nulla.substring(0, 1).toUpperCase();
      }
      return null;
    }

    Map<int, String> useMap;
    switch (config.configType) {
      case RomanNumeralsType.common:
        useMap = {
          ..._sharedRomanNumbersToLetters,
          ..._commonRomanNumbersToLetters
        };
        break;
      case RomanNumeralsType.apostrophus:
        useMap = {};
        final aConfig = config as ApostrophusRomanNumeralsConfig;
        if (aConfig.compact) {
          useMap = _compactApostrophusRomanNumbersToLetters;
        } else {
          useMap = _apostrophusRomanNumbersToLetters;
        }
        break;
      case RomanNumeralsType.vinculum:
        useMap = {
          ..._sharedRomanNumbersToLetters,
          ..._vinculumRomanNumbersToLetters
        };
        break;
    }
    List<int> nRevMap = useMap.keys.toList();
    nRevMap.sort((a, b) => b.compareTo(a));

    var curString = '';
    var accum = this;
    var nIndex = 0;
    while (accum > 0) {
      var divisor = nRevMap[nIndex];
      var units = accum ~/ divisor;

      /**
       - When we have any amount of quotient > 0, add the current numeral to the return-string,
          subtract the amount from the accumulator, and continue.
       - When the quotient is zero, then increment the index of the number-value array to the next number.
       */
      if (units > 0) {
        var got = useMap[divisor];
        if (got != null) {
          curString += got;
          accum -= divisor;
        }
      } else {
        nIndex += 1;
      }
    }
    return curString;
  }
}

```

#### 📄 `lib/widget\simple_html\src\html_elements.dart`

```dart
// ignore_for_file: constant_identifier_names

export 'styled_element.dart';
export 'interactable_element.dart';
export 'replaced_element.dart';

const STYLED_ELEMENTS = [
  "abbr",
  "acronym",
  "address",
  "b",
  "bdi",
  "bdo",
  "big",
  "cite",
  "code",
  "data",
  "del",
  "dfn",
  "em",
  "font",
  "i",
  "ins",
  "kbd",
  "mark",
  "q",
  "rt",
  "s",
  "samp",
  "small",
  "span",
  "strike",
  "strong",
  "sub",
  "sup",
  "time",
  "tt",
  "u",
  "var",
  "wbr",

  //BLOCK ELEMENTS
  "article",
  "aside",
  "blockquote",
  "body",
  "center",
  "dd",
  "div",
  "dl",
  "dt",
  "figcaption",
  "figure",
  "footer",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "header",
  "hr",
  "html",
  "li",
  "main",
  "nav",
  "noscript",
  "ol",
  "p",
  "pre",
  "section",
  "summary",
  "ul",
];

const BLOCK_ELEMENTS = [
  "article",
  "aside",
  "blockquote",
  "body",
  "center",
  "dd",
  "div",
  "dl",
  "dt",
  "figcaption",
  "figure",
  "footer",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "header",
  "hr",
  "html",
  "li",
  "main",
  "nav",
  "noscript",
  "ol",
  "p",
  "pre",
  "section",
  "summary",
  "ul",
];

const INTERACTABLE_ELEMENTS = [
  "a",
];

const REPLACED_ELEMENTS = [
  "br",
  "template",
  "rp",
  "rt",
  "ruby",
];

const LAYOUT_ELEMENTS = [
  "details",
  "tr",
  "tbody",
  "tfoot",
  "thead",
];

const TABLE_CELL_ELEMENTS = ["th", "td"];

const TABLE_DEFINITION_ELEMENTS = ["col", "colgroup"];

const EXTERNAL_ELEMENTS = [
  "audio",
  "iframe",
  "img",
  "math",
  "svg",
  "table",
  "video"
];

const SELECTABLE_ELEMENTS = [
  "br",
  "a",
  "article",
  "aside",
  "blockquote",
  "body",
  "center",
  "dd",
  "div",
  "dl",
  "dt",
  "figcaption",
  "figure",
  "footer",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "header",
  "hr",
  "html",
  "main",
  "nav",
  "noscript",
  "p",
  "pre",
  "section",
  "summary",
  "abbr",
  "acronym",
  "address",
  "b",
  "bdi",
  "bdo",
  "big",
  "cite",
  "code",
  "data",
  "del",
  "dfn",
  "em",
  "font",
  "i",
  "ins",
  "kbd",
  "mark",
  "q",
  "s",
  "samp",
  "small",
  "span",
  "strike",
  "strong",
  "time",
  "tt",
  "u",
  "var",
  "wbr",
];

/**
  Here is a list of elements with planned support:
    a         - i [x]
    abbr      - s [x]
    acronym   - s [x]
    address   - s [x]
    audio     - c [x]
    article   - b [x]
    aside     - b [x]
    b         - s [x]
    bdi       - s [x]
    bdo       - s [x]
    big       - s [x]
    blockquote- b [x]
    body      - b [x]
    br        - b [x]
    button    - i [ ]
    caption   - b [ ]
    center    - b [x]
    cite      - s [x]
    code      - s [x]
    data      - s [x]
    dd        - b [x]
    del       - s [x]
    dfn       - s [x]
    div       - b [x]
    dl        - b [x]
    dt        - b [x]
    em        - s [x]
    figcaption- b [x]
    figure    - b [x]
    font      - s [x]
    footer    - b [x]
    h1        - b [x]
    h2        - b [x]
    h3        - b [x]
    h4        - b [x]
    h5        - b [x]
    h6        - b [x]
    head      - e [x]
    header    - b [x]
    hr        - b [x]
    html      - b [x]
    i         - s [x]
    img       - c [x]
    ins       - s [x]
    kbd       - s [x]
    li        - b [x]
    main      - b [x]
    mark      - s [x]
    nav       - b [x]
    noscript  - b [x]
    ol        - b [x] post
    p         - b [x]
    pre       - b [x]
    q         - s [x] post
    rp        - s [x]
    rt        - s [x]
    ruby      - s [x]
    s         - s [x]
    samp      - s [x]
    section   - b [x]
    small     - s [x]
    source    -   [-] child of content
    span      - s [x]
    strike    - s [x]
    strong    - s [x]
    sub       - s [x]
    sup       - s [x]
    svg       - c [x]
    table     - b [x]
    tbody     - b [x]
    td        - s [ ]
    template  - e [x]
    tfoot     - b [x]
    th        - s [ ]
    thead     - b [x]
    time      - s [x]
    tr        - ? [ ]
    track     -   [-] child of content
    tt        - s [x]
    u         - s [x]
    ul        - b [x] post
    var       - s [x]
    video     - c [x]
    wbr       - s [x]
 */

```

#### 📄 `lib/widget\simple_html\src\interactable_element.dart`

```dart
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../style.dart';
import 'styled_element.dart';

/// An [InteractableElement] is a [StyledElement] that takes user gestures (e.g. tap).
class InteractableElement extends StyledElement {
  String? href;

  InteractableElement({
    required super.name,
    required super.children,
    required super.style,
    required this.href,
    required dom.Node node,
    required super.elementId,
  }) : super(node: node as dom.Element?);
}

/// A [Gesture] indicates the type of interaction by a user.
enum Gesture {
  TAP,
}

StyledElement parseInteractableElement(
    dom.Element element, List<StyledElement> children) {
  switch (element.localName) {
    case "a":
      if (element.attributes.containsKey('href')) {
        return InteractableElement(
            name: element.localName!,
            children: children,
            href: element.attributes['href'],
            style: Style(
              color: Colors.blue,
              textDecoration: TextDecoration.underline,
            ),
            node: element,
            elementId: element.id);
      }
      // When <a> tag have no href, it must be non clickable and without decoration.
      return StyledElement(
        name: element.localName!,
        children: children,
        style: Style(),
        node: element,
        elementId: element.id,
      );

    /// will never be called, just to suppress missing return warning
    default:
      return InteractableElement(
          name: element.localName!,
          children: children,
          node: element,
          href: '',
          style: Style(),
          elementId: "[[No ID]]");
  }
}

```

#### 📄 `lib/widget\simple_html\src\layout_element.dart`

```dart
// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../html_parser.dart';
import '../style.dart';
import 'anchor.dart';
import 'styled_element.dart';

/// A [LayoutElement] is an element that breaks the normal Inline flow of
/// an html document with a more complex layout. LayoutElements handle
abstract class LayoutElement extends StyledElement {
  LayoutElement({
    super.name = "[[No Name]]",
    required super.children,
    String? elementId,
    super.node,
  }) : super(style: Style(), elementId: elementId ?? "[[No ID]]");

  Widget? toWidget(RenderContext context);
}

class TableSectionLayoutElement extends LayoutElement {
  TableSectionLayoutElement({
    required super.name,
    required super.children,
  });

  @override
  Widget toWidget(RenderContext context) {
    // Not rendered; TableLayoutElement will instead consume its children
    return Container(child: const Text("TABLE SECTION"));
  }
}

class TableRowLayoutElement extends LayoutElement {
  TableRowLayoutElement({
    required super.name,
    required super.children,
    required dom.Element super.node,
  });

  @override
  Widget toWidget(RenderContext context) {
    // Not rendered; TableLayoutElement will instead consume its children
    return Container(child: const Text("TABLE ROW"));
  }
}

class TableCellElement extends StyledElement {
  int colspan = 1;
  int rowspan = 1;

  TableCellElement({
    required super.name,
    required super.elementId,
    required super.elementClasses,
    required super.children,
    required super.style,
    required dom.Element super.node,
  }) {
    colspan = _parseSpan(this, "colspan");
    rowspan = _parseSpan(this, "rowspan");
  }

  static int _parseSpan(StyledElement element, String attributeName) {
    final spanValue = element.attributes[attributeName];
    return spanValue == null ? 1 : int.tryParse(spanValue) ?? 1;
  }
}

TableCellElement parseTableCellElement(
  dom.Element element,
  List<StyledElement> children,
) {
  final cell = TableCellElement(
    name: element.localName!,
    elementId: element.id,
    elementClasses: element.classes.toList(),
    children: children,
    node: element,
    style: Style(),
  );
  if (element.localName == "th") {
    cell.style = Style(
      fontWeight: FontWeight.bold,
    );
  }
  return cell;
}

class TableStyleElement extends StyledElement {
  TableStyleElement({
    required super.name,
    required super.children,
    required super.style,
    required dom.Element super.node,
  });
}

TableStyleElement parseTableDefinitionElement(
  dom.Element element,
  List<StyledElement> children,
) {
  switch (element.localName) {
    case "colgroup":
    case "col":
      return TableStyleElement(
        name: element.localName!,
        children: children,
        node: element,
        style: Style(),
      );
    default:
      return TableStyleElement(
        name: "[[No Name]]",
        children: children,
        node: element,
        style: Style(),
      );
  }
}

class DetailsContentElement extends LayoutElement {
  List<dom.Element> elementList;

  DetailsContentElement({
    required super.name,
    required super.children,
    required dom.Element super.node,
    required this.elementList,
  }) : super(elementId: node.id);

  @override
  Widget toWidget(RenderContext context) {
    List<InlineSpan>? childrenList = children
        .map((tree) => context.parser.parseTree(context, tree))
        .toList();
    List<InlineSpan> toRemove = [];
    for (InlineSpan child in childrenList) {
      if (child is TextSpan &&
          child.text != null &&
          child.text!.trim().isEmpty) {
        toRemove.add(child);
      }
    }
    for (InlineSpan child in toRemove) {
      childrenList.remove(child);
    }
    InlineSpan? firstChild =
        childrenList.isNotEmpty == true ? childrenList.first : null;
    return ExpansionTile(
        key: AnchorKey.of(context.parser.parseKey, this),
        expandedAlignment: Alignment.centerLeft,
        title: elementList.isNotEmpty == true &&
                elementList.first.localName == "summary"
            ? StyledText(
                textSpan: TextSpan(
                  style: style.generateTextStyle(),
                  children: firstChild == null ? [] : [firstChild],
                ),
                style: style,
                renderContext: context,
              )
            : const Text("Details"),
        children: [
          StyledText(
            textSpan: TextSpan(
                style: style.generateTextStyle(),
                children: getChildren(
                    childrenList,
                    context,
                    elementList.isNotEmpty == true &&
                            elementList.first.localName == "summary"
                        ? firstChild
                        : null)),
            style: style,
            renderContext: context,
          ),
        ]);
  }

  List<InlineSpan> getChildren(List<InlineSpan> children, RenderContext context,
      InlineSpan? firstChild) {
    if (firstChild != null) children.removeAt(0);
    return children;
  }
}

class EmptyLayoutElement extends LayoutElement {
  EmptyLayoutElement({required super.name}) : super(children: []);

  @override
  Widget? toWidget(context) => null;
}

LayoutElement parseLayoutElement(
  dom.Element element,
  List<StyledElement> children,
) {
  switch (element.localName) {
    case "details":
      if (children.isEmpty) {
        return EmptyLayoutElement(name: "empty");
      }
      return DetailsContentElement(
          node: element,
          name: element.localName!,
          children: children,
          elementList: element.children);
    case "thead":
    case "tbody":
    case "tfoot":
      return TableSectionLayoutElement(
        name: element.localName!,
        children: children,
      );
    case "tr":
      return TableRowLayoutElement(
        name: element.localName!,
        children: children,
        node: element,
      );
    default:
      return EmptyLayoutElement(name: "[[No Name]]");
  }
}

```

#### 📄 `lib/widget\simple_html\src\replaced_element.dart`

```dart
// ignore_for_file: avoid_renaming_method_parameters

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as dom;

import '../html_parser.dart';
import '../style.dart';
import 'anchor.dart';
import 'styled_element.dart';

/// A [ReplacedElement] is a type of [StyledElement] that does not require its [children] to be rendered.
///
/// A [ReplacedElement] may use its children nodes to determine relevant information
/// (e.g. <video>'s <source> tags), but the children nodes will not be saved as [children].
abstract class ReplacedElement extends StyledElement {
  PlaceholderAlignment alignment;

  ReplacedElement({
    required super.name,
    required super.style,
    required super.elementId,
    List<StyledElement>? children,
    super.node,
    this.alignment = PlaceholderAlignment.aboveBaseline,
  }) : super(children: children ?? []);

  static List<String?> parseMediaSources(List<dom.Element> elements) {
    return elements
        .where((element) => element.localName == 'source')
        .map((element) {
      return element.attributes['src'];
    }).toList();
  }

  Widget? toWidget(RenderContext context);
}

/// [TextContentElement] is a [ContentElement] with plaintext as its content.
class TextContentElement extends ReplacedElement {
  String? text;
  dom.Node? node;

  TextContentElement({
    required super.style,
    required this.text,
    this.node,
    dom.Element? element,
  }) : super(name: "[text]", node: element, elementId: "[[No ID]]");

  @override
  String toString() {
    return "\"${text!.replaceAll("\n", "\\n")}\"";
  }

  @override
  Widget? toWidget(_) => null;
}

class EmptyContentElement extends ReplacedElement {
  EmptyContentElement({super.name = "empty"})
      : super(style: Style(), elementId: "[[No ID]]");

  @override
  Widget? toWidget(_) => null;
}

class RubyElement extends ReplacedElement {
  @override
  dom.Element element;

  RubyElement(
      {required this.element,
      required List<StyledElement> super.children,
      super.name = "ruby"})
      : super(
            alignment: PlaceholderAlignment.middle,
            style: Style(),
            elementId: element.id);

  @override
  Widget toWidget(RenderContext context) {
    StyledElement? node;
    List<Widget> widgets = <Widget>[];
    final rubySize = context.parser.style['rt']?.fontSize?.size ??
        max(9.0, context.style.fontSize!.size! / 2);
    final rubyYPos = rubySize + rubySize / 2;
    List<StyledElement> children = [];
    context.tree.children.forEachIndexed((index, element) {
      if (!((element is TextContentElement) &&
          (element.text ?? "").trim().isEmpty &&
          index > 0 &&
          index + 1 < context.tree.children.length &&
          context.tree.children[index - 1] is! TextContentElement &&
          context.tree.children[index + 1] is! TextContentElement)) {
        children.add(element);
      }
    });
    for (var c in children) {
      if (c.name == "rt" && node != null) {
        final widget = Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
                alignment: Alignment.bottomCenter,
                child: Center(
                    child: Transform(
                        transform: Matrix4.translationValues(0, -(rubyYPos), 0),
                        child: ContainerSpan(
                          newContext: RenderContext(
                            buildContext: context.buildContext,
                            parser: context.parser,
                            style: c.style,
                            tree: c,
                          ),
                          style: c.style,
                          child: Text(c.element!.innerHtml,
                              style: c.style
                                  .generateTextStyle()
                                  .copyWith(fontSize: rubySize)),
                        )))),
            ContainerSpan(
                newContext: context,
                style: context.style,
                children: node is TextContentElement
                    ? null
                    : [context.parser.parseTree(context, node)],
                child: node is TextContentElement
                    ? Text((node).text?.trim() ?? "",
                        style: context.style.generateTextStyle())
                    : null),
          ],
        );
        widgets.add(widget);
      } else {
        node = c;
      }
    }
    return Padding(
      padding: EdgeInsets.only(top: rubySize),
      child: Wrap(
        key: AnchorKey.of(context.parser.parseKey, this),
        runSpacing: rubySize,
        children: widgets
            .map((e) => Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisSize: MainAxisSize.min,
                  children: [e],
                ))
            .toList(),
      ),
    );
  }
}

ReplacedElement parseReplacedElement(
  dom.Element element,
  List<StyledElement> children,
) {
  switch (element.localName) {
    case "br":
      return TextContentElement(
          text: "\n",
          style: Style(whiteSpace: WhiteSpace.PRE),
          element: element,
          node: element);
    case "ruby":
      return RubyElement(
        element: element,
        children: children,
      );
    default:
      return EmptyContentElement(
          name: element.localName == null ? "[[No Name]]" : element.localName!);
  }
}

```

#### 📄 `lib/widget\simple_html\src\styled_element.dart`

```dart
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
//ignore: implementation_imports
import 'package:html/src/query_selector.dart';

import '../style.dart';
import 'css_parser.dart';

/// A [StyledElement] applies a style to all of its children.
class StyledElement {
  final String name;
  final String elementId;
  final List<String> elementClasses;
  List<StyledElement> children;
  Style style;
  final dom.Element? _node;

  StyledElement({
    this.name = "[[No name]]",
    this.elementId = "[[No ID]]",
    this.elementClasses = const [],
    required this.children,
    required this.style,
    required dom.Element? node,
  }) : _node = node;

  bool matchesSelector(String selector) =>
      (_node != null && matches(_node!, selector)) || name == selector;

  Map<String, String> get attributes =>
      _node?.attributes.map((key, value) {
        return MapEntry(key.toString(), value);
      }) ??
      <String, String>{};

  dom.Element? get element => _node;

  @override
  String toString() {
    String selfData =
        "[$name] ${children.length} ${elementClasses.isNotEmpty == true ? 'C:${elementClasses.toString()}' : ''}${elementId.isNotEmpty == true ? 'ID: $elementId' : ''}";
    for (var child in children) {
      selfData += ("\n${child.toString()}")
          .replaceAll(RegExp("^", multiLine: true), "-");
    }
    return selfData;
  }
}

StyledElement parseStyledElement(
    dom.Element element, List<StyledElement> children) {
  StyledElement styledElement = StyledElement(
    name: element.localName!,
    elementId: element.id,
    elementClasses: element.classes.toList(),
    children: children,
    node: element,
    style: Style(),
  );

  switch (element.localName) {
    case "abbr":
    case "acronym":
      styledElement.style = Style(
        textDecoration: TextDecoration.underline,
        textDecorationStyle: TextDecorationStyle.dotted,
      );
      break;
    case "address":
      continue italics;
    case "article":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "aside":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    bold:
    case "b":
      styledElement.style = Style(
        fontWeight: FontWeight.bold,
      );
      break;
    case "bdo":
      TextDirection textDirection =
          ((element.attributes["dir"] ?? "ltr") == "rtl")
              ? TextDirection.rtl
              : TextDirection.ltr;
      styledElement.style = Style(
        direction: textDirection,
      );
      break;
    case "big":
      styledElement.style = Style(
        fontSize: FontSize.larger,
      );
      break;
    case "blockquote":
      if (element.parent!.localName == "blockquote") {
        styledElement.style = Style(
          margin: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 14.0),
          display: Display.BLOCK,
        );
      } else {
        styledElement.style = Style(
          margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 14.0),
          display: Display.BLOCK,
        );
      }
      break;
    case "body":
      styledElement.style = Style(
        margin: const EdgeInsets.all(8.0),
        display: Display.BLOCK,
      );
      break;
    case "center":
      styledElement.style = Style(
        alignment: Alignment.center,
        display: Display.BLOCK,
      );
      break;
    case "cite":
      continue italics;
    monospace:
    case "code":
      styledElement.style = Style(
        fontFamily: 'Monospace',
      );
      break;
    case "dd":
      styledElement.style = Style(
        margin: const EdgeInsets.only(left: 40.0),
        display: Display.BLOCK,
      );
      break;
    strikeThrough:
    case "del":
      styledElement.style = Style(
        textDecoration: TextDecoration.lineThrough,
      );
      break;
    case "dfn":
      continue italics;
    case "div":
      styledElement.style = Style(
        margin: const EdgeInsets.all(0),
        display: Display.BLOCK,
      );
      break;
    case "dl":
      styledElement.style = Style(
        margin: const EdgeInsets.symmetric(vertical: 14.0),
        display: Display.BLOCK,
      );
      break;
    case "dt":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "em":
      continue italics;
    case "figcaption":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "figure":
      styledElement.style = Style(
        margin: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0),
        display: Display.BLOCK,
      );
      break;
    case "footer":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "font":
      styledElement.style = Style(
        color: element.attributes['color'] != null
            ? element.attributes['color']!.startsWith("#")
                ? ExpressionMapping.stringToColor(element.attributes['color']!)
                : ExpressionMapping.namedColorToColor(
                    element.attributes['color']!)
            : null,
        fontFamily: element.attributes['face']?.split(",").first,
        fontSize: element.attributes['size'] != null
            ? numberToFontSize(element.attributes['size']!)
            : null,
      );
      break;
    case "h1":
      styledElement.style = Style(
        fontSize: FontSize.xxLarge,
        fontWeight: FontWeight.bold,
        margin: const EdgeInsets.symmetric(vertical: 18.67),
        display: Display.BLOCK,
      );
      break;
    case "h2":
      styledElement.style = Style(
        fontSize: FontSize.xLarge,
        fontWeight: FontWeight.bold,
        margin: const EdgeInsets.symmetric(vertical: 17.5),
        display: Display.BLOCK,
      );
      break;
    case "h3":
      styledElement.style = Style(
        fontSize: const FontSize(16.38),
        fontWeight: FontWeight.bold,
        margin: const EdgeInsets.symmetric(vertical: 16.5),
        display: Display.BLOCK,
      );
      break;
    case "h4":
      styledElement.style = Style(
        fontSize: FontSize.medium,
        fontWeight: FontWeight.bold,
        margin: const EdgeInsets.symmetric(vertical: 18.5),
        display: Display.BLOCK,
      );
      break;
    case "h5":
      styledElement.style = Style(
        fontSize: const FontSize(11.62),
        fontWeight: FontWeight.bold,
        margin: const EdgeInsets.symmetric(vertical: 19.25),
        display: Display.BLOCK,
      );
      break;
    case "h6":
      styledElement.style = Style(
        fontSize: const FontSize(9.38),
        fontWeight: FontWeight.bold,
        margin: const EdgeInsets.symmetric(vertical: 22),
        display: Display.BLOCK,
      );
      break;
    case "header":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "hr":
      styledElement.style = Style(
        margin: const EdgeInsets.symmetric(vertical: 7.0),
        width: double.infinity,
        height: 1,
        backgroundColor: Colors.black,
        display: Display.BLOCK,
      );
      break;
    case "html":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    italics:
    case "i":
      styledElement.style = Style(
        fontStyle: FontStyle.italic,
      );
      break;
    case "ins":
      continue underline;
    case "kbd":
      continue monospace;
    case "li":
      styledElement.style = Style(
        display: Display.LIST_ITEM,
      );
      break;
    case "main":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "mark":
      styledElement.style = Style(
        color: Colors.black,
        backgroundColor: Colors.yellow,
      );
      break;
    case "nav":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "noscript":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "ol":
    case "ul":
      if (element.parent!.localName == "li") {
        styledElement.style = Style(
//          margin: EdgeInsets.only(left: 30.0),
          display: Display.BLOCK,
          listStyleType: element.localName == "ol"
              ? ListStyleType.DECIMAL
              : ListStyleType.DISC,
        );
      } else {
        styledElement.style = Style(
//          margin: EdgeInsets.only(left: 30.0, top: 14.0, bottom: 14.0),
          display: Display.BLOCK,
          listStyleType: element.localName == "ol"
              ? ListStyleType.DECIMAL
              : ListStyleType.DISC,
        );
      }
      break;
    case "p":
      styledElement.style = Style(
        margin: const EdgeInsets.symmetric(vertical: 14.0),
        display: Display.BLOCK,
      );
      break;
    case "pre":
      styledElement.style = Style(
        fontFamily: 'monospace',
        margin: const EdgeInsets.symmetric(vertical: 14.0),
        whiteSpace: WhiteSpace.PRE,
        display: Display.BLOCK,
      );
      break;
    case "q":
      styledElement.style = Style(
        before: "\"",
        after: "\"",
      );
      break;
    case "s":
      continue strikeThrough;
    case "samp":
      continue monospace;
    case "section":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "small":
      styledElement.style = Style(
        fontSize: FontSize.smaller,
      );
      break;
    case "strike":
      continue strikeThrough;
    case "strong":
      continue bold;
    case "sub":
      styledElement.style = Style(
        fontSize: FontSize.smaller,
        verticalAlign: VerticalAlign.SUB,
      );
      break;
    case "sup":
      styledElement.style = Style(
        fontSize: FontSize.smaller,
        verticalAlign: VerticalAlign.SUPER,
      );
      break;
    case "tt":
      continue monospace;
    underline:
    case "u":
      styledElement.style = Style(
        textDecoration: TextDecoration.underline,
      );
      break;
    case "var":
      continue italics;
  }

  return styledElement;
}

typedef ListCharacter = String Function(int i);

FontSize numberToFontSize(String num) {
  switch (num) {
    case "1":
      return FontSize.xxSmall;
    case "2":
      return FontSize.xSmall;
    case "3":
      return FontSize.small;
    case "4":
      return FontSize.medium;
    case "5":
      return FontSize.large;
    case "6":
      return FontSize.xLarge;
    case "7":
      return FontSize.xxLarge;
  }
  if (num.startsWith("+")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 + relativeNum).toString());
  }
  if (num.startsWith("-")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 - relativeNum).toString());
  }
  return FontSize.medium;
}

```

#### 📄 `lib/widget\simple_html\src\utils.dart`

```dart
import 'package:flutter/material.dart';

import '../style.dart';

Map<String, String> namedColors = {
  "White": "#FFFFFF",
  "Silver": "#C0C0C0",
  "Gray": "#808080",
  "Black": "#000000",
  "Red": "#FF0000",
  "Maroon": "#800000",
  "Yellow": "#FFFF00",
  "Olive": "#808000",
  "Lime": "#00FF00",
  "Green": "#008000",
  "Aqua": "#00FFFF",
  "Teal": "#008080",
  "Blue": "#0000FF",
  "Navy": "#000080",
  "Fuchsia": "#FF00FF",
  "Purple": "#800080",
};

class Context<T> {
  T data;

  Context(this.data);
}

// This class is a workaround so that both an image
// and a link can detect taps at the same time.
class MultipleTapGestureDetector extends InheritedWidget {
  final void Function()? onTap;

  const MultipleTapGestureDetector({
    super.key,
    required super.child,
    required this.onTap,
  });

  static MultipleTapGestureDetector? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MultipleTapGestureDetector>();
  }

  @override
  bool updateShouldNotify(MultipleTapGestureDetector oldWidget) => false;
}

class CustomBorderSide {
  CustomBorderSide({
    this.color = const Color(0xFF000000),
    this.width = 1.0,
    this.style = BorderStyle.none,
  }) : assert(width >= 0.0);

  Color? color;
  double width;
  BorderStyle style;
}

extension TextTransformUtil on String? {
  String? transformed(TextTransform? transform) {
    if (this == null) return null;
    if (transform == TextTransform.uppercase) {
      return this!.toUpperCase();
    } else if (transform == TextTransform.lowercase) {
      return this!.toLowerCase();
    } else if (transform == TextTransform.capitalize) {
      final stringBuffer = StringBuffer();

      var capitalizeNext = true;
      for (final letter in this!.toLowerCase().codeUnits) {
        // UTF-16: A-Z => 65-90, a-z => 97-122.
        if (capitalizeNext && letter >= 97 && letter <= 122) {
          stringBuffer.writeCharCode(letter - 32);
          capitalizeNext = false;
        } else {
          // UTF-16: 32 == space, 46 == period
          if (letter == 32 || letter == 46) capitalizeNext = true;
          stringBuffer.writeCharCode(letter);
        }
      }

      return stringBuffer.toString();
    } else {
      return this;
    }
  }
}

```

