import SwiftUI

struct BondSpecies {
    let formula: String
    let coefficient: Int
    let atoms: [String: Int]
    var charge: Int = 0
}

enum BondReaction: String, CaseIterable, Identifiable {
    case water = "Make water", photosynthesis = "Photosynthesis", atp = "ATP hydrolysis"
    var id: String { rawValue }
    var reactants: [BondSpecies] {
        switch self {
        case .water:
            [.init(formula: "H₂", coefficient: 2, atoms: ["H": 2]), .init(formula: "O₂", coefficient: 1, atoms: ["O": 2])]
        case .photosynthesis:
            [.init(formula: "CO₂", coefficient: 6, atoms: ["C": 1, "O": 2]), .init(formula: "H₂O", coefficient: 6, atoms: ["H": 2, "O": 1])]
        case .atp:
            [.init(formula: "ATP⁴⁻", coefficient: 1, atoms: ["C": 10, "H": 12, "N": 5, "O": 13, "P": 3], charge: -4), .init(formula: "H₂O", coefficient: 1, atoms: ["H": 2, "O": 1])]
        }
    }
    var products: [BondSpecies] {
        switch self {
        case .water:
            [.init(formula: "H₂O", coefficient: 2, atoms: ["H": 2, "O": 1])]
        case .photosynthesis:
            [.init(formula: "C₆H₁₂O₆", coefficient: 1, atoms: ["C": 6, "H": 12, "O": 6]), .init(formula: "O₂", coefficient: 6, atoms: ["O": 2])]
        case .atp:
            [.init(formula: "ADP³⁻", coefficient: 1, atoms: ["C": 10, "H": 12, "N": 5, "O": 10, "P": 2], charge: -3), .init(formula: "HPO₄²⁻", coefficient: 1, atoms: ["H": 1, "O": 4, "P": 1], charge: -2), .init(formula: "H⁺", coefficient: 1, atoms: ["H": 1], charge: 1)]
        }
    }
    var equation: String {
        func side(_ species: [BondSpecies]) -> String {
            species.map { "\($0.coefficient == 1 ? "" : String($0.coefficient))\($0.formula)" }.joined(separator: " + ")
        }
        return "\(side(reactants)) → \(side(products))"
    }
    var explanation: String {
        switch self {
        case .water: "Two H–H pairs and one O=O pair can rearrange into two water molecules. Bonds must be disrupted before new bonding can stabilize the products."
        case .photosynthesis: "Light drives a network of reactions that fixes carbon into carbohydrates. This net equation counts atoms; it does not mean twelve molecules collide in one step."
        case .atp: "Water participates in converting ATP to ADP and inorganic phosphate. The products can have lower free energy; coupled cellular processes use this change to do work."
        }
    }
    var caveat: String {
        switch self {
        case .water: "Scrubbing is an atom map, not a simulation of hydrogen combustion. Atom trajectories are illustrative."
        case .photosynthesis: "Glucose represents the net carbohydrate product. Oxygen released by oxygenic photosynthesis comes from water; this toy map tracks counts, not isotope provenance."
        case .atp: "One balanced set of ionic forms is shown. Protonation and Mg²⁺ binding vary with conditions; biochemical shorthand is ATP + H₂O → ADP + Pᵢ. Breaking a bond alone costs energy."
        }
    }
    static func inventory(_ species: [BondSpecies]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for item in species {
            for (symbol, count) in item.atoms { counts[symbol, default: 0] += item.coefficient * count }
        }
        return counts
    }
    static func totalCharge(_ species: [BondSpecies]) -> Int { species.reduce(0) { $0 + $1.coefficient * $1.charge } }
    var isBalanced: Bool { Self.inventory(reactants) == Self.inventory(products) && Self.totalCharge(reactants) == Self.totalCharge(products) }
    var endEnergy: Double { self == .photosynthesis ? 0.32 : -0.25 }
    static func suggested(for molecule: BondMolecule) -> BondReaction {
        molecule == .carbonDioxide || molecule == .methane ? .photosynthesis : .water
    }
    func schematicEnergy(_ progress: Double) -> Double {
        endEnergy * progress + 0.8 * pow(sin(.pi * progress), 2)
    }
}

struct BondReactionView: View {
    let molecule: BondMolecule
    @Binding var reaction: BondReaction
    @Binding var progress: Double
    @Binding var thermal: Double
    @Binding var catalyst: Bool
    private var milestone: Int { progress < 0.01 ? 0 : (progress > 0.99 ? 2 : 1) }

