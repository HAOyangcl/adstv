import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:catmovie/app/extension.dart';
import 'package:catmovie/app/widget/zoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xi/xi.dart';

class AutoUpdate extends StatefulWidget {
  const AutoUpdate({super.key});

  @override
  State<AutoUpdate> createState() => _AutoUpdateState();
}

class _AutoUpdateState extends State<AutoUpdate> with AfterLayoutMixin {
  bool _isLoading = true;
  String _errorMsg = "";

  // 公众号名称
  static const String _officialAccount = "鹏星影音";

  // 网盘地址配置
  final List<Map<String, String>> _downloadLinks = [
    // {
    //   "name": "123云盘",
    //   "url": "https://www.123pan.com/s/xxxxxx",
    //   "icon": "☁️",
    //   "color": "#2d8cf0",
    // },
    // {
    //   "name": "阿里云盘",
    //   "url": "https://www.aliyundrive.com/s/xxxxxx",
    //   "icon": "📦",
    //   "color": "#ff6a00",
    // },
    {
      "name": "百度网盘",
      "url": "https://pan.baidu.com/s/1PC-NeeqAdx6ZZc6EKSkHtA?pwd=pyxh",
      "icon": "💾",
      "color": "#2d8cf0",
    },
    // {
    //   "name": "蓝奏云",
    //   "url": "https://wwi.lanzoup.com/xxxxxx",
    //   "icon": "📁",
    //   "color": "#00a870",
    // },
    // {
    //   "name": "GitHub Releases",
    //   "url": "https://github.com/waifu-project/movie/releases/latest",
    //   "icon": "🐙",
    //   "color": "#24292e",
    // },
  ];

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    // 不需要网络请求，直接显示
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SizedBox(
      width: double.infinity,
      height: context.mediaQuery.size.height * .68,
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.update_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "应用更新",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "选择网盘下载最新版本",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 分隔线
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 20),
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),

          // 下载链接列表
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(radius: 20),
                        SizedBox(height: 12),
                        Text(
                          "加载中...",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMsg.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.shade400,
                            ),
                            SizedBox(height: 12),
                            Text(
                              _errorMsg,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _downloadLinks.length,
                        itemBuilder: (context, index) {
                          final link = _downloadLinks[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Zoom(
                              scaleRatio: .98,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    link["url"]?.openURL();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.black.withOpacity(0.02),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.black.withOpacity(0.05),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(
                                                    link["color"]!
                                                        .substring(1, 7),
                                                    radix: 16))
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              link["icon"]!,
                                              style: TextStyle(fontSize: 24),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                link["name"]!,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                link["url"]!,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.black45,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.open_in_new_rounded,
                                          size: 18,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // 底部提示
          Container(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                SizedBox(width: 6),
                Text(
                  "如链接失效，请前往公众号【$_officialAccount】获取最新地址",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
