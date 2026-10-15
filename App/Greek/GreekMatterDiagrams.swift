import SwiftUI

extension GreekPainter {
    func efficiency(_ fraction: Double) {
        let rect = CGRect(x: 35, y: 82, width: size.width - 70, height: 65)
        context.fill(Path(roundedRect: rect, cornerRadius: 12), with: .color(amber.opacity(0.25)))
        let useful = CGRect(x: rect.minX, y: rect.minY, width: rect.width * CGFloat(fraction), height: rect.height)
        context.fill(Path(roundedRect: useful, cornerRadius: 12), with: .color(cyan.opacity(0.7)))
        context.stroke(Path(roundedRect: rect, cornerRadius: 12), with: .color(.white.opacity(0.3)), lineWidth: 1)
        label("100 J in", at: CGPoint(x: center.x, y: 52), color: .white)
        label("useful work", at: CGPoint(x: 35, y: 180), color: cyan, size: 12, anchor: .leading)
        label("other transfers", at: CGPoint(x: size.width - 35, y: 204), color: amber, size: 12, anchor: .trailing)
        label("η", at: center, color: .white, size: 34)
    }

    func friction(_ coefficient: Double) {
        let block = CGRect(x: center.x - 35, y: 82, width: 70, height: 65)
        context.fill(Path(roundedRect: block, cornerRadius: 10), with: .color(cyan.opacity(0.2)))
        context.stroke(Path(roundedRect: block, cornerRadius: 10), with: .color(cyan), lineWidth: 2)
        line(CGPoint(x: 30, y: 151), CGPoint(x: size.width - 30, y: 151), color: amber, width: 2)
        for i in 0..<14 {
            let x = CGFloat(30 + i * 20)
            guard x < size.width - 30 else { break }
            line(CGPoint(x: x, y: 156), CGPoint(x: x - 8, y: 166), color: amber.opacity(0.3), width: 1)
        }
        arrow(CGPoint(x: center.x, y: 65), CGPoint(x: center.x + 66, y: 65), color: .white.opacity(0.5))
        arrow(CGPoint(x: center.x, y: 118), CGPoint(x: center.x - CGFloat(coefficient) * 88, y: 118), color: amber, width: 3)
        label("sliding →", at: CGPoint(x: center.x, y: 35), color: .white.opacity(0.6), size: 11)
        label(coefficient == 0 ? "friction = 0 · N = 10 N" : "← friction · N = 10 N", at: CGPoint(x: center.x, y: 206), color: amber, size: 12)
    }

    func density(count: Int) {
        let box = CGRect(x: center.x - 82, y: 43, width: 164, height: 154)
        context.stroke(Path(roundedRect: box, cornerRadius: 12), with: .color(.white.opacity(0.35)), lineWidth: 1)
        for i in 0..<count {
            let col = i % 8, row = i / 8
            let p = CGPoint(x: box.minX + 15 + CGFloat(col) * 19, y: box.minY + 20 + CGFloat(row) * 28)
            dot(p, radius: 4, color: i.isMultiple(of: 3) ? amber : cyan)
        }
        label("1 dot = 1 kg · volume = 1 m³", at: CGPoint(x: center.x, y: 218), color: .white.opacity(0.65), size: 10)
    }

    func torque(force: Double) {
        let pivot = CGPoint(x: 55, y: 142), end = CGPoint(x: size.width - 60, y: 142)
        line(pivot, end, color: cyan, width: 6)
        dot(pivot, radius: 9, color: amber)
        arrow(CGPoint(x: end.x, y: end.y - 5), CGPoint(x: end.x, y: end.y - 5 - CGFloat(force) * 6), color: amber, width: 3)
        label("F", at: CGPoint(x: end.x + 18, y: 98), color: amber, size: 22)
        label("r = 1 metre", at: CGPoint(x: center.x, y: 173), color: cyan, size: 12)
        var arc = Path()
        arc.addArc(center: pivot, radius: 27, startAngle: .degrees(-20), endAngle: .degrees(-110), clockwise: true)
        context.stroke(arc, with: .color(violet), lineWidth: 2)
        label("τ", at: CGPoint(x: 47, y: 98), color: violet, size: 27)
        label("force perpendicular to the lever", at: CGPoint(x: center.x, y: 218), color: .white.opacity(0.65), size: 10)
    }

