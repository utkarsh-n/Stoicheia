import SwiftUI

private func bondPoint(_ vector: BondVector, size: CGSize, scale: Double) -> CGPoint {
    CGPoint(x: Double(size.width) / 2 + vector.x * scale, y: Double(size.height) / 2 + vector.y * scale)
}

private func bondLine(_ context: GraphicsContext, _ a: CGPoint, _ b: CGPoint, color: Color, width: Double = 2, dash: [CGFloat] = []) {
    var path = Path()
    path.move(to: a)
    path.addLine(to: b)
    context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, dash: dash))
}

private func bondDot(_ context: GraphicsContext, at point: CGPoint, color: Color, radius: Double = 3) {
    context.fill(Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)), with: .color(color))
}

private func bondArrow(_ context: GraphicsContext, from a: CGPoint, to b: CGPoint, color: Color) {
    bondLine(context, a, b, color: color, width: 2)
    let direction = atan2(b.y - a.y, b.x - a.x)
    for sign in [-1.0, 1.0] {
        let end = CGPoint(x: b.x - 8 * cos(direction + sign * 0.45), y: b.y - 8 * sin(direction + sign * 0.45))
        bondLine(context, b, end, color: color, width: 2)
    }
}

struct BondLewisCanvas: View {
    let molecule: BondMolecule
    let progress: Double

    var body: some View {
        Canvas { context, size in
            let atoms = molecule.atoms
            let scale = min(Double(size.width) / 3.4, Double(size.height) / 3.2)
            let centers = atoms.map { bondPoint($0.lewis, size: size, scale: scale) }
            var used = Array(repeating: 0, count: atoms.count)

            func originalDot(_ atomIndex: Int, _ electronIndex: Int) -> CGPoint {
                let side = electronIndex % 4
                let paired = electronIndex >= 4 ? 1.0 : -1.0
                let angle = Double(side) * .pi / 2 - .pi / 2
                let center = centers[atomIndex]
                return CGPoint(x: center.x + 31 * cos(angle) - paired * 4 * sin(angle), y: center.y + 31 * sin(angle) + paired * 4 * cos(angle))
            }
            func movingDot(_ origin: CGPoint, _ target: CGPoint, _ color: Color) {
                bondDot(context, at: CGPoint(x: origin.x + (target.x - origin.x) * progress, y: origin.y + (target.y - origin.y) * progress), color: color)
            }

            for connection in molecule.connections {
                let a = centers[connection.first], b = centers[connection.second]
                let dx = b.x - a.x, dy = b.y - a.y
                let length = max(1, hypot(dx, dy))
                let px = -dy / length, py = dx / length
                let midpoint = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
                for pair in 0..<connection.order {
                    let pairOffset = Double(pair) * 14 - Double(connection.order - 1) * 7
                    for side in 0..<2 {
                        let index = side == 0 ? connection.first : connection.second
                        let offset = pairOffset + (side == 0 ? -4.0 : 4.0)
                        let target = CGPoint(x: midpoint.x + px * offset, y: midpoint.y + py * offset)
                        movingDot(originalDot(index, used[index]), target, atoms[index].color)
                        used[index] += 1
                    }
                }
                let start = CGPoint(x: a.x + dx / length * 19, y: a.y + dy / length * 19)
                let end = CGPoint(x: b.x - dx / length * 19, y: b.y - dy / length * 19)
                bondLine(context, start, end, color: .white.opacity(progress * 0.22), width: 1)
            }

            if molecule == .salt {
                for electron in 0..<7 {
                    movingDot(originalDot(1, electron), originalDot(1, electron), atoms[1].color)
                }
                movingDot(originalDot(0, 0), originalDot(1, 7), atoms[0].color)
                if progress > 0.5 {
                    context.draw(Text("⁺").font(.title2).foregroundStyle(ToyStyle.amber), at: CGPoint(x: centers[0].x + 21, y: centers[0].y - 20))
                    context.draw(Text("⁻").font(.title2).foregroundStyle(ToyStyle.cyan), at: CGPoint(x: centers[1].x + 21, y: centers[1].y - 20))
                }
            } else {
                for index in atoms.indices {
                    let atom = atoms[index]
                    for pair in 0..<atom.lonePairs {
                        // Lone pairs stay outside the bonds; this is a Lewis map, not an orbital shape.
                        let angle: Double
                        if atom.id == 0 && molecule == .water { angle = pair == 0 ? -.pi * 0.75 : -.pi * 0.25 }
                        else if atom.id == 0 && molecule == .ammonia { angle = -.pi / 2 }
                        else { angle = pair == 0 ? -.pi / 2 : .pi / 2 }
                        for side in 0..<2 {
                            let offset = side == 0 ? -4.0 : 4.0
                            let target = CGPoint(x: centers[index].x + 30 * cos(angle) - offset * sin(angle), y: centers[index].y + 30 * sin(angle) + offset * cos(angle))
                            movingDot(originalDot(index, used[index]), target, atom.color)
                            used[index] += 1
                        }
                    }
                }
            }
            for index in atoms.indices {
                context.draw(Text(atoms[index].symbol).font(.system(size: 23, weight: .bold, design: .rounded)).foregroundStyle(atoms[index].color), at: centers[index])
            }
        }
        .accessibilityLabel("Lewis electron map for \(molecule.name). \(molecule.totalValence) total valence electrons, \(molecule.sharedPairs) shared pairs, \(molecule.nonbondingPairs) nonbonding pairs.")
        .accessibilityIdentifier("bond-lewis-canvas")
    }
}

