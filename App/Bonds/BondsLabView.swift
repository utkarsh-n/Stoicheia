import SwiftUI

struct BondsLabView: View {
    let initialAtomicNumber: Int
    @State private var molecule: BondMolecule = .water
    @State private var stage: BondStage = .electrons
    @State private var exploration: BondExploration

    init(initialAtomicNumber: Int = 6) {
        self.initialAtomicNumber = initialAtomicNumber
        _molecule = State(initialValue: Self.moleculeForElement(initialAtomicNumber))
        _exploration = State(initialValue: BondExploration(molecule: Self.moleculeForElement(initialAtomicNumber)))
    }

    private static func moleculeForElement(_ atomicNumber: Int) -> BondMolecule {
        switch atomicNumber {
        case 6: .methane
        case 8: .water
        case 7: .ammonia
        case 11, 17: .salt
        case 1: .hydrogen
        default: .water
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FROM ELECTRONS TO LIFE")
                        .font(.caption.weight(.semibold).monospaced())
                        .foregroundStyle(ToyStyle.cyan)
                    Text("Bonds are a beginning.")
                        .font(.title2.bold())
                    Text("Share electrons. Turn a molecule. Feel why shape changes what matter can do.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                moleculePicker
                stagePicker
                selectedContent
                Text("Teaching models: dots count electrons; spheres locate nuclei; rods indicate connectivity. Electron density is quantum, and real molecules vibrate.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .background(ToyStyle.background)
        .onChange(of: initialAtomicNumber) { _, number in molecule = Self.moleculeForElement(number) }
        .onChange(of: molecule) { _, new in exploration.follow(new) }
        .sensoryFeedback(.selection, trigger: molecule)
        .sensoryFeedback(.selection, trigger: stage)
        .accessibilityIdentifier("bonds-lab")
    }

    private var moleculePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(BondMolecule.allCases) { item in
                        Button {
                            molecule = item
                        } label: {
                            VStack(spacing: 3) {
                                Text(item.formula).font(.headline.monospaced())
                                Text(item == .salt ? "Crystal" : item.name).font(.caption2)
                            }
                            .frame(minWidth: 67, minHeight: 48)
                        }
                        .buttonStyle(.glass)
                        .tint(molecule == item ? ToyStyle.cyan : .white.opacity(0.5))
                        .accessibilityLabel(item == .salt ? "Sodium chloride crystal" : item.name)
                        .accessibilityAddTraits(molecule == item ? .isSelected : [])
                        .accessibilityIdentifier("bond-molecule-\(item.rawValue)")
                    }
                }
            }
            .padding(.vertical, 3)
        }
        .accessibilityIdentifier("bond-molecule-picker")
    }

    private var stagePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(BondStage.allCases.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 3)
                    }
                    Button {
                        stage = item
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: item.symbol).font(.title3)
                            Text(item.rawValue).font(.caption.weight(.medium))
                        }
                        .frame(width: 67, height: 62)
                        .foregroundStyle(stage == item ? ToyStyle.cyan : .secondary)
                        .background(stage == item ? ToyStyle.cyan.opacity(0.10) : .clear, in: RoundedRectangle(cornerRadius: 15))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Learning stage: \(item.rawValue)")
                    .accessibilityAddTraits(stage == item ? .isSelected : [])
                    .accessibilityIdentifier("bond-stage-\(item.rawValue.lowercased())")
                }
            }
        }
        .accessibilityIdentifier("bond-stage-picker")
    }

    @ViewBuilder private var selectedContent: some View {
        switch stage {
        case .electrons: BondElectronView(molecule: molecule, progress: $exploration.electronProgress)
        case .shape: BondShapeView(molecule: molecule, yaw: $exploration.yaw, pitch: $exploration.pitch, showPolarity: $exploration.showPolarity, showDomains: $exploration.showDomains)
        case .binding: BondBindingView(molecule: molecule, distance: $exploration.distance)
        case .reactions: BondReactionView(molecule: molecule, reaction: $exploration.reaction, progress: $exploration.reactionProgress, thermal: $exploration.thermal, catalyst: $exploration.catalyst)
        case .life: BondLifeView(molecule: molecule, link: $exploration.lifeLink, progress: $exploration.lifeProgress)
        }
    }
}

struct BondPanel<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder var content: Content

    init(_ title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                if let subtitle { Text(subtitle).font(.caption).foregroundStyle(.secondary) }
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ToyStyle.panel, in: RoundedRectangle(cornerRadius: 23))
        .overlay(RoundedRectangle(cornerRadius: 23).strokeBorder(.white.opacity(0.07), lineWidth: 1))
    }
}

