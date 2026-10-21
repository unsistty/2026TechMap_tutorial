import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .top) {
            ARViewContainer()
                .ignoresSafeArea()

            VStack(spacing: 6) {
                Label("창문 위에 후우링을 매달아 보세요", systemImage: "wind")
                    .font(.headline)
                Text("창문을 천천히 비춘 뒤, 상단 창틀을 터치하세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }
}

#Preview {
    ContentView()
}

