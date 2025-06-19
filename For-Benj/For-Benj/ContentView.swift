//  ContentView.swift
//  For-Benj
//
//  Created by Taylor Tam on 6/18/25.

import SwiftUI

/// Heart tap ▶︎ animates upside‑down triangle ▶︎ navigates to `MainView`.
struct ContentView: View {
    // MARK: - State
    @State private var triangleProgress: CGFloat = 0   // 0 → tip at mid‑height, 1 → raised
    @State private var goToMain           = false      // drives NavigationLink

    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    Color.white.ignoresSafeArea()

                    // Upside‑down triangle whose tip rises as `triangleProgress` animates
                    UpsideTriangle(progress: triangleProgress)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 3)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .allowsHitTesting(false)

                    // Heart button
                    VStack {
                        Spacer()
                        Button(action: startAnimationAndNavigate) {
                            Text("❤️")
                                .font(.system(size: 64))
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }

                    // Hidden link that fires after animation completes
                    NavigationLink(destination: MainView(), isActive: $goToMain) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
        }
    }

    private func startAnimationAndNavigate() {
        let duration: Double = 1.5
        withAnimation(.easeInOut(duration: duration)) {
            triangleProgress = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            goToMain = true
        }
    }
}

struct UpsideTriangle: Shape {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let leftBase  = CGPoint(x: 0,         y: 0)
        let rightBase = CGPoint(x: rect.maxX, y: 0)

        let startTipY = rect.midY
        let endTipY = -rect.midY / 2
        let tipY = startTipY + (endTipY - startTipY) * progress

        let apex = CGPoint(x: rect.midX, y: tipY)

        var p = Path()
        p.move(to: leftBase)
        p.addLine(to: rightBase)
        p.addLine(to: apex)
        p.closeSubpath()
        return p
    }
}

#Preview {
    ContentView()
}
