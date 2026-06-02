# Flutter 项目 lib 目录代码导出

> 自动生成的项目代码文档，按目录结构整理

## 📂 lib/

#### 📄 `lib/interface.dart`

```dart
import 'package:equatable/equatable.dart';

/// 视频类型
enum VideoType {
  /// 内嵌的 html 链接
  /// 有两个类型:
  ///  1. 真实的内嵌了播放器的 html 链接, 这种需要直接喂给 `webview` 播放
  ///  2. 真实的平台播放链接(比如说爱奇艺链接), 这种一般需要 vip 链接解析才能播放
  iframe,

  /// m3u8 格式的链接 `iOS`/`macOS` 平台原生支持播放
  /// > `macOS` 平台也可以使用第三方播放, 比如说 `iiNA` 或者 `mpv`
  m3u8,

  /// mp4 播放链接大部分都支持, 但一些需要鉴权的就播放不了
  mp4,
}

/// 视频大小
/// 这里基本上没用过, 没有特定解析过
class VideoSize {
  /// 宽
  final double x;

  /// 高
  final double y;

  /// 视频长度
  final double duration;

  /// 视频大小
  /// 视频大小应该在 [VideoInfo] 中包含
  final double size;

  /// 格式化视频大小
  void get humanSize {}

  /// 格式化视频时间
  void get humanDuration {}

  const VideoSize({
    this.x = 0,
    this.y = 0,
    this.duration = 0,
    this.size = 0,
  });
}

// 视频信息
class VideoInfo {
  /// 名称
  final String name;

  /// 视频类型
  final VideoType type;

  /// 视频链接
  final String url;

  VideoInfo({
    this.name = "未命名",
    this.type = VideoType.iframe,
    required this.url,
  });
}

class Videos {
  final String title;
  // final VideoType type;
  List<VideoInfo> datas;
  Videos({
    // this.type = VideoType.iframe,
    required this.title,
    required this.datas,
  });
}

// 视频详情
class VideoDetail {
  /// id
  final String id;

  /// 标题
  final String title;

  /// 介绍
  final String desc;

  /// 更新时间
  final String updateTime;

  /// 备注
  final String remark;

  /// 喜欢
  final int likeCount;

  /// 访问人数
  final int viewCount;

  /// 不喜欢
  final int dislikeCount;

  /// 小封面图(必须要有)
  final String smallCoverImage;

  /// 大封面图
  final String bigCoverImage;

  /// 视频列表
  final List<Videos> videos;

  /// 视频信息
  /// 视频尺寸大小
  /// 视频长度大小
  final VideoSize videoInfo;

  Map<String, dynamic> extra;

  SourceMeta? getContext() {
    return extra['source'];
  }

  void setContext(SourceMeta value) {
    extra['source'] = value;
  }

  VideoDetail({
    required this.id,
    required this.title,
    required this.extra,
    this.desc = "",
    this.updateTime = "",
    this.remark = "",
    this.likeCount = 0,
    this.viewCount = 0,
    this.dislikeCount = 0,
    this.bigCoverImage = "",
    required this.smallCoverImage,
    this.videoInfo = kDefaultVideoSize,
    this.videos = const [],
  });

  VideoDetail mergeWith(VideoDetail neoDetail) {
    var title = neoDetail.title.isEmpty ? this.title : neoDetail.title;
    var desc = neoDetail.desc.isEmpty ? this.desc : neoDetail.desc;
    var updateTime = neoDetail.updateTime.isEmpty ? this.updateTime : neoDetail.updateTime;
    var remark = neoDetail.remark.isEmpty ? this.remark : neoDetail.remark;
    var bigCoverImage = neoDetail.bigCoverImage.isEmpty ? this.bigCoverImage : neoDetail.bigCoverImage;
    var smallCoverImage = neoDetail.smallCoverImage.isEmpty ? this.smallCoverImage : neoDetail.smallCoverImage;
    var videos = neoDetail.videos.isEmpty ? this.videos : neoDetail.videos;
    var id = neoDetail.id.isEmpty ? this.id : neoDetail.id;
    return VideoDetail(
      id: id,
      title: title,
      desc: desc,
      updateTime: updateTime,
      remark: remark,
      likeCount: neoDetail.likeCount,
      viewCount: neoDetail.viewCount,
      dislikeCount: neoDetail.dislikeCount,
      bigCoverImage: bigCoverImage,
      smallCoverImage: smallCoverImage,
      videoInfo: neoDetail.videoInfo,
      videos: videos,
      extra: neoDetail.extra,
    );
  }
}

enum SourceType {
  maccms, // 0
  universal, // 1
  // drpy,
}

class SourceMeta extends Equatable {
  final String id;
  final String name;
  final SourceType type;
  final String logo;
  final String desc;
  final String api;
  final bool isNsfw;
  final bool status;
  final Map<String, dynamic> extra;

  const SourceMeta({
    required this.id,
    required this.name,
    required this.type,
    required this.api,
    this.status = true,
    this.isNsfw = false,
    this.logo = "",
    this.desc = "",
    this.extra = const {},
  });

  /// 获取搜索分页大小
  int get searchLimit {
    return extra['searchLimit'] ?? (type == SourceType.universal ? 10 : 20);
  }

  @override
  List<Object?> get props => [id, name, type, api, isNsfw];
}

class SourceSpiderQueryCategory extends Equatable {
  final String name;
  final String id;

  const SourceSpiderQueryCategory(this.name, this.id);

  @override
  String toString() {
    return '$id: $name';
  }

  @override
  List<Object?> get props => [id, name];
}

//=====================================

abstract class ISpiderAdapter {
  /// 是否为R18资源
  /// **Not Safe For Work**
  bool get isNsfw;

  /// 源信息
  late final SourceMeta meta;

  /// 获取分类
  Future<List<SourceSpiderQueryCategory>> getCategory();

  /// 获取首页
  Future<List<VideoDetail>> getHome({
    int page = 1,
    int limit = 10,
    String? category,
  });

  /// 搜索
  Future<List<VideoDetail>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  });

  /// 获取视频详情
  Future<VideoDetail> getDetail(String movieId);

  /// 解析 iframe 链接
  Future<List<String>> parseIframe(String iframe);
}

/// 基本上它就是一个空的占位符
class EmptySpiderAdapter implements ISpiderAdapter {

  @override
  bool get isNsfw => false;

  @override
  late final SourceMeta meta;

  EmptySpiderAdapter() {
    meta = const SourceMeta(id: '', name: '', type: SourceType.maccms, api: '');
  }

  @override
  Future<List<SourceSpiderQueryCategory>> getCategory() async {
    return [];
  }

  @override
  Future<VideoDetail> getDetail(String movieId) async {
    return VideoDetail(id: '', title: '', smallCoverImage: '', extra: {});
  }

  @override
  Future<List<VideoDetail>> getHome(
      {int page = 1, int limit = 10, String? category}) async {
    return [];
  }

  @override
  Future<List<VideoDetail>> getSearch(
      {required String keyword, int page = 1, int limit = 10}) async {
    return [];
  }

  @override
  Future<List<String>> parseIframe(String iframe) async {
    return [];
  }

}

const VideoSize kDefaultVideoSize = VideoSize();

// 默认全部分类
const kDefaultAllCategory = SourceSpiderQueryCategory('全部', "-114514");

```

#### 📄 `lib/xi.dart`

```dart
library;

export 'package:dio/dio.dart';
export 'package:jsonc/jsonc.dart';

export 'interface.dart';
export 'utils/utils.dart';
export 'models/models.dart';

export 'adapters/mac_cms.dart';
export 'adapters/universal.dart';

```

### 📂 lib/adapters

#### 📄 `lib/adapters\mac_cms.dart`

