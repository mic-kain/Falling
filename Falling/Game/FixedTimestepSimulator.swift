import Foundation
import QuartzCore

/// Authoritative fixed-timestep simulation driver (ARCHITECTURE.md §8.1).
///
/// physicsStep = 1 / 120 second
/// accumulator += min(frameDelta, 0.1)
/// while accumulator >= physicsStep: simulate(physicsStep); accumulator -= physicsStep
///
/// Driven by CADisplayLink so physics is decoupled from SpriteKit's own
/// per-frame `update(_:)` / render timing.
final class FixedTimestepSimulator: NSObject {
    private let physicsStep: TimeInterval
    private let maxFrameDelta: TimeInterval
    private let simulate: (TimeInterval) -> Void

    private var accumulator: TimeInterval = 0
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval?

    init(
        physicsStep: TimeInterval = WorldConstants.physicsStep,
        maxFrameDelta: TimeInterval = WorldConstants.maxFrameDelta,
        simulate: @escaping (TimeInterval) -> Void
    ) {
        self.physicsStep = physicsStep
        self.maxFrameDelta = maxFrameDelta
        self.simulate = simulate
        super.init()
    }

    func start() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
        lastTimestamp = nil
        accumulator = 0
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = nil
        accumulator = 0
    }

    @objc private func tick(_ link: CADisplayLink) {
        let timestamp = link.timestamp
        defer { lastTimestamp = timestamp }

        guard let lastTimestamp else { return }

        let frameDelta = timestamp - lastTimestamp
        accumulator += min(frameDelta, maxFrameDelta)

        while accumulator >= physicsStep {
            simulate(physicsStep)
            accumulator -= physicsStep
        }
    }
}
