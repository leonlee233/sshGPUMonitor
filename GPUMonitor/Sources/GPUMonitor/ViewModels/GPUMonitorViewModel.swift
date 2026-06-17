import Foundation
import Combine

class GPUMonitorViewModel: ObservableObject {
    @Published var gpus: [GPUInfo] = []
    @Published var selectedServerId: UUID?
    @Published var isConnected: Bool = false
    @Published var errorMessage: String?
    @Published var isMonitoring: Bool = false
    @Published var isAutoPolling: Bool = false
    @Published var pollInterval: TimeInterval = 10
    @Published var currentPollingServerName: String = ""

    var statusBarText: String {
        if gpus.isEmpty {
            return "🖥"
        }
        let percents = gpus.map { "\($0.utilization)%" }.joined(separator: " ")
        if isAutoPolling && !currentPollingServerName.isEmpty {
            return "🖥 \(currentPollingServerName): \(percents)"
        }
        return "🖥 \(percents)"
    }

    private let sshManager = SSHManager.shared
    private let configStore = ConfigStore.shared
    private var pollingTimer: Timer?
    private var autoPollingTask: Task<Void, Never>?
    private var autoPollingIndex: Int = 0

    var servers: [ServerConfig] {
        configStore.servers
    }

    var selectedServer: ServerConfig? {
        guard let id = selectedServerId else { return configStore.servers.first }
        return configStore.servers.first { $0.id == id }
    }

    func selectServer(_ id: UUID) {
        selectedServerId = id
        if isMonitoring {
            stopMonitoring()
            startMonitoring()
        }
    }

    func addServer(_ config: ServerConfig) {
        configStore.addServer(config)
        if configStore.servers.count == 1 {
            selectedServerId = config.id
        }
        objectWillChange.send()
    }

    func removeServer(_ id: UUID) {
        configStore.removeServer(id)
        if selectedServerId == id {
            selectedServerId = configStore.servers.first?.id
        }
        objectWillChange.send()
    }

    func updateServer(_ config: ServerConfig) {
        configStore.updateServer(config)
        objectWillChange.send()
    }

    func startMonitoring() {
        guard selectedServer != nil else { return }
        isMonitoring = true
        isAutoPolling = false
        errorMessage = nil

        fetchGPUData()

        pollingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.fetchGPUData()
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        pollingTimer?.invalidate()
        pollingTimer = nil
        gpus = []
        isConnected = false
        currentPollingServerName = ""
    }

    func startAutoPolling() {
        let allServers = configStore.servers
        guard !allServers.isEmpty else { return }

        pollingTimer?.invalidate()
        pollingTimer = nil
        autoPollingTask?.cancel()
        autoPollingTask = nil

        isAutoPolling = true
        isMonitoring = true
        errorMessage = nil
        autoPollingIndex = 0

        autoPollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { return }
                let servers = self.configStore.servers
                guard !servers.isEmpty else {
                    await MainActor.run {
                        self.stopAutoPolling()
                    }
                    return
                }

                if self.autoPollingIndex >= servers.count {
                    self.autoPollingIndex = 0
                }

                let server = servers[self.autoPollingIndex]

                await MainActor.run {
                    self.selectedServerId = server.id
                    self.currentPollingServerName = server.name.isEmpty ? server.displayHost : server.name
                }

                await self.fetchGPUDataForServer(server)

                try? await Task.sleep(nanoseconds: UInt64(self.pollInterval) * 1_000_000_000)

                self.autoPollingIndex += 1
            }
        }
    }

    func stopAutoPolling() {
        autoPollingTask?.cancel()
        autoPollingTask = nil
        isAutoPolling = false
        currentPollingServerName = ""
        if isMonitoring {
            stopMonitoring()
        }
    }

    private func fetchGPUData() {
        guard let config = selectedServer else { return }

        let manager = sshManager
        Task {
            do {
                let gpuData = try await manager.fetchGPUInfo(config: config)
                await MainActor.run { [weak self] in
                    self?.gpus = gpuData
                    self?.isConnected = true
                    self?.errorMessage = nil
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.isConnected = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func fetchGPUDataForServer(_ config: ServerConfig) async {
        let manager = sshManager
        do {
            let gpuData = try await manager.fetchGPUInfo(config: config)
            await MainActor.run { [weak self] in
                self?.gpus = gpuData
                self?.isConnected = true
                self?.errorMessage = nil
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.isConnected = false
                self?.errorMessage = error.localizedDescription
            }
        }
    }
}
