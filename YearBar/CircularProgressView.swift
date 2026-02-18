import SwiftUI

struct CircularProgressView: View {

    let progress: Double       // 0–100
    let label: String
    let color: Color
    var decimalPlaces: Int = 2
    var isSelected: Bool = false

    private var formatString: String { "%.\(decimalPlaces)f" }

    var body: some View {

        VStack(spacing: 6) {

            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: progress / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(String(format: formatString, progress))%")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
            }
            .frame(width: 72, height: 72)

            Text(label)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .primary : .secondary)

            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
                .opacity(isSelected ? 1 : 0)
        }
    }
}
