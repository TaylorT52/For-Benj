import SwiftUI

struct ContentView: View {
    @State private var showCard = false
    @State private var goToMain = false 

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                if showCard {
                    CardView {
                        goToMain = true
                    }
                    .zIndex(1)
                }

                if !showCard {
                    VStack {
                        Spacer()
                        Button {
                            withAnimation { showCard = true }
                        } label: {
                            Text("❤️").font(.system(size: 64))
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }

                NavigationLink("", destination: MainView(), isActive: $goToMain)
                    .hidden()
            }
        }
    }
}

#Preview {
    ContentView()
}
