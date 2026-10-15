import SwiftUI
import ChemistryCore

struct AtomOrbView: View {
    let atom: AtomState
    var layer = AtomLayer.clouds
    var orbital = "2p"
    var running = true
    @State private var yaw = 0.35
    @State private var pitch = -0.2
    @State private var spinPhase = 0.0
    @GestureState private var translation = CGSize.zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var selectedOccupancy: OrbitalOccupancy? { atom.orbitals.first { $0.label == orbital } }
    private var cloudLabel: String {
        guard let selectedOccupancy else {
            return atom.electrons == 0 ? "NO ELECTRONS / BARE NUCLEUS" : "SELECT AN OCCUPIED SUBSHELL"
        }
        return "\(selectedOccupancy.label.uppercased()) / \(selectedOccupancy.electrons) e⁻ IN SUBSHELL"
    }
    var body: some View {
            Canvas { context, size in
                let angle = yaw + Double(translation.width) / 130 + spinPhase
                let tilt = pitch + Double(translation.height) / 160
                let radius = min(size.width, size.height) * 0.40
                let centre = CGPoint(x: size.width / 2, y: size.height / 2)
                drawGrid(&context, size: size)
                if layer == .clouds { drawCloud(&context, centre: centre, radius: radius, angle: angle, tilt: tilt) }
                if layer == .shells { drawShells(&context, centre: centre, radius: radius, angle: angle, tilt: tilt) }
                drawNucleus(&context, centre: centre, radius: layer == .nucleus ? radius * 0.65 : 16, angle: angle, tilt: tilt)
            }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 5) {
                Text(layer == .clouds ? cloudLabel : layer == .shells ? "\(atom.shells.count) SHELLS" : "\(atom.protons) p⁺ · \(atom.neutrons) n⁰")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(ToyStyle.cyan)
                Text("DRAG TO ROTATE").font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
            }.padding(8)
        }
        .contentShape(Rectangle())
        .gesture(DragGesture().updating($translation) { value, state, _ in state = value.translation }
            .onEnded { value in yaw += Double(value.translation.width) / 130; pitch += Double(value.translation.height) / 160 })
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(atom.element.name) \(layer.rawValue) visualisation")
        .accessibilityValue("\(atom.protons) protons, \(atom.neutrons) neutrons, \(atom.electrons) electrons; \(selectedOccupancy.map { "\($0.label) subshell selected" } ?? "no occupied subshell")")
        .accessibilityHint("Drag to rotate. Adjustable action rotates the model.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: yaw += 0.25
            case .decrement: yaw -= 0.25
            @unknown default: break
            }
        }
        .accessibilityIdentifier("atom-orb")
        .task(id: running && !reduceMotion) {
            guard running && !reduceMotion else { return }
            while !Task.isCancelled {
                do { try await Task.sleep(for: .milliseconds(33)) } catch { return }
                spinPhase += 0.0033
            }
        }
    }

    private func project(_ x: Double, _ y: Double, _ z: Double, centre: CGPoint, radius: Double, angle: Double, tilt: Double) -> (CGPoint, Double) {
        let xx = x * cos(angle) + z * sin(angle)
        let zz = -x * sin(angle) + z * cos(angle)
        let yy = y * cos(tilt) - zz * sin(tilt)
        let depth = y * sin(tilt) + zz * cos(tilt)
        return (CGPoint(x: centre.x + xx * radius, y: centre.y + yy * radius), depth)
    }
    private func noise(_ index: Int, _ salt: Double) -> Double {
        let value = sin(Double(index) * 127.1 + salt * 311.7) * 43758.5453
        return value - floor(value)
    }
    private func drawCloud(_ context: inout GraphicsContext, centre: CGPoint, radius: Double, angle: Double, tilt: Double) {
        guard let occupancy = selectedOccupancy else { return }
        let particles = OrbitalCloud.samples(n: occupancy.n, l: occupancy.l)
        for sample in particles {
            let (point, depth) = project(sample.x, sample.y, sample.z, centre: centre, radius: radius, angle: angle, tilt: tilt)
            let color = sample.positive ? ToyStyle.cyan : ToyStyle.violet
            let dot = 1.5 + (depth + 1) * 0.55
            context.fill(Path(ellipseIn: CGRect(x: point.x - dot/2, y: point.y - dot/2, width: dot, height: dot)), with: .color(color.opacity(0.22 + (depth + 1) * 0.2)))
        }
        // A visual bounding sphere gives the cloud a tactile, spatial presence.
        context.stroke(Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)), with: .color(ToyStyle.cyan.opacity(0.10)), lineWidth: 1)
    }
    private func drawShells(_ context: inout GraphicsContext, centre: CGPoint, radius: Double, angle: Double, tilt: Double) {
        for (shell, electrons) in atom.shells.enumerated() where electrons > 0 {
            let r = radius * (0.30 + Double(shell) * 0.11)
            let color = shell == atom.shells.count - 1 ? ToyStyle.cyan : ToyStyle.violet.opacity(0.6)
            var path = Path()
            for j in 0...100 {
                let a = Double(j) / 100 * .pi * 2
                let (point, _) = project(cos(a), sin(a), 0, centre: centre, radius: r, angle: angle * 0.35, tilt: tilt + Double(shell) * 0.16)
                if j == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            context.stroke(path, with: .color(color.opacity(0.35)), lineWidth: 1)
            for j in 0..<electrons {
                let a = Double(j) / Double(electrons) * .pi * 2
                let (point, _) = project(cos(a), sin(a), 0, centre: centre, radius: r, angle: angle * 0.35, tilt: tilt + Double(shell) * 0.16)
                context.fill(Path(ellipseIn: CGRect(x: point.x - 2.5, y: point.y - 2.5, width: 5, height: 5)), with: .color(color))
            }
        }
    }
    private func drawNucleus(_ context: inout GraphicsContext, centre: CGPoint, radius: Double, angle: Double, tilt: Double) {
        let total = atom.protons + atom.neutrons
        let drawn = min(total, layer == .nucleus ? 180 : 32)
        for i in 0..<drawn {
            let a = Double(i) * 2.39996
            let z = 1 - 2 * (Double(i) + 0.5) / Double(max(1, drawn))
            let xy = sqrt(max(0, 1 - z*z))
            let r = pow(noise(i, 7), 1.0/3)
            let (point, depth) = project(xy*cos(a)*r, xy*sin(a)*r, z*r, centre: centre, radius: radius, angle: angle, tilt: tilt)
            let d = layer == .nucleus ? 8.0 + depth * 2 : 4.0
            let isProton = Double(i) / Double(max(1, drawn)) < Double(atom.protons) / Double(max(1, total))
            let color = isProton ? ToyStyle.amber : ToyStyle.violet
            context.fill(Path(ellipseIn: CGRect(x: point.x - d/2, y: point.y - d/2, width: d, height: d)), with: .color(color.opacity(0.75 + depth * 0.15)))
        }
    }
    private func drawGrid(_ context: inout GraphicsContext, size: CGSize) {
        var path = Path()
        for x in stride(from: 0.0, through: size.width, by: 28) { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)) }
        for y in stride(from: 0.0, through: size.height, by: 28) { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)) }
        context.stroke(path, with: .color(.white.opacity(0.025)), lineWidth: 0.5)
    }
}
