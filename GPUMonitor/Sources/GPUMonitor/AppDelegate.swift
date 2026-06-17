import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var floatingWindowController: FloatingWindowController!
    var viewModel: GPUMonitorViewModel!
    private var cancellable: AnyCancellable?

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
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 320),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        configWindow.center()
        configWindow.title = "Server Configuration"
        configWindow.isReleasedWhenClosed = false
        configWindow.contentView = NSHostingView(rootView: ServerConfigView(viewModel: viewModel, onClose: { [weak configWindow] in
            configWindow?.close()
        }))
        configWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