```dart
// https://github.com/cuiocean/ZY-Player-APP/blob/main/utils/request.js

// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:xi/xi.dart';
import '../models/mac_cms/xml_data.dart';
import '../models/mac_cms/xml_search_data.dart';
import 'package:xml2json/xml2json.dart';
import 'package:path/path.dart' as path;

/// m3u8 | mp4 都会抓取到
final kIframeParseRegex = RegExp("[\"']([^\"']+.(m3u8|mp4))[\"']");

/// 请求返回的内容
enum ResponseCustomType {
  xml,

  json,

  /// 未知
  unknow
}

class MacCMSSpider extends ISpiderAdapter {
  MacCMSSpider(SourceMeta sourceMeta) {
    meta = sourceMeta;
  }

  String get jiexiUrl => meta.extra['jiexiUrl'] ?? '';
  String get root_url {
    var uri = Uri.parse(meta.api);
    return uri.origin;
  }

  String get api_path {
    var uri = Uri.parse(meta.api);
    return uri.path;
  }

  String createUrl({
    required String suffix,
  }) {
    return root_url + suffix;
  }

  Options ops = Options(responseType: ResponseType.plain, headers: {
    "User-Agent":
        'Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1',
    "sec-ch-ua-platform": "macOS",
    'sec-ch-ua': '"Not=A?Brand";v="24", "Chromium";v="140"',
    'DNT': '1',
  });

  bool get hasJiexiUrl {
    return jiexiUrl.isNotEmpty;
  }

  String _normalDesc(String raw) {
    return kUnescape.convert(raw);
  }

  /// 简单获取视频链接类型
  static VideoType easyGetVideoType(String rawUrl) {
    var ext = path.extension(rawUrl);
    switch (ext) {
      case '.m3u8':
      case '.m3u':
        return VideoType.m3u8;
      case '.mp4':
        return VideoType.mp4;
      default:
        return VideoType.iframe;
    }
  }

  /// 尽可能的拿到视频链接
  ///
  /// 规则:
  /// => `在线播放$https://vod3.jializyzm3u8.com/20210819/9VhEvIhE/index.m3u8`
  ///
  String easyGetVideoURL(dynamic raw) {
    if (raw == null) return "";
    var _raw = raw.toString().trim();
    if (isURL(_raw)) return _raw;
    var _block = _raw.split("\$");
    if (_block.length >= 3) return _raw;
    var sybIndex = _raw.indexOf("\$");
    if (sybIndex >= 0) {
      return _raw.substring(sybIndex + 1);
    }
    return "";
  }

  String get _responseParseFail => "接口返回值解析错误 :(";

  /// 获取结构类型并且检测一下请求之后返回的内容
  ///
  /// 如果是内容为 [ResponseCustomType.unknow] 则抛出异常
  ResponseCustomType getResponseTypeAndCheck(dynamic data) {
    ResponseCustomType _type = getResponseType(data);
    if (_type == ResponseCustomType.unknow) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    return _type;
  }

  @override
  Future<VideoDetail> getDetail(String movieId) async {
    var resp = await XHttp.dio.post(
      createUrl(suffix: api_path),
      queryParameters: {
        "ac": "videolist",
        "ids": movieId,
      },
      options: ops,
    );
    var _type = getResponseTypeAndCheck(resp.data);
    if (_type == ResponseCustomType.json) {
      return _parseDetailJSON(resp.data);
    }
    return _parseDetailXML(resp.data);
  }

  @override
  Future<List<VideoDetail>> getHome({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    var qs = {
      "ac": "videolist",
      "pg": page,
    };
    if (category != null &&
        category.isNotEmpty &&
        category != kDefaultAllCategory.id) {
      qs['t'] = category;
    }
    var resp = await XHttp.dio.get(
      createUrl(suffix: api_path),
      queryParameters: qs,
      options: ops,
    );
    dynamic data = resp.data;
    var _type = getResponseTypeAndCheck(data);
    if (_type == ResponseCustomType.json) {
      return _parseHomeJSON(data);
    }
    return _parseHomeXML(data);
  }

  /// 匹配的规则:
  ///   https://www.88zy.net/upload/vod/2020-10-26/202010261603727118.jpg\r\\n
  String normalizeCoverImage(String rawString) {
    String syb = r'\r\\n';
    var index = rawString.lastIndexOf(syb);
    var _offset = rawString.length - syb.length;
    if (index == _offset) return rawString.substring(0, index);
    return rawString;
  }

  ///   返回值比对 [kv]
  final Map<String, ResponseCustomType> _RespCheckkv = {
    "{\"": ResponseCustomType.json,
    "<?xml": ResponseCustomType.xml,
  };

  /// 获取返回内容的类型
  /// return [ResponseCustomType]
  ///
  /// 通过判断内容的首部分字符
  ///
  /// `json` 参考:
  /// ```markdown
  ///   `{"`
  /// ```
  ///
  /// `xml` 参考:
  /// ```makrdown
  ///   `<?xml`
  /// ```
  ResponseCustomType getResponseType(String checkText) {
    if (checkText.length < 2) return ResponseCustomType.unknow;
    var _k = _RespCheckkv.keys.where((_key) {
      int _len = _key.length;
      var _sub = checkText.substring(0, _len);
      bool _if = _sub.contains(_key, 0);
      return _if;
    }).toList();

    if (_k.isNotEmpty) {
      return _RespCheckkv[_k[0]] as ResponseCustomType;
    }

    return ResponseCustomType.unknow;
  }

  @override
  Future<List<VideoDetail>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    var resp = await XHttp.dio.post(
      createUrl(suffix: api_path),
      queryParameters: {
        "ac": "videolist",
        // "t": limit,
        "pg": page,
        "wd": keyword,
      },
      options: ops,
    );
    dynamic data = resp.data;
    var _type = getResponseTypeAndCheck(data);
    if (_type == ResponseCustomType.json) {
      return _parseSearchJSON(data);
    }
    return _parseSearchXML(data);
  }

  @override
  bool get isNsfw => meta.isNsfw;

  @override
  Future<List<SourceSpiderQueryCategory>> getCategory() async {
    var path = createUrl(suffix: api_path);
    var resp = await XHttp.dio.get(path, options: ops);
    dynamic data = resp.data;
    var _type = getResponseTypeAndCheck(data);
    List<SourceSpiderQueryCategory> category = [];
    if (_type == ResponseCustomType.json) {
      category = _parseCategoryJSON(data);
    } else {
      category = _parseCategoryXML(data);
    }
    // NOTE(d1y): 分类默认添加一个全部分类
    return [kDefaultAllCategory, ...category];
  }

  dynamic _parseDetailJSON(dynamic data) {
    if (data is! String) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    var list = _getJSONList(data);
    if (list.isEmpty) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    return list[0];
  }

  VideoDetail _parseDetailXML(dynamic data) {
    var x2j = Xml2Json();
    x2j.parse(data);
    var _json = x2j.toBadgerfish();
    var cx = json.decode(_json);
    KBaseMovieXmlData xml = KBaseMovieXmlData.fromJson(cx);
    var video = xml.rss.list.video;
    var cards = video.map(
      (e) {
        var __dd = e.dl.dd;
        List<VideoInfo> videos = __dd.map((item) {
          return VideoInfo(
            url: easyGetVideoURL(item.cData),
            name: item.flag,
            type: easyGetVideoType(item.cData),
          );
        }).toList();
        var realVideos = videoInfo2RealVideos(videos);
        var pic = normalizeCoverImage(e.pic);
        return VideoDetail(
          id: e.id,
          smallCoverImage: pic,
          title: e.name,
          videos: realVideos,
          desc: _normalDesc(e.des),
          updateTime: e.last,
          remark: e.note,
          extra: {},
        );
      },
    ).toList();
    if (cards.isEmpty) {
      throw UnimplementedError();
    }
    return cards[0];
  }

  dynamic _parseSearchJSON(dynamic data) {
    if (data is! String) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    return _getJSONList(data);
  }

  List<VideoDetail> _parseSearchXML(dynamic data) {
    var x2j = Xml2Json();
    x2j.parse(data);
    var _json = x2j.toBadgerfish();
    KBaseMovieSearchXmlData searchData = kBaseMovieSearchXmlDataFromJson(_json);
    var defaultCoverImage = meta.logo;
    List<VideoDetail> result = searchData.rss?.list?.video!
            .map(
              (e) => VideoDetail(
                id: e.id ?? "",
                smallCoverImage: defaultCoverImage,
                title: e.name?.cdata ?? "",
                updateTime: e.last == null ? "" : e.last!.toIso8601String(),
                remark: e.note?.cdata ?? "",
                extra: {},
              ),
            )
            .toList() ??
        [];
    return result;
  }

  List<SourceSpiderQueryCategory> _parseCategoryJSON(dynamic data) {
    if (data is! String) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    var json = jsonDecode(data);
    List<Map<String, dynamic>> cx = json['class'].cast<Map<String, dynamic>>();
    var result = <SourceSpiderQueryCategory>[];
    for (var item in cx) {
      var name = item['type_name'] ?? "";
      var _id = item['type_id'];
      late String id;
      if (_id is int) {
        id = _id.toString();
      } else {
        id = _id;
      }
      result.add(SourceSpiderQueryCategory(name, id));
    }
    return result;
  }

  List<SourceSpiderQueryCategory> _parseCategoryXML(dynamic data) {
    var x2j = Xml2Json();
    x2j.parse(data);
    var _json = x2j.toBadgerfish();
    var cx = json.decode(_json);
    KBaseMovieXmlData xml = KBaseMovieXmlData.fromJson(cx);
    return xml.rss.category;
  }

  List<VideoDetail> _parseHomeXML(dynamic data) {
    var x2j = Xml2Json();
    x2j.parse(data);
    var _json = x2j.toBadgerfish();
    var cx = json.decode(_json);
    KBaseMovieXmlData xml = KBaseMovieXmlData.fromJson(cx);
    return xml.rss.list.video.map(
      (e) {
        var __dd = e.dl.dd;
        List<VideoInfo> videos = __dd.map((item) {
          return VideoInfo(
            url: easyGetVideoURL(item.cData),
            name: item.flag,
            type: easyGetVideoType(item.cData),
          );
        }).toList();
        var realVideos = videoInfo2RealVideos(videos);
        var pic = normalizeCoverImage(e.pic);
        return VideoDetail(
          id: e.id,
          smallCoverImage: pic,
          title: e.name,
          videos: realVideos,
          desc: _normalDesc(e.des),
          updateTime: e.last,
          remark: e.note,
          extra: {},
        );
      },
    ).toList();
  }

  List<VideoDetail> _parseHomeJSON(dynamic data) {
    if (data is! String) {
      throw AsyncError(
        _responseParseFail,
        StackTrace.fromString(_responseParseFail),
      );
    }
    return _getJSONList(data);
  }

  List<VideoDetail> _getJSONList(dynamic jsonData) {
    var json = jsonDecode(jsonData);
    var list = json['list']; //;
    var result = <VideoDetail>[];
    if (list is Map) {
      var cx = list as Map<String, dynamic>;
      result.add(__parseListItem(cx));
    } else if (list is List) {
      for (var item in list.cast<Map<String, dynamic>>()) {
        result.add(__parseListItem(item));
      }
    }
    return result;
  }

  // [0] => episode(name)
  // [1] => url
  List<String> __parseVideoInfo(String input) {
    // 第一集$https://x.dev/1.m3u8
    if (input.contains("\$")) {
      return input.split("\$");
    }
    // 第一集https://x.dev/1.m3u8
    // 第二集https://x.dev/2.m3u8
    const String httpsPrefix = 'https://';
    const String httpPrefix = 'http://';
    int urlStartIndex = input.indexOf(httpsPrefix);
    if (urlStartIndex == -1) {
      urlStartIndex = input.indexOf(httpPrefix);
    }
    if (urlStartIndex == -1) {
      return []; // throw error
    }
    String episode = input.substring(0, urlStartIndex).trim();
    String url = input.substring(urlStartIndex).trim();
    return [episode, url];
  }

  VideoDetail __parseListItem(dynamic item) {
    var videos = <VideoInfo>[];
    // 参考格式: vod_play_from":"ukyun$$$ukm3u8","vod_play_server":"no$$$no","vod_play_note":"$$$","vod_play_url": "xxxx$$$xxxxx"
    String vodFrom = item["vod_play_from"] ?? "默认";
    String vodNote = item['vod_play_note'] ?? "";
    String _vodURL = (item['vod_play_url'] ?? "");
    late List<String> tags;
    if (vodNote.isNotEmpty) {
      tags = vodFrom.split(vodNote /* $$$ */);
    } else {
      if (vodFrom.isEmpty) {
        vodFrom = "默认";
      }
      tags = [vodFrom];
    }
    String vodURL = _vodURL.replaceAll(RegExp(r'#$'), '');
    List<String> _t = vodURL.split(vodNote /* $$$ */);
    if (tags.length >= 2) {
      Map<String, List<VideoInfo>> _cx = {};
      for (final (index, subItem) in _t.indexed) {
        var _nameKey = tags[index];
        List<VideoInfo> _map =
            subItem.split("#").where((e) => e.trim().isNotEmpty).map((item) {
          List<String> items = __parseVideoInfo(item);
          if (items.length == 1) {}
          return VideoInfo(
            name: items[0],
            url: items[1],
            type: easyGetVideoType(items[1]),
          );
        }).toList();
        _cx[_nameKey] = _map;
      }
      _cx.forEach((key, value) {
        var url = value
            .map((item) {
              /// 这里转成 [videoInfo2PlayListData] 需要的格式
              return "${item.name}\$${item.url}";
            })
            .toList()
            .join("#");
        var video = VideoInfo(name: key, url: url, type: easyGetVideoType(url));
        videos.add(video);
      });
    } else if (tags.length == 1) {
      videos.add(
        VideoInfo(
          name: tags[0],
          url: _vodURL,
          type: easyGetVideoType(_vodURL),
        ),
      );
    }
    var _id = item['vod_id'];
    late String id;
    if (_id is int) {
      id = _id.toString();
    } else {
      id = _id;
    }
    var realVideos = videoInfo2RealVideos(videos);
    var detail = VideoDetail(
      id: id,
      title: item['vod_name'] ?? "",
      desc: _normalDesc(item['vod_blurb'] ?? ""),
      updateTime: item["vod_time"] ?? "",
      remark: item["vod_remarks"] ?? "",
      smallCoverImage: item['vod_pic'] ?? "",
      videos: realVideos,
      extra: {},
    );
    return detail;
  }

  @override
  String toString() {
    var output = "\n";
    output += "name: ${meta.name}\n";
    output += " url: $root_url$api_path";
    return output;
  }

  List<String> _parseIframe(String iframe, String body) {
    var url = Uri.tryParse(iframe);
    if (url == null) return [];
    var domain = "${url.scheme}://${url.host}";
    final List<String> m3u8Links = [];
    for (final Match match in kIframeParseRegex.allMatches(body)) {
      if (match.groupCount >= 1) {
        String? link = match.group(1);
        if (link != null && link.isNotEmpty) {
          if (!(link.startsWith("http://") || link.startsWith("https://"))) {
            /// 如果 $link 前缀不是 /xx/xx.m3u8 那就惨了!
            link = "$domain$link";
          }
          m3u8Links.add(link);
        }
      }
    }
    return m3u8Links;
  }

  @override
  // TODO(d1y): 这个应该交由原配置去解析, 这里的通用解析只是为了乐呵乐呵(某些估计解析不了?)
  Future<List<String>> parseIframe(String iframe) async {
    try {
      var resp = await XHttp.dio.get<String>(iframe, options: ops);
      var htmlText = resp.data ?? "";
      return _parseIframe(iframe, htmlText);
    } catch (e) {
      return []; // catch error
    }
  }
}

