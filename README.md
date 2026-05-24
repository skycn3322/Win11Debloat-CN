**[简体中文]** [[English]](README-EN.md)

# Win11Debloat

[![GitHub 发行版](https://img.shields.io/github/v/release/Raphire/Win11Debloat?style=for-the-badge&label=最新版本)](https://github.com/Raphire/Win11Debloat/releases/latest)
[![加入讨论](https://img.shields.io/badge/加入讨论-2D9F2D?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Raphire/Win11Debloat/discussions)
[![静态徽章](https://img.shields.io/badge/文档-_?style=for-the-badge&logo=bookstack&color=grey)](https://github.com/Raphire/Win11Debloat/wiki/)

Win11Debloat 是一个轻量级、易于使用的 PowerShell 脚本，可让您快速清理和自定义 Windows 体验。它可以移除预装的膨胀软件、禁用遥测功能、移除烦人的界面元素等等。无需自己费力地逐一调整所有设置或逐个卸载应用。Win11Debloat 让整个过程变得快速而简单！

该脚本还包含许多系统管理员和高级用户会喜欢的功能。例如强大的命令行界面、支持 Windows 审核模式以及可对其他 Windows 用户进行更改的选项。更多详情请参阅我们的 [wiki](https://github.com/Raphire/Win11Debloat/wiki/)。

![Win11Debloat 菜单](/Assets/Images/menu.png)

#### 这个脚本对您有帮助吗？请考虑请我喝杯咖啡，支持我的工作

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M5C6UPC)

## 使用方法

> [!警告]
> 我们已尽力确保此脚本不会无意中破坏任何操作系统功能，但使用风险自负！如果您遇到任何问题，请在此处 [报告](https://github.com/Raphire/Win11Debloat/issues)。

### 快速方法

通过 PowerShell 自动下载并运行脚本。

1.  打开 PowerShell 或终端，最好以管理员身份运行。
2.  将以下命令复制并粘贴到 PowerShell 中：

```PowerShell
& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))
```

3.  等待脚本自动下载 Win11Debloat。
4.  仔细阅读并按照屏幕上的说明操作。

此方法支持命令行参数以自定义脚本行为。更多信息请点击 [此处](https://github.com/Raphire/Win11Debloat/wiki/Command%E2%80%90line-Interface#parameters)。

### 传统方法

<details>
  <summary>手动下载并运行脚本。</summary><br/>

  1.  [下载最新版本的脚本](https://github.com/Raphire/Win11Debloat/releases/latest)，并将 .ZIP 文件解压到您想要的位置。
  2.  导航到 Win11Debloat 文件夹。
  3.  双击 `Run.bat` 文件启动脚本。注意：如果控制台窗口立即关闭且没有任何反应，请尝试下面的高级方法。
  4.  接受 Windows UAC 提示，以管理员身份运行脚本，这是脚本正常运行所必需的。
  5.  仔细阅读并按照屏幕上的说明操作。
</details>

### 高级方法

<details>
  <summary>手动下载脚本并通过 PowerShell 运行。推荐给高级用户。</summary><br/>

  1.  [下载最新版本的脚本](https://github.com/Raphire/Win11Debloat/releases/latest)，并将 .ZIP 文件解压到您想要的位置。
  2.  以管理员身份打开 PowerShell 或终端。
  3.  通过输入以下命令临时启用 PowerShell 执行：

  ```PowerShell
  Set-ExecutionPolicy Unrestricted -Scope Process -Force
  ```

  4.  在 PowerShell 中，导航到文件解压的目录。例如：`cd c:\Win11Debloat`
  5.  现在通过输入以下命令运行脚本：

  ```PowerShell
  .\Win11Debloat.ps1
  ```

  6.  仔细阅读并按照屏幕上的说明操作。

  此方法支持命令行参数以自定义脚本行为。更多信息请点击 [此处](https://github.com/Raphire/Win11Debloat/wiki/Command%E2%80%90line-Interface#parameters)。
</details>

## 功能特性

以下是 Win11Debloat 提供的主要功能和特性概述。有关默认设置预设的更多信息，请参阅 [wiki](https://github.com/Raphire/Win11Debloat/wiki/Default-Settings)。

> [!提示]
> Win11Debloat 所做的所有更改都可以轻松还原，并且几乎所有应用都可以通过 Microsoft Store 重新安装。如何还原更改的完整指南可以在此处 [找到](https://github.com/Raphire/Win11Debloat/wiki/Reverting-Changes)。

#### 应用移除

-   移除各种预装应用。点击 [此处](https://github.com/Raphire/Win11Debloat/wiki/App-Removal) 获取更多信息。

#### 隐私与推荐内容

-   禁用遥测、诊断数据、活动历史记录、应用启动跟踪和定向广告。
-   在 Windows 各处禁用提示、技巧、建议和广告。
-   禁用 Windows 位置服务和应用位置访问。
-   禁用“查找我的设备”位置跟踪。
-   禁用锁屏上的“Windows 聚焦”和提示与技巧。
-   禁用桌面背景的“Windows 聚焦”选项。
-   在 Microsoft Edge 中禁用广告、建议和 MSN 新闻源。
-   在设置“主页”页面上隐藏 Microsoft 365 广告，或完全隐藏“主页”页面。

#### AI 功能

-   禁用并移除 Microsoft Copilot。
-   禁用 Windows Recall。
-   禁用“点击执行”AI 文本和图像分析工具。
-   防止 AI 服务 (WSAIFabricSvc) 自动启动。
-   禁用 Edge 中的 AI 功能。
-   禁用画图中的 AI 功能。
-   禁用记事本中的 AI 功能。

#### 系统

-   禁用用于共享和移动文件的“拖放”托盘。
-   恢复旧的 Windows 10 样式右键菜单。
-   关闭“增强指针精确度”，也称为鼠标加速。
-   禁用粘滞键键盘快捷键。
-   禁用存储感知自动磁盘清理。
-   禁用快速启动以确保完全关机。
-   禁用 BitLocker 自动设备加密。
-   在现代待机期间禁用网络连接以减少电池消耗。

#### Windows 更新

-   防止 Windows 在更新可用时立即获取。
-   防止登录时更新后自动重启。
-   禁用与其他 PC 共享已下载的更新，也称为传递优化。

#### 外观

-   为系统和应用启用深色模式。
-   禁用透明效果。
-   禁用动画和视觉效果。

#### 开始菜单和搜索

-   从开始菜单中移除或替换所有固定应用。
-   隐藏开始菜单中的推荐部分。
-   隐藏开始菜单中的“所有应用”部分。
-   禁用开始菜单中的“手机连接”移动设备集成。
-   在 Windows 搜索中禁用必应网络搜索和 Copilot 集成。
-   在 Windows 搜索中禁用 Microsoft Store 应用建议。
-   在任务栏搜索框中禁用搜索亮点（动态/品牌内容）。
-   禁用本地 Windows 搜索历史记录。

#### 任务栏

-   将任务栏图标左对齐。
-   隐藏或更改任务栏上的搜索图标/框。
-   从任务栏隐藏任务视图按钮。
-   禁用任务栏和锁屏上的小组件。
-   从任务栏隐藏聊天（meet now）图标。
-   在任务栏右键菜单中启用“结束任务”选项。
-   在任务栏应用区域启用“最后活动点击”行为。这允许您重复单击任务栏中应用程序的图标，在该应用程序的打开窗口之间切换焦点。
-   选择在使用多个显示器时如何在任务栏上显示应用图标。
-   选择任务栏按钮和标签的组合模式。

#### 文件资源管理器

-   更改文件资源管理器打开时的默认位置。
-   显示已知文件类型的文件扩展名。
-   显示隐藏的文件、文件夹和驱动器。
-   从文件资源管理器导航窗格中隐藏“主页”或“图库”部分。
-   从文件资源管理器导航窗格中隐藏重复的可移动驱动器条目，只保留“此电脑”下的条目。
-   将所有常用文件夹（桌面、下载等）重新添加回文件资源管理器中的“此电脑”。
-   从文件资源管理器导航窗格中隐藏 3D 对象、音乐或 OneDrive 文件夹。
-   从右键菜单中隐藏“包含到库中”、“授予访问权限”和“共享”选项。
-   更改文件资源管理器中驱动器盘符的显示位置或可见性。

#### 多任务处理

-   禁用窗口贴靠。
-   在贴靠窗口时禁用贴靠辅助建议。
-   在将窗口拖动到屏幕顶部以及悬停在最大化按钮上时禁用贴靠布局建议。
-   更改贴靠窗口或按 Alt+Tab 时是否显示标签页。

#### 可选 Windows 功能

-   启用 Windows 沙盒，这是一个轻量级桌面环境，用于安全地隔离运行应用程序。
-   启用适用于 Linux 的 Windows 子系统，允许您直接在 Windows 上运行 Linux 环境。

#### 其他

-   禁用 Xbox 游戏栏集成和游戏/屏幕录制。如果您卸载了 Xbox 游戏栏，这也会禁用 `ms-gamingoverlay`/`ms-gamebar` 弹窗。
-   禁用 Brave 浏览器中的膨胀功能（AI、加密、新闻等）。

#### 高级功能

-   选项 [将更改应用到其他用户](https://github.com/Raphire/Win11Debloat/wiki/Advanced-Features#running-as-another-user)，而不是当前登录的用户。
-   [Sysprep 模式](https://github.com/Raphire/Win11Debloat/wiki/Advanced-Features#sysprep-mode)，将更改应用到 Windows 默认用户配置文件。这确保所有新用户都将自动应用这些更改。

## 贡献

我们欢迎各种形式的贡献！请参阅我们的 [贡献指南](/.github/CONTRIBUTING.md)，了解如何开始的详细说明以及贡献的最佳实践。

## 许可证

Win11Debloat 采用 MIT 许可证。更多信息请参阅 LICENSE 文件。
