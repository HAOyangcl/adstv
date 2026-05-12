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
