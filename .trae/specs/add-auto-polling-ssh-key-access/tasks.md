# Tasks

- [x] Task 1: 实现 SSH 密钥文件 Security-Scoped Bookmark
  - [x] SubTask 1.1: 在 ServerConfig 中新增 keyBookmark: Data? 字段用于持久化 bookmark
  - [x] SubTask 1.2: 创建 KeyFileManager 类，封装 NSOpenPanel 选择密钥、创建/恢复 bookmark、获取密钥路径的逻辑
  - [x] SubTask 1.3: 修改 SSHManager，使用 KeyFileManager 获取密钥路径，通过 bookmark 访问文件
  - [x] SubTask 1.4: 修改 ServerConfigView，密钥选择改用 NSOpenPanel 按钮，替代手动输入路径

- [x] Task 2: 实现自动轮询多服务器
  - [x] SubTask 2.1: 在 GPUMonitorViewModel 中新增 autoPolling 模式和 pollInterval 属性
  - [x] SubTask 2.2: 实现轮询逻辑：依次遍历所有服务器，每台停留 pollInterval 秒后切换下一台
  - [x] SubTask 2.3: 轮询切换时更新 selectedServerId 和 UI，显示当前服务器名称
  - [x] SubTask 2.4: 新增 startAutoPolling() / stopAutoPolling() 方法

- [x] Task 3: 更新 UI 支持轮询控制和间隔设置
  - [x] SubTask 3.1: MenuBarPopoverView 和 FloatingWindowContent 中新增自动轮询开关按钮
  - [x] SubTask 3.2: 新增轮询间隔设置控件（Stepper 或输入框）
  - [x] SubTask 3.3: 显示当前正在监控的服务器名称和轮询进度指示

# Task Dependencies
- [Task 2] depends on [Task 1] (轮询需要 SSH 连接正常工作)
- [Task 3] depends on [Task 2] (UI 依赖 ViewModel 逻辑)
