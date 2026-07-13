import CoreGraphics
import Foundation

/// Static crumbling platform geometry in world units (PROCEDURAL_GENERATION_TIER1.md §9).
struct Platform: Identifiable, Equatable {
    let id: UUID
    var center: CGPoint
    var size: CGSize

    init(id: UUID = UUID(), center: CGPoint, size: CGSize) {
        self.id = id
        self.center = center
        self.size = size
    }

    var topSurfaceY: CGFloat { center.y + size.height * 0.5 }
    var left: CGFloat { center.x - size.width * 0.5 }
    var right: CGFloat { center.x + size.width * 0.5 }
}
