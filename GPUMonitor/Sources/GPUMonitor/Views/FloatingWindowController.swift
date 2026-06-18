import SwiftUI

class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    init(contentRect: NSRect, content: some View) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovableByWindowBackground = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = .clear
        hasShadow = true

        let hostingView = NSHostingView(rootView: content)
        hostingView.frame = contentRect
        contentView = hostingView
    }
}

class FloatingWindowController: ObservableObject {
    private var panel: FloatingPanel?
    @Published var isVisible: Bool = false

    func showPanel(with viewModel: GPUMonitorViewModel) {
        if panel == nil {
            let content = FloatingWindowContent(viewModel: viewModel, onClose: { [weak self] in
                self?.hidePanel()
            })
            let panelRect = NSRect(x: 0, y: 0, width: 320, height: 160)
            let newPanel = FloatingPanel(contentRect: panelRect, content: content)
            newPanel.center()
            panel = newPanel
        }
        panel?.orderFront(nil)
        isVisible = true
    }

    func hidePanel() {
        panel?.orderOut(nil)
        isVisible = false
    }

    func toggle(with viewModel: GPUMonitorViewModel) {
        if isVisible {
            hidePanel()
        } else {
            showPanel(with: viewModel)
        }
    }
}

struct FloatingWindowContent: View {
    @ObservedObject var viewModel: GPUMonitorViewModel
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                if viewModel.isAutoPolling {
                    Text(viewModel.currentPollingServerName)
                        .font(.system(size: 11, weight: .semibold))
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
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                } else if viewModel.isMonitoring {
                    Button(action: { viewModel.stopMonitoring() }) {
                        Image(systemName: "stop.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: { viewModel.startMonitoring() }) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .lineLimit(2)
                    .padding(.horizontal, 10)
            }

            GPUBarChartView(gpus: viewModel.gpus)

            if !viewModel.gpus.isEmpty {
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.isConnected ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                    Text(viewModel.isConnected ? "Connected" : "Disconnected")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 6)
            }
        }
        .background(
            VisualEffectView()
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct ServerPickerView: View {
    @ObservedObject var viewModel: GPUMonitorViewModel

    var body: some View {
        Menu {
            ForEach(viewModel.servers) { server in
                Button(action: { viewModel.selectServer(server.id) }) {
                    if viewModel.selectedServerId == server.id {
                        Text("✓ \(server.name.isEmpty ? server.displayHost : server.name)")
                    } else {
                        Text(server.name.isEmpty ? server.displayHost : server.name)
                    }
                }
            }
            Divider()
            Button("Add Server...") {
                NotificationCenter.default.post(name: .showServerConfig, object: nil)
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.selectedServer?.name.isEmpty == false ? viewModel.selectedServer!.name : viewModel.selectedServer?.displayHost ?? "Select Server")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .menuStyle(.borderlessButton)
    }
}

extension Notification.Name {
    static let showServerConfig = Notification.Name("showServerConfig")
    static let showSSHError = Notification.Name("showSSHError")
}
