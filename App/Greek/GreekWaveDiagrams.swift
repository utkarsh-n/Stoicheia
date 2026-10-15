import SwiftUI

extension GreekPainter {
    func wave(wavelength: Double, phase: Double, gamma: Bool) {
        let left: CGFloat = 24, right = size.width - 24
        let y = center.y
        line(CGPoint(x: left, y: y), CGPoint(x: right, y: y), color: .white.opacity(0.16), width: 1)
        var wave = Path()
        for i in 0...240 {
            let f = Double(i) / 240
            let x = left + CGFloat(f) * (right - left)
            let displacement = sin((f * 4 / wavelength - phase) * 2 * .pi)
            let point = CGPoint(x: x, y: y - CGFloat(displacement) * 48)
            if i == 0 { wave.move(to: point) } else { wave.addLine(to: point) }
        }
        context.stroke(wave, with: .color(cyan.opacity(0.13)), lineWidth: 10)
        context.stroke(wave, with: .color(cyan), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        let span = CGFloat(wavelength / 4) * (right - left)
        let start = CGPoint(x: left + 8, y: 198)
        arrow(start, CGPoint(x: start.x + span, y: start.y), color: amber)
        label("λ", at: CGPoint(x: start.x + span / 2, y: 179), color: amber, size: 24)
        label(gamma ? "γ photon · schematic scale" : "wave speed fixed at 2 model m/s", at: CGPoint(x: center.x, y: 25), color: .white.opacity(0.65), size: 11)
    }

    func wavefunction(state n: Int) {
        let left: CGFloat = 25, right = size.width - 25
        label("ψ amplitude", at: CGPoint(x: left, y: 24), color: cyan, size: 11, anchor: .leading)
        label("|ψ|² probability density", at: CGPoint(x: left, y: 143), color: amber, size: 11, anchor: .leading)
        var amplitude = Path(), density = Path()
        density.move(to: CGPoint(x: left, y: 216))
        for i in 0...180 {
            let f = Double(i) / 180
            let x = left + CGFloat(f) * (right - left)
            let psi = sqrt(2) * sin(Double(n) * .pi * f)
            let a = CGPoint(x: x, y: 82 - CGFloat(psi) * 27)
            let p = CGPoint(x: x, y: 216 - CGFloat(psi * psi) * 26)
            if i == 0 { amplitude.move(to: a) } else { amplitude.addLine(to: a) }
            density.addLine(to: p)
        }
        density.addLine(to: CGPoint(x: right, y: 216)); density.closeSubpath()
        line(CGPoint(x: left, y: 82), CGPoint(x: right, y: 82), color: .white.opacity(0.22), width: 1)
        context.stroke(amplitude, with: .color(cyan), lineWidth: 2)
        context.fill(density, with: .color(amber.opacity(0.25)))
        context.stroke(density, with: .color(amber), lineWidth: 1.5)
        for x in [left, right] {
            line(CGPoint(x: x, y: 43), CGPoint(x: x, y: 120), color: .white.opacity(0.45), width: 2)
        }
    }

    func limit(epsilon: Double) {
        let width = size.width - 60, height: CGFloat = 138
        let origin = CGPoint(x: center.x, y: 124)
        let band = CGFloat(epsilon) * 53
        context.fill(Path(CGRect(x: 30, y: origin.y - band, width: width, height: band * 2)), with: .color(amber.opacity(0.11)))
        context.fill(Path(CGRect(x: origin.x - band / 2, y: 45, width: band, height: height)), with: .color(cyan.opacity(0.12)))
        line(CGPoint(x: 30, y: origin.y), CGPoint(x: size.width - 30, y: origin.y), color: .white.opacity(0.25), width: 1)
        line(CGPoint(x: origin.x, y: 45), CGPoint(x: origin.x, y: 190), color: .white.opacity(0.25), width: 1)
        line(CGPoint(x: origin.x - 42, y: origin.y + 84), CGPoint(x: origin.x + 42, y: origin.y - 84), color: cyan, width: 3)
        for sign in [-1.0, 1.0] {
            let y = origin.y + CGFloat(sign) * band
            line(CGPoint(x: 30, y: y), CGPoint(x: size.width - 30, y: y), color: amber.opacity(0.55), width: 1)
        }
        dot(origin, color: .white)
        label("ε", at: CGPoint(x: size.width - 45, y: origin.y - band - 12), color: amber, size: 23)
        label("δ = ε/2", at: CGPoint(x: origin.x, y: 213), color: cyan)
        label("f(x) = 2x · a = 1 · L = 2", at: CGPoint(x: center.x, y: 24), color: .white.opacity(0.65), size: 11)
    }

    func series(count: Int, exponent: Double?) {
        let left: CGFloat = 26, width = size.width - 52
        let maximumCount = exponent == nil ? 12 : 40
        let spacing = width / CGFloat(maximumCount)
        let baseline: CGFloat = 190
        for i in 1...maximumCount {
            let height = exponent.map { CGFloat(pow(Double(i), -$0)) * 135 } ?? CGFloat(i) / 12 * 135
            let active = i <= count
            let bar = CGRect(x: left + CGFloat(i - 1) * spacing, y: baseline - height, width: max(2, spacing - 3), height: height)
            context.fill(Path(roundedRect: bar, cornerRadius: 2), with: .color(active ? cyan.opacity(0.85) : .white.opacity(0.08)))
            if maximumCount == 12 {
                label("\(i)", at: CGPoint(x: bar.midX, y: 208), color: active ? .white : .white.opacity(0.22), size: 10)
            }
        }
        label(exponent == nil ? "Σ · collect the illuminated terms" : "ζ · 40 terms, not the infinite sum", at: CGPoint(x: center.x, y: 25), color: .white.opacity(0.7), size: 11)
    }

    func growth(n: Double) {
        let left: CGFloat = 30, right = size.width - 30, bottom: CGFloat = 192
        let top: CGFloat = 52
        line(CGPoint(x: left, y: top), CGPoint(x: left, y: bottom), color: .white.opacity(0.3), width: 1)
        line(CGPoint(x: left, y: bottom), CGPoint(x: right, y: bottom), color: .white.opacity(0.3), width: 1)
        var linear = Path(), quadratic = Path()
        for i in 0...100 {
            let f = Double(i) / 100
            let x = left + CGFloat(f) * (right - left)
            let p = CGPoint(x: x, y: bottom - CGFloat(f) * (bottom - top) * 0.4)
            let q = CGPoint(x: x, y: bottom - CGFloat(f * f) * (bottom - top))
            if i == 0 { linear.move(to: p); quadratic.move(to: q) }
            else { linear.addLine(to: p); quadratic.addLine(to: q) }
        }
        context.stroke(linear, with: .color(cyan), lineWidth: 2)
        context.stroke(quadratic, with: .color(amber), lineWidth: 2)
        let x = left + CGFloat(n / 50) * (right - left)
        line(CGPoint(x: x, y: top), CGPoint(x: x, y: bottom), color: violet.opacity(0.6), width: 1)
        label("n (cyan) · n² (amber)", at: CGPoint(x: center.x, y: 25), color: .white.opacity(0.7), size: 11)
        label("separately scaled curves · ratio → 0", at: CGPoint(x: center.x, y: 217), color: .white.opacity(0.6), size: 10)
    }
}
