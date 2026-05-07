# 小故事 - 儿童中国传统故事 App

一个专为小朋友设计的中国传统故事App，包含50个经典故事，支持音频播放和文本同步阅读。

## 功能特性

- 个性化：启动时输入小朋友名字，所有故事开场白会称呼小朋友
- 50个中国传统故事：神话传说、历史故事、民间故事、节日传说、寓言智慧
- TTS开场白：每个故事开始前用童声朗读入场词
- 音频播放：完整故事音频，支持播放/暂停/快进快退/音量调节
- 文本同步：故事文字随音频同步展示
- 分类筛选：按故事类型筛选浏览
- 收藏功能：标记喜欢的故事
- 搜索：按故事名搜索
- 离线可用：全部数据本地存储

## 技术栈

- Flutter 3.x (Dart)
- just_audio (音频播放)
- flutter_tts (TTS开场白)
- shared_preferences (本地存储)
- provider (状态管理)

## 项目结构

```
chinese_stories_app/
├── lib/
│   ├── main.dart              # App入口
│   ├── models/
│   │   └── story.dart         # 故事数据模型
│   ├── screens/
│   │   ├── welcome_screen.dart     # 欢迎页（输入名字）
│   │   ├── home_screen.dart        # 主页（故事列表）
│   │   └── story_player_screen.dart # 播放页（音频+文本）
│   ├── services/
│   │   ├── audio_service.dart  # 音频播放服务
│   │   ├── tts_service.dart    # TTS语音服务
│   │   └── storage_service.dart # 本地存储服务
│   ├── providers/
│   │   └── app_provider.dart   # 全局状态管理
│   └── widgets/
│       └── story_card.dart     # 故事卡片组件
├── stories/                    # 50个故事JSON + 索引
├── audio/                      # 50个MP3音频文件
├── android/                    # Android配置
├── pubspec.yaml                # 依赖配置
└── README.md
```

## 构建和运行

### 前置条件

1. 安装 Flutter SDK (>=3.0.0)
2. 安装 Android Studio / Xcode
3. 配置 Android SDK

### 安装依赖

```bash
cd chinese_stories_app
flutter pub get
```

### 运行开发版本

```bash
flutter run
```

### 构建APK

```bash
flutter build apk --release
```

APK位置：`build/app/outputs/flutter-apk/app-release.apk`

### 构建iOS

```bash
flutter build ios --release
```

## 安装到手机

1. 将 `app-release.apk` 传输到安卓手机
2. 在手机上打开「设置」→「安全」→ 允许安装未知来源应用
3. 点击APK文件安装

## 鸿蒙系统 (HarmonyOS) 适配

### 方案一：通过安卓兼容层运行（推荐）

鸿蒙系统支持运行安卓APK，直接将 `app-release.apk` 安装到鸿蒙手机即可使用。

### 方案二：使用 Flutter OHOS

对于原生鸿蒙适配（NEXT版本），可使用 `flutter_ohos` 插件：

```bash
# 克隆 Flutter OHOS 分支
git clone https://gitee.com/openharmony-sig/flutter_flutter.git

# 创建 OHOS 模块
flutter create --platforms ohos .

# 构建 HAP
flutter build hap --release
```

详细的鸿蒙适配文档: https://gitee.com/openharmony-sig/flutter_flutter

## 后续可扩展功能

- 夜间模式：睡前故事专用暗色主题
- 定时关闭：设定播放时长后自动停止
- 家长控制：设置每日收听时长限制
- 录音功能：家长录制自己的故事版本
- 分享功能：分享喜欢的故事给朋友
- 多语言：英文版中国传统故事
- 动画效果：故事文本中的角色动画
- 互动问答：故事后的趣味小测验
- 云端同步：跨设备同步收藏和进度
- 个性化推荐：根据收听记录推荐故事
