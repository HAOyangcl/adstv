import 'package:auto_injector/auto_injector.dart';
// TODO: WebView播放功能已重构，不再需要自动注入
// import 'package:catmovie/shared/webplayer_placeholder.dart';

final autoInjector = AutoInjector();

void registerAutoInjector() {
  // TODO: 添加其他需要自动注入的服务
  // autoInjector.addSingleton(WebPlayerEmbedded.new);
  autoInjector.commit();
}
