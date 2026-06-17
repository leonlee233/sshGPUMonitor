# Tasks

- [x] Task 1: 修复应用崩溃问题
  - [x] SubTask 1.1: 重写 GPUMonitorApp.swift 入口，使用 @NSApplicationDelegateAdaptor 确保 AppDelegate 生命周期正确
  - [x] SubTask 1.2: 移除 GPUMonitorViewModel 的 @MainActor 标注，改用 Timer + MainActor.run 确保线程安全
  - [x] SubTask 1.3: 修复 AppDelegate 中 statusItem.button 的 target/action 设置
  - [x] SubTask 1.4: 修复 ServerConfigView dismiss() 导致退出，改用 onClose 回调关闭窗口

- [x] Task 2: 修复菜单栏图标空白
  - [x] SubTask 2.1: 使用 emoji "🖥" 替代 SF Symbol 和自定义绘制图标

- [x] Task 3: 提高文字对比度
  - [x] SubTask 3.1: 更新 GPUBarView 中文字颜色为 .white，字号增大到 10
  - [x] SubTask 3.2: 更新 FloatingWindowController 和 MenuBarView 中文字颜色

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 1]
