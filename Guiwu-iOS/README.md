# 归物 · Guiwu

SwiftUI 本地物品成本记录 App，支持 iOS 17 及以上。无第三方依赖，无联网功能。

## Windows + iPhone 安装流程

1. 将本项目的内容放到 GitHub 仓库根目录，包括 `.github/workflows/build-ios.yml`。
2. 打开仓库 **Actions → Build Guiwu IPA**。提交 main/master 分支后会自动编译，也可以点击 **Run workflow** 手动运行。
3. 等任务成功后，在该次任务页面底部 **Artifacts** 下载 `Guiwu-unsigned-IPA`，解压得到 `Guiwu-unsigned.ipa`。
4. 在 Windows 安装 [Sideloadly](https://sideloadly.io/)，按照其官方要求安装 Apple 设备连接组件。
5. 用数据线连接 iPhone，解锁并在手机上选择信任电脑。
6. 将 IPA 拖入 Sideloadly，选择手机，在你自己的电脑上输入 Apple 账号进行签名安装。
7. 若系统提示，按提示在 iPhone 设置中信任开发者，并开启开发者模式。不同 iOS 版本的提示顺序可能不同。

**这个 IPA 是待签名产物，不能从 Safari 下载后直接点开安装。**

普通免费 Apple 账号签名通常只有 7 天有效期；Sideloadly 支持在手机可通过 USB 或同一 Wi-Fi 访问时自动刷新签名。无需把 Apple 密码、验证码或证书发送给任何人，也不要上传到仓库。

更新或刷新时保持相同 Apple 账号和 Bundle ID，覆盖安装以保留数据。**不要先卸载归物**，卸载会清除 App 内的本地物品记录。

GitHub Actions 的可用额度与仓库可见性、账号套餐及账单设置有关；请以 GitHub 账号页面为准。本项目不配置付费运行器。

## 本地 Xcode

打开 `Guiwu.xcodeproj`，选择 Guiwu scheme，配置自己的 Signing Team 后运行。

## 功能与计算

- 添加物品：Emoji、名称、分类、整数人民币金额、购买日期。
- 首页：总投入、日均成本合计、分类筛选、物品列表、空状态。
- 详情页及编辑，保存成功后同步更新。
- 购买当天计为第 1 天；按本地日历计算持有天数；每分钟更新显示。
- 单件日均成本 = 购买金额 / 持有天数。
- 总日均成本 = 未格式化的单件日均成本之和；最终显示四舍五入到两位小数。
- 本地 Application Support/Guiwu/items.json，原子写入；读取异常时保留原文件。

## 构建状态

本项目在 Windows 环境准备。云端编译是否成功，请以 Actions 的实际结果为准；尚未完成真机测试。

## 官方参考

- https://docs.github.com/en/actions/concepts/runners/github-hosted-runners
- https://developer.apple.com/help/account/basics/about-your-developer-account/
- https://sideloadly.io/faq.html
