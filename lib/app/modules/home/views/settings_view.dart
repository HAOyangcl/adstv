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

const kTelegramGroup = "https://t.me/ucbaidu";
const kQQGroup = "654486119"; // QQ群号
const kOfficialAccount = "鹏星影音"; // 公众号名称

// 二维码图片URL（请替换为实际的图片地址）
const kQQGroupQRCode =
    "https://blog.lzphy.top/_astro/image-20260415160544679.DJmGN3Qf_Z20qTyo.webp"; // QQ群二维码
const kOfficialAccountQRCode =
    "https://blog.lzphy.top/_astro/image-20260415160544679.DJmGN3Qf_Z20qTyo.webp"; // 公众号二维码
const kTelegramQRCode =
    "https://blog.lzphy.top/_astro/image-20260415160544679.DJmGN3Qf_Z20qTyo.webp"; // Telegram二维码

const kGithubIconSvg = r"""
<svg t="1757744978460" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="13267" width="200" height="200"><path d="M512 42.666667A464.64 464.64 0 0 0 42.666667 502.186667 460.373333 460.373333 0 0 0 363.52 938.666667c23.466667 4.266667 32-9.813333 32-22.186667v-78.08c-130.56 27.733333-158.293333-61.44-158.293333-61.44a122.026667 122.026667 0 0 0-52.053334-67.413333c-42.666667-28.16 3.413333-27.733333 3.413334-27.733334a98.56 98.56 0 0 1 71.68 47.36 101.12 101.12 0 0 0 136.533333 37.973334 99.413333 99.413333 0 0 1 29.866667-61.44c-104.106667-11.52-213.333333-50.773333-213.333334-226.986667a177.066667 177.066667 0 0 1 47.36-124.16 161.28 161.28 0 0 1 4.693334-121.173333s39.68-12.373333 128 46.933333a455.68 455.68 0 0 1 234.666666 0c89.6-59.306667 128-46.933333 128-46.933333a161.28 161.28 0 0 1 4.693334 121.173333A177.066667 177.066667 0 0 1 810.666667 477.866667c0 176.64-110.08 215.466667-213.333334 226.986666a106.666667 106.666667 0 0 1 32 85.333334v125.866666c0 14.933333 8.533333 26.88 32 22.186667A460.8 460.8 0 0 0 981.333333 502.186667 464.64 464.64 0 0 0 512 42.666667" fill="#231F20" p-id="13268"></path></svg>
""";

// SVG 图标常量
const String qqIconSvg = '''
<svg t="1780286636639" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="5183" width="200" height="200"><path d="M512.268258 64.433103c-247.183323 0-447.569968 200.380501-447.569968 447.563825 0 247.189467 200.385621 447.570992 447.569968 447.570992s447.569968-200.380501 447.569968-447.569968c0-247.184347-200.386645-447.564849-447.569968-447.564849z m252.85872 584.692787c-18.997168 16.287968-43.668709-53.628042-47.2134-42.875198-8.642616 26.161294-12.695154 43.646184-38.148944 72.127602-1.35972 1.521494 29.43056 12.647032 38.148944 36.396051 8.346713 22.756875 24.596797 58.811973-81.725503 70.125906-62.389428 6.635801-107.471099-33.244533-111.964932-32.85648-8.325212 0.734126-4.618747 0-13.568528 0-7.321804 0-7.807126 0.534468-14.69685 0-1.899307-0.140272-22.632985 32.85648-115.364231 32.85648-71.878798 0-90.48177-45.243445-76.032701-70.125906 14.464428-24.877342 38.579999-32.122354 35.176604-36.06636-16.73643-19.39546-28.287904-40.1404-35.176604-58.882621-1.705793-4.666869-3.135137-9.209848-4.262434-13.574672-2.611931-10.008479-22.627866 58.76385-44.111028 42.875198-21.483162-15.883533-19.567472-56.309597-5.659014-95.003248 14.033372-39.006959 49.37687-76.562049 49.771065-84.854496 1.412962-30.849665-3.044011-35.975235 0-44.078263 6.780169-18.149391 15.034732-11.190043 15.034733-20.609788 0-118.64476 88.172909-214.829571 196.933079-214.829571 108.755051 0 196.928984 96.184811 196.928984 214.829571 0 4.554242 11.815637 0 17.474651 20.609788 1.165181 4.256291 1.968931 20.684531 0.58771 44.078263-0.658358 11.238165 29.954789 24.914202 45.777913 84.854496 15.845649 59.945414 0 88.215912-7.909514 95.003248z" fill="#68A5E1" p-id="5184"></path></svg>
''';

