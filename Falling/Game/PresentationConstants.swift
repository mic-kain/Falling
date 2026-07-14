import CoreGraphics

/// Screen-space presentation anchors for the depth projection model (ARCHITECTURE.md §8.4).
/// These values are cosmetic only and never feed back into physics or collision.
enum PresentationConstants {
    /// Normalized horizontal centreline for the player feet and vanishing point.
    static let anchorXFraction: CGFloat = 0.5

    /// Player feet / lower-body anchor near the bottom of the viewport.
    static let playerAnchorYFraction: CGFloat = 0.14

    /// Fixed vanishing point at the centre of the viewport (ARCHITECTURE.md §8.4).
    static let vanishingPointYFraction: CGFloat = 0.5

    /// World-unit depth at which a ledge sits fully at the vanishing point / minimum scale.
    /// Lower than before so mid-field ledges clearly climb toward centre instead of stacking
    /// near the feet like a side-view platformer.
    static let fullVanishingDepth: CGFloat = 620

    /// Smallest rendered scale for geometry at / beyond `fullVanishingDepth`.
    static let minimumScale: CGFloat = 0.08

    /// Look-down slab thickness vs true projected platform height (cosmetic only).
    static let ledgeSlabHeightFactor: CGFloat = 0.32

    /// Feet / lower-body footprint drawn at the bottom anchor (not a side-view body).
    static let playerFeetPresentationSize = CGSize(width: 72, height: 40)

    static func playerAnchor(in viewportSize: CGSize) -> CGPoint {
        CGPoint(
            x: viewportSize.width * anchorXFraction,
            y: viewportSize.height * playerAnchorYFraction
        )
    }

    static func vanishingPoint(in viewportSize: CGSize) -> CGPoint {
        CGPoint(
            x: viewportSize.width * anchorXFraction,
            y: viewportSize.height * vanishingPointYFraction
        )
    }

    /// Maps depth-to-player → 0 at the feet anchor, 1 at the centre vanishing point.
    static func projectionT(depthToPlayer: CGFloat) -> CGFloat {
        min(1, max(0, depthToPlayer) / fullVanishingDepth)
    }

    static func projectionScale(for t: CGFloat) -> CGFloat {
        max(minimumScale, 1 - t * (1 - minimumScale))
    }
}
