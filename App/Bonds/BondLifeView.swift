import SwiftUI

enum BondLifeLink: String, CaseIterable, Identifiable {
    case water = "Water", carbon = "Carbon", nitrogen = "Nitrogen", oxygen = "O₂ + iron", gradient = "Na⁺ / K⁺", calcium = "Calcium", phosphate = "Phosphate"
    var id: String { rawValue }
    var optionIdentifier: String {
        switch self {
        case .water: "bond-life-option-water"
        case .carbon: "bond-life-option-carbon"
        case .nitrogen: "bond-life-option-nitrogen"
        case .oxygen: "bond-life-option-oxygen"
        case .gradient: "bond-life-option-gradient"
        case .calcium: "bond-life-option-calcium"
        case .phosphate: "bond-life-option-phosphate"
        }
    }
    var title: String {
        switch self {
        case .water: "Polarity → a living solvent"
        case .carbon: "Four bonds → a molecular backbone"
        case .nitrogen: "Nitrogen → amino groups"
        case .oxygen: "Reversible binding → oxygen transport"
        case .gradient: "Ion gradients → electrical possibility"
        case .calcium: "An ion pulse → a cellular message"
        case .phosphate: "Phosphate chemistry → coupled work"
        }
    }
    var control: String {
        switch self {
        case .water: "Align neighboring water molecules"
        case .carbon: "Extend a carbon chain"
        case .nitrogen: "Highlight the nitrogen-containing group"
        case .oxygen: "Bring oxygen to a heme site"
        case .gradient: "Scrub one sodium–potassium pump cycle"
        case .calcium: "Release a calcium pulse"
        case .phosphate: "Scrub ATP hydrolysis"
        }
    }
    var explanation: String {
        switch self {
        case .water: "Water’s partial charges allow hydrogen bonds between molecules and interactions with ions and polar groups. This supports solvent behavior and much of the chemistry inside cells."
        case .carbon: "Carbon can connect through four covalent bonds. Chains, branches, and rings let biology build sugars, lipids, proteins, and nucleic acids with varied three-dimensional structures."
        case .nitrogen: "Amino acids carry nitrogen in an amino group and connect into proteins. Microbial nitrogen fixation converts atmospheric N₂ into ammonia, making nitrogen available to biological chemistry."
        case .oxygen: "Each heme has an iron binding site for one O₂ molecule. Hemoglobin contains four hemes, and their cooperative binding helps load and release oxygen."
        case .gradient: "The sodium–potassium ATPase uses ATP to move three Na⁺ outward and two K⁺ inward per cycle. Ion concentration differences and charge separation help create electrochemical gradients."
        case .calcium: "A change in cytosolic Ca²⁺ can be read by calcium-binding proteins. Cells use pulses and local concentrations to link signals to responses, including secretion and contraction."
        case .phosphate: "ATP hydrolysis gives ADP and inorganic phosphate. Enzymes couple this favorable free-energy change to transport, motion, and chemical synthesis."
        }
    }
    var caveat: String {
        switch self {
        case .water: "The dotted hydrogen bond is between molecules. It is distinct from the stronger covalent O–H bonds within each water molecule. Solubility also depends on conditions."
        case .carbon: "Hydrogens are implicit in this alkane chain. The zigzag is schematic; conformations move, and most biological molecules have additional elements and functional groups."
        case .nitrogen: "Glycine is drawn in its zwitterionic form: NH₃⁺–CH₂–COO⁻. This control highlights a group, not a chemical conversion. Protonation depends on pH."
        case .oxygen: "This simplified site does not predict oxygen affinity. Protein structure, pH, oxygen pressure, and other conditions affect real binding."
        case .gradient: "The slider illustrates transport stoichiometry, not pumping speed or a measured membrane voltage. A membrane and selective proteins keep these gradients possible."
        case .calcium: "The pulse is a schematic signal. No calcium concentration, timing, or cellular response is quantitatively simulated."
        case .phosphate: "Energy is released by the overall chemical change and stabilization of products. Breaking a phosphate bond by itself requires energy."
        }
    }
    static func suggested(for molecule: BondMolecule) -> BondLifeLink {
        switch molecule {
        case .water, .hydrogen: .water
        case .methane, .carbonDioxide: .carbon
        case .oxygen: .oxygen
        case .salt: .gradient
        case .ammonia: .nitrogen
        }
    }
}