const String wxIconSvg = '''
<svg t="1780286721558" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="6226" width="200" height="200"><path d="M337.387283 341.82659c-17.757225 0-35.514451 11.83815-35.514451 29.595375s17.757225 29.595376 35.514451 29.595376 29.595376-11.83815 29.595376-29.595376c0-18.49711-11.83815-29.595376-29.595376-29.595375zM577.849711 513.479769c-11.83815 0-22.936416 12.578035-22.936416 23.6763 0 12.578035 11.83815 23.676301 22.936416 23.676301 17.757225 0 29.595376-11.83815 29.595376-23.676301s-11.83815-23.676301-29.595376-23.6763zM501.641618 401.017341c17.757225 0 29.595376-12.578035 29.595376-29.595376 0-17.757225-11.83815-29.595376-29.595376-29.595375s-35.514451 11.83815-35.51445 29.595375 17.757225 29.595376 35.51445 29.595376zM706.589595 513.479769c-11.83815 0-22.936416 12.578035-22.936416 23.6763 0 12.578035 11.83815 23.676301 22.936416 23.676301 17.757225 0 29.595376-11.83815 29.595376-23.676301s-11.83815-23.676301-29.595376-23.6763z" fill="#28C445" p-id="6227"></path><path d="M510.520231 2.959538C228.624277 2.959538 0 231.583815 0 513.479769s228.624277 510.520231 510.520231 510.520231 510.520231-228.624277 510.520231-510.520231-228.624277-510.520231-510.520231-510.520231zM413.595376 644.439306c-29.595376 0-53.271676-5.919075-81.387284-12.578034l-81.387283 41.433526 22.936416-71.768786c-58.450867-41.433526-93.965318-95.445087-93.965317-159.815029 0-113.202312 105.803468-201.988439 233.803468-201.98844 114.682081 0 216.046243 71.028902 236.023121 166.473989-7.398844-0.739884-14.797688-1.479769-22.196532-1.479769-110.982659 1.479769-198.289017 85.086705-198.289017 188.67052 0 17.017341 2.959538 33.294798 7.398844 49.572255-7.398844 0.739884-15.537572 1.479769-22.936416 1.479768z m346.265896 82.867052l17.757225 59.190752-63.630058-35.514451c-22.936416 5.919075-46.612717 11.83815-70.289017 11.83815-111.722543 0-199.768786-76.947977-199.768786-172.393063-0.739884-94.705202 87.306358-171.653179 198.289017-171.65318 105.803468 0 199.028902 77.687861 199.028902 172.393064 0 53.271676-34.774566 100.624277-81.387283 136.138728z" fill="#28C445" p-id="6228"></path></svg>
''';