```

#### 📄 `lib/adapters\universal.dart`

```dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:dart_qjson/dart_qjson.dart';
import 'package:xi/xi.dart';

const kEvalTimeout = Duration(seconds: 6);

var kJSEmptyException = Exception("JS 代码为空");

extension BetterJSONList on JsonList {
  void forEach(ValueChanged<JsonObject> cb) {
    for (var i = 0; i < length; i++) {
      JsonObject cx = getObject(i)!;
      cb(cx);
    }
  }

  List<T> map<T>(T Function(JsonObject value) cb) {
    List<T> result = [];
    forEach((item) {
      result.add(cb(item));
    });
    return result;
  }
}

extension BetterJsonObject on JsonObject {
  String $getString(String key, {String defaultValue = ""}) {
    var cx = get(key);
    if (cx == null || cx.isNull) return defaultValue;
    return cx.toString();
  }

  JsonList $getList(String key) {
    var cx = getList(key);
    if (cx == null || cx.isEmpty) return JsonList([]);
    return cx;
  }
}

enum JSCodeType {
  category,
  home,
  search,
  detail,
  parseIframe,
}

class UniversalSpider extends ISpiderAdapter {
  UniversalSpider(SourceMeta sourceMeta) {
    meta = sourceMeta;
  }

  String get url => meta.api;

  List<SourceSpiderQueryCategory> parseCategoryWithJSResult(String _result) {
    var jsonList = JsonList.fromJsonString(_result);
    List<SourceSpiderQueryCategory> result = [];
    jsonList.forEach((item) {
      var text = item.$getString("text", defaultValue: "默认");
      var id = item.$getString("id");
      result.add(SourceSpiderQueryCategory(text, id));
    });
    return result;
  }

  List<Videos> parsePlaylistWithJSONList(JsonList? cx) {
    if (cx == null || cx.isEmpty) return [];
    List<Videos> realVideos = [];
    cx.forEach((item) {
      var title = item.$getString("title", defaultValue: "默认");
      var videos = item.$getList("videos");
      var videoInfos = videos.map((subItem) {
        var name = subItem.$getString("text", defaultValue: "默认");
        var id = subItem.$getString("id"); // id => iframe
        var url = subItem.$getString("url"); // url => m3u8
        VideoType type = VideoType.m3u8;
        if (id.isNotEmpty) {
          type = VideoType.iframe;
          url = id;
        }
        return VideoInfo(
          name: name,
          url: url,
          type: type,
        );
      }).toList();
      realVideos.add(Videos(title: title, datas: videoInfos));
    });
    return realVideos;
  }

  List<VideoDetail> parseListWithJSResult(String _result) {
    var jsonList = JsonList.fromJsonString(_result);
    List<VideoDetail> result = [];
    jsonList.forEach((item) {
      var cover = item.$getString("cover");
      var title = item.$getString("title");
      var desc = item.$getString("desc");
      var id = item.$getString("id");
      var remark = item.$getString("remark");
      var playlist = item.$getList("playlist");
      var realVideos = parsePlaylistWithJSONList(playlist);
      result.add(
        VideoDetail(
          id: id,
          title: title,
          desc: desc,
          smallCoverImage: cover,
          remark: remark,
          videos: realVideos,
          extra: {},
        ),
      );
    });
    return result;
  }

  Map<String, dynamic> get _jsMap => meta.extra['js'] ?? {};

  String? get _templateId => meta.extra['template'];

  bool get _hasTemplate => _templateId != null && _templateId!.isNotEmpty;

  String _generateJSCode(String realCode, {Map<String, dynamic>? params}) {
    var ps = jsonEncode(params ?? {});
    var result = """
(async ()=> {
  const env = {
    get(key, defaultValue) {
      return this.params[key] ?? defaultValue
    },
    baseUrl: `$url`,
    params: $ps,
  };
  $realCode
})()""";
    return result;
  }

  String _getLogicJSCode(JSCodeType type) {
    // 如果有模板ID，优先使用模板中的JS代码
    if (_hasTemplate) {
      try {
        var template = jsTemplate.get(_templateId!);
        var code = template.get(type);
        if (code.isNotEmpty) {
          return code;
        }
      } catch (e) {
        // 模板不存在或获取失败，回退到原始逻辑
      }
    }

    // 使用原始的JS配置
    var code = _jsMap[type.name];
    if (code is! String) {
      return jsonEncode(code);
    }
    return _jsMap[type.name] ?? "";
  }