struct BondMoleculeCanvas: View {
    let molecule: BondMolecule
    let yaw: Double
    let pitch: Double
    let showPolarity: Bool
    let showDomains: Bool

    var body: some View {
        Canvas { context, size in
            let scale = min(Double(size.width) / 4.2, Double(size.height) / 3.8)
            let atoms = molecule == .salt ? latticeAtoms : molecule.atoms
            let positions = atoms.map { $0.position.rotated(yaw: yaw, pitch: pitch) }
            let centers = positions.map { bondPoint($0, size: size, scale: scale) }
            let connections = molecule == .salt ? latticeConnections(atoms) : molecule.connections
            if showDomains && molecule != .salt {
                for connection in connections {
                    let a = centers[connection.first], b = centers[connection.second]
                    let midpoint = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
                    context.fill(Path(ellipseIn: CGRect(x: midpoint.x - 33, y: midpoint.y - 24, width: 66, height: 48)), with: .color(ToyStyle.cyan.opacity(0.12)))
                }
                for atom in atoms where atom.lonePairs > 0 {
                    for index in 0..<atom.lonePairs {
                        let local: BondVector
                        if molecule == .water {
                            local = BondVector(x: index == 0 ? -0.42 : 0.42, y: -0.62, z: -0.18)
                        } else if molecule == .ammonia {
                            local = BondVector(x: 0, y: -0.72, z: -0.18)
                        } else {
                            local = BondVector(x: 0, y: index == 0 ? -0.58 : 0.58, z: 0)
                        }
                        let vector = BondVector(x: atom.position.x + local.x, y: atom.position.y + local.y, z: atom.position.z + local.z).rotated(yaw: yaw, pitch: pitch)
                        let point = bondPoint(vector, size: size, scale: scale)
                        context.fill(Path(ellipseIn: CGRect(x: point.x - 21, y: point.y - 28, width: 42, height: 56)), with: .color(ToyStyle.violet.opacity(0.24)))
                        bondDot(context, at: CGPoint(x: point.x - 5, y: point.y), color: ToyStyle.violet)
                        bondDot(context, at: CGPoint(x: point.x + 5, y: point.y), color: ToyStyle.violet)
                    }
                }
            }
            for connection in connections {
                let a = centers[connection.first], b = centers[connection.second]
                let z = (positions[connection.first].z + positions[connection.second].z) / 2
                let opacity = max(0.25, min(0.75, 0.5 + z * 0.15))
                let dx = b.x - a.x, dy = b.y - a.y, length = max(1, hypot(dx, dy))
                for order in 0..<connection.order {
                    let shift = Double(order) * 7 - Double(connection.order - 1) * 3.5
                    bondLine(context, CGPoint(x: a.x - dy / length * shift, y: a.y + dx / length * shift), CGPoint(x: b.x - dy / length * shift, y: b.y + dx / length * shift), color: .white.opacity(opacity), width: molecule == .salt ? 1.5 : 5, dash: molecule == .salt ? [4, 4] : [])
                }
                if showPolarity && molecule != .salt {
                    let en = atoms[connection.second].electronegativity - atoms[connection.first].electronegativity
                    if abs(en) > 0.05 {
                        let start = en > 0 ? a : b, end = en > 0 ? b : a
                        let s = CGPoint(x: start.x * 0.7 + end.x * 0.3 - dy / length * 15, y: start.y * 0.7 + end.y * 0.3 + dx / length * 15)
                        let e = CGPoint(x: start.x * 0.3 + end.x * 0.7 - dy / length * 15, y: start.y * 0.3 + end.y * 0.7 + dx / length * 15)
                        bondArrow(context, from: s, to: e, color: ToyStyle.amber)
                    }
                }
            }
            for index in atoms.indices.sorted(by: { positions[$0].z < positions[$1].z }) {
                let atom = atoms[index], center = centers[index]
                let radius = molecule == .salt ? 13.0 : (atom.symbol == "H" ? 17.0 : 23.0)
                let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .radialGradient(Gradient(colors: [atom.color.opacity(0.95), atom.color.opacity(0.32)]), center: CGPoint(x: center.x - radius * 0.35, y: center.y - radius * 0.4), startRadius: 1, endRadius: radius * 1.7))
                context.stroke(Path(ellipseIn: rect), with: .color(atom.color.opacity(0.85)), lineWidth: 1)
                let label = molecule == .salt ? (atom.symbol == "Na" ? "+" : "−") : atom.symbol
                context.draw(Text(label).font(.system(size: molecule == .salt ? 14 : 19, weight: .bold, design: .rounded)).foregroundStyle(.white), at: center)
            }
        }
        .accessibilityLabel("Rotatable \(molecule.shape.lowercased()) model of \(molecule.name). \(molecule.angle). Use the rotation slider to change viewpoint.")
        .accessibilityValue("\(Int((yaw * 180 / .pi).rounded())) degrees yaw, \(Int((pitch * 180 / .pi).rounded())) degrees tilt. \(overlaySummary)")
        .accessibilityIdentifier("bond-molecule-canvas")
    }

    private var overlaySummary: String {
        if molecule == .salt { return "Ionic lattice fragment. Molecular electron-region and polarity overlays do not apply." }
        var descriptions: [String] = []
        if showDomains {
            descriptions.append("\(molecule.connections.count) bonding regions and \(molecule.nonbondingPairs) lone-pair regions shown.")
        } else {
            descriptions.append("Electron regions hidden.")
        }
        if showPolarity {
            let atoms = molecule.atoms
            let arrowCount = molecule.connections.filter { abs(atoms[$0.second].electronegativity - atoms[$0.first].electronegativity) > 0.05 }.count
            descriptions.append("Polarity overlay on: \(arrowCount) bond polarity arrows shown.")
        } else {
            descriptions.append("Bond polarity arrows hidden.")
        }
        return descriptions.joined(separator: " ")
    }

    private var latticeAtoms: [BondAtom] {
        var result: [BondAtom] = []
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    let sodium = (x + y + z) % 2 == 0
                    let position = BondVector(x: Double(x) * 0.75, y: Double(y) * 0.75, z: Double(z) * 0.75)
                    result.append(BondAtom(id: result.count, symbol: sodium ? "Na" : "Cl", valence: 0, lonePairs: 0, electronegativity: 0, position: position, lewis: position))
                }
            }
        }
        return result
    }

    private func latticeConnections(_ atoms: [BondAtom]) -> [BondConnection] {
        var result: [BondConnection] = []
        for first in atoms.indices {
            for second in atoms.indices where second > first {
                let a = atoms[first].position, b = atoms[second].position
                let distance = abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)
                if abs(distance - 0.75) < 0.01 { result.append(.init(first: first, second: second, order: 1)) }
            }
        }
        return result
    }
}

