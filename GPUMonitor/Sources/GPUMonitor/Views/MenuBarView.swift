import SwiftUI

struct MenuBarPopoverView: View {
    @ObservedObject var viewModel: GPUMonitorViewModel
    @StateObject private var autoStartManager = AutoStartManager.shared

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                if viewModel.isAutoPolling {
                    Text(viewModel.currentPollingServerName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                } else {
                    ServerPickerView(viewModel: viewModel)
                }
                Spacer()
                if viewModel.isAutoPolling {
                    Button(action: { viewModel.stopAutoPolling() }) {
                        Image(systemName: "forward.circle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                } else if viewModel.isMonitoring {
                    Button(action: { viewModel.stopMonitoring() }) {
                        Image(systemName: "stop.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: { viewModel.startMonitoring() }) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
            }

            GPUBarChartView(gpus: viewModel.gpus)

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text("Poll:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                    TextField("", text: Binding(
                        get: { "\(Int(viewModel.pollInterval))" },
                        set: { if let v = Int($0), v >= 3 { viewModel.pollInterval = TimeInterval(v) } }
                    ))
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .frame(width: 28)
                    .textFieldStyle(.plain)
                    Text("s")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                }

                Button(viewModel.isAutoPolling ? "Auto: ON" : "Auto: OFF") {
                    if viewModel.isAutoPolling {
                        viewModel.stopAutoPolling()
                    } else {
                        viewModel.startAutoPolling()
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(viewModel.isAutoPolling ? .orange : .white)
            }
            .padding(.horizontal, 12)

            Divider()
                .padding(.horizontal, 12)

            HStack {
                Button(autoStartManager.isEnabled ? "Auto-Start: ON" : "Auto-Start: OFF") {
                    autoStartManager.toggle()
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(autoStartManager.isEnabled ? .green : .white)

                Spacer()

                Button("Settings") {
                    NotificationCenter.default.post(name: .showServerConfig, object: nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .frame(width: 320)
    }
}