    var body: some View {
        VStack(spacing: 16) {
            BondPanel("Rearrange. Keep every atom.") {
                Picker("Reaction", selection: $reaction) {
                    ForEach(BondReaction.allCases) { item in Text(item.rawValue).tag(item) }
                }
                .pickerStyle(.menu)
                .tint(ToyStyle.cyan)
                .accessibilityIdentifier("bond-reaction-picker")
                Text(reaction.equation)
                    .font(.headline.monospaced())
                    .foregroundStyle(ToyStyle.cyan)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("bond-reaction-equation")
                BondReactionAtomCanvas(reaction: reaction, progress: progress)
                    .frame(height: 150)
                    .background(ToyStyle.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 17))
                Slider(value: $progress, in: 0...1)
                    .tint(ToyStyle.cyan)
                    .accessibilityLabel("Reactant to product atom map")
                    .accessibilityValue("\(Int(progress * 100)) percent")
                    .accessibilityIdentifier("bond-reaction-progress")
                HStack {
                    Text("Reactants").font(.caption)
                    Spacer()
                    Text("\(Int((progress * 100).rounded()))%")
                        .font(.caption.monospaced()).foregroundStyle(ToyStyle.amber)
                        .accessibilityIdentifier("bond-reaction-progress-value")
                    Spacer()
                    Text("Products").font(.caption).foregroundStyle(ToyStyle.cyan)
                }
                conservationLedger
                Text(reaction.explanation).font(.subheadline)
                Text(reaction.caveat).font(.caption).foregroundStyle(.secondary)
            }
            BondPanel("Energy opens a path", subtitle: "Qualitative reaction coordinate, not measured kinetics.") {
                BondBarrierCanvas(reaction: reaction, progress: progress, thermal: thermal, catalyst: catalyst)
                    .frame(height: 163)
                Toggle("Add a catalyst", isOn: $catalyst).tint(ToyStyle.violet)
                    .accessibilityIdentifier("bond-catalyst-toggle")
                Text(catalyst ? "Lower barrier · same endpoints" : "Uncatalyzed route")
                    .font(.caption).foregroundStyle(catalyst ? ToyStyle.violet : ToyStyle.cyan)
                    .accessibilityIdentifier("bond-catalyst-readout")
                HStack {
                    Text("Cooler").font(.caption)
                    Spacer()
                    Text("Warmer").font(.caption).foregroundStyle(ToyStyle.amber)
                }
                Slider(value: $thermal, in: 0...1)
                    .tint(ToyStyle.amber)
                    .accessibilityLabel("Conceptual temperature")
                    .accessibilityValue("\(Int(thermal * 100)) percent of illustrative range")
                    .accessibilityIdentifier("bond-temperature-slider")
                Text("Thermal dial: \(Int((thermal * 100).rounded()))%")
                    .font(.caption.monospaced()).foregroundStyle(ToyStyle.amber)
                    .accessibilityIdentifier("bond-temperature-value")
                Text("Warmer particles sample a broader range of energies. A catalyst provides a lower-barrier route; it does not change the energy difference between reactants and products.")
                    .font(.subheadline)
                Text("The amber band suggests thermal energy. Its height has no kelvin calibration, and slider position does not predict reaction rate. Photosynthesis additionally needs light and its biochemical machinery.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .onChange(of: reaction) { _, _ in progress = 0 }
        .sensoryFeedback(.selection, trigger: reaction)
        .sensoryFeedback(.selection, trigger: milestone)
        .sensoryFeedback(.selection, trigger: catalyst)
    }

    private var conservationLedger: some View {
        let before = BondReaction.inventory(reaction.reactants)
        let after = BondReaction.inventory(reaction.products)
        return VStack(alignment: .leading, spacing: 8) {
            Label(reaction.isBalanced ? "Atoms and charge conserved" : "Equation needs balancing", systemImage: reaction.isBalanced ? "checkmark.seal" : "exclamationmark.triangle")
                .font(.caption.weight(.semibold)).foregroundStyle(ToyStyle.cyan)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 82), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(before.keys.sorted(), id: \.self) { symbol in
                    Text("\(symbol)  \(before[symbol, default: 0]) = \(after[symbol, default: 0])")
                        .font(.caption.monospaced())
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 9))
                }
            }
            Text("Net charge: \(BondReaction.totalCharge(reaction.reactants)) = \(BondReaction.totalCharge(reaction.products))")
                .font(.caption.monospaced()).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("bond-conservation-ledger")
    }
}

private struct BondMappedAtom {
    let symbol: String
    let point: CGPoint
}

