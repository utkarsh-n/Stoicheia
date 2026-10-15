import SwiftUI
import ChemistryCore
import LabKitCore
import LabKitUI

enum AtomLayer: String, CaseIterable { case clouds = "Clouds", shells = "Shells", nucleus = "Nucleus" }

struct AtomLabView: View {
    @Bindable var session: LabSession
    @State private var layer = AtomLayer.clouds
    @State private var precisionParticle: ParticleKind?
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var body: some View {
        GeometryReader { viewport in
            let contentWidth = min(618, max(0, viewport.size.width - 32))
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    stage
                    particleControls(availableWidth: contentWidth)
                    ToyPanel(title: "Follow the change") {
                        Text(session.lastChange).font(.subheadline).fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("atom-observation")
                        Text(session.atom.stabilityDescription).font(.caption).foregroundStyle(.secondary)
                        HStack {
                            Button("Neutralise") { session.neutralise() }.buttonStyle(.glass)
                                .accessibilityIdentifier("atom-neutralise")
                            Button("Reference isotope") { session.resetIsotope() }.buttonStyle(.glass)
                        }.font(.caption).frame(minHeight: 44)
                    }
                    OrbitalLedger(atom: session.atom, selection: Binding(
                        get: { session.selectedOrbital }, set: { session.selectOrbital($0) }))
                    connection
                    experiments
                }
                // Keep an oversized child from widening every section of the scroll content.
                .frame(width: contentWidth, alignment: .leading)
                .padding(16).frame(maxWidth: .infinity)
            }.scrollIndicators(.hidden).background(ToyStyle.background)
        }
            .sheet(item: $precisionParticle) { kind in precisionControls(kind) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ToyEyebrow(text: "01 / Build an atom")
            HStack(alignment: .firstTextBaseline) {
                Text(session.atom.element.name).font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .accessibilityIdentifier("atom-element")
                Spacer()
                Text("\(session.atom.massNumber)\(session.atom.element.symbol)")
                    .font(.system(.title, design: .serif)).foregroundStyle(ToyStyle.amber)
            }
            Text("Turn the parts. Watch the identity emerge.").font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var stage: some View {
        VStack(spacing: 10) {
            Picker("Atom view", selection: $layer) {
                ForEach(AtomLayer.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }.pickerStyle(.segmented).accessibilityIdentifier("atom-layer")
            AtomOrbView(atom: session.atom, layer: layer, orbital: session.selectedOrbital,
                        running: session.running && scenePhase == .active && session.tab == .atom)
                .frame(height: 200)
            HStack {
                Label(layer == .clouds ? "Hydrogen-like orbital shape" : layer == .shells ? "Shell occupancy diagram" : "Illustrative nucleus", systemImage: "sparkle")
                    .font(.caption2).foregroundStyle(.secondary)
                Spacer()
                Button(session.running ? "Pause" : "Spin", systemImage: session.running ? "pause.fill" : "play.fill") {
                    session.running.toggle(); session.haptics.play(.soft)
                }.font(.caption).buttonStyle(.glass).accessibilityIdentifier("atom-spin")
            }
            HStack {
                MetricTile(label: "Atomic number", value: "\(session.atom.protons)", color: ToyStyle.amber)
                MetricTile(label: "Charge", value: session.chargeText)
                MetricTile(label: "Outer shell", value: "\(session.atom.valenceElectrons) e⁻", color: ToyStyle.violet)
            }
        }.padding(16).background(ToyStyle.panel, in: RoundedRectangle(cornerRadius: 28))
            .overlay(RoundedRectangle(cornerRadius: 28).strokeBorder(ToyStyle.cyan.opacity(0.18)))
    }

    private func particleControls(availableWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ToyEyebrow(text: "Decompose / Recompose")
            GlassEffectContainer(spacing: 14) {
                // Each column needs two 44-point controls and a 6-point gap.
                if availableWidth >= 3 * 94 + 2 * 12 && !dynamicTypeSize.isAccessibilitySize {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(ParticleKind.allCases, id: \.self) { kind in
                            VStack(spacing: 8) {
                                particleKnob(kind)
                                particleCountButtons(kind)
                                particleFineButton(kind)
                            }.frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        ForEach(ParticleKind.allCases, id: \.self) { kind in
                            VStack(spacing: 8) {
                                particleKnob(kind)
                                HStack(spacing: 12) {
                                    particleCountButtons(kind)
                                    particleFineButton(kind)
                                }.frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            Text("Drag a knob up or right. Use ± for one particle, or Fine for an exact slider. Double-tap resets that count to 6.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private func particleKnob(_ kind: ParticleKind) -> some View {
        GlassKnob(spec: spec(kind), value: binding(kind),
                  onPrecision: { precisionParticle = kind })
    }

    private func particleCountButtons(_ kind: ParticleKind) -> some View {
        HStack(spacing: 6) {
            particleNudgeButton(kind, amount: -1)
            particleNudgeButton(kind, amount: 1)
        }
    }

    private func particleNudgeButton(_ kind: ParticleKind, amount: Int) -> some View {
        Button { nudge(kind, amount) } label: {
            Image(systemName: amount < 0 ? "minus" : "plus")
                .foregroundStyle(ToyStyle.cyan)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .glassEffect(.regular.interactive(), in: .circle)
        }.buttonStyle(.plain)
            .accessibilityLabel("\(amount < 0 ? "Remove" : "Add") one \(kind.rawValue)")
            .accessibilityIdentifier("atom-\(kind.rawValue)-\(amount < 0 ? "minus" : "plus")")
    }

    private func particleFineButton(_ kind: ParticleKind) -> some View {
        Button { precisionParticle = kind } label: {
            Label("Fine", systemImage: "slider.horizontal.3")
                .font(.caption).foregroundStyle(ToyStyle.cyan)
                .padding(.horizontal, 10).frame(minWidth: 80, minHeight: 44)
                .contentShape(Rectangle())
                .glassEffect(.regular.interactive(), in: .capsule)
        }.buttonStyle(.plain)
            .accessibilityLabel("Fine control for \(kind.title.lowercased())")
            .accessibilityIdentifier("atom-\(kind.rawValue)-fine")
    }

    private var connection: some View {
        ToyPanel(title: "Structure → behaviour", subtitle: session.atom.valenceNote) {
            Text(behaviour).font(.subheadline)
            Button("Find \(session.atom.element.symbol) in the table", systemImage: "square.grid.3x3") {
                session.tab = .table
            }.buttonStyle(.glass).font(.subheadline)
                .accessibilityIdentifier("atom-open-table")
            Button("Follow into bonds & life", systemImage: "arrow.right") { session.tab = .bonds }
                .buttonStyle(.glass).font(.subheadline).accessibilityIdentifier("atom-open-bonds")
        }
    }

    private var behaviour: String {
        let element = session.atom.element
        if session.atom.charge != 0 {
            return "This \(element.name) ion has \(session.atom.electrons) electrons and \(session.atom.outerShellElectrons) in its outer occupied shell. Its \(session.atom.protons) protons keep the element's identity. Charge affects electrostatic attraction and bonding; an arbitrary ion count is not proof that the ion is stable."
        }
        if element.group == 18 { return "A filled outer shell often makes a neutral noble gas relatively unreactive. Heavy noble gases can still form compounds." }
        if element.group == 1 && element.atomicNumber > 1 { return "One outer electron is often lost in bonding. A +1 ion then has the previous noble gas's electron count." }
        if element.group == 17 { return "Seven outer-shell electrons: gaining one often produces a −1 ion. Sharing electrons can also complete the shell." }
        if element.atomicNumber == 6 { return "Four outer-shell electrons let carbon share electrons in up to four ordinary covalent bonds: chains, rings, and the frameworks of biological molecules." }
        if element.atomicNumber == 8 { return "Six outer-shell electrons: oxygen commonly makes two bonds. Its pull on shared electrons makes water polar." }
        return "Recurring outer-shell patterns help explain periodic families. Bonding also depends on energy, partner atoms, and the environment. Explore those connections in Bonds & Life."
    }

    private var experiments: some View {
        ToyPanel(title: "Try a transformation") {
            VStack(spacing: 10) {
                experimentButton("Carbon-12 → Carbon-13", detail: "Add a neutron; the element remains carbon.") { session.experiment(6, neutrons: 7) }
                experimentButton("Oxygen → oxide ion", detail: "Add two electrons; charge becomes −2.") { session.experiment(8, charge: -2) }
                experimentButton("Sodium → sodium ion", detail: "Remove one electron; reveal a filled shell.") { session.experiment(11, charge: 1) }
                experimentButton("Copper's filling exception", detail: "Inspect the 3d¹⁰ 4s¹ ground-state pattern.") { session.experiment(29) }
            }
        }
    }
    private func experimentButton(_ title: String, detail: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.medium))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading).padding(8)
        }.buttonStyle(.glass)
    }
    private func value(_ kind: ParticleKind) -> Int {
        switch kind { case .proton: session.atom.protons; case .neutron: session.atom.neutrons; case .electron: session.atom.electrons }
    }
    private func binding(_ kind: ParticleKind) -> Binding<Double> {
        Binding(get: { Double(value(kind)) }, set: { session.change(kind, to: Int($0.rounded())) })
    }
    private func nudge(_ kind: ParticleKind, _ amount: Int) {
        let changed = session.change(kind, to: value(kind) + amount)
        session.haptics.play(changed ? .tick : .boundary)
    }

    private func precisionControls(_ kind: ParticleKind) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(value(kind)) \(kind.title.lowercased())")
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold)).monospacedDigit()
                    .accessibilityIdentifier("atom-\(kind.rawValue)-exact-value")
                Slider(value: Binding(get: { Double(value(kind)) }, set: { next in
                    if session.change(kind, to: Int(next.rounded())) { session.haptics.play(.tick) }
                }), in: spec(kind).range, step: 1, onEditingChanged: { editing in
                    session.haptics.play(editing ? .grab : .release)
                }) { Text(kind.title) }
                    .frame(minHeight: 44)
                    .accessibilityLabel("\(kind.title), exact particle count")
                    .accessibilityValue("\(value(kind))")
                    .accessibilityHint("Swipe up or down to change by one particle.")
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: nudge(kind, 1)
                        case .decrement: nudge(kind, -1)
                        @unknown default: break
                        }
                    }
                    .accessibilityIdentifier("knob-\(kind.rawValue)-slider")
                HStack {
                    Text("\(Int(spec(kind).range.lowerBound))")
                    Spacer()
                    Text("\(Int(spec(kind).range.upperBound))")
                }.font(.caption).foregroundStyle(.secondary).accessibilityHidden(true)
                Text(spec(kind).hint).font(.subheadline).foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }.padding(24).background(ToyStyle.background)
                .navigationTitle(kind.title).navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { precisionParticle = nil }
                        .accessibilityIdentifier("atom-fine-done")
                } }
        }.presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
    }
    private func spec(_ kind: ParticleKind) -> ParamSpec {
        let maxValue = kind == .neutron ? 200.0 : 118.0
        let tint: LabColor = switch kind { case .proton: LabColor(1, 0.73, 0.35); case .neutron: LabColor(0.73, 0.64, 1); case .electron: LabColor(0.40, 0.91, 0.95) }
        return ParamSpec(ParamID(kind.rawValue), title: kind.title, icon: "circle.fill", tint: tint,
                         range: (kind == .proton ? 1.0 : 0.0)...maxValue, defaultValue: 6, step: 1,
                         hint: "Changes \(kind == .proton ? "element identity" : kind == .neutron ? "isotope mass" : "charge and electron structure").",
                         provenance: .illustrative, format: .number(precision: 0, unit: ""))
    }
}

