import Foundation

/// A phase anchor keeps a rate change or pause from moving the current wave/rotor frame.
/// Rates are cycles per second, and phase wraps into 0..<1 without a timer-owned model.
struct GreekMotionClock {
    private(set) var phase = 0.0
    private(set) var rate = 0.0
    private var anchor: TimeInterval?

    func phase(at time: TimeInterval) -> Double {
        let elapsed = anchor.map { max(0, time - $0) } ?? 0
        let advanced = (phase + elapsed * rate).truncatingRemainder(dividingBy: 1)
        return advanced < 0 ? advanced + 1 : advanced
    }

    mutating func rebase(at time: TimeInterval, rate nextRate: Double, running: Bool) {
        phase = phase(at: time)
        rate = max(0, nextRate)
        anchor = running && rate > 0 ? time : nil
    }
}
