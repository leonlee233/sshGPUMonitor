import SwiftUI

@main
struct GPUMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
                .onAppear {
                    if let window = NSApplication.shared.windows.first(where: { $0.contentView?.subviews.first is NSHostingView<EmptyView> }) {
                        window.close()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.topLeading)
    }
}