    func goldenSplit(_ fraction: Double) {
        let left: CGFloat = 28, width = size.width - 56
        let y: CGFloat = 114, split = left + width * CGFloat(fraction)
        line(CGPoint(x: left, y: y), CGPoint(x: split, y: y), color: cyan, width: 14)
        line(CGPoint(x: split + 2, y: y), CGPoint(x: left + width, y: y), color: amber, width: 14)
        dot(CGPoint(x: split, y: y), radius: 6, color: .white)
        let target = left + width * CGFloat(1 / ((1 + sqrt(5)) / 2))
        line(CGPoint(x: target, y: 142), CGPoint(x: target, y: 166), color: violet, width: 2)
        label("golden split", at: CGPoint(x: target, y: 185), color: violet, size: 11)
        label("long", at: CGPoint(x: left + (split - left) / 2, y: 80), color: cyan)
        label("short", at: CGPoint(x: split + (left + width - split) / 2, y: 80), color: amber)
        label("φ ≈ 1.6180339…", at: CGPoint(x: center.x, y: 29), color: .white.opacity(0.7))
    }

    func chiSquare(observed: Double) {
        let base: CGFloat = 180, height: CGFloat = 110
        for (i, amount) in [observed, 40 - observed].enumerated() {
            let x = center.x + CGFloat(i == 0 ? -58 : 32)
            let rect = CGRect(x: x, y: base - CGFloat(amount / 40) * height, width: 42, height: CGFloat(amount / 40) * height)
            context.fill(Path(roundedRect: rect, cornerRadius: 5), with: .color(cyan.opacity(0.7)))
            let expectedY = base - height / 2
            line(CGPoint(x: x - 6, y: expectedY), CGPoint(x: x + 48, y: expectedY), color: amber, width: 2)
            label(i == 0 ? "A" : "B", at: CGPoint(x: x + 21, y: 203), color: .white)
        }
        label("cyan: observed · amber: expected", at: CGPoint(x: center.x, y: 29), color: .white.opacity(0.7), size: 10)
        label("40 observations · expected 20 + 20", at: CGPoint(x: center.x, y: 225), color: .white.opacity(0.5), size: 10)
    }

    func upsilon(separation: Double) {
        let distance = 24 + CGFloat(separation) * 48
        let left = CGPoint(x: center.x - distance, y: center.y)
        let right = CGPoint(x: center.x + distance, y: center.y)
        var spring = Path()
        for i in 0...80 {
            let f = CGFloat(i) / 80
            let p = CGPoint(x: left.x + f * (right.x - left.x), y: center.y + sin(f * .pi * 16) * 7)
            if i == 0 { spring.move(to: p) } else { spring.addLine(to: p) }
        }
        context.stroke(spring, with: .color(violet.opacity(0.65)), lineWidth: 2)
        dot(left, radius: 15, color: cyan)
        dot(right, radius: 15, color: amber)
        label("b", at: left, color: ToyStyle.background, size: 17)
        label("b̄", at: right, color: ToyStyle.background, size: 17)
        label("Υ · bottom + antibottom", at: CGPoint(x: center.x, y: 32), color: .white.opacity(0.75), size: 12)
        label("a bound-state illustration", at: CGPoint(x: center.x, y: 213), color: .white.opacity(0.5), size: 11)
    }

    func betaDecay(progress: Double) {
        let neutron = CGPoint(x: center.x - 45, y: center.y)
        let transformed = progress >= 0.5
        dot(neutron, radius: 23, color: transformed ? amber : cyan)
        label(transformed ? "p⁺" : "n", at: neutron, color: ToyStyle.background, size: 21)
        let separation = CGFloat(max(0, (progress - 0.5) * 2))
        if transformed {
            // Both products must remain visible at the transition, before the scrubbed paths spread.
            let verticalSeparation = 12 + separation * 36
            let electron = CGPoint(x: neutron.x + 45 + separation * 77, y: neutron.y - verticalSeparation)
            let antineutrino = CGPoint(x: neutron.x + 45 + separation * 77, y: neutron.y + verticalSeparation)
            arrow(neutron, electron, color: cyan.opacity(0.45))
            arrow(neutron, antineutrino, color: violet.opacity(0.45))
            dot(electron, radius: 7, color: cyan)
            dot(antineutrino, radius: 5, color: violet)
            label("e⁻", at: CGPoint(x: electron.x, y: electron.y - 20), color: cyan)
            label("ν̄ₑ", at: CGPoint(x: antineutrino.x, y: antineutrino.y + 20), color: violet)
        }
        label("β⁻ · one illustrative event", at: CGPoint(x: center.x, y: 32), color: .white.opacity(0.7), size: 11)
        label("charge and lepton number conserved", at: CGPoint(x: center.x, y: 219), color: .white.opacity(0.5), size: 10)
    }
}
