# Tasks

- [x] Task 1: 重构 ServerConfigView 为服务器管理列表
  - [x] SubTask 1.1: 创建 ServerListView，显示所有服务器列表（名称 + host:port），每行有编辑和删除按钮
  - [x] SubTask 1.2: 列表底部添加 "+" 按钮弹出添加服务器表单
  - [x] SubTask 1.3: 编辑按钮弹出编辑表单（复用现有 ServerConfigView 表单）
  - [x] SubTask 1.4: 更新 AppDelegate.showServerConfig() 使用新窗口尺寸和 ServerListView

- [x] Task 2: 实现 SSH 错误弹窗
  - [x] SubTask 2.1: 在 GPUMonitorViewModel 中添加错误弹窗逻辑，使用 NotificationCenter 发送弹窗通知
  - [x] SubTask 2.2: 在 AppDelegate 中监听错误通知，弹出 NSAlert
  - [x] SubTask 2.3: 添加防重复弹窗逻辑：同一服务器仅弹一次，连接恢复后重置

# Task Dependencies
- [Task 2] depends on [Task 1] (ViewModel 改动需同步)
