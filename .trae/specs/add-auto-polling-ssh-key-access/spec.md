# 自动轮询多服务器 + SSH 密钥授权 Spec

## Why
当前应用只能监控单台服务器，用户需手动切换；且每次启动访问 SSH 密钥文件时 macOS 都会弹出授权弹窗，体验很差。

## What Changes
- 新增自动轮询模式：按设定间隔自动切换所有已配置服务器，依次采集 GPU 数据并展示
- 新增轮询间隔设置（可配置秒数）
- 修复 SSH 密钥文件重复授权问题：使用 NSOpenPanel 选择密钥文件并创建 Security-Scoped Bookmark，仅首次授权

## Impact
- Affected code: GPUMonitorViewModel.swift, SSHManager.swift, ServerConfig.swift, ServerConfigView.swift, MenuBarView.swift, FloatingWindowController.swift

## ADDED Requirements

### Requirement: 自动轮询多服务器
系统 SHALL 支持自动轮询模式，按设定间隔依次采集所有已配置服务器的 GPU 数据。

#### Scenario: 启用自动轮询
- **WHEN** 用户点击自动轮询按钮
- **THEN** 系统按设定间隔依次连接每台服务器，采集 GPU 数据并更新 UI

#### Scenario: 轮询切换
- **WHEN** 当前正在显示服务器 A 的 GPU 数据，轮询间隔到达
- **THEN** 自动切换到下一台服务器 B 并显示其 GPU 数据

#### Scenario: 只有一台服务器
- **WHEN** 只配置了一台服务器
- **THEN** 轮询模式下持续采集该服务器的数据（等同于普通监控）

### Requirement: 轮询间隔可配置
系统 SHALL 允许用户设置轮询间隔（每台服务器的停留时间），默认 10 秒。

#### Scenario: 修改轮询间隔
- **WHEN** 用户将轮询间隔设为 5 秒
- **THEN** 每台服务器停留 5 秒后切换到下一台

### Requirement: SSH 密钥文件仅授权一次
系统 SHALL 使用 Security-Scoped Bookmark 存储 SSH 密钥文件访问权限，仅在首次选择密钥时弹出授权。

#### Scenario: 首次选择密钥文件
- **WHEN** 用户在配置服务器时选择 SSH 密钥认证
- **THEN** 弹出 NSOpenPanel 让用户选择密钥文件，系统创建 bookmark 并持久化

#### Scenario: 后续启动
- **WHEN** 应用重启后使用已保存的密钥文件
- **THEN** 通过 bookmark 恢复访问权限，不再弹出授权弹窗

## MODIFIED Requirements
### Requirement: GPU 数据采集
系统 SHALL 通过 SSH 定时执行 nvidia-smi 获取 GPU 利用率数据。在轮询模式下，依次采集所有服务器的数据。
