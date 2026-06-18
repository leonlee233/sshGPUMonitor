import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var floatingWindowController: FloatingWindowController!
    var viewModel: GPUMonitorViewModel!
    private var cancellable: AnyCancellable?
    private var alertedServers: Set<UUID> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        viewModel = GPUMonitorViewModel()

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 240)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarPopoverView(viewModel: viewModel))
        self.popover = popover

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "🖥"
            button.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .medium)
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        cancellable = viewModel.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.statusItem.button?.title = self?.viewModel.statusBarText ?? "🖥"
        }

        floatingWindowController = FloatingWindowController()

        NotificationCenter.default.addObserver(
            forName: .showServerConfig,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showServerConfig()
        }

        NotificationCenter.default.addObserver(
            forName: .showSSHError,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let userInfo = notification.userInfo,
               let message = userInfo["message"] as? String,
               let serverId = userInfo["serverId"] as? UUID {
                self?.handleSSHError(message: message, serverId: serverId)
            }
        }

        if viewModel.servers.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showServerConfig()
            }
        }
    }

    @objc func togglePopover(_ sender: Any?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    func showServerConfig() {
        let configWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 350),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        configWindow.center()
        configWindow.title = "Server Management"
        configWindow.isReleasedWhenClosed = false
        configWindow.contentView = NSHostingView(rootView: ServerListView(viewModel: viewModel, onClose: { [weak configWindow] in
            configWindow?.close()
        }))
        configWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func handleSSHError(message: String, serverId: UUID) {
        if alertedServers.contains(serverId) { return }
        alertedServers.insert(serverId)
        showSSHError(message)
    }

    private func showSSHError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "SSH Connection Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
