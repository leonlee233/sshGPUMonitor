import SwiftUI

struct GPUBarChartView: View {
    let gpus: [GPUInfo]

    private let gpuColors: [Color] = [
        .blue, .green, .orange, .pink, .purple, .red, .yellow, .cyan,
        .mint, .teal, .indigo, .brown
    ]

    var body: some View {
        if gpus.isEmpty {
            Text("No GPU Data")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .frame(height: 100)
        } else {
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(gpus) { gpu in
                    GPUBarView(
                        gpu: gpu,
                        color: gpuColors[gpu.id % gpuColors.count]
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
    }
}
