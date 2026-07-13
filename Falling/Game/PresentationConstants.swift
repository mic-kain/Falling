import CoreGraphics

/// Screen-space presentation anchors for the depth projection model (ARCHITECTURE.md §8.4).
/// These values are cosmetic only and never feed back into physics or collision.
enum PresentationConstants {
    /// Normalized horizontal centreline for the player feet and vanishing point.
    static let anchorXFraction: CGFloat = 0.5

    /// Player feet / lower-body anchor near the bottom of the viewport.
    static let playerAnchorYFraction: CGFloat = 0.18

    /// Fixed vanishing point at the centre of the viewport (ARCHITECTURE.md §8.4).
    static let vanishingPointYFraction: CGFloat = 0.5

    /// World-unit depth at which projection is halfway between anchor and vanishing point.
    static let referenceDepth: CGFloat = 180

    /// Smallest rendered scale for very distant geometry.
    static let minimumScale: CGFloat = 0.14

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
}
