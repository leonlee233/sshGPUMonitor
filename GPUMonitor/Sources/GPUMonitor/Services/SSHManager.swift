import Foundation

enum SSHError: LocalizedError {
    case processError(String)
    case noData
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .processError(let msg): return "SSH Error: \(msg)"
        case .noData: return "No data received from server"
        case .parseError(let msg): return "Parse Error: \(msg)"
        }
    }
}

class SSHManager {
    static let shared = SSHManager()
    private let keyFileManager = KeyFileManager.shared
    private let executionQueue = DispatchQueue(label: "com.gpumonitor.ssh", qos: .userInitiated)

    private init() {}

    func execute(command: String, config: ServerConfig) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            executionQueue.async { [keyFileManager] in
                do {
                    let result = try self._executeSync(command: command, config: config, keyFileManager: keyFileManager)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func _executeSync(command: String, config: ServerConfig, keyFileManager: KeyFileManager) throws -> String {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/ssh")

        var arguments = [
            "-o", "StrictHostKeyChecking=no",
            "-o", "ConnectTimeout=5",
            "-o", "BatchMode=yes",
            "-p", "\(config.port)"
        ]

        if config.authType == .key {
            var keyPath: String?
            if let bookmark = config.keyBookmark {
                keyPath = keyFileManager.startAccessing(bookmark: bookmark)
            }
            if keyPath == nil {
                keyPath = NSString(string: config.keyPath).expandingTildeInPath
            }
            if let path = keyPath {
                arguments += ["-i", path]
            }
        }

        arguments += ["\(config.user)@\(config.host)", command]
        process.arguments = arguments

        process.standardOutput = outputPipe
        process.standardError = errorPipe

        var outputData = Data()
        var errorData = Data()

        outputPipe.fileHandleForReading.readabilityHandler = { handler in
            outputData.append(handler.availableData)
        }
        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            errorData.append(handler.availableData)
        }

        try process.run()
        process.waitUntilExit()

        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil

        outputData.append(outputPipe.fileHandleForReading.readDataToEndOfFile())
        errorData.append(errorPipe.fileHandleForReading.readDataToEndOfFile())

        if process.terminationStatus != 0 {
            let errorMsg = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown error"
            throw SSHError.processError(errorMsg)
        }

        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if output.isEmpty {
            throw SSHError.noData
        }

        return output
    }

    func fetchGPUInfo(config: ServerConfig) async throws -> [GPUInfo] {
        let command = "nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits"
        let output = try await execute(command: command, config: config)
        return try parseGPUOutput(output)
    }

    private func parseGPUOutput(_ output: String) throws -> [GPUInfo] {
        let lines = output.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        guard !lines.isEmpty else {
            throw SSHError.parseError("No GPU data found")
        }

        var gpus: [GPUInfo] = []
        for (index, line) in lines.enumerated() {
            let components = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard components.count >= 3,
                  let utilization = Int(components[0]),
                  let memoryUsed = Int(components[1]),
                  let memoryTotal = Int(components[2]) else {
                throw SSHError.parseError("Failed to parse line: \(line)")
            }
            gpus.append(GPUInfo(id: index, utilization: utilization, memoryUsed: memoryUsed, memoryTotal: memoryTotal))
        }

        return gpus
    }
}
