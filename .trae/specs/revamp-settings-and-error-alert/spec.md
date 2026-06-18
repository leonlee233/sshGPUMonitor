# 重构 Settings 为服务器管理界面 + SSH 错误弹窗 Spec

## Why
当前 Settings 只能添加服务器，无法删除或编辑已有服务器，用户无法管理多台服务器。SSH 连接错误仅在面板中显示小字，不够醒目。

## What Changes
- 重构 ServerConfigView 为 ServerListView：显示所有服务器列表，支持删除和编辑
- 添加服务器改为二级弹出窗口（Sheet）
- SSH 错误信息改为 NSAlert 弹窗提醒

## Impact
- Affected code: ServerConfigView.swift, AppDelegate.swift, GPUMonitorViewModel.swift

## ADDED Requirements

### Requirement: 服务器管理界面
Settings 窗口 SHALL 显示所有已配置服务器的列表，每条显示名称/主机信息，支持编辑和删除操作。

#### Scenario: 查看服务器列表
- **WHEN** 用户打开 Settings
- **THEN** 显示所有已配置服务器列表，每条显示名称和 host:port

#### Scenario: 删除服务器
- **WHEN** 用户点击某服务器的删除按钮
- **THEN** 该服务器从列表中移除，配置持久化更新

#### Scenario: 编辑服务器
- **WHEN** 用户点击某服务器的编辑按钮
- **THEN** 弹出编辑表单，修改后保存更新

### Requirement: 添加服务器为二级弹出
添加服务器 SHALL 通过点击列表底部的"+"按钮弹出二级窗口完成。

#### Scenario: 添加服务器
- **WHEN** 用户点击"+"按钮
- **THEN** 弹出添加服务器表单，填写后保存并出现在列表中

### Requirement: SSH 错误弹窗
SSH 连接失败时 SHALL 弹出 NSAlert 提醒用户。

#### Scenario: 连接失败
- **WHEN** SSH 连接失败或 nvidia-smi 执行出错
- **THEN** 弹出 NSAlert 显示错误信息，用户点击 OK 关闭

#### Scenario: 不重复弹窗
- **WHEN** 同一错误持续发生（如服务器离线）
- **THEN** 不重复弹出多个弹窗，同一服务器仅弹一次，连接恢复后重置

## MODIFIED Requirements
### Requirement: SSH 连接管理
Settings 窗口从单一添加表单改为服务器管理列表，添加操作为二级弹出。
