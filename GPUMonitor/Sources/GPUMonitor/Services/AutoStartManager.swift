import ServiceManagement

class AutoStartManager: ObservableObject {
    static let shared = AutoStartManager()

    @Published var isEnabled: Bool = false

    private init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func enable() {
        do {
            try SMAppService.mainApp.register()
            isEnabled = true
        } catch {
            isEnabled = false
        }
    }

    func disable() {
        do {
            try SMAppService.mainApp.unregister()
            isEnabled = false
        } catch {
            isEnabled = true
        }
    }

    func toggle() {
        if isEnabled {
            disable()
        } else {
            enable()
        }
    }
}