struct BondReactionAtomCanvas: View {
    let reaction: BondReaction
    let progress: Double
    var body: some View {
        Canvas { context, size in
            let initial = positions(reaction.reactants, size: size)
            let final = positions(reaction.products, size: size)
            var finalByElement: [String: [CGPoint]] = [:]
            for atom in final { finalByElement[atom.symbol, default: []].append(atom.point) }
            var used: [String: Int] = [:]
            for atom in initial {
                let index = used[atom.symbol, default: 0]
                used[atom.symbol] = index + 1
                guard let target = finalByElement[atom.symbol]?[index] else { continue }
                let point = CGPoint(x: atom.point.x + (target.x - atom.point.x) * progress, y: atom.point.y + (target.y - atom.point.y) * progress)
                let color = elementColor(atom.symbol)
                let radius = reaction == .water ? 10.0 : 4.0
                context.fill(Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)), with: .color(color))
                if reaction == .water {
                    context.draw(Text(atom.symbol).font(.caption2.bold()).foregroundStyle(ToyStyle.background), at: point)
                }
            }
            let label = progress < 0.05 ? "reactant atom groups" : (progress > 0.95 ? "product atom groups" : "same atoms, new grouping")
            context.draw(Text(label).font(.caption.monospaced()).foregroundStyle(.secondary), at: CGPoint(x: size.width / 2, y: size.height - 15))
        }
        .accessibilityLabel("\(reaction.rawValue) atom map. Each element retains the same atom count as groups rearrange.")
        .accessibilityValue("\(Int((progress * 100).rounded())) percent through rearrangement")
        .accessibilityIdentifier("bond-reaction-canvas")
    }

    private func positions(_ species: [BondSpecies], size: CGSize) -> [BondMappedAtom] {
        let expanded = species.flatMap { item in Array(repeating: item, count: item.coefficient) }
        let columns = min(expanded.count, expanded.count > 7 ? 6 : 4)
        let rows = (expanded.count + columns - 1) / columns
        var result: [BondMappedAtom] = []
        for (index, item) in expanded.enumerated() {
            let center = CGPoint(x: Double(index % columns + 1) * Double(size.width) / Double(columns + 1), y: 26 + Double(index / columns + 1) * (Double(size.height) - 60) / Double(rows + 1))
            let symbols = item.atoms.keys.sorted().flatMap { symbol in Array(repeating: symbol, count: item.atoms[symbol, default: 0]) }
            for (atomIndex, symbol) in symbols.enumerated() {
                let angle = Double(atomIndex) * 2.399963
                let radius = reaction == .water ? 12.0 : 4.0 * sqrt(Double(atomIndex))
                result.append(.init(symbol: symbol, point: CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))))
            }
        }
        return result
    }

    private func elementColor(_ symbol: String) -> Color {
        switch symbol {
        case "O": Color(red: 1, green: 0.4, blue: 0.47)
        case "C": ToyStyle.violet
        case "N": ToyStyle.cyan
        case "P": ToyStyle.amber
        default: .white
        }
    }
}

struct BondBarrierCanvas: View {
    let reaction: BondReaction
    let progress: Double
    let thermal: Double
    let catalyst: Bool
    var body: some View {
        Canvas { context, size in
            let width = Double(size.width), height = Double(size.height)
            func point(_ x: Double, _ e: Double) -> CGPoint { CGPoint(x: 18 + x * (width - 36), y: height - 27 - (e + 0.36) * (height - 42) / 1.45) }
            let bandTop = point(0, thermal * 0.78).y
            let bandBottom = point(0, 0).y
            context.fill(Path(CGRect(x: 18, y: bandTop, width: width - 36, height: max(1, bandBottom - bandTop))), with: .color(ToyStyle.amber.opacity(0.10)))
            for isCatalyzed in catalyst ? [false, true] : [false] {
                var path = Path()
                for index in 0...100 {
                    let x = Double(index) / 100
                    let energy = reaction.endEnergy * x + (isCatalyzed ? 0.4 : 0.8) * pow(sin(.pi * x), 2)
                    let p = point(x, energy)
                    if index == 0 { path.move(to: p) } else { path.addLine(to: p) }
                }
                context.stroke(path, with: .color(isCatalyzed ? ToyStyle.violet : ToyStyle.cyan.opacity(catalyst ? 0.4 : 1)), style: StrokeStyle(lineWidth: isCatalyzed ? 3 : 2, dash: catalyst && !isCatalyzed ? [4, 5] : []))
            }
            let e = reaction.endEnergy * progress + (catalyst ? 0.4 : 0.8) * pow(sin(.pi * progress), 2)
            let cursor = point(progress, e)
            context.fill(Path(ellipseIn: CGRect(x: cursor.x - 5, y: cursor.y - 5, width: 10, height: 10)), with: .color(ToyStyle.amber))
            context.draw(Text("reaction coordinate →").font(.caption.monospaced()).foregroundStyle(.secondary), at: CGPoint(x: width / 2, y: height - 9))
        }
        .accessibilityLabel("Schematic activation barrier. \(catalyst ? "Catalyst route has a lower barrier, with identical endpoints." : "Uncatalyzed route shown.") Thermal energy illustration at \(Int(thermal * 100)) percent.")
        .accessibilityIdentifier("bond-barrier-canvas")
    }
}