const String telegramIconSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path d="M12 0C5.37 0 0 5.37 0 12s5.37 12 12 12 12-5.37 12-12S18.63 0 12 0zm5.89 8.12l-2.43 8.44c-.19.66-.53.82-1.07.51l-2.96-2.18-1.43 1.37c-.16.16-.29.29-.6.29l.21-2.96 5.38-4.86c.24-.21-.05-.33-.37-.12L7.1 12.6l-2.86-.9c-.62-.19-.63-.62.13-.92l11.18-4.31c.52-.19.98.12.81.92l-.47 2.73z" fill="#2AABEE"/>
</svg>
''';

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
      _hapticFeedback = boop.enabled;
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

    if (_showNsfwSetting) {
      EasyLoading.showSuccess("绅士模式已关闭");
      boop.success();

      // 清空当前首页数据
      home.homedata.clear();
      home.update();

      await Future.delayed(Duration(milliseconds: 420));
      _showNsfwSetting = false;
      updateSetting(SettingsAllKey.showNsfwSetting, false);
      home.isNsfw = false;
      setState(() {});
      _copyrightClickCount = 0;

      // 重新加载首页数据
      home.refreshHomeDataWithFilter();
      return;
    }

    var countMap = {7: "三", 8: "二", 9: "一"};

    if (countMap.containsKey(_copyrightClickCount)) {
      String count = countMap[_copyrightClickCount]!;
      EasyLoading.showInfo("再点击$count次即可开启绅士模式");
      boop.warning();
    } else if (_copyrightClickCount >= 10) {
      EasyLoading.showSuccess("绅士模式已开启");
      boop.success();

      // 清空当前首页数据
      home.homedata.clear();
      home.update();

      await Future.delayed(Duration(milliseconds: 420));
      _showNsfwSetting = true;
      updateSetting(SettingsAllKey.showNsfwSetting, true);
      home.isNsfw = true;
      setState(() {});
      _copyrightClickCount = 0;

      // 重新加载首页数据（自动过滤 NSFW 内容）
      home.refreshHomeDataWithFilter();
    }
  }

  // 显示QQ群对话框（美化版）
  void _showQQGroupDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: context.isDarkMode ? Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部装饰条
                Container(
                  height: 4,
                  width: 40,
                  margin: EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 标题区域
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF12B7F5), Color(0xFF0D8FD9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.string(
                          qqIconSvg,
                          width: 24,
                          height: 24,
                          colorFilter:
                              ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "QQ交流群",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // 二维码区域
                if (kQQGroupQRCode.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            kQQGroupQRCode,
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 180,
                                height: 180,
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: CupertinoActivityIndicator(radius: 15),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 180,
                                height: 180,
                                color: Colors.grey.shade100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code,
                                        size: 60, color: Colors.grey.shade400),
                                    SizedBox(height: 8),
                                    Text(
                                      "二维码加载失败",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        // 截屏提示
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF12B7F5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.crop_free,
                                  size: 14, color: Color(0xFF12B7F5)),
                              SizedBox(width: 6),
                              Text(
                                "截屏保存二维码",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF12B7F5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // 群号区域
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "群号",
                        style: TextStyle(
                          fontSize: 14,
                          color: context.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      SelectableText(
                        kQQGroup,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // 提示文字
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "📱 截屏保存二维码，或复制群号打开QQ搜索加入",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          context.isDarkMode ? Colors.white54 : Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // 按钮区域
                Container(
                  margin: EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          borderRadius: BorderRadius.circular(12),
                          color: context.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.shade100,
                          child: Text(
                            "取消",
                            style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFF12B7F5),
                          child: Text(
                            "复制群号",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: kQQGroup));
                            EasyLoading.showSuccess("群号已复制");
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 显示公众号对话框（美化版）
  void _showOfficialAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: context.isDarkMode ? Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部装饰条
                Container(
                  height: 4,
                  width: 40,
                  margin: EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 标题区域
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF07C160), Color(0xFF059F4C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.string(
                          wxIconSvg,
                          width: 24,
                          height: 24,
                          colorFilter:
                              ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "微信公众号",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // 二维码区域
                if (kOfficialAccountQRCode.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            kOfficialAccountQRCode,
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 180,
                                height: 180,
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: CupertinoActivityIndicator(radius: 15),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 180,
                                height: 180,
                                color: Colors.grey.shade100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code,
                                        size: 60, color: Colors.grey.shade400),
                                    SizedBox(height: 8),
                                    Text(
                                      "二维码加载失败",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        // 截屏提示
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF07C160).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.crop_free,
                                  size: 14, color: Color(0xFF07C160)),
                              SizedBox(width: 6),
                              Text(
                                "截屏保存二维码",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF07C160),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // 公众号名称区域
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "公众号",
                        style: TextStyle(
                          fontSize: 14,
                          color: context.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      SelectableText(
                        kOfficialAccount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // 提示文字
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "📱 截屏保存二维码，或复制名称在微信中搜索关注",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          context.isDarkMode ? Colors.white54 : Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // 按钮区域
                Container(
                  margin: EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          borderRadius: BorderRadius.circular(12),
                          color: context.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.shade100,
                          child: Text(
                            "取消",
                            style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFF07C160),
                          child: Text(
                            "复制名称",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: kOfficialAccount));
                            EasyLoading.showSuccess("公众号名称已复制");
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 显示Telegram对话框（美化版）
  // 显示Telegram对话框（美化版）
  void _showTelegramDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: context.isDarkMode ? Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部装饰条
                Container(
                  height: 4,
                  width: 40,
                  margin: EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 标题区域
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2AABEE), Color(0xFF229ED9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.string(
                          telegramIconSvg,
                          width: 24,
                          height: 24,
                          colorFilter:
                              ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Telegram 群组",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // 二维码区域
                if (kTelegramQRCode.isNotEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            kTelegramQRCode,
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 180,
                                height: 180,
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: CupertinoActivityIndicator(radius: 15),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 180,
                                height: 180,
                                color: Colors.grey.shade100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code,
                                        size: 60, color: Colors.grey.shade400),
                                    SizedBox(height: 8),
                                    Text(
                                      "二维码加载失败",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        // 截屏提示
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF2AABEE).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.crop_free,
                                  size: 14, color: Color(0xFF2AABEE)),
                              SizedBox(width: 6),
                              Text(
                                "截屏保存二维码",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2AABEE),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // 链接区域 - 左右布局
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "链接",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 12),
                          child: SelectableText(
                            kTelegramGroup,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 提示文字
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "📱 截屏保存二维码，或复制链接打开浏览器加入",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          context.isDarkMode ? Colors.white54 : Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // 按钮区域
                Container(
                  margin: EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          borderRadius: BorderRadius.circular(12),
                          color: context.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.shade100,
                          child: Text(
                            "取消",
                            style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFF2AABEE),
                          child: Text(
                            "复制链接",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: kTelegramGroup));
                            EasyLoading.showSuccess("链接已复制");
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  leading: leadingIcon(r"""
<svg t="1758654465566" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="8017" width="200" height="200"><path d="M900.3008 597.2992a46.9504 46.9504 0 0 0-47.0016-46.8992H768a46.8992 46.8992 0 0 0-46.848 46.8992v256c0 25.9072 20.992 46.9504 46.848 46.9504h85.3504c25.9584 0 47.0016-20.992 47.0016-46.9504v-256z m-170.752-256V256a46.9504 46.9504 0 0 0-46.848-46.9504h-512A46.9504 46.9504 0 0 0 123.7504 256v298.6496a46.9504 46.9504 0 0 0 46.9504 46.9504H512a38.4 38.4 0 0 1 0 76.8h-46.8992v93.8496H512a38.4 38.4 0 0 1 0 76.8H298.6496a38.4 38.4 0 0 1 0-76.8h89.6V678.4h-217.6a123.8016 123.8016 0 0 1-123.6992-123.7504V256a123.7504 123.7504 0 0 1 123.7504-123.7504h512A123.8016 123.8016 0 0 1 806.2976 256v85.2992a38.4 38.4 0 0 1-76.8 0z m247.552 512a123.7504 123.7504 0 0 1-123.8016 123.7504H768a123.7504 123.7504 0 0 1-123.648-123.7504v-256a123.6992 123.6992 0 0 1 123.648-123.6992h85.3504a123.7504 123.7504 0 0 1 123.8016 123.6992v256z" p-id="8018"></path></svg>
""", width: 25, height: 25),
                  title: Text('跟随系统主题'),
                ),
                if (false)
                  SettingsTile.navigation(
                    leading: Icon(Icons.add_box),
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
              title: Text('联系我们'),
              tiles: <AbstractSettingsTile>[
                SettingsTile.navigation(
                  leading: SvgPicture.string(
                    telegramIconSvg,
                    width: 24,
                    height: 24,
                  ),
                  title: Text('Telegram 群组'),
                  onPressed: (cx) {
                    boop.selection();
                    _showTelegramDialog();
                  },
                ),
                SettingsTile.navigation(
                  leading: SvgPicture.string(
                    qqIconSvg,
                    width: 24,
                    height: 24,
                  ),
                  title: Text('QQ交流群'),
                  onPressed: (cx) {
                    boop.selection();
                    _showQQGroupDialog();
                  },
                ),
                SettingsTile.navigation(
                  leading: SvgPicture.string(
                    wxIconSvg,
                    width: 24,
                    height: 24,
                  ),
                  title: Text('微信公众号'),
                  onPressed: (cx) {
                    boop.selection();
                    _showOfficialAccountDialog();
                  },
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
                SettingsTile.navigation(
                  leading: Icon(CupertinoIcons.arrow_down_right_square_fill),
                  title: Text('视频源帮助'),
                  onPressed: (cx) {
                    boop.selection();
                    Get.to(() => const SourceHelpTable());
                  },
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
          var firstWriteYear = '2026';
          String currentYearString = DateTime.now().year.toString();
          var text = "© 雕将军 ";
          text += "$firstWriteYear-$currentYearString ";
          return HoverCursor(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
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
