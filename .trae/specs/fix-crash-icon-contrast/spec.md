# 修复崩溃、图标和对比度 Spec

## Why
应用启动后崩溃（EXC_BAD_ACCESS），菜单栏图标空白，文字与背景对比度不足。

## What Changes
- 修复 AppDelegate 内存管理导致的崩溃：使用 NSApplication delegate 属性正确持有，移除 @MainActor 冲突
- 修复菜单栏图标空白：使用自定义绘制图标替代 SF Symbol "gpu"（该符号在某些 macOS 版本不可用）
- 提高文字与背景对比度：将浅色文字改为更亮的白色，调整背景透明度

## Impact
- Affected code: GPUMonitorApp.swift, AppDelegate.swift, GPUBarView.swift, GPUBarChartView.swift, FloatingWindowController.swift, MenuBarView.swift

## ADDED Requirements

### Requirement: 应用不崩溃
应用 SHALL 稳定运行，不因 AppDelegate 内存管理或 @MainActor 隔离问题崩溃。

#### Scenario: 启动后正常运行
- **WHEN** 用户启动应用
- **THEN** 应用稳定运行，菜单栏图标可见，点击不崩溃

### Requirement: 菜单栏图标可见
菜单栏 SHALL 显示清晰可辨的 GPU 图标。

#### Scenario: 图标显示
- **WHEN** 应用启动
- **THEN** 菜单栏显示一个可见的 GPU 监控图标

### Requirement: 文字对比度充足
UI 中所有文字 SHALL 与背景有足够对比度，确保可读性。

#### Scenario: 深色背景文字可读
- **WHEN** 悬浮窗/菜单栏面板显示
- **THEN** 百分比、GPU 编号、按钮文字清晰可读

## MODIFIED Requirements
### Requirement: 简洁设计
UI SHALL 保持极简风格但确保可读性：文字使用 .white 而非 .white.opacity(0.5/0.7)，背景使用更深材质。
