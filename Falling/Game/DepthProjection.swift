import CoreGraphics

/// Cosmetic depth projection from world units to screen-space sprite layout (ARCHITECTURE.md §8.4).
///
/// World depth and lateral offset remain authoritative for physics. This type only maps
/// those values into presentation scale and position for a look-down shaft camera:
/// far ledges sit small at the centre vanishing point; near ledges grow while moving
/// downward toward the bottom feet anchor.
enum DepthProjection {
    struct ProjectedSprite: Equatable {
        let position: CGPoint
        let size: CGSize
        let scale: CGFloat
        let depthToPlayer: CGFloat
        let projectionT: CGFloat
    }

    /// Projects the player so their feet remain at the fixed bottom-screen anchor.
    static func projectPlayer(
        viewportSize: CGSize
    ) -> ProjectedSprite {
        let anchor = PresentationConstants.playerAnchor(in: viewportSize)
        let projectedSize = PresentationConstants.playerFeetPresentationSize
        let projectedCenter = CGPoint(
            x: anchor.x,
            y: anchor.y + projectedSize.height * 0.5
        )

        return ProjectedSprite(
            position: projectedCenter,
            size: projectedSize,
            scale: 1,
            depthToPlayer: 0,
            projectionT: 0
        )
    }

    /// Projects a platform from world depth/lateral offset into screen scale and position.
    static func projectPlatform(
        platform: Platform,
        playerWorldCenter: CGPoint,
        playerWorldSize: CGSize,
        viewportSize: CGSize
    ) -> ProjectedSprite {
        let playerFootWorldY = playerWorldCenter.y - playerWorldSize.height * 0.5
        let depthToPlayer = max(0, playerFootWorldY - platform.topSurfaceY)
        let t = PresentationConstants.projectionT(depthToPlayer: depthToPlayer)
        let scale = PresentationConstants.projectionScale(for: t)

        let playerAnchor = PresentationConstants.playerAnchor(in: viewportSize)
        let vanishingPoint = PresentationConstants.vanishingPoint(in: viewportSize)
        let lateralOffset = platform.center.x - playerWorldCenter.x

        // t = 0 → bottom feet anchor; t = 1 → centre vanishing point.
        let projectedTopY = playerAnchor.y + (vanishingPoint.y - playerAnchor.y) * t
        let projectedWidth = platform.size.width * scale
        let projectedHeight = max(
            3,
            platform.size.height * scale * PresentationConstants.ledgeSlabHeightFactor
        )
        let projectedSize = CGSize(width: projectedWidth, height: projectedHeight)
        let projectedCenter = CGPoint(
            x: playerAnchor.x + lateralOffset * scale,
            y: projectedTopY - projectedSize.height * 0.5
        )

        return ProjectedSprite(
            position: projectedCenter,
            size: projectedSize,
            scale: scale,
            depthToPlayer: depthToPlayer,
            projectionT: t
        )
    }
}