struct BondReadout: View {
    let label: String
    let value: String
    var color: Color = ToyStyle.cyan
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.title3.weight(.semibold).monospaced()).foregroundStyle(color)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct BondElectronView: View {
    let molecule: BondMolecule
    @Binding var progress: Double
    private var milestone: Int { progress < 0.01 ? 0 : (progress > 0.99 ? 2 : 1) }

    var body: some View {
        BondPanel("\(molecule.formula) · Valence → bonds", subtitle: "Every visible dot is one valence electron.") {
            BondLewisCanvas(molecule: molecule, progress: progress)
                .frame(height: 238)
                .background(ToyStyle.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 17))
            HStack {
                BondReadout(label: "Valence electrons", value: "\(molecule.totalValence)")
                BondReadout(label: molecule == .salt ? "Transferred" : "Shared pairs", value: molecule == .salt ? "1 e⁻" : "\(molecule.sharedPairs)", color: ToyStyle.amber)
                BondReadout(label: "Lone pairs", value: "\(molecule.nonbondingPairs)", color: ToyStyle.violet)
            }
            .accessibilityIdentifier("bond-electron-readout")
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Separate atoms").font(.caption)
                    Spacer()
                    Text(molecule == .salt ? "Transfer" : "Share").font(.caption).foregroundStyle(ToyStyle.cyan)
                }
                Slider(value: $progress, in: 0...1)
                    .tint(ToyStyle.cyan)
                    .accessibilityLabel(molecule == .salt ? "Electron transfer" : "Electron sharing")
                    .accessibilityValue("\(Int(progress * 100)) percent")
                    .accessibilityIdentifier("bond-sharing-slider")
                Text("Bond map: \(Int((progress * 100).rounded()))% assembled")
                    .font(.caption.monospaced()).foregroundStyle(ToyStyle.cyan)
                    .accessibilityIdentifier("bond-sharing-progress-value")
            }
            Text(molecule.electronExplanation).font(.subheadline)
            Text("Lewis dots are a bookkeeping picture, not little particles following these paths. The octet rule is useful for these examples, not a universal law.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .sensoryFeedback(.selection, trigger: milestone)
    }
}

