import SwiftUI

struct MainView: View {
    var body: some View {
        // Countdown to August 29, 2025
        Text(daysUntilAugust292025())
            .font(.title2)
            .padding(.top, 8)
    }
}

func daysUntilAugust292025() -> String {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    var dateComponents = DateComponents()
    dateComponents.year = 2025
    dateComponents.month = 8
    dateComponents.day = 29
    
    guard let targetDate = calendar.date(from: dateComponents) else {
        return "Invalid date"
    }
    let components = calendar.dateComponents([.day], from: today, to: targetDate)
    if let days = components.day, days >= 0 {
        return "\(days) days until Euro trip!"
    } else {
        return "The date has passed."
    }
}

#Preview {
    MainView()
}
