import CoreGraphics

/// Screen-space presentation anchors for the depth projection model (ARCHITECTURE.md §8.4).
/// These values are cosmetic only and never feed back into physics or collision.
enum PresentationConstants {
    /// Normalized horizontal anchor for the player feet and vanishing point (centreline).
    static let anchorXFraction: CGFloat = 0.5

    /// Player feet / lower-body anchor in the lower-middle of the viewport.
    static let playerAnchorYFraction: CGFloat = 0.24

    /// Fixed vanishing point near the upper-centre of the viewport.
    static let vanishingPointYFraction: CGFloat = 0.86

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
