import SwiftUI

struct GreekToyStage: View {
    let letter: GreekLetter
    let value: Double
    var isPlaying = true
    @Binding var motion: GreekMotionClock
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    private var running: Bool {
        GreekToyModel.hasMotion(letter) && isPlaying && !reduceMotion && scenePhase == .active
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !running || GreekToyModel.animationRate(letter, value: value) == 0)) { timeline in
            // Drawing and accessibility read the same frame, without another timer or state write.
            let phase = motion.phase(at: timeline.date.timeIntervalSinceReferenceDate)
            Canvas { context, size in
                let scene = GreekPainter(context: context, size: size)
                scene.grid()
                switch letter {
                case .alpha, .theta: scene.angle(degrees: value, glyph: letter.entry.lower)
                case .omega: scene.rotor(speed: value, phase: phase)
                case .gamma, .lambda: scene.wave(wavelength: value, phase: phase, gamma: letter == .gamma)
                case .nu: scene.wave(wavelength: 2 / value, phase: phase, gamma: false)
                case .psi: scene.wavefunction(state: Int(value.rounded()))
                case .delta: scene.coordinate(value: value / 5, glyph: "Δx", change: true)
                case .xi: scene.coordinate(value: value, glyph: "ξ", change: false)
                case .epsilon: scene.limit(epsilon: value)
                case .zeta: scene.series(count: 40, exponent: value)
                case .sigma: scene.series(count: Int(value.rounded()), exponent: nil)
                case .eta: scene.efficiency(value)
                case .iota: scene.smallQuantity(value)
                case .kappa: scene.circle(radius: value / 4, glyph: "κ = 1/r")
                case .pi: scene.circle(radius: value / 4, glyph: "π = C/d", diameter: true)
                case .mu: scene.friction(value)
                case .rho: scene.density(count: Int(value.rounded()))
                case .omicron: scene.growth(n: value)
                case .tau: scene.torque(force: value)
                case .upsilon: scene.upsilon(separation: value)
                case .phi: scene.goldenSplit(value)
                case .chi: scene.chiSquare(observed: value)
                case .beta: scene.betaDecay(progress: value)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(letter.entry.title) diagram")
            .accessibilityValue(stageValue(phase: phase))
            .accessibilityIdentifier("greek-stage-\(letter.rawValue)")
        }
        .allowsHitTesting(false)
        .onAppear { updateClock() }
        .onDisappear { motion.rebase(at: Date().timeIntervalSinceReferenceDate, rate: GreekToyModel.animationRate(letter, value: value), running: false) }
        .onChange(of: value) { _, _ in updateClock() }
        .onChange(of: running) { _, _ in updateClock() }
    }

    private func updateClock() {
        motion.rebase(at: Date().timeIntervalSinceReferenceDate, rate: GreekToyModel.animationRate(letter, value: value), running: running)
    }

    private func stageValue(phase: Double) -> String {
        let equation = GreekToyModel.reading(letter, value: value)
        guard GreekToyModel.hasMotion(letter) else { return equation }
        let state: String
        if reduceMotion { state = "Reduce Motion: still" }
        else if !isPlaying { state = "Paused" }
        else if scenePhase != .active { state = "Inactive" }
        else if GreekToyModel.animationRate(letter, value: value) == 0 { state = "Zero speed: still" }
        else { state = "Playing" }
        return "\(equation) · visual phase \(String(format: "%.3f", phase)) turns · \(state)"
    }
}

struct GreekPainter {
    let context: GraphicsContext
    let size: CGSize
    var cyan: Color { ToyStyle.cyan }
    var amber: Color { ToyStyle.amber }
    var violet: Color { ToyStyle.violet }
    var center: CGPoint { CGPoint(x: size.width / 2, y: size.height / 2) }

    func grid() {
        var path = Path()
        for x in stride(from: CGFloat(20), through: size.width, by: 28) {
            path.move(to: CGPoint(x: x, y: 16)); path.addLine(to: CGPoint(x: x, y: size.height - 16))
        }
        for y in stride(from: CGFloat(20), through: size.height, by: 28) {
            path.move(to: CGPoint(x: 16, y: y)); path.addLine(to: CGPoint(x: size.width - 16, y: y))
        }
        context.stroke(path, with: .color(.white.opacity(0.035)), lineWidth: 0.5)
    }

    func line(_ from: CGPoint, _ to: CGPoint, color: Color, width: CGFloat = 2) {
        var path = Path(); path.move(to: from); path.addLine(to: to)
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
    }

