import CoreGraphics

/// Cosmetic depth projection from world units to screen-space sprite layout (ARCHITECTURE.md §8.4).
///
/// World depth and lateral offset remain authoritative for physics. This type only maps
/// those values into presentation scale and position for rendering.
enum DepthProjection {
    struct ProjectedSprite: Equatable {
        let position: CGPoint
        let size: CGSize
        let scale: CGFloat
        let depthToPlayer: CGFloat
    }

    /// Projects the player so their feet remain at the fixed bottom-screen anchor.
    static func projectPlayer(
        worldCenter: CGPoint,
        worldSize: CGSize,
        viewportSize: CGSize
    ) -> ProjectedSprite {
        let anchor = PresentationConstants.playerAnchor(in: viewportSize)
        let scale: CGFloat = 1
        let projectedSize = CGSize(width: worldSize.width * scale, height: worldSize.height * scale)
        let projectedCenter = CGPoint(
            x: anchor.x,
            y: anchor.y + projectedSize.height * 0.5
        )

        return ProjectedSprite(
            position: projectedCenter,
            size: projectedSize,
            scale: scale,
            depthToPlayer: 0
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
        let projectionT = depthToPlayer / (depthToPlayer + PresentationConstants.referenceDepth)

        let scale = max(
            PresentationConstants.minimumScale,
            1 - projectionT * (1 - PresentationConstants.minimumScale)
        )

        let playerAnchor = PresentationConstants.playerAnchor(in: viewportSize)
        let vanishingPoint = PresentationConstants.vanishingPoint(in: viewportSize)
        let lateralOffset = platform.center.x - playerWorldCenter.x

        let projectedTopY = playerAnchor.y + (vanishingPoint.y - playerAnchor.y) * projectionT
        let projectedSize = CGSize(width: platform.size.width * scale, height: platform.size.height * scale)
        let projectedCenter = CGPoint(
            x: playerAnchor.x + lateralOffset * scale,
            y: projectedTopY + projectedSize.height * 0.5
        )

        return ProjectedSprite(
            position: projectedCenter,
            size: projectedSize,
            scale: scale,
            depthToPlayer: depthToPlayer
        )
    }
}
