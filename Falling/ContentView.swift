import SpriteKit
import SwiftUI

/// Hosts the edge-to-edge SpriteKit gameplay view (ARCHITECTURE.md §8).
struct ContentView: View {
    @State private var scene: GameScene = {
        let scene = GameScene(
            size: CGSize(width: WorldConstants.referenceWidth, height: WorldConstants.referenceWidth * (844.0 / 390.0))
        )
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .onAppear {
                        resizeScene(to: geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        resizeScene(to: newSize)
                    }

                // If this banner is missing on device, Xcode is not running this branch.
                Text("LOOK-DOWN ACTIVE")
                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color(red: 0.15, green: 1.0, blue: 0.4))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.75))
                    .padding(.top, 8)
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }

    /// Match the SpriteKit scene size to the view in points so depth projection
    /// uses real screen coordinates (ARCHITECTURE.md §8.4).
    private func resizeScene(to viewSize: CGSize) {
        let width = max(viewSize.width, 1)
        let height = max(viewSize.height, 1)
        let screenSize = CGSize(width: width, height: height)
        if scene.size != screenSize {
            scene.size = screenSize
        }
    }
}

#Preview {
    ContentView()
}