    func dot(_ point: CGPoint, radius: CGFloat = 5, color: Color) {
        let box = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: box), with: .color(color))
        context.stroke(Path(ellipseIn: box.insetBy(dx: -4, dy: -4)), with: .color(color.opacity(0.14)), lineWidth: 5)
    }

    func label(_ text: String, at point: CGPoint, color: Color = .white, size: CGFloat = 13, anchor: UnitPoint = .center) {
        context.draw(Text(text).font(.system(size: size, weight: .medium, design: .monospaced)).foregroundColor(color), at: point, anchor: anchor)
    }

    func arrow(_ from: CGPoint, _ to: CGPoint, color: Color, width: CGFloat = 2) {
        guard hypot(to.x - from.x, to.y - from.y) > 0.5 else { return }
        line(from, to, color: color, width: width)
        let angle = atan2(to.y - from.y, to.x - from.x)
        let length: CGFloat = 8
        for offset in [-0.5, 0.5] {
            let a = angle + CGFloat(offset)
            line(CGPoint(x: to.x - cos(a) * length, y: to.y - sin(a) * length), to, color: color, width: width)
        }
    }

    func angle(degrees: Double, glyph: String) {
        let r = min(size.width, size.height) * 0.33
        let c = CGPoint(x: center.x, y: center.y + 17)
        let a = degrees * .pi / 180
        let end = CGPoint(x: c.x + cos(a) * r, y: c.y - sin(a) * r)
        var wedge = Path(); wedge.move(to: c)
        wedge.addLine(to: CGPoint(x: c.x + r * 0.6, y: c.y))
        wedge.addArc(center: c, radius: r * 0.6, startAngle: .degrees(0), endAngle: .degrees(-degrees), clockwise: true)
        wedge.closeSubpath()
        context.fill(wedge, with: .color(cyan.opacity(0.12)))
        context.stroke(wedge, with: .color(cyan.opacity(0.6)), lineWidth: 1)
        line(c, CGPoint(x: c.x + r, y: c.y), color: .white.opacity(0.5))
        arrow(c, end, color: cyan, width: 3)
        dot(c, color: amber)
        label(glyph, at: CGPoint(x: c.x + cos(a / 2) * r * 0.37, y: c.y - sin(a / 2) * r * 0.37), color: amber, size: 24)
        label("one turn = 360° = 2π rad", at: CGPoint(x: center.x, y: 25), color: .white.opacity(0.55), size: 11)
    }

    func rotor(speed: Double, phase: Double) {
        let radius: CGFloat = 73
        let box = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.stroke(Path(ellipseIn: box), with: .color(cyan.opacity(0.28)), lineWidth: 1)
        let a = phase * 2 * .pi
        for i in 0..<(speed > 0 ? 12 : 1) {
            let t = a - Double(i) * speed / 30
            let p = CGPoint(x: center.x + cos(t) * radius, y: center.y - sin(t) * radius)
            dot(p, radius: i == 0 ? 7 : 3, color: cyan.opacity(1 - Double(i) / 12))
        }
        let end = CGPoint(x: center.x + cos(a) * radius, y: center.y - sin(a) * radius)
        line(center, end, color: amber, width: 2)
        dot(center, color: amber)
        label("ω", at: CGPoint(x: center.x, y: center.y - 26), color: .white, size: 28)
        label("radians per second", at: CGPoint(x: center.x, y: 218), color: .white.opacity(0.6), size: 11)
    }

    func coordinate(value: Double, glyph: String, change: Bool) {
        let left: CGFloat = 35, right = size.width - 35, y: CGFloat = 135
        line(CGPoint(x: left, y: y), CGPoint(x: right, y: y), color: .white.opacity(0.4))
        for i in -5...5 {
            let x = center.x + CGFloat(i) * (right - left) / 10
            line(CGPoint(x: x, y: y - 4), CGPoint(x: x, y: y + 4), color: .white.opacity(0.4), width: 1)
        }
        let x = center.x + CGFloat(value) * (right - left) / 2
        if change {
            arrow(CGPoint(x: center.x, y: 100), CGPoint(x: x, y: 100), color: cyan, width: 3)
            dot(CGPoint(x: center.x, y: y), color: amber)
            label("initial", at: CGPoint(x: center.x, y: 173), color: amber, size: 11)
        }
        dot(CGPoint(x: x, y: y), radius: 8, color: cyan)
        label(glyph, at: CGPoint(x: x, y: 73), color: cyan, size: 26)
        label("−", at: CGPoint(x: left, y: 165), color: .white.opacity(0.5))
        label("+", at: CGPoint(x: right, y: 165), color: .white.opacity(0.5))
    }

    func circle(radius: Double, glyph: String, diameter: Bool = false) {
        let r = CGFloat(radius) * 87
        let box = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        context.stroke(Path(ellipseIn: box), with: .color(cyan.opacity(0.12)), lineWidth: 9)
        context.stroke(Path(ellipseIn: box), with: .color(cyan), lineWidth: 2)
        if diameter {
            line(CGPoint(x: center.x - r, y: center.y), CGPoint(x: center.x + r, y: center.y), color: amber)
            label("d", at: CGPoint(x: center.x, y: center.y + 16), color: amber)
        } else {
            line(center, CGPoint(x: center.x + r, y: center.y), color: amber)
            label("r", at: CGPoint(x: center.x + r * 0.5, y: center.y + 15), color: amber)
        }
        label(glyph, at: CGPoint(x: center.x, y: 25), color: .white.opacity(0.75))
    }

    func smallQuantity(_ value: Double) {
        let full: CGFloat = 70, r = full * sqrt(CGFloat(value))
        let box = CGRect(x: center.x - full, y: center.y - full, width: full * 2, height: full * 2)
        context.stroke(Path(ellipseIn: box), with: .color(.white.opacity(0.24)), style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
        context.fill(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)), with: .color(cyan.opacity(0.2)))
        context.stroke(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)), with: .color(cyan), lineWidth: 2)
        label("ι", at: center, color: amber, size: 36)
        label("area relative to one whole", at: CGPoint(x: center.x, y: 218), color: .white.opacity(0.6), size: 11)
    }
}
