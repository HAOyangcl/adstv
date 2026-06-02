# Flutter 项目 lib 目录代码导出

> 自动生成的项目代码文档，按目录结构整理

## 📂 lib/

#### 📄 `lib/intent.dart`

```dart
import 'package:flutter/widgets.dart';

class ScrollDownIntent extends Intent {}

class ScrollUpIntent extends Intent {}

class CategoryNextIntent extends Intent {}

class CategoryPrevIntent extends Intent {}

class MirrorTableIntent extends Intent {}
```

#### 📄 `lib/utils.dart`

```dart
import 'package:flutter/widgets.dart';

const kScrollDuration = Duration(milliseconds: 420);
const kScrollSize = 240;

void scrollUp(ScrollController cx) {
  var curr = cx.offset;
  if (curr == 0) return;
  var exec = curr - kScrollSize;
  if (exec < 0) exec = 0;
  cx.animateTo(exec, duration: kScrollDuration, curve: Curves.ease);
}

void scrollDown(ScrollController cx) {
  var curr = cx.offset;
  var max = cx.position.maxScrollExtent;
  if (curr == max) return;
  var exec = curr + kScrollSize;
  if (exec > max) exec = max;
  cx.animateTo(exec, duration: kScrollDuration, curve: Curves.ease);
}

```

#### 📄 `lib/x.dart`

```dart
library;

export 'intent.dart';
export 'utils.dart';

```

