# Alive MVP（Flutter，本地优先）

这是 Alive 的本地化 MVP：

- 无账号
- 无后端
- 不上传云端
- 事件卡片 + 日记/游记 + 回忆推荐
- 云相册兼容状态（`local`、`cloudOnly`、`missing`）

## 产品概念

Alive 不是传统“相册管理器”，而是一个本地优先的“回忆区”。

- 核心目标：把照片从“文件列表”变成“事件记忆”
- 体验重点：围绕事件卡片回忆、补写日记/游记、定期重温
- 隐私原则：不登录、不上传、离线可用
- 云相册策略：兼容系统云照片来源，但事件结构与文字始终保存在本地

一句话：**Alive 帮用户在手机上建立自己的记忆居所。**

## 功能理念

Alive 的产品设计围绕“回忆被看见、被记录、被重温”展开。

- 从照片到事件：不只展示图片，而是把同一段经历组织成可回看的事件卡片
- 从浏览到表达：每个事件都支持补写日记/游记，让回忆从素材变成故事
- 从整理到提醒：通过回忆推荐机制，提醒用户补完未记录的重要时刻
- 从在线依赖到本地掌控：核心体验不依赖账号和网络，默认在本机完成
- 从数据堆积到情绪价值：强调“生活体验的再感受”，而不是“文件管理效率”

这意味着 Alive 的重点不是“管理更多照片”，而是“帮助用户留住更完整的生活记忆”。

## 当前能力

- 回忆页：事件流 + 顶部推荐卡片
- 事件详情：可编辑标题与日记
- 收藏事件
- 时间线与足迹页（MVP 占位）
- 本地持久化：`shared_preferences`
- 设置项：模拟离线、仅推荐本地可查看事件

## 运行方式

```bash
flutter pub get
```

### 一键启动脚本

脚本文件：`run_alive.sh`

```bash
chmod +x run_alive.sh
```

参数说明：

- `ios`：启动 iOS 模拟器并运行 App
- `android`：启动 Android 模拟器并运行 App
- `both`：同时启动 iOS 和 Android（默认值）

自动探测逻辑：

- 若当前已有可用 iOS/Android 设备，直接运行
- 若无可用设备，脚本会自动从 `flutter emulators` 中选择对应平台的第一个模拟器并拉起

使用示例：

```bash
./run_alive.sh ios
./run_alive.sh android
./run_alive.sh both
```

不传参数时等价于：

```bash
./run_alive.sh both
```

脚本执行流程：

1. 自动检查 `flutter` 命令（或回退到 `$HOME/development/flutter/bin/flutter`）
2. 自动执行 `flutter pub get`
3. 根据参数拉起对应模拟器并执行 `flutter run`

注意事项：

- `both` 会在同一终端同时挂两个 `flutter run` 进程，按 `Ctrl + C` 可结束
- 若提示未找到可用模拟器，请先执行 `flutter emulators` 确认至少存在一个 iOS/Android 模拟器
- 若提示未找到 Flutter，请确认 PATH 或 Flutter 安装目录

### iOS

```bash
flutter run -d ios
```

### Android

```bash
flutter run -d android
```

如需查看可用设备：

```bash
flutter devices
```

## 兼容性说明

- 仅使用 Flutter SDK + `shared_preferences`，依赖简单，兼容性高。
- 云相册仅做“来源兼容”，不接第三方云账号，不做云同步。
- 事件结构与文字始终本地可用，离线时优先推荐本地可查看事件。

## 下一步建议

下一阶段可接入真实相册读取（如 `photo_manager`），将示例数据替换为系统相册分组结果，继续沿用现有事件与推荐模型。
