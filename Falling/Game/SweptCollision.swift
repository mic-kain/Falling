import CoreGraphics
import Foundation

/// Swept top-surface landing collision (ARCHITECTURE.md §8).
enum SweptCollision {
    struct LandingResult: Equatable {
        let platformID: UUID
        let position: CGPoint
    }

    /// Finds the earliest valid top-surface landing along the segment from
    /// `previousPosition` to `currentPosition`, if any.
    static func findLanding(
        previousPosition: CGPoint,
        currentPosition: CGPoint,
        playerSize: CGSize,
        platforms: [Platform]
    ) -> LandingResult? {
        let halfWidth = playerSize.width * 0.5
        let halfHeight = playerSize.height * 0.5
        let previousBottom = previousPosition.y - halfHeight
        let currentBottom = currentPosition.y - halfHeight

        // Landing requires downward motion across a top surface.
        guard currentBottom < previousBottom else { return nil }

        var bestResult: LandingResult?
        var bestTime = CGFloat.greatestFiniteMagnitude

        for platform in platforms {
            let platformTop = platform.topSurfaceY
            guard previousBottom >= platformTop - 0.001 else { continue }
            guard currentBottom <= platformTop + 0.001 else { continue }

            let verticalTravel = previousBottom - currentBottom
            guard verticalTravel > 0 else { continue }

            let time = (previousBottom - platformTop) / verticalTravel
            guard time >= 0, time <= 1 else { continue }

            let landingX = previousPosition.x + (currentPosition.x - previousPosition.x) * time
            let landingLeft = landingX - halfWidth
            let landingRight = landingX + halfWidth

            let overlapsHorizontally = landingRight > platform.left && landingLeft < platform.right
            guard overlapsHorizontally else { continue }

            if time < bestTime {
                bestTime = time
                bestResult = LandingResult(
                    platformID: platform.id,
                    position: CGPoint(x: landingX, y: platformTop + halfHeight)
                )
            }
        }

        return bestResult
    }

    /// Returns the platform whose top surface currently supports the player, if any.
    static func supportingPlatform(
        at position: CGPoint,
        playerSize: CGSize,
        platforms: [Platform]
    ) -> Platform? {
        let halfWidth = playerSize.width * 0.5
        let halfHeight = playerSize.height * 0.5
        let bottom = position.y - halfHeight
        let left = position.x - halfWidth
        let right = position.x + halfWidth

        return platforms.first { platform in
            abs(bottom - platform.topSurfaceY) <= 0.5
                && right > platform.left
                && left < platform.right
        }
    }
}