struct BondPotentialCanvas: View {
    let distance: Double
    var body: some View {
        Canvas { context, size in
            let left = 35.0, right = Double(size.width) - 18, top = 16.0, bottom = Double(size.height) - 29
            func point(_ r: Double, _ energy: Double) -> CGPoint {
                CGPoint(x: left + (r - 0.55) / 2.45 * (right - left), y: bottom - (min(2.0, max(-1.15, energy)) + 1.15) / 3.15 * (bottom - top))
            }
            bondLine(context, CGPoint(x: left, y: top), CGPoint(x: left, y: bottom), color: .white.opacity(0.3), width: 1)
            bondLine(context, CGPoint(x: left, y: bottom), CGPoint(x: right, y: bottom), color: .white.opacity(0.3), width: 1)
            let zero = point(0.55, 0).y
            bondLine(context, CGPoint(x: left, y: zero), CGPoint(x: right, y: zero), color: .white.opacity(0.18), width: 1, dash: [4, 4])
            var path = Path()
            for index in 0...200 {
                let r = 0.55 + Double(index) / 200 * 2.45
                let p = point(r, BondPhysics.potential(r))
                if index == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            context.stroke(path, with: .color(ToyStyle.cyan), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            let minimum = point(1, -1)
            bondLine(context, minimum, CGPoint(x: minimum.x, y: bottom), color: ToyStyle.violet.opacity(0.5), width: 1, dash: [3, 4])
            let cursor = point(distance, BondPhysics.potential(distance))
            bondLine(context, cursor, CGPoint(x: cursor.x, y: bottom), color: ToyStyle.amber.opacity(0.6), width: 1)
            bondDot(context, at: cursor, color: ToyStyle.amber, radius: 6)
            context.draw(Text("E").font(.caption.monospaced()).foregroundStyle(.secondary), at: CGPoint(x: 13, y: 25))
            context.draw(Text("separation r / r₀").font(.caption.monospaced()).foregroundStyle(.secondary), at: CGPoint(x: (left + right) / 2, y: bottom + 18))
            context.draw(Text("0").font(.caption.monospaced()).foregroundStyle(.secondary), at: CGPoint(x: 22, y: zero))
        }
        .accessibilityLabel("Qualitative potential energy well. Current separation \(distance, specifier: "%.2f") times the equilibrium distance. Relative energy \(BondPhysics.potential(distance), specifier: "%.2f").")
        .accessibilityIdentifier("bond-potential-chart")
    }
}
