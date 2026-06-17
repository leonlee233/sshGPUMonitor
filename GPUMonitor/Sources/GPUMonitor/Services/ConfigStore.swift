import Foundation
import Combine

class ConfigStore: ObservableObject {
    static let shared = ConfigStore()

    @Published var servers: [ServerConfig] = []

    private let userDefaultsKey = "GPUMonitorServerConfigs"

    private init() {
        loadConfigs()
    }

    func loadConfigs() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        guard let decoded = try? JSONDecoder().decode([ServerConfig].self, from: data) else { return }
        servers = decoded
    }

    func saveConfigs() {
        guard let data = try? JSONEncoder().encode(servers) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    func addServer(_ config: ServerConfig) {
        servers.append(config)
        saveConfigs()
    }

    func removeServer(_ id: UUID) {
        servers.removeAll { $0.id == id }
        saveConfigs()
    }

    func updateServer(_ config: ServerConfig) {
        if let index = servers.firstIndex(where: { $0.id == config.id }) {
            servers[index] = config
            saveConfigs()
        }
    }
}