struct BondLifeView: View {
    let molecule: BondMolecule
    @Binding var link: BondLifeLink
    @Binding var progress: Double
    private var milestone: Int { Int((progress * 5).rounded()) }

    var body: some View {
        VStack(spacing: 16) {
            BondPanel("The same elements, alive") {
                Menu {
                    ForEach(BondLifeLink.allCases) { item in
                        Button {
                            link = item
                        } label: {
                            if link == item {
                                Label(item.rawValue, systemImage: "checkmark")
                            } else {
                                Text(item.rawValue)
                            }
                        }
                        .accessibilityIdentifier(item.optionIdentifier)
                    }
                } label: {
                    HStack {
                        Text("Biological connection")
                        Spacer()
                        Text(link.rawValue)
                        Image(systemName: "chevron.up.chevron.down").font(.caption)
                    }
                }
                .tint(ToyStyle.cyan)
                .accessibilityLabel("Biological connection")
                .accessibilityValue(link.rawValue)
                .accessibilityIdentifier("bond-life-picker")
                Text(link.title).font(.title3.bold()).foregroundStyle(ToyStyle.cyan)
                    .accessibilityIdentifier("bond-life-title")
                BondLifeCanvas(link: link, progress: progress)
                    .frame(height: 225)
                    .background(ToyStyle.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 17))
                Text(link.control).font(.subheadline.weight(.medium))
                Slider(value: $progress, in: 0...1, step: link == .carbon ? 0.2 : 0.01)
                    .tint(link == .phosphate ? ToyStyle.amber : ToyStyle.cyan)
                    .accessibilityLabel(link.control)
                    .accessibilityValue("\(Int((progress * 100).rounded())) percent; \(readout)")
                    .accessibilityIdentifier("bond-life-slider")
                Text(readout).font(.subheadline.monospaced()).foregroundStyle(ToyStyle.amber)
                    .accessibilityIdentifier("bond-life-readout")
                Text("Scene control: \(Int((progress * 100).rounded()))%")
                    .font(.caption.monospaced()).foregroundStyle(.secondary)
                    .accessibilityIdentifier("bond-life-progress-value")
                Text(link.explanation).font(.subheadline)
                Text(link.caveat).font(.caption).foregroundStyle(.secondary)
            }
            BondPanel("Keep the causal chain") {
                Text("Electron structure determines possible bonding. Bonding and electron regions shape molecules. Shape and charge influence interactions. Reactions and molecular recognition let cells function.")
                    .font(.subheadline)
                Text("A molecule’s behavior also depends on its environment: temperature, solvent, concentration, neighboring molecules, and enzymes.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .onChange(of: link) { _, new in progress = new == .carbon ? 0.4 : 0.5 }
        .sensoryFeedback(.selection, trigger: link)
        .sensoryFeedback(.selection, trigger: milestone)
    }

    private var readout: String {
        switch link {
        case .water: return progress > 0.75 ? "Aligned: an O···H contact" : "Turn the positive H toward negative O"
        case .carbon:
            let count = 1 + Int((progress * 5).rounded())
            return "\(count) C · \(2 * count + 2) H · alkane"
        case .nitrogen: return "Glycine · one N in the amino group"
        case .oxygen: return progress > 0.85 ? "O₂ at one Fe binding site" : "O₂ approaching the Fe site"
        case .gradient: return progress > 0.95 ? "3 Na⁺ out · 2 K⁺ in · 1 ATP" : "3 Na⁺ outward / 2 K⁺ inward"
        case .calcium: return "\(1 + Int((progress * 5).rounded())) Ca²⁺ shown in the signaling region"
        case .phosphate: return progress > 0.75 ? "ADP + inorganic phosphate" : "ATP + water"
        }
    }
}

struct BondLifeCanvas: View {
    let link: BondLifeLink
    let progress: Double

    var body: some View {
        Canvas { context, size in
            let width = Double(size.width), height = Double(size.height)
            func sphere(_ symbol: String, _ x: Double, _ y: Double, _ color: Color, radius: Double = 17) {
                let circle = Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
                context.fill(circle, with: .color(color.opacity(0.23)))
                context.stroke(circle, with: .color(color), lineWidth: 1.5)
                context.draw(Text(symbol).font(.system(size: radius < 13 ? 10 : 13, weight: .bold, design: .rounded)).foregroundStyle(color), at: CGPoint(x: x, y: y))
            }
            func line(_ a: CGPoint, _ b: CGPoint, _ color: Color, dashed: Bool = false) {
                var path = Path(); path.move(to: a); path.addLine(to: b)
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: dashed ? 2 : 3, lineCap: .round, dash: dashed ? [4, 5] : []))
            }
            func label(_ text: String, _ x: Double, _ y: Double, _ color: Color = .secondary) {
                context.draw(Text(text).font(.caption.monospaced()).foregroundStyle(color), at: CGPoint(x: x, y: y))
            }
            switch link {
            case .water:
                let left = CGPoint(x: width * 0.3, y: height * 0.43)
                let right = CGPoint(x: width * 0.72, y: height * 0.49)
                let angle = (1 - progress) * .pi * 0.7
                let h1 = CGPoint(x: right.x - 34 * cos(angle), y: right.y - 34 * sin(angle))
                let h2 = CGPoint(x: right.x + 34 * cos(angle + 1.317), y: right.y + 34 * sin(angle + 1.317))
                let waterHalfAngle = 52.25 * Double.pi / 180
                for point in [CGPoint(x: left.x - 34 * cos(waterHalfAngle), y: left.y - 34 * sin(waterHalfAngle)), CGPoint(x: left.x - 34 * cos(waterHalfAngle), y: left.y + 34 * sin(waterHalfAngle))] {
                    line(left, point, .white.opacity(0.45))
                    sphere("Hδ+", point.x, point.y, .white, radius: 15)
                }
                line(right, h1, .white.opacity(0.45)); line(right, h2, .white.opacity(0.45))
                sphere("Hδ+", h1.x, h1.y, .white, radius: 15); sphere("Hδ+", h2.x, h2.y, .white, radius: 15)
                sphere("Oδ−", left.x, left.y, ToyStyle.cyan, radius: 21); sphere("Oδ−", right.x, right.y, ToyStyle.cyan, radius: 21)
                if progress > 0.75 { line(CGPoint(x: left.x + 23, y: left.y), CGPoint(x: h1.x - 17, y: h1.y), ToyStyle.amber, dashed: true) }
                label("between: hydrogen bond", width / 2, height - 43, ToyStyle.amber)
                label("within: covalent O–H", width / 2, height - 22)
            case .carbon:
                let count = 1 + Int((progress * 5).rounded())
                let spacing = min(42, (width - 55) / Double(max(1, count - 1)))
                let start = (width - Double(count - 1) * spacing) / 2
                var previous: CGPoint?
                for index in 0..<count {
                    let point = CGPoint(x: start + Double(index) * spacing, y: height * 0.45 + (index % 2 == 0 ? -13 : 13))
                    if let previous { line(previous, point, ToyStyle.violet.opacity(0.7)) }
                    sphere("C", point.x, point.y, ToyStyle.violet, radius: 16)
                    previous = point
                }
                label("CₙH₂ₙ₊₂ · hydrogens implicit", width / 2, height - 30, ToyStyle.violet)
            case .nitrogen:
                let y = height * 0.45
                let first = CGPoint(x: width * 0.23, y: y), middle = CGPoint(x: width * 0.5, y: y), last = CGPoint(x: width * 0.77, y: y)
                line(first, middle, ToyStyle.cyan.opacity(0.3 + progress * 0.6))
                line(middle, last, ToyStyle.violet.opacity(0.6))
                sphere("NH₃⁺", first.x, first.y, ToyStyle.cyan.opacity(0.45 + progress * 0.55), radius: 25 + progress * 3)
                sphere("CH₂", middle.x, middle.y, ToyStyle.violet, radius: 24)
                sphere("COO⁻", last.x, last.y, ToyStyle.amber, radius: 26)
                label("amino", first.x, y + 46, ToyStyle.cyan)
                label("carboxylate", last.x, y + 46, ToyStyle.amber)
                label("glycine · a protein building block", width / 2, height - 25)
            case .oxygen:
                let center = CGPoint(x: width / 2, y: height * 0.56)
                var ring = Path()
                for index in 0...8 {
                    let angle = Double(index) / 8 * .pi * 2
                    let point = CGPoint(x: center.x + 51 * cos(angle), y: center.y + 44 * sin(angle))
                    if index == 0 { ring.move(to: point) } else { ring.addLine(to: point) }
                }
                context.stroke(ring, with: .color(ToyStyle.violet.opacity(0.7)), lineWidth: 3)
                for index in 0..<4 {
                    let angle = Double(index) / 4 * .pi * 2
                    let point = CGPoint(x: center.x + 32 * cos(angle), y: center.y + 29 * sin(angle))
                    line(center, point, ToyStyle.cyan.opacity(0.4)); sphere("N", point.x, point.y, ToyStyle.cyan, radius: 10)
                }
                sphere("Fe", center.x, center.y, ToyStyle.amber, radius: 18)
                let oxygenY = 44 + progress * (center.y - 84)
                let boundOxygen = CGPoint(x: center.x, y: oxygenY)
                let distalOxygen = CGPoint(x: center.x + 21, y: oxygenY - 17)
                line(boundOxygen, distalOxygen, .white.opacity(0.4))
                sphere("O", boundOxygen.x, boundOxygen.y, .pink, radius: 12); sphere("O", distalOxygen.x, distalOxygen.y, .pink, radius: 12)
                if progress > 0.85 { line(CGPoint(x: boundOxygen.x, y: boundOxygen.y + 14), CGPoint(x: center.x, y: center.y - 20), ToyStyle.amber, dashed: true) }
                label("heme site · protein omitted", width / 2, height - 22)
            case .gradient:
                let membrane = width / 2
                context.fill(Path(CGRect(x: membrane - 9, y: 27, width: 18, height: height - 63)), with: .color(ToyStyle.violet.opacity(0.16)))
                label("inside", width * 0.23, 18); label("outside", width * 0.77, 18)
                for index in 0..<3 {
                    let x = width * 0.2 + progress * width * 0.6
                    sphere("Na⁺", x, 57 + Double(index) * 31, ToyStyle.amber, radius: 13)
                }
                for index in 0..<2 {
                    let x = width * 0.8 - progress * width * 0.6
                    sphere("K⁺", x, 152 + Double(index) * 31, ToyStyle.cyan, radius: 13)
                }
                label("3 →", membrane, 36, ToyStyle.amber); label("← 2", membrane, 132, ToyStyle.cyan)
                label("ATP-powered pump", width / 2, height - 13)
            case .calcium:
                let center = CGPoint(x: width * 0.62, y: height * 0.5)
                context.fill(Path(ellipseIn: CGRect(x: center.x - 65, y: center.y - 60, width: 130, height: 120)), with: .color(ToyStyle.violet.opacity(0.12)))
                sphere("sensor", center.x + 17, center.y, ToyStyle.violet, radius: 29)
                let count = 1 + Int((progress * 5).rounded())
                for index in 0..<count {
                    let angle = Double(index) * 2.399963
                    let radius = 30 + Double(index % 2) * 22
                    sphere("Ca²⁺", center.x - 24 + radius * cos(angle), center.y + radius * sin(angle), ToyStyle.cyan, radius: 12)
                }
                label("local signal → sensor", width / 2, height - 24, ToyStyle.cyan)
                label("stored Ca²⁺", width * 0.22, 36)
            case .phosphate:
                let start = width * 0.24, y = height * 0.47
                let tail = start + 116 + progress * 30
                sphere("A", start, y, ToyStyle.violet, radius: 25)
                line(CGPoint(x: start + 25, y: y), CGPoint(x: start + 45, y: y), .white.opacity(0.35))
                sphere("Pα", start + 53, y, ToyStyle.amber)
                line(CGPoint(x: start + 70, y: y), CGPoint(x: start + 84, y: y), .white.opacity(0.35))
                sphere("Pβ", start + 94, y, ToyStyle.amber)
                if progress < 0.75 { line(CGPoint(x: start + 111, y: y), CGPoint(x: tail - 4, y: y), .white.opacity(0.35)) }
                sphere(progress > 0.75 ? "Pᵢ" : "Pγ", tail + 17, y, progress > 0.75 ? ToyStyle.cyan : ToyStyle.amber)
                label(progress > 0.75 ? "ADP + Pᵢ" : "ATP + H₂O", width / 2, height - 40, ToyStyle.amber)
                label("A: adenosine · P: phosphate group", width / 2, height - 20)
            }
        }
        .accessibilityLabel("\(link.title). \(link.control), \(Int(progress * 100)) percent through the schematic.")
        .accessibilityIdentifier("bond-life-canvas")
    }
}
