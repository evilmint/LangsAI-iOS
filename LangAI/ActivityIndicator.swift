import SwiftUI

struct ActivityIndicator: View {
    @State private var animate = false

    private let style = StrokeStyle(lineWidth: 3, lineCap: .round)
    private let color1 = Color.neutral200
    private let color2 = Color.neutral200.opacity(0.5)

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(gradient: .init(colors: [color1, color2]), center: .center),
                    style: style
                )
                .rotationEffect(Angle(degrees: animate ? 360 : 0))
                .animation(
                    .linear(duration: 0.7).repeatForever(autoreverses: false),
                    value: UUID()
                )
        }
        .onAppear {
            self.animate.toggle()
        }
    }
}
