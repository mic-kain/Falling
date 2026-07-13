import SpriteKit
import SwiftUI

/// Hosts the edge-to-edge SpriteKit gameplay view (ARCHITECTURE.md §8).
struct ContentView: View {
    @State private var scene: GameScene = {
        let scene = GameScene(
            size: CGSize(width: WorldConstants.referenceWidth, height: WorldConstants.referenceWidth * (844.0 / 390.0))
        )
        scene.scaleMode = .aspectFill
        return scene
    }()

    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    resizeScene(to: geometry.size)
                }
                .onChange(of: geometry.size) { _, newSize in
                    resizeScene(to: newSize)
                }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }

    /// Sizes the scene in world units: fixed 390-wide reference width mapped
    /// to the view aspect ratio (ARCHITECTURE.md §8.2).
    private func resizeScene(to viewSize: CGSize) {
        let width = max(viewSize.width, 1)
        let height = max(viewSize.height, 1)
        let aspect = height / width
        let worldSize = CGSize(
            width: WorldConstants.referenceWidth,
            height: WorldConstants.referenceWidth * aspect
        )
        if scene.size != worldSize {
            scene.size = worldSize
        }
    }
}

#Preview {
    ContentView()
}
