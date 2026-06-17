import Foundation

struct GPUInfo: Identifiable, Codable, Equatable {
    let id: Int
    let utilization: Int
    let memoryUsed: Int
    let memoryTotal: Int

    var memoryUsagePercent: Int {
        guard memoryTotal > 0 else { return 0 }
        return Int(Double(memoryUsed) / Double(memoryTotal) * 100)
    }
}
