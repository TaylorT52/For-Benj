import SwiftUI

struct CardView: View {
    var onUnlock: () -> Void
    var body: some View {
        ZStack { FrontCard().zIndex(1) }
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

private struct FrontCard: View {
    @State private var now = Date()
    @State private var totalMinutes: Int = 0

    private let londonCalendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Europe/London")!
        return cal
    }()

    private var target: Date {
        var comps = DateComponents(
            timeZone: TimeZone(identifier: "Europe/London"),
            year: 2025, month: 8, day: 30,
            hour: 15, minute: 0, second: 0
        )
        return londonCalendar.date(from: comps)!
    }

    private var remaining: DateComponents {
        londonCalendar.dateComponents([.day, .hour, .minute],
                                      from: now,
                                      to: target)
    }

    private var remainingMinutes: Int {
        max(londonCalendar.dateComponents([.minute], from: now, to: target).minute ?? 0, 0)
    }

    private var progress: Double {
        guard totalMinutes > 0 else { return 0 }
        return 1 - Double(remainingMinutes) / Double(totalMinutes)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.white)
            .frame(width: 420, height: 270)
            .shadow(radius: 12)
            .overlay(
                VStack(spacing: 24) {

                    CountdownText(components: remaining)
                        .font(.largeTitle.monospacedDigit())
                        .foregroundColor(.black)

                    HeartsLine(progress: progress)
                        .frame(height: 40)
                }
                .padding()
            )

            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) {
                now = $0
            }

            .onAppear {
                let mins = londonCalendar.dateComponents([.minute], from: now, to: target).minute ?? 0
                totalMinutes = max(mins, 1)
            }
    }
}

private struct HeartsLine: View {
    /// 0 = far apart, 1 = touching
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            let heartSize: CGFloat = 32
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            let maxOffset = (geo.size.width - heartSize) / 2
            let currentOffset = maxOffset * (1 - progress)

            let lineWidth = max(0,
                (currentOffset * 2) - heartSize)

            ZStack {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: lineWidth, height: 4)
                    .position(x: centerX, y: centerY)

                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: heartSize)
                    .foregroundColor(.red)
                    .offset(x: -currentOffset)

                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: heartSize)
                    .foregroundColor(.red)
                    .offset(x:  currentOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


private struct CountdownText: View {
    let components: DateComponents
    var body: some View {
        HStack(spacing: 12) {
            timeBlock(components.day ?? 0,   "DAY")
            timeBlock(components.hour ?? 0,  "HR")
            timeBlock(components.minute ?? 0,"MIN")
        }
    }

    @ViewBuilder
    private func timeBlock(_ value: Int, _ label: String) -> some View {
        VStack {
            Text(String(format: "%02d", max(value, 0)))
                .fontWeight(.bold)
            Text(label).font(.caption2)
        }
        .frame(minWidth: 48)
    }
}
