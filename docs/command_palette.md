# 命令面板功能说明

## 概述

命令面板是一个快速访问应用功能的界面，类似于 VS Code 的命令面板或 macOS 的 Spotlight。

## 使用方法

### 快捷键

- **Windows/Linux**: `Ctrl + K`
- **macOS**: `Cmd + K`

### 键盘操作

- `↑` / `↓`: 上下选择命令
- `Enter`: 执行选中的命令
- `Esc`: 关闭命令面板

### 搜索功能

在输入框中输入关键词可以过滤命令列表，支持模糊匹配。

## 可用命令

### 导航类

1. **返回首页** - 快速跳转到首页
2. **电视直播** - 跳转到电视直播页面
3. **设置** - 跳转到设置页面

### 功能类

1. **切换成人模式** - 开启/关闭成人内容显示
2. **刷新首页** - 重新加载首页数据
3. **视频源管理** - 打开视频源管理表格

## 扩展命令

要添加新的命令，请在 `HomeController.showCommandPalette()` 方法中添加新的 `CommandPaletteItem`：

```dart
CommandPaletteItem(
  id: 'unique_id',           // 唯一标识
  label: '命令名称',          // 显示的名称
  subtitle: '命令描述',       // 可选的描述文字
  icon: Icons.example,        // 可选的图标
  keywords: ['关键词1', '关键词2'],  // 用于搜索的关键词
  onTap: () {
    // 执行的操作
  },
),
```

## 技术实现

- 组件位置: `lib/app/components/command_palette.dart`
- 控制器: `CommandPaletteController` (使用 GetX 状态管理)
- 集成位置: `lib/app/modules/home/controllers/home_controller.dart`
- 快捷键绑定: `lib/app/modules/home/views/home_view.dart`

## 注意事项

1. 命令面板使用 GetX 进行状态管理，确保在使用前已正确初始化
2. 所有命令项应该是无状态的，避免在命令中保存状态
3. 关键词应该包含中文和英文，以支持不同语言的搜索