struct OrbitalLedger: View {
    let atom: AtomState
    @Binding var selection: String
    var body: some View {
        ToyPanel(title: "Electron structure", subtitle: "Tap a subshell to see its cloud. Boxes are orbitals; arrows are electrons.") {
            Text(atom.configuration.isEmpty ? "No electrons" : atom.configuration)
                .font(.system(.body, design: .monospaced)).foregroundStyle(ToyStyle.cyan)
                .accessibilityIdentifier("atom-configuration")
            Text(atom.configurationNote).font(.caption).foregroundStyle(.secondary)
            if atom.orbitals.isEmpty {
                Text("No occupied subshells. This is a bare nucleus; add an electron to reveal its cloud.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 145))], alignment: .leading, spacing: 10) {
                ForEach(atom.orbitals, id: \.label) { orbital in
                    Button { selection = orbital.label } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(orbital.label) · \(orbital.electrons) e⁻").font(.caption.weight(.semibold))
                            HStack(spacing: 3) {
                                ForEach(0..<(2 * orbital.l + 1), id: \.self) { box in
                                    let count = orbital.electrons > box ? (orbital.electrons > box + 2 * orbital.l + 1 ? 2 : 1) : 0
                                    Text(count == 2 ? "↑↓" : count == 1 ? "↑" : " ")
                                        .font(.system(size: 12, design: .monospaced))
                                        .frame(minWidth: 15, minHeight: 23)
                                        .overlay(Rectangle().stroke(.white.opacity(0.25)))
                                }
                            }
                        }.padding(8).frame(maxWidth: .infinity, alignment: .leading)
                    }.buttonStyle(.plain)
                        .background(selection == orbital.label ? ToyStyle.cyan.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityLabel("\(orbital.label), \(orbital.electrons) electrons")
                        .accessibilityAddTraits(selection == orbital.label ? .isSelected : [])
                        .accessibilityIdentifier("orbital-\(orbital.label)")
                }
            }
            Text("Shells: \(atom.shells.isEmpty ? "none" : atom.shells.map(String.init).joined(separator: " · ")). Ion configurations are a teaching filling model; arbitrary charge states may not exist as bound atoms.")
                .font(.caption).foregroundStyle(.secondary)
            Text("An orbital is a quantum probability distribution. Cloud dots are samples, not little electrons travelling on tracks; colour distinguishes lobes, not charge.")
                .font(.caption).foregroundStyle(.secondary)
            Text("The cloud combines a hydrogen-like radial distribution with one representative angular orbital per subshell (s, pᵧ, dₓᵧ, fₓᵧ𝓏). Radial nodes change with n. Multi-electron screening, actual size and hybridisation are not calculated.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}