  String _realCode(JSCodeType type, {Map<String, dynamic>? params}) {
    var logic = _getLogicJSCode(type);
    if (logic.isEmpty) return "";
    return _generateJSCode(logic, params: params);
  }

  @override
  Future<List<SourceSpiderQueryCategory>> getCategory() async {
    var cates = _getLogicJSCode(JSCodeType.category);
    if (cates.isEmpty) return [];
    if (getJSONBodyType(cates) == JSONBodyType.array) {
      var result = JsonList.fromJsonString(cates).map((item) {
        return SourceSpiderQueryCategory(
          item.$getString("text"),
          item.$getString("id"),
        );
      });
      return result;
    }
    var code = _generateJSCode(cates);
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    return parseCategoryWithJSResult(result);
  }

  @override
  Future<List<VideoDetail>> getHome({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    var code = _realCode(JSCodeType.home, params: {
      "category": category,
      "page": page,
      "limit": limit,
    });
    if (code.isEmpty) throw kJSEmptyException;
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    return parseListWithJSResult(result);
  }

  @override
  Future<VideoDetail> getDetail(String movieId) async {
    var code = _realCode(JSCodeType.detail, params: {
      "movieId": movieId,
    });
    if (code.isEmpty) throw kJSEmptyException;
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    var resultWithArray = "[$result]";
    return parseListWithJSResult(resultWithArray)[0];
  }

  @override
  Future<List<VideoDetail>> getSearch({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    var code = _realCode(JSCodeType.search, params: {
      "page": page,
      "limit": limit,
      "keyword": keyword,
    });
    if (code.isEmpty) [];
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    return parseListWithJSResult(result);
  }

  @override
  bool get isNsfw => meta.isNsfw;

  @override
  Future<List<String>> parseIframe(String iframe) async {
    var code = _realCode(JSCodeType.parseIframe, params: {
      "iframe": iframe,
    });
    if (code.isEmpty) return [];
    var result = await js2.evalSync(code, timeout: kEvalTimeout);
    // 返回的貌似是 '"xx.m3u8"'
    // 所以可能还需要在解析一下
    String realResult = jsonDecode(result);
    return [realResult];
  }
}

class Template {
  Map<JSCodeType, String> jsCodeMap = {};
  Template(this.jsCodeMap);
  String get(JSCodeType type) {
    return jsCodeMap[type] ?? "";
  }
}

class Templates {
  Map<String, Template> templates = {};
  Templates(this.templates);
  Template get(String id) {
    return templates[id]!;
  }
}

// 创建全局的 jsTemplate 实例
final jsTemplate = Templates({});

```

#### 📂 lib/adapters\templates

##### 📂 lib/adapters\templates\src

### 📂 lib/models

#### 📄 `lib/models\models.dart`

```dart
export './spec.dart';

```

#### 📄 `lib/models\spec.dart`

```dart
/// 源列表导入列表, 一般来说是 waifu-project/assets 仓库维护的 .json 文件
class AssetSourceItemJSONData {
  /// 源名称
  String? title;

  /// 采集地址, 一般是地址合集
  String? url;

  /// 源的说明, 一般是导入的时候用来提示的
  String? msg;

  /// 是否是 18+ 的源
  bool? nsfw;

  AssetSourceItemJSONData({
    this.title,
    this.url,
    this.msg,
    this.nsfw,
  });

  AssetSourceItemJSONData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    url = json['url'];
    msg = json['msg'];
    nsfw = json['nsfw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['url'] = url;
    data['msg'] = msg;
    data['nsfw'] = nsfw;
    return data;
  }
}

```

#### 📂 lib/models\mac_cms

#### 📄 `lib/models\mac_cms\xml_data.dart`

```dart
import 'package:xi/xi.dart';

class KBaseMovieXmlData {
  KBaseMovieXmlData({
    required this.rss,
  });
  late final Rss rss;

  KBaseMovieXmlData.fromJson(Map<String, dynamic> json) {
    rss = Rss.fromJson(json['rss']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['rss'] = rss.toJson();
    return _data;
  }
}

class Rss {
  Rss({
    required this.list,
    required this.version,
    required this.category,
  });
  late final ListX list;
  late final String version;
  late final List<SourceSpiderQueryCategory> category;

  Rss.fromJson(Map<String, dynamic> json) {
    list = ListX.fromJson(json['list']);
    version = json['@version'];
    Map<String, dynamic> _category = json['class'] ?? {};
    dynamic ty = _category['ty'];
    List<dynamic> data = [];
    if (ty is List) {
      data = ty;
    } else if (ty is Map) {
      data.add(ty);
    }
    List<SourceSpiderQueryCategory> _categorys = data.map((e) {
      var map = Map<String, String>.from(e);
      var name = map['\$'] ?? "";
      var id = map['@id'] ?? "";
      return SourceSpiderQueryCategory(name, id);
    }).toList();
    category = _categorys;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['list'] = list.toJson();
    _data['_version'] = version;
    _data['category'] = category;
    return _data;
  }
}

class ListX {
  ListX({
    required this.video,
    required this.page,
    required this.pagecount,
    required this.pagesize,
    required this.recordcount,
  });
  late final List<Video> video;
  late final String page;
  late final String pagecount;
  late final String pagesize;
  late final String recordcount;

  ListX.fromJson(Map<String, dynamic> json) {
    var v = json['video'];
    List<Video> rv = [];
    if (v == null) {
      // ignore the line
    } else if (v is Map) {
      rv = [Video.fromJson(v.cast())];
    } else {
      rv = List.from(v).map((e) {
        return Video.fromJson(e);
      }).toList();
    }
    video = rv;
    page = json['@page'];
    pagecount = json['@pagecount'];
    pagesize = json['@pagesize'];
    recordcount = json['@recordcount'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['video'] = video.map((e) => e.toJson()).toList();
    _data['_page'] = page;
    _data['_pagecount'] = pagecount;
    _data['_pagesize'] = pagesize;
    _data['_recordcount'] = recordcount;
    return _data;
  }
}

class Video {
  Video({
    required this.last,
    required this.id,
    required this.tid,
    required this.name,
    required this.type,
    required this.pic,
    required this.lang,
    required this.area,
    required this.year,
    required this.state,
    required this.note,
    required this.actor,
    required this.director,
    required this.dl,
    required this.des,
  });
  late final String last;
  late final String id;
  late final String tid;
  late final String name;
  late final String type;
  late final String pic;
  late final String lang;
  late final String area;
  late final String year;
  late final String state;
  late final String note;
  late final String actor;
  late final String director;
  late final Dl dl;
  late final String des;

  /// NOTE:
  ///   => 该库默认行为会生成一个Map,
  dynamic autoFix2String(dynamic raw, String rawKey) {
    if (raw is Map) {
      var _m = raw[rawKey];
      if (_m == null) return null;
      var r = _m['\$'];
      if (r == null) {
        var __r = raw[rawKey]['__cdata'];
        if (__r == null) return "";
        return __r;
      }
      return r;
    }
    return raw[rawKey];
  }

  Video.fromJson(Map<String, dynamic> json) {
    last = autoFix2String(json, 'last') ?? "";
    id = autoFix2String(json, 'id') ?? "";
    tid = autoFix2String(json, 'tid') ?? "";
    name = autoFix2String(json, 'name') ?? "";
    type = autoFix2String(json, 'type') ?? "";
    pic = autoFix2String(json, 'pic') ?? "";
    lang = autoFix2String(json, 'lang') ?? "";
    area = autoFix2String(json, 'area') ?? "";
    year = autoFix2String(json, 'year') ?? "";
    state = autoFix2String(json, 'state') ?? "";
    note = autoFix2String(json, 'note') ?? "";
    actor = autoFix2String(json, 'actor') ?? "";
    director = autoFix2String(json, 'director') ?? "";
    dl = Dl.fromJson(json['dl'] ?? {});
    des = autoFix2String(json, 'des') ?? "";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['last'] = last;
    _data['id'] = id;
    _data['tid'] = tid;
    _data['name'] = name;
    _data['type'] = type;
    _data['pic'] = pic;
    _data['lang'] = lang;
    _data['area'] = area;
    _data['year'] = year;
    _data['state'] = state;
    _data['note'] = note;
    _data['actor'] = actor;
    _data['director'] = director;
    _data['dl'] = dl.toJson();
    _data['des'] = des;
    return _data;
  }
}

class Dl {
  Dl({
    required this.dd,
  });
  late final List<Dd> dd;

  Dl.fromJson(Map<String, dynamic> json) {
    var __dd = json['dd'] ?? {};
    if (__dd is Map) {
      dd = [Dd.fromJson(__dd.cast())];
    } else {
      dd = List.from(json['dd']).map((e) => Dd.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['dd'] = dd.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Dd {
  Dd({
    required this.flag,
    required this.cData,
  });
  late final String flag;
  late final String cData;

  Dd.fromJson(Map<String, dynamic> json) {
    flag = json['@flag'] ?? "";
    cData = json['__cdata'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['_flag'] = flag;
    _data['__cdata'] = cData;
    return _data;
  }
}

```

#### 📄 `lib/models\mac_cms\xml_search_data.dart`

```dart
// To parse this JSON data, do
//
//     final kBaseMovieSearchXmlData = kBaseMovieSearchXmlDataFromJson(jsonString);

import 'dart:convert';

KBaseMovieSearchXmlData kBaseMovieSearchXmlDataFromJson(String str) =>
    KBaseMovieSearchXmlData.fromJson(json.decode(str));

String kBaseMovieSearchXmlDataToJson(KBaseMovieSearchXmlData data) =>
    json.encode(data.toJson());

class KBaseMovieSearchXmlData {
  KBaseMovieSearchXmlData({
    this.rss,
  });

  Rss? rss;

  factory KBaseMovieSearchXmlData.fromJson(Map<String, dynamic> json) =>
      KBaseMovieSearchXmlData(
        rss: Rss.fromJson(json["rss"]),
      );

  Map<String, dynamic> toJson() => {
        "rss": rss?.toJson(),
      };
}

class Rss {
  Rss({
    this.list,
    this.rssClass,
    this.version,
  });

  ListClass? list;
  Class? rssClass;
  String? version;

  factory Rss.fromJson(Map<String, dynamic> json) {
    var _class = json['class'];
    return Rss(
      list: ListClass.fromJson(json["list"]),
      rssClass: Class.fromJson(_class ??
          {
            "ty": [],
          }),
      version: json["_version"],
    );
  }

  Map<String, dynamic> toJson() => {
        "list": list?.toJson(),
        "class": rssClass?.toJson(),
        "_version": version,
      };
}

class ListClass {
  ListClass({
    this.video,
    this.page,
    this.pagecount,
    this.pagesize,
    this.recordcount,
  });

  List<Video>? video;
  String? page;
  String? pagecount;
  String? pagesize;
  String? recordcount;

  factory ListClass.fromJson(Map<String, dynamic> json) {
    var video = json["video"];
    List<Video> data = [];
    if (video is Map) {
      data.add(Video.fromJson(video.cast()));
    } else {
      if (video != null && video is List) {
        var cacheVideo = List<Video>.from(video.map((x) => Video.fromJson(x)));
        data.addAll(cacheVideo);
      }
    }
    return ListClass(
      video: data,
      page: json["_page"],
      pagecount: json["_pagecount"],
      pagesize: json["_pagesize"],
      recordcount: json["_recordcount"],
    );
  }

  Map<String, dynamic> toJson() => {
        "video": List<dynamic>.from(video!.map((x) => x.toJson())),
        "_page": page,
        "_pagecount": pagecount,
        "_pagesize": pagesize,
        "_recordcount": recordcount,
      };
}

/// NOTE:
///   => 该库默认行为会生成一个Map,
dynamic autoFix2String(dynamic raw, String rawKey) {
  try {
    if (raw == null) return "";
    if (raw is Map) {
      var r = raw[rawKey]['\$'];
      if (r == null) {
        var __r = raw[rawKey]['__cdata'];
        if (__r == null) return "";
        return __r;
      }
      return r;
    }
    return raw[rawKey];
  } catch (e) {
    return "";
  }
}

class Video {
  Video({
    this.last,
    this.id,
    this.tid,
    this.name,
    this.type,
    this.dt,
    this.note,
  });

  DateTime? last;
  String? id;
  String? tid;
  Name? name;
  String? type;
  String? dt;
  Name? note;

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        last: DateTime.parse(autoFix2String(json, "last")),
        id: autoFix2String(json, 'id'),
        tid: autoFix2String(json, 'tid'),
        name: Name.fromJson(json["name"]),
        type: autoFix2String(json, 'type'),
        dt: autoFix2String(json, 'dt'),
        note: Name.fromJson(json["note"]),
      );

  Map<String, dynamic> toJson() => {
        "last": last!.toIso8601String(),
        "id": id,
        "tid": tid,
        "name": name!.toJson(),
        "type": type,
        "dt": dt,
        "note": note!.toJson(),
      };
}

class Name {
  Name({
    this.cdata,
  });

  String? cdata;

  factory Name.fromJson(Map<String, dynamic> json) => Name(
        cdata: json["__cdata"],
      );

  Map<String, dynamic> toJson() => {
        "__cdata": cdata,
      };
}

class Class {
  Class({
    this.ty,
  });

  List<Ty>? ty;

  factory Class.fromJson(Map<String, dynamic> json) => Class(
        ty: List<Ty>.from(json["ty"].map((x) => Ty.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ty": List<dynamic>.from(ty!.map((x) => x.toJson())),
      };
}

class Ty {
  Ty({
    this.id,
    this.text,
  });

  String? id;
  String? text;

  factory Ty.fromJson(Map<String, dynamic> json) {
    var id = json["_id"];
    id ??= json["@id"];
    var text = json["__text"];
    text ??= json["\$"];
    return Ty(
      id: id,
      text: text,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "__text": text,
      };
}

```

### 📂 lib/utils

#### 📄 `lib/utils\helper.dart`

```dart
// copy https://github.com/dart-league/validators/blob/master/lib/validators.dart

// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

RegExp _ipv4Maybe = RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
RegExp _ipv6 =
    RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

dynamic shift(List l) {
  if (l.isNotEmpty) {
    var first = l.first;
    l.removeAt(0);
    return first;
  }
  return null;
}

/// check if the string [str] is IP [version] 4 or 6
///
/// * [version] is a String or an `int`.
bool isIP(String? str, [/*<String | int>*/ version]) {
  version = version.toString();
  if (version == 'null') {
    return isIP(str, 4) || isIP(str, 6);
  } else if (version == '4') {
    if (!_ipv4Maybe.hasMatch(str!)) {
      return false;
    }
    var parts = str.split('.');
    parts.sort((a, b) => int.parse(a) - int.parse(b));
    return int.parse(parts[3]) <= 255;
  }
  return version == '6' && _ipv6.hasMatch(str!);
}

/// check if the string [str] is a fully qualified domain name (e.g. domain.com).
///
/// * [requireTld] sets if TLD is required
/// * [allowUnderscore] sets if underscores are allowed
bool isFQDN(String str,
    {bool requireTld = true, bool allowUnderscores = false}) {
  var parts = str.split('.');
  if (requireTld) {
    var tld = parts.removeLast();
    if (parts.isEmpty || !RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
      return false;
    }
  }

  for (var part in parts) {
    if (allowUnderscores) {
      if (part.contains('__')) {
        return false;
      }
    }
    if (!RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
      return false;
    }
    if (part[0] == '-' ||
        part[part.length - 1] == '-' ||
        part.contains('---')) {
      return false;
    }
  }
  return true;
}

/// check if the string [str] is a URL
///
/// * [protocols] sets the list of allowed protocols
/// * [requireTld] sets if TLD is required
/// * [requireProtocol] is a `bool` that sets if protocol is required for validation
/// * [allowUnderscore] sets if underscores are allowed
/// * [hostWhitelist] sets the list of allowed hosts
/// * [hostBlacklist] sets the list of disallowed hosts
bool isURL(String? str,
    {List<String?> protocols = const ['http', 'https', 'ftp'],
    bool requireTld = true,
    bool requireProtocol = false,
    bool allowUnderscore = false,
    List<String> hostWhitelist = const [],
    List<String> hostBlacklist = const []}) {
  if (str == null ||
      str.isEmpty ||
      str.length > 2083 ||
      str.startsWith('mailto:')) {
    return false;
  }

  var protocol,
      user,
      auth,
      host,
      hostname,
      port,
      portStr,
      path,
      query,
      hash,
      split;

  // check protocol
  split = str.split('://');
  if (split.length > 1) {
    protocol = shift(split);
    if (!protocols.contains(protocol)) {
      return false;
    }
  } else if (requireProtocol == true) {
    return false;
  }
  str = split.join('://');

  // check hash
  split = str!.split('#');
  str = shift(split);
  hash = split.join('#');
  if (hash != null && hash != "" && RegExp(r'\s').hasMatch(hash)) {
    return false;
  }

  // check query params
  split = str!.split('?');
  str = shift(split);
  query = split.join('?');
  if (query != null && query != "" && RegExp(r'\s').hasMatch(query)) {
    return false;
  }

  // check path
  split = str!.split('/');
  str = shift(split);
  path = split.join('/');
  if (path != null && path != "" && RegExp(r'\s').hasMatch(path)) {
    return false;
  }

  // check auth type urls
  split = str!.split('@');
  if (split.length > 1) {
    auth = shift(split);
    if (auth.indexOf(':') >= 0) {
      auth = auth.split(':');
      user = shift(auth);
      if (!RegExp(r'^\S+$').hasMatch(user)) {
        return false;
      }
      if (!RegExp(r'^\S*$').hasMatch(user)) {
        return false;
      }
    }
  }

  // check hostname
  hostname = split.join('@');
  split = hostname.split(':');
  host = shift(split);
  if (split.length > 0) {
    portStr = split.join(':');
    try {
      port = int.parse(portStr, radix: 10);
    } catch (e) {
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(portStr) || port <= 0 || port > 65535) {
      return false;
    }
  }

  if (!isIP(host) &&
      !isFQDN(host,
          requireTld: requireTld, allowUnderscores: allowUnderscore) &&
      host != 'localhost') {
    return false;
  }

  if (hostWhitelist.isNotEmpty && !hostWhitelist.contains(host)) {
    return false;
  }

  if (hostBlacklist.isNotEmpty && hostBlacklist.contains(host)) {
    return false;
  }

  return true;
}

/// 获取 [windows] 平台的主题
/// 参考:
///   => https://github.com/albertosottile/darkdetect/blob/master/darkdetect/_windows_detect.py
Brightness getWindowsThemeMode() {
  if (!Platform.isWindows) return Brightness.light;

  // PS C:\Users\PureBoy> reg query HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /z /t REG_DWORD
  // HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize
  //     AppsUseLightTheme    REG_DWORD (4)    0x1
  // 搜索结束: 找到 1 匹配。

  // 0x1 => 浅色
  // 0x0 => 深色
  var pipe = Process.runSync("reg", [
    "query",
    "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
    "/v",
    "AppsUseLightTheme",
    "/z",
    "/t",
    "REG_DWORD"
  ]);
  var io2 = pipe.stdout.toString();
  return [
    {"k": "0x1", "v": Brightness.light},
    {"k": "0x0", "v": Brightness.dark},
  ].firstWhere((element) => io2.contains(element["k"] as String))["v"]
      as Brightness;
}

class DragonScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

/// check file is `binary`
///
/// see: https://stackoverflow.com/a/66670519/10272586
bool isBinaryAsFile(File file) {
  RandomAccessFile raf = file.openSync(mode: FileMode.read);
  Uint8List data = raf.readSync(124);
  for (final b in data) {
    if (b >= 0x00 && b <= 0x08) {
      raf.close();
      return true;
    }
  }
  raf.close();
  return false;
}

bool isBinaryAsPath(String path) {
  final file = File(path);
  return isBinaryAsFile(file);
}

/// 判断 `iina` 是否安装
bool checkInstalledIINA() {
  const iinaAPP = '/Applications/IINA.app';
  // if (kDebugMode) return false;
  return Directory(iinaAPP).existsSync();
}

String encodeURL(String raw) {
  return Uri.encodeFull(raw);
}

String decodeURL(String raw) {
  return Uri.decodeFull(raw);
}

var kUnescape = HtmlUnescape();
```

#### 📄 `lib/utils\http.dart`

```dart
import 'dart:io';

import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'path.dart';
// import 'package:native_dio_adapter/native_dio_adapter.dart';

/// dio http 请求库缓存时间
const kHttpCacheTime = Duration(hours: 2);

const kConnectTimeout = Duration(seconds: 12);
const kReceiveTimeout = Duration(seconds: 12);

extension DioWithForceNoCache on Options {
  Options withNoCache() {
    extra ??= {};
    extra!["no-cache"] = true;
    return this;
  }
}

/// 默认所有的 `dio-http` 请求都持久化话([kHttpCacheTime])
///
/// 此扩展可以修改 `options` 控制缓存行为
/// ```dart
/// var resp = await XHttp.dio.get(
///  fetchMirrorAPI,
///  options: $noCacheOption,
/// );
///```
extension AnyInjectHttpCacheOptions on Object {
  Options $noCacheOption() {
    return Options().withNoCache();
  }
}

var kHttpCacheMiddlewareOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.forceCache,
  hitCacheOnErrorCodes: const [401, 403],
  maxStale: kHttpCacheTime,
  priority: CachePriority.normal,
  cipher: null,
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  allowPostMethod: true,
);

class XHttp {
  XHttp._internal();

  /// 网络请求配置
  static final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        "User-Agent":
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36",
      },
    ),
  );

  static void setDefaultTImeout() {
    dio.options.connectTimeout = kConnectTimeout;
    dio.options.receiveTimeout = kReceiveTimeout;
  }

  static void setTimeout(int connect, int receive) {
    dio.options.connectTimeout = Duration(seconds: connect);
    dio.options.receiveTimeout = Duration(seconds: receive);
  }

  /// 初始化dio
  static Future<void> init({bool enableLog = false}) async {
    /// 初始化cookie
    var value = await PathUtils.getDocumentsDirPath();
    var cookieJar = PersistCookieJar(
      storage: FileStorage("$value/.cookies/"),
    );
    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors
        .add(DioCacheInterceptor(options: kHttpCacheMiddlewareOptions));

    if (enableLog) {
      dio.interceptors.add(
        AwesomeDioInterceptor(
          logRequestTimeout: true,
          logRequestHeaders: true,
          logResponseHeaders: true,
          logger: debugPrint,
        ),
      );
    }

    // if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
    //   // TODO(d1y): 这里需要忽律掉证书错误的域名
    //   dio.httpClientAdapter = NativeAdapter(createCupertinoConfiguration: () {
    //     return URLSessionConfiguration.defaultSessionConfiguration()
    //       ..allowsCellularAccess = true
    //       ..allowsConstrainedNetworkAccess = true
    //       ..allowsExpensiveNetworkAccess = true;
    //   }, createCronetEngine: () {
    //     return CronetEngine.build(enableHttp2: true, enableQuic: true);
    //   });
    // } else {
    dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    });
    // }
  }

  static Future<T> get<T>(String url, [Map<String, dynamic>? params]) async {
    Response response;
    if (params != null) {
      response = await dio.get<T>(url, queryParameters: params);
    } else {
      response = await dio.get<T>(url);
    }
    return response.data;
  }

  static Future<T> post<T>(String url, [Map<String, dynamic>? params]) async {
    Response response = await dio.post<T>(url, queryParameters: params);
    return response.data;
  }

  static Future<T> postWithBody<T>(String url,
      [Map<String, dynamic>? data]) async {
    Response response = await dio.post<T>(url, data: data);
    return response.data;
  }
}

```

#### 📄 `lib/utils\js2.dart`

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/extensions/xhr.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:xi/xi.dart';

class JS2 {
  late JavascriptRuntime _runtime;

  Future<void> init() async {
    _runtime = getJavascriptRuntime();
    await _runtime.enableHandlePromises();
    await _runtime.enableFetch();
    await _installCheerio();
    _runtime.setInspectable(true);
    _runtime.enableXhr();
    _injectMethods();
  }

  void _injectMethods() {
    _runtime.injectMethod('req', (dynamic args) async {
      if (args is List && args.isNotEmpty) {
        String url = "";
        Options options = Options(
          responseType: ResponseType.plain,
        );
        var arg1 = args[0];
        Map argMap = {};

        if (args.length >= 2) {
          // [ "$url", { "headers", "method" } ]
          if (arg1 is String) {
            url = arg1;
          }
          var arg2 = args[1];
          if (arg2 is Map) {
            argMap = arg2;
          }
        } else if (args.length == 1) {
          // [ "$url" ] | [ { "headers", "method", "url" } ]
          if (arg1 is String) {
            url = arg1;
          } else if (arg1 is Map) {
            argMap = arg1;
          }
        }

        if (url.isEmpty && argMap.isNotEmpty) {
          url = argMap["url"]?.toString() ?? "";
        }

        if (url.isEmpty) {
          return "";
        }

        options.method = argMap["method"]?.toString() ?? "GET";

        Map<String, String> defaultHeaders = {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59'
        };

        argMap["headers"] ??= {};

        argMap["noCache"] ??= false;

        var bodyType = argMap["bodyType"] ?? "json";

        if (bodyType == "form") {
          defaultHeaders["Content-Type"] = "application/x-www-form-urlencoded";
        } else {
          defaultHeaders["Content-Type"] = "application/json";
        }

        if ((argMap["headers"] as Map).isNotEmpty) {
          var customHeaders = Map<String, String>.from(argMap["headers"]);
          defaultHeaders.addAll(customHeaders);
        }

        options.headers = defaultHeaders;

        if (bodyType == "form") {
          if (argMap["data"] is Map) {
            argMap["data"] = FormData.fromMap(argMap["data"]);
          }
        }

        if (argMap["noCache"] == true) {
          options = options.withNoCache();
        }

        var result = "";
        try {
          var resp = await XHttp.dio.request(
            url,
            options: options,
            data: argMap["data"],
            queryParameters: argMap["params"],
          );
          result = resp.data?.toString() ?? "";
        } catch (e) {
          // TODO(d1y): handle error
          debugPrint(e.toString());
        }
        return result;
      }
      return "";
    });
  }

  Future<void> _installCheerio() async {
    var result = await rootBundle.loadString(
      'packages/xi/assets/js/kitty.umd.js',
    );
    _runtime.evaluate("var window = global = globalThis;");
    _runtime.evaluate(result);
  }

  String eval(String code) {
    var result = _runtime.evaluate(code);
    return result.stringResult;
  }

  /// 在 JSCore 中似乎可以直接返回一个正确的序列化JSON
  /// 但是在 quickjs 中它会返回一个错误的序列化
  /// 例: [data: 你好]
  Future<String> _fixJSONStringify(JsEvalResult promise) async {
    // JScore
    if (Platform.isIOS || Platform.isMacOS) {
      return promise.stringResult;
    }
    // QuickJS
    var data = await promise.rawResult;
    var strResult = jsonEncode(data);
    return strResult;
  }

  Future<String> evalSync(String code, {Duration? timeout}) async {
    var result = await _runtime.evaluateAsync(code);
    var promise = await _runtime.handlePromise(result, timeout: timeout);
    return _fixJSONStringify(promise);
  }
}

var js2 = JS2();

```

#### 📄 `lib/utils\json.dart`

```dart
var MAGIC_START_SYMBOL = [
  "[",
  "{",
];

var MAGIC_END_SYMBOL = [
  "]",
  "}",
];

enum JSONBodyType {
  /// 对象
  ///
  /// ```
  /// {}
  /// ```
  obj,

  /// 数组
  ///
  /// ```
  /// []
  /// ```
  array,
}

/// 获取 [json] 的类型
///
/// 使用 [verifyStringIsJSON] 判断是否是 [json] 字符串
JSONBodyType? getJSONBodyType(String data) {
  data = data.trim();
  if (data.startsWith(MAGIC_START_SYMBOL[0])) {
    return JSONBodyType.array;
  } else if (data.startsWith(MAGIC_START_SYMBOL[1])) {
    return JSONBodyType.obj;
  } else {
    return null;
  }
}

/// 用最二逼的方式校验是否是正确的`json`格式
///
/// [vJSON] 待校验的json字符串
///
/// [return] 是否是正确的json格式
bool verifyStringIsJSON(String vJSON) {
  var target = vJSON.trim();
  String start = target[0];
  String end = target[target.length - 1];
  return [0, 1].any((index) {
    bool startFlag = MAGIC_START_SYMBOL[index] == start;
    bool endFlag = MAGIC_END_SYMBOL[index] == end;
    return startFlag && endFlag;
  });
}

```

#### 📄 `lib/utils\maccms.dart`

```dart
import '../adapters/mac_cms.dart';
import '../interface.dart';
import 'helper.dart';

/// 将 [VideoInfo] 转换为 [Videos]
/// 单个 [VideoInfo] 格式参考:
/// - name: 源分类集合
/// - url: 多个视频播放地址, 通过 `.split("#").split("$")`
///        > 其中 [0] 为名称, [1] 为视频地址
List<Videos> videoInfo2RealVideos(List<VideoInfo> cx) {
  List<Videos> result = [];
  for (var element in cx) {
    var url = element.url;
    var hasUrl = isURL(url);
    if (hasUrl) {
      var output = [element];
      result.add(Videos(title: element.name, datas: []));
      var urls = url.split("#");
      if (urls.length >= 2) {
        output = urls
            .map(
              (e) => VideoInfo(
                url: e,
                type: MacCMSSpider.easyGetVideoType(e),
              ),
            )
            .toList();
      }
      result.last.datas.addAll(output);
    } else {
      var movies = url.split("#");
      var cache = Videos(title: element.name, datas: []);
      for (var e in movies) {
        var subItem = e.split("\$");
        if (subItem.length <= 1) continue;
        var title = subItem[0];
        var url = subItem[1];
        // var subType = subItem[2];
        cache.datas.add(VideoInfo(
          name: title,
          url: url,
          type: MacCMSSpider.easyGetVideoType(url),
        ));
      }
      result.add(cache);
    }
  }
  result = result.where((element) {
    return element.datas.isNotEmpty;
  }).toList();
  return result;
}

```

#### 📄 `lib/utils\path.dart`

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

///文件路径工具类
class PathUtils {
  PathUtils._internal();

  ///获取缓存目录路径
  static Future<String> getCacheDirPath() async {
    Directory directory = await getTemporaryDirectory();
    return directory.path;
  }

  ///获取文件缓存目录路径
  static Future<String> getFilesDirPath() async {
    Directory directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  ///获取文档存储目录路径
  static Future<String> getDocumentsDirPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

```

#### 📄 `lib/utils\source.dart`

```dart
import 'package:flutter/material.dart';
import 'package:xi/xi.dart';

class SourceUtils {
  /// [rawString] 从输入框拿到值
  /// 1. 去除`\n`行
  /// 2. 如果不是 `url` 也不需要
  static List<String> getSources(String rawString) {
    var spList = rawString.split("\n");
    return spList.map((e) => e.trim()).toList().where((item) {
      var flag = (item.isNotEmpty && isURL(item));
      return flag;
    }).toList();
  }

  static ISpiderAdapter? parse(Map<String, dynamic> rawData) {
    List<dynamic> tryData = tryParseData(rawData);
    bool status = tryData[0];
    if (status) {
      var data = tryData[1] as Map<String, dynamic>;
      var sourceType = _getSourceType(data);
      Map<String, dynamic> extraMap = {
        'jiexiUrl': data['jiexiUrl'] ?? '',
        'gfw': data['gfw'] ?? false,
        'searchLimit': _getSearchLimit(data, sourceType),
      };

      // 如果有 template 配置，添加到 extra 中
      if (data['template'] != null) {
        extraMap['template'] = data['template'];
      }

      // 如果有 JS 配置，添加到 extra 中
      if (data['js'] != null) {
        extraMap['js'] = data['js'];
      }

      var meta = SourceMeta(
        id: data['id'] ?? Xid().toString(),
        name: data['name'] ?? "",
        type: sourceType,
        api: data['api'] ?? "",
        logo: data['logo'] ?? "",
        desc: data['desc'] ?? "",
        status: data['status'] ?? true,
        isNsfw: data['nsfw'] ?? false,
        extra: extraMap,
      );

      switch (sourceType) {
        case SourceType.universal:
          return UniversalSpider(meta);
        case SourceType.maccms:
          return MacCMSSpider(meta);
      }
    } else {
      return null;
    }
  }

  static int _getSearchLimit(Map<String, dynamic> data, SourceType sourceType) {
    // 如果数据中明确指定了 searchLimit，使用指定值
    if (data.containsKey('searchLimit') && data['searchLimit'] is int) {
      return data['searchLimit'] as int;
    }
    // 根据源类型设置默认值
    return sourceType == SourceType.universal ? 10 : 20;
  }

  static SourceType _getSourceType(Map<String, dynamic> data) {
    if (data.containsKey('type')) {
      var typeStr = data['type'].toString().toLowerCase();
      if (typeStr == 'universal' || typeStr == '1') {
        return SourceType.universal;
      }
    }
    return SourceType.maccms;
  }

  /// 返回一个数组
  ///
  /// ```js
  /// [
  ///   status: bool,
  ///   data: Map<String, dynamic>
  /// ]
  /// ```
  static List<dynamic> tryParseData(Map<String, dynamic> rawData) {
    String? name = rawData['name'];
    bool hasName = name != null;
    var api = rawData['api'];
    String id = rawData['id'] ?? Xid().toString();

    // 从 extra 中获取 jiexiUrl、gfw、searchLimit 和 template
    var extra = rawData['extra'] as Map<String, dynamic>? ?? {};
    var jiexiUrl = extra['jiexiUrl'];
    var gfw = extra['gfw'];
    var searchLimit = extra['searchLimit'];
    var template = extra['template'];
    var js = extra['js'];

    String apiUrl = '';
    if (api is String) {
      apiUrl = api;
    } else if (api is Map<String, dynamic>) {
      apiUrl = '${api['root'] ?? ''}${api['path'] ?? ''}';
    }
    if (apiUrl.isEmpty) return [false, null];

    if (hasName) {
      bool isNsfw = false;
      if ((rawData['group'] ?? "") == "18禁") {
        isNsfw = true;
      }
      if (rawData['nsfw'] ?? false) {
        isNsfw = true;
      }
      var data = {
        'id': id,
        'name': name,
        'logo': rawData["logo"] ?? "",
        'desc': rawData["desc"] ?? "",
        'nsfw': isNsfw,
        'jiexiUrl': jiexiUrl,
        'gfw': gfw,
        'searchLimit': searchLimit,
        'template': template,
        'api': apiUrl,
        'status': rawData['status'] ?? true,
        'type': rawData['type'],
        'js': js,
      };
      return [true, data];
    }
    return [false, null];
  }

  /// 解析数据
  ///
  /// [data] 为 [String] 转为
  ///
  /// [List<Map<String, dynamic>>] (并递归解析)
  ///
  /// [<Map<String, dynamic>>] (并递归解析)
  ///
  /// 返回值
  ///
  /// => [null]
  ///
  /// => [List<ISpiderAdapter>]
  ///
  /// => [ISpiderAdapter?]
  static dynamic tryParseDynamic(dynamic data) {
    if (data is String) {
      bool isJSON = verifyStringIsJSON(data);
      if (!isJSON) return null;
      var typeAs = getJSONBodyType(data);
      if (typeAs == null) return null;
      dynamic jsonData = jsonc.decode(data);
      if (typeAs == JSONBodyType.array) {
        List<dynamic> cache = jsonData as List<dynamic>;
        List<Map<String, dynamic>> cacheAsMap = cache.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
        return tryParseDynamic(cacheAsMap);
      } else {
        // 如果是对象, 则尝试解析 .data / .mirrors 节点
        var _rootKeys = ['mirrors', 'data'];
        var jsonDataAsMap = jsonData as Map<String, dynamic>;
        for (var key in _rootKeys) {
          if (jsonDataAsMap.containsKey(key)) {
            var cache = jsonDataAsMap[key];
            if (cache is List) {
              List<Map<String, dynamic>> cacheAsMapList = cache
                  .map((item) {
                    if (item is Map<String, dynamic>) return item;
                    return null;
                  })
                  .toList()
                  .where((element) {
                    return element != null;
                  })
                  .toList()
                  .map((e) {
                    return e as Map<String, dynamic>;
                  })
                  .toList();
              return tryParseDynamic(cacheAsMapList);
            }
          }
        }
        return tryParseDynamic(jsonDataAsMap);
      }
    } else if (data is List<Map<String, dynamic>>) {
      return data.map((item) {
        return tryParseDynamic(item);
      }).toList();
    } else if (data is Map<String, dynamic>) {
      var _tryData = parse(data);
      return _tryData;
    } else if (data is List) {
      return tryParseDynamic(data.map((e) {
        return e as Map<String, dynamic>;
      }).toList());
    }
    return null;
  }

  /// 加载网络源
  static Future<List<ISpiderAdapter>> runTaks(List<String> sources) async {
    List<ISpiderAdapter> result = [];
    await Future.forEach(sources, (String element) async {
      debugPrint("加载网络源: $element");
      try {
        var time = const Duration(seconds: 9 /* 秒 */);
        var resp = await XHttp.dio.get(
          element,
          options: Options(
            responseType: ResponseType.plain,
            receiveTimeout: time,
            sendTimeout: time,
          ).withNoCache(),
        );
        dynamic respData = resp.data;
        var data = tryParseDynamic(respData);
        if (data == null) return;
        if (data is ISpiderAdapter) {
          result.add(data);
        } else if (data is List) {
          var append = data
              .where((element) {
                return element != null;
              })
              .toList()
              .map((ele) {
                return ele as ISpiderAdapter;
              })
              .toList();
          result.addAll(append);
        }
      } catch (e) {
        debugPrint("获取网络源失败: $e");
        return null;
      }
    });
    return result;
  }

  /// 合并资源
  ///
  /// [diff] 时返回
  ///
  /// => [len, List<Map<String, dynamic>>]
  ///
  /// => [List<Map<String, dynamic>>]
  @Deprecated("REMOVE THIS")
  static dynamic mergeMirror(
    List<ISpiderAdapter> extend,
    List<ISpiderAdapter> newSourceData, {
    /// diff 是为了返回增加的源源量
    bool diff = false,

    /// cover 是为了覆盖
    bool cover = false,
  }) {
    int len = extend.length;

    if (!cover) {
      for (var element in newSourceData) {
        var newDataApi = element.meta.api;
        extend.removeWhere(
          (element) => element.meta.api == newDataApi,
        );
      }
      extend.addAll(newSourceData);
    } else {
      extend.clear();
      extend.addAll(newSourceData);
    }

    int newLen = extend.length;

    /// 如果比对之后发现没有改变, 则返回 [0, []]
    if (newLen <= 0 && diff) return [0, []];

    var copyData = extend.map(
      (e) {
        return {
          'name': e.meta.name,
          'logo': e.meta.logo,
          'desc': e.meta.desc,
          'nsfw': e.meta.isNsfw,
          'jiexiUrl': e.meta.extra['jiexiUrl'] ?? '',
          'gfw': e.meta.extra['gfw'] ?? false,
          'api': e.meta.api,
          'id': e.meta.id,
          'status': e.meta.status,
          'type': e.meta.type.name,
        };
      },
    ).toList();
    if (diff) {
      return [newLen - len, copyData];
    }
    return copyData;
  }
}

```

#### 📄 `lib/utils\utils.dart`

```dart
export 'helper.dart';
export 'http.dart';
export 'json.dart';
export 'path.dart';
export 'source.dart';
export 'xid.dart';
export 'maccms.dart';
export 'js2.dart';

```

#### 📄 `lib/utils\xid.dart`

```dart
// The lib copy by: https://github.com/pitabwire/xid

import 'dart:math';

import "dart:typed_data";

const String _base32Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUV";

String base32encode(List<int> input) {
  Uint8List bytes = input is Uint8List ? input : Uint8List.fromList(input);
  int i = 0, index = 0, digit = 0;
  int currByte, nextByte;
  StringBuffer base32 = StringBuffer();

  while (i < bytes.length) {
    currByte = (bytes[i] >= 0) ? bytes[i] : (bytes[i] + 256);

    if (index > 3) {
      if ((i + 1) < bytes.length) {
        nextByte = (bytes[i + 1] >= 0) ? bytes[i + 1] : (bytes[i + 1] + 256);
      } else {
        nextByte = 0;
      }

      digit = currByte & (0xFF >> index);
      index = (index + 5) % 8;
      digit <<= index;
      digit |= nextByte >> (8 - index);
      i++;
    } else {
      digit = (currByte >> (8 - (index + 5)) & 0x1F);
      index = (index + 5) % 8;
      if (index == 0) {
        i++;
      }
    }
    base32.write(_base32Chars[digit]);
  }
  return base32.toString();
}

const List<int> _base32Lookup = [
  0x00,
  0x01,
  0x02,
  0x03,
  0x04,
  0x05,
  0x06,
  0x07,
  // '0', '1', '2', '3', '4', '5', '6', '7'
  0x08,
  0x09,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // '8', '9', ':', ';', '<', '=', '>', '?'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  // 'X', 'Y', 'Z', '[', '\', ']', '^', '_'
  0xFF,
  0x0A,
  0x0B,
  0x0C,
  0x0D,
  0x0E,
  0x0F,
  0x10,
  // '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g'
  0x11,
  0x12,
  0x13,
  0x14,
  0x15,
  0x16,
  0x17,
  0x18,
  // 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o'
  0x19,
  0x1A,
  0x1B,
  0x1C,
  0x1D,
  0x1E,
  0x1F,
  0xFF,
  // 'p', 'q', 'r', 's', 't', 'u', 'v', 'w'
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF,
  0xFF
  // 'x', 'y', 'z', '{', '|', '}', '~', 'DEL'
];

List<int> base32decode(String input) {
  int index = 0, lookup, offset = 0, digit;
  Uint8List bytes = Uint8List(input.length * 5 ~/ 8);

  for (int i = 0; i < input.length; i++) {
    lookup = input.codeUnitAt(i) - 48;
    if (lookup < 0 || lookup >= _base32Lookup.length) continue;

    digit = _base32Lookup[lookup];
    if (digit == 0xFF) continue;

    if (index <= 3) {
      index = (index + 5) % 8;
      if (index == 0) {
        bytes[offset] |= digit;
        offset++;
        if (offset >= bytes.length) break;
      } else {
        bytes[offset] |= digit << (8 - index);
      }
    } else {
      index = (index + 5) % 8;
      bytes[offset] |= (digit >> index);
      offset++;

      if (offset >= bytes.length) break;

      bytes[offset] |= digit << (8 - index);
    }
  }
  return bytes;
}

class InvalidXidException implements Exception {}

const String _allChars = "0123456789abcdefghijklmnopqrstuv";

///
/// A globally unique identifier for objects.
///
/// <p>Consists of 12 bytes, divided as follows:</p>
///  <table border="1">
///   <caption>layout</caption>
///   <tr><td>0</td><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td><td>11</td></tr>
///   <tr><td colspan="4">time</td><td colspan="5">random value</td><td colspan="3">inc</td></tr>
/// </table>
///
///  Instances of this class are immutable.
///
class Xid {
  static String? _machineId;
  static int? _processId;
  static int? _counterInt;

  List<int>? _xidBytes;

  /// Creates a new instance of xid
  Xid() {
    _generateXid();
  }

  ///
  /// Constructs a new instance of xid from the given a string of xid
  /// throws InvalidXidException if the string supplied is not a valid xid
  Xid.fromString(String newXid) {
    if (!_isValid(newXid)) {
      throw InvalidXidException();
    }
    _xidBytes = _toBytes(newXid);
  }

  String _toHexString() {
    return base32encode(_xidBytes!);
  }

  List<int> _toBytes(String xid) {
    return base32decode(xid);
  }

  /// Creates and returns a new instance of xid
  static Xid get() {
    return Xid();
  }

  /// Creates a new instance of xid and returns the string representation
  static String string() {
    return get().toString();
  }

  bool _isValid(String xid) {
    if (xid.length != 20) {
      return false;
    }

    var allowedChars = _allChars.split('');

    for (int i = 0; i < xid.length; i++) {
      var c = xid[i];
      if (allowedChars.contains(c)) {
        continue;
      }

      return false;
    }

    return true;
  }

  List<int> _getMachineId() {
    if (_machineId != null) {
      return _toBytes(_machineId!);
    }

    _processId = Random.secure().nextInt(4194304);
    _machineId = Random.secure().nextInt(5170000).toString();
    return _toBytes(_machineId!);
  }

  static int _counter() {
    _counterInt ??= Random.secure().nextInt(16777215);
    _counterInt = _counterInt! + 1;

    return _counterInt!;
  }

  String _generateXid() {
    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var counter = _counter();
    var machineID = _getMachineId();

    _xidBytes = List.filled(20, 0, growable: false);

    _xidBytes![0] = (now >> 24) & 0xff;
    _xidBytes![1] = (now >> 16) & 0xff;
    _xidBytes![2] = (now >> 8) & 0xff;
    _xidBytes![3] = (now) & 0xff;

    _xidBytes![4] = machineID[0];
    _xidBytes![5] = machineID[1];
    _xidBytes![6] = machineID[2];

    _xidBytes![7] = (_processId! >> 8) & 0xff;
    _xidBytes![8] = (_processId!) & 0xff;

    _xidBytes![9] = (counter >> 16) & 0xff;
    _xidBytes![10] = (counter >> 8) & 0xff;
    _xidBytes![11] = (counter) & 0xff;

    return _toHexString();
  }

  @override
  String toString() {
    return _toHexString().toLowerCase().substring(0, 20);
  }

  /// Returns the byte representation of the current xid instance
  List<int> toBytes() {
    return [...?_xidBytes];
  }
}

```

