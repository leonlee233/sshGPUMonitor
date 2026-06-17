# SSH GPU Monitor macOS App Spec

## Why
用户需要实时监控远程服务器 GPU 使用情况，避免频繁 SSH 登录执行 `nvidia-smi`，通过 macOS 悬浮窗或菜单栏即可一目了然地查看所有 GPU 利用率。

## What Changes
- 创建一个 macOS 原生应用（SwiftUI），支持通过 SSH 连接远程服务器
- 定时执行 `nvidia-smi` 获取 GPU 利用率数据
- 在悬浮窗中以简洁柱状图展示每张 GPU 的利用率，每张卡颜色不同
- 支持菜单栏图标模式，点击展开 GPU 状态面板
- 支持配置多个 SSH 连接（主机、端口、用户名、密钥/密码）

## Impact
- Affected code: 全新项目，无已有代码影响
- 依赖: SwiftUI, Combine, Security.framework (SSH 密钥), Process / NMSSH

## ADDED Requirements

### Requirement: SSH 连接管理
系统 SHALL 提供配置 SSH 连接的功能，支持主机地址、端口、用户名、认证方式（密码/密钥）。

#### Scenario: 添加新连接
- **WHEN** 用户点击"添加服务器"并填写 SSH 连接信息
- **THEN** 系统保存连接配置并验证连通性

#### Scenario: 连接失败
- **WHEN** SSH 连接无法建立
- **THEN** 系统显示错误提示，不崩溃

### Requirement: GPU 数据采集
系统 SHALL 通过 SSH 定时执行 `nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits` 获取 GPU 利用率和显存使用数据。

#### Scenario: 正常采集
- **WHEN** SSH 连接正常且服务器安装了 NVIDIA 驱动
- **THEN** 系统每 3 秒获取一次 GPU 数据并更新 UI

#### Scenario: nvidia-smi 不可用
- **WHEN** 远程服务器未安装 NVIDIA 驱动
- **THEN** 系统显示"未检测到 GPU"提示

### Requirement: 悬浮窗 GPU 柱状图展示
系统 SHALL 在悬浮窗中以竖向柱状图展示每张 GPU 的利用率，每张卡使用不同颜色。

#### Scenario: 8 卡服务器
- **WHEN** 远程服务器有 8 张 GPU
- **THEN** 悬浮窗显示 8 个柱状图，每个颜色不同，柱高反映利用率百分比，柱下方显示 GPU 编号

#### Scenario: 利用率变化
- **WHEN** GPU 利用率从 30% 变为 80%
- **THEN** 对应柱状图高度平滑过渡到新高度

### Requirement: 菜单栏模式
系统 SHALL 支持在 macOS 菜单栏显示图标，点击展开 GPU 状态面板。

#### Scenario: 点击菜单栏图标
- **WHEN** 用户点击菜单栏图标
- **THEN** 弹出面板显示当前选中服务器的 GPU 柱状图

### Requirement: 简洁设计
UI SHALL 保持极简风格：无多余边框，半透明背景，紧凑布局，仅显示 GPU 编号 + 利用率柱状图 + 百分比数值。

#### Scenario: 悬浮窗显示
- **WHEN** 悬浮窗激活
- **THEN** 窗口无边框、半透明毛玻璃背景、8 个柱状图紧凑排列，底部显示 GPU 编号，柱顶显示百分比

### Requirement: 多服务器切换
系统 SHALL 支持配置多个远程服务器，用户可快速切换查看不同服务器的 GPU 状态。

#### Scenario: 切换服务器
- **WHEN** 用户从下拉菜单选择另一台服务器
- **THEN** 柱状图更新为新服务器的 GPU 数据

### Requirement: 开机自启动
系统 SHALL 支持设置开机自启动（Login Item）。

#### Scenario: 启用自启动
- **WHEN** 用户在设置中启用"开机自启动"
- **THEN** 应用注册为 Login Item，下次开机自动启动
