import SwiftUI

struct GPUBarView: View {
    let gpu: GPUInfo
    let color: Color
    let maxBarHeight: CGFloat

    init(gpu: GPUInfo, color: Color, maxBarHeight: CGFloat = 80) {
        self.gpu = gpu
        self.color = color
        self.maxBarHeight = maxBarHeight
    }

    var barHeight: CGFloat {
        maxBarHeight * CGFloat(gpu.utilization) / 100.0
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(gpu.utilization)%")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .monospacedDigit()

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 24, height: maxBarHeight)

                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 24, height: max(barHeight, 2))
                    .animation(.easeInOut(duration: 0.5), value: gpu.utilization)
            }

            Text("\(gpu.id)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
        }
    }
}