struct BondShapeView: View {
    let molecule: BondMolecule
    @Binding var yaw: Double
    @Binding var pitch: Double
    @Binding var showPolarity: Bool
    @Binding var showDomains: Bool
    @State private var dragStart: (yaw: Double, pitch: Double)?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 16) {
            BondPanel("\(molecule.formula) · \(molecule.shape)", subtitle: "Drag to turn. A 2D projection can hide a 3D arrangement.") {
                BondMoleculeCanvas(molecule: molecule, yaw: yaw, pitch: pitch, showPolarity: showPolarity, showDomains: showDomains)
                    .frame(height: 266)
                    .background(ToyStyle.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 17))
                    .gesture(DragGesture(minimumDistance: 3)
                        .onChanged { value in
                            if dragStart == nil { dragStart = (yaw, pitch) }
                            yaw = BondPhysics.normalizedYaw((dragStart?.yaw ?? 0) + Double(value.translation.width) / 110)
                            pitch = min(1.3, max(-1.3, (dragStart?.pitch ?? 0) - Double(value.translation.height) / 150))
                        }
                        .onEnded { _ in dragStart = nil })
                HStack {
                    BondReadout(label: molecule == .salt ? "Coordination" : "Bond angle", value: molecule.angle)
                    BondReadout(label: "Molecular polarity", value: molecule == .salt ? "Ionic crystal" : (molecule.isPolar ? "Polar" : "Nonpolar"), color: ToyStyle.amber)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("bond-shape-readout")
                Slider(value: $yaw, in: -Double.pi...Double.pi)
                    .tint(ToyStyle.cyan)
                    .accessibilityLabel("Molecule rotation")
                    .accessibilityValue("\(Int(yaw * 180 / .pi)) degrees")
                    .accessibilityIdentifier("bond-rotation-slider")
                Text("Viewpoint: \(Int((yaw * 180 / .pi).rounded()))° yaw · \(Int((pitch * 180 / .pi).rounded()))° tilt")
                    .font(.caption.monospaced()).foregroundStyle(.secondary)
                    .accessibilityIdentifier("bond-rotation-value")
                GlassEffectContainer(spacing: 10) {
                    HStack(spacing: 10) {
                        Button("Face on", systemImage: "arrow.counterclockwise") {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) { yaw = 0; pitch = 0 }
                        }
                        .buttonStyle(.glass)
                        .accessibilityIdentifier("bond-rotation-reset")
                        Button("Tilt", systemImage: "rotate.3d") {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) { yaw = 0.6; pitch = -0.65 }
                        }
                        .buttonStyle(.glass)
                        .accessibilityIdentifier("bond-rotation-tilt")
                    }
                    .controlSize(.large)
                }
                if molecule != .salt {
                    Toggle("Electron regions", isOn: $showDomains).tint(ToyStyle.violet)
                        .accessibilityIdentifier("bond-domains-toggle")
                    Toggle("Bond polarity arrows", isOn: $showPolarity).tint(ToyStyle.amber)
                        .accessibilityIdentifier("bond-polarity-toggle")
                }
                Text(molecule.shapeExplanation).font(.subheadline)
                if showDomains && molecule != .salt {
                    Text("Blue regions suggest shared density; violet suggests lone pairs. These schematic lobes are not computed molecular orbitals.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            BondPanel("Why the charge pulls this way") {
                Text(molecule.polarityExplanation).font(.subheadline)
                if molecule != .salt {
                    HStack {
                        ForEach(uniqueElements, id: \.symbol) { atom in
                            BondReadout(label: "χ \(atom.symbol) · Pauling", value: String(format: "%.2f", atom.electronegativity), color: atom.color)
                        }
                    }
                    Text("χ measures attraction for bonded electrons. Arrows point δ+ → δ− using the chemistry convention; their lengths are illustrative.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: showPolarity)
        .sensoryFeedback(.selection, trigger: showDomains)
    }

    private var uniqueElements: [BondAtom] {
        var symbols = Set<String>()
        return molecule.atoms.filter { symbols.insert($0.symbol).inserted }
    }
}

struct BondBindingView: View {
    let molecule: BondMolecule
    @Binding var distance: Double
    private var zone: Int { distance < 0.92 ? -1 : (distance > 1.08 ? 1 : 0) }
    private var stateLabel: String { zone < 0 ? "Repulsion dominates" : (zone > 0 ? "Attraction pulls inward" : "Near the energy minimum") }

    var body: some View {
        BondPanel("Binding · Find the resting distance", subtitle: "A generic potential well, with dimensionless axes.") {
            BondPotentialCanvas(distance: distance).frame(height: 200)
            HStack {
                BondReadout(label: "r / r₀", value: String(format: "%.2f", distance), color: ToyStyle.amber)
                BondReadout(label: "Relative E", value: String(format: "%.2f", BondPhysics.potential(distance)))
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("bond-binding-readout")
            separationVisual
            Slider(value: $distance, in: 0.55...3)
                .tint(ToyStyle.amber)
                .accessibilityLabel("Atom separation relative to equilibrium")
                .accessibilityValue(String(format: "%.2f", distance))
                .accessibilityIdentifier("bond-distance-slider")
            Text(stateLabel).font(.subheadline.bold()).foregroundStyle(zone == 0 ? ToyStyle.cyan : ToyStyle.amber)
                .accessibilityIdentifier("bond-binding-state")
            Button("Return to minimum", systemImage: "scope") { distance = 1 }
                .buttonStyle(.glass)
                .controlSize(.large)
                .accessibilityIdentifier("bond-equilibrium-button")
            Text("Too close, overlapping electron clouds and nuclear repulsion raise energy. Too far, attraction weakens. A stable separation lies at the balance, where the energy curve is lowest.")
                .font(.subheadline)
            Text("This Morse-style curve illustrates a pair interaction. It is not fitted to \(molecule.formula), and does not calculate lattice energy, binding affinity, or a real reaction pathway.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .sensoryFeedback(.selection, trigger: zone)
    }

    private var separationVisual: some View {
        GeometryReader { geometry in
            let separation = min(geometry.size.width - 55, 36 + distance * 57)
            let center = geometry.size.width / 2
            ZStack {
                Capsule().fill(ToyStyle.cyan.opacity(0.12)).frame(width: separation, height: 26)
                Circle().fill(ToyStyle.violet).frame(width: 28, height: 28).position(x: center - separation / 2, y: 24)
                Circle().fill(ToyStyle.cyan).frame(width: 28, height: 28).position(x: center + separation / 2, y: 24)
                Text(zone < 0 ? "←   →" : (zone > 0 ? "→   ←" : "⇌"))
                    .font(.caption.bold()).foregroundStyle(ToyStyle.amber)
            }
        }
        .frame(height: 48)
        .accessibilityHidden(true)
    }
}
