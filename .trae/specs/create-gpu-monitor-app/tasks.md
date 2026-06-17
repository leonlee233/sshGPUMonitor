# Tasks

- [x] Task 1: 创建 macOS SwiftUI 项目基础结构
  - [x] SubTask 1.1: 使用 SwiftUI 创建 macOS App 项目，配置 Info.plist（无边框窗口、悬浮层级）
  - [x] SubTask 1.2: 创建 App 入口和基础导航结构

- [x] Task 2: 实现 SSH 连接层
  - [x] SubTask 2.1: 创建 SSHManager 类，封装 SSH 连接（基于 Process 调用系统 ssh 或集成 NMSSH）
  - [x] SubTask 2.2: 实现远程执行 `nvidia-smi` 命令并解析 CSV 输出为结构化数据
  - [x] SubTask 2.3: 实现定时轮询机制（3 秒间隔），使用 Combine Timer 发布 GPU 数据

- [x] Task 3: 实现 GPU 数据模型
  - [x] SubTask 3.1: 定义 GPUInfo 结构体（id, utilization, memoryUsed, memoryTotal）
  - [x] SubTask 3.2: 定义 ServerConfig 结构体（host, port, user, authType, keyPath/password）
  - [x] SubTask 3.3: 创建 GPUMonitorViewModel，管理连接状态与 GPU 数据流

- [x] Task 4: 实现悬浮窗 GPU 柱状图 UI
  - [x] SubTask 4.1: 创建 GPUBarView 组件（单个柱状图：颜色、高度动画、GPU 编号、百分比）
  - [x] SubTask 4.2: 创建 GPUBarChartView 组件（横向排列多个 GPUBarView）
  - [x] SubTask 4.3: 创建 FloatingWindow（NSPanel 子类），设置无边框、半透明毛玻璃背景、始终置顶
  - [x] SubTask 4.4: 实现柱状图高度变化的平滑动画过渡

- [x] Task 5: 实现菜单栏模式
  - [x] SubTask 5.1: 创建 NSStatusItem 菜单栏图标
  - [x] SubTask 5.2: 点击图标弹出 popover 面板，复用 GPUBarChartView

- [x] Task 6: 实现 SSH 连接配置界面
  - [x] SubTask 6.1: 创建 ServerConfigView（表单：主机、端口、用户名、认证方式）
  - [x] SubTask 6.2: 实现配置持久化（UserDefaults / JSON 文件）
  - [x] SubTask 6.3: 实现多服务器列表与切换

- [x] Task 7: 实现开机自启动
  - [x] SubTask 7.1: 使用 ServiceManagement.framework 注册 Login Item

# Task Dependencies
- [Task 2] depends on [Task 3] (数据模型先行)
- [Task 4] depends on [Task 3] (ViewModel 数据驱动 UI)
- [Task 5] depends on [Task 4] (复用柱状图组件)
- [Task 6] depends on [Task 2] (配置驱动连接)
- [Task 7] independent
