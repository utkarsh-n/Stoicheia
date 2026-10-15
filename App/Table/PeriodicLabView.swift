import SwiftUI
import ChemistryCore

enum ElementProperty: String, CaseIterable {
    case family = "Family", valence = "Outer electrons", electronegativity = "Electronegativity", radius = "Radius", mass = "Atomic mass", phase = "State"
    var unit: String {
        switch self { case .radius: "pm (van der Waals)"; case .mass: "u"; case .electronegativity: "Pauling scale"; default: "" }
    }
    func value(_ element: Element) -> Double? {
        switch self {
        case .valence: Double(element.valenceElectrons)
        case .electronegativity: element.electronegativity
        case .radius: element.atomicRadius
        case .mass: element.atomicMass
        default: nil
        }
    }
    func label(_ element: Element) -> String {
        if let value = value(element) { return value.formatted(.number.precision(.fractionLength(0...2))) }
        if self == .family { return element.category }
        if self == .phase { return element.standardState }
        return "—"
    }
    func color(_ element: Element) -> Color {
        switch self {
        case .family:
            return switch element.category {
            case "Alkali metal": ToyStyle.amber
            case "Alkaline earth metal": Color.orange
            case "Transition metal": Color(red: 0.55, green: 0.75, blue: 1)
            case "Post-transition metal": Color(red: 0.63, green: 0.79, blue: 0.74)
            case "Metalloid": Color(red: 0.82, green: 0.86, blue: 0.44)
            case "Halogen": Color(red: 0.60, green: 0.92, blue: 0.65)
            case "Noble gas": ToyStyle.violet
            case "Lanthanide": Color.pink
            case "Actinide": Color(red: 0.85, green: 0.54, blue: 0.90)
            default: ToyStyle.cyan
            }
        case .phase:
            let state = element.standardState.lowercased()
            return state.contains("gas") ? ToyStyle.cyan : state.contains("liquid") ? ToyStyle.amber : state.contains("solid") ? ToyStyle.violet : .gray
        default:
            guard let value = value(element) else { return .gray }
            let maximum = self == .valence ? 8.0 : self == .electronegativity ? 4.0 : self == .radius ? 350.0 : 300.0
            return Color(hue: 0.56 - min(1, value / maximum) * 0.48, saturation: 0.65, brightness: 0.95)
        }
    }
    var lesson: String {
        switch self {
        case .family: "Read down a column: related outer-electron structures often produce related chemistry. The d and f blocks have more variable bonding patterns."
        case .valence: "A repeating outer-shell count is the rhythm of the table. Transition metals may also use d electrons in bonding; this map shows outer-shell count."
        case .electronegativity: "Electronegativity describes attraction for shared electrons in bonds. It generally rises across a period and falls down a group. A dash means no value in this dataset."
        case .radius: "These are van der Waals radii, one definition of atomic size. Different radius definitions give different numbers; periodic trends are broad patterns with exceptions."
        case .mass: "Atomic weights describe isotope mixtures; they are not proton-plus-neutron counts for one atom. For radioactive elements the source may list a selected isotope's mass."
        case .phase: "Physical state reflects ordinary reference conditions in the source. Temperature and pressure can change it; missing entries remain unknown."
        }
    }
}

struct PeriodicLabView: View {
    @Bindable var session: LabSession
    @State private var property = ElementProperty.family
    @State private var query = ""
    @State private var family = "All families"
    @State private var compact = false
    @State private var compareNumber: Int?
    @FocusState private var searchFocused: Bool
    private var selected: Element { session.atom.element }
    private var categories: [String] { ["All families"] + Array(Set(ElementCatalog.elements.map(\.category))).sorted() }
    private var matches: [Element] { ElementCatalog.elements.filter(matchesFilter) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    ToyEyebrow(text: "02 / A map of matter")
                    Text("Patterns, not a poster.").font(.system(.title, design: .rounded, weight: .bold))
                    Text("Tap an element. Change the lens. Compare neighbours.").font(.subheadline).foregroundStyle(.secondary)
                }
                controls
                if compact || !query.isEmpty { compactGrid } else { periodicGrid }
                ToyPanel(title: property.rawValue, subtitle: property.unit.isEmpty ? nil : property.unit) {
                    Text(property.lesson).font(.subheadline)
                    if property.value(selected) != nil {
                        HStack {
                            Text("Low").font(.caption)
                            LinearGradient(colors: [Color(hue: 0.56, saturation: 0.65, brightness: 0.95), Color(hue: 0.08, saturation: 0.65, brightness: 0.95)], startPoint: .leading, endPoint: .trailing)
                                .frame(height: 5).clipShape(Capsule())
                            Text("High").font(.caption)
                        }.foregroundStyle(.secondary)
                    }
                }
                inspector
                if let compareNumber { ElementComparison(left: selected, right: ElementCatalog.element(compareNumber)) }
                ToyPanel(title: "Find the pattern") {
                    Text("Load sodium, then neon. Both can have ten electrons as Na⁺ and Ne, but their different proton counts keep them different elements. Try the Atom controls to see why.")
                        .font(.subheadline)
                    Button("Try sodium", systemImage: "atom") { session.experiment(11, charge: 1); session.tab = .atom }
                        .buttonStyle(.glass).accessibilityIdentifier("table-sodium-challenge")
                }
            }.padding(16).frame(maxWidth: 750).frame(maxWidth: .infinity)
        }.scrollIndicators(.hidden).scrollDismissesKeyboard(.interactively).background(ToyStyle.background)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Name, symbol, or atomic number", text: $query).textInputAutocapitalization(.never)
                    .autocorrectionDisabled().focused($searchFocused).submitLabel(.search)
                    .onSubmit { searchFocused = false }
                    .accessibilityIdentifier("table-search")
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill").frame(width: 44, height: 44)
                    }.accessibilityLabel("Clear search").accessibilityIdentifier("table-clear-search")
                }
            }.padding(12).background(ToyStyle.panel, in: RoundedRectangle(cornerRadius: 14))
            HStack {
                Menu { Picker("Property lens", selection: $property) { ForEach(ElementProperty.allCases, id: \.self) { Text($0.rawValue).tag($0) } } } label: {
                    Label(property.rawValue, systemImage: "line.3.horizontal.decrease").font(.caption.weight(.medium)).frame(minHeight: 44)
                }.buttonStyle(.glass).accessibilityIdentifier("table-property")
                Menu { Picker("Family filter", selection: $family) { ForEach(categories, id: \.self) { Text($0).tag($0) } } } label: {
                    Text(family).font(.caption).lineLimit(1).frame(minHeight: 44)
                }.buttonStyle(.glass).accessibilityIdentifier("table-family")
                Spacer(minLength: 0)
                Button { compact.toggle() } label: {
                    Image(systemName: compact ? "tablecells" : "square.grid.2x2").frame(width: 44, height: 44)
                }.accessibilityLabel(compact ? "Table layout" : "Tile layout")
                    .buttonStyle(.glass).accessibilityIdentifier("table-layout")
            }
            Text("\(matches.count) / 118 elements · \(compact || !query.isEmpty ? "tiles" : "swipe table sideways")")
                .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("table-result-count")
        }
    }

    private var periodicGrid: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) { ForEach(1...18, id: \.self) { Text("\($0)").font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary).frame(width: 48) } }
                ForEach(1...7, id: \.self) { period in
                    HStack(spacing: 4) {
                        ForEach(1...18, id: \.self) { group in
                            if let element = mainElement(period, group) { elementTile(element, width: 48) }
                            else if group == 3 && period >= 6 {
                                Text(period == 6 ? "57–71\n↓" : "89–103\n↓").font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.secondary).frame(width: 48, height: 62)
                            } else { Color.clear.frame(width: 48, height: 62).accessibilityHidden(true) }
                        }
                    }
                }
                Text("F BLOCK / DETACHED FOR SPACE").font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary).padding(.top, 14)
                detachedRow(57...71)
                detachedRow(89...103)
            }.padding(12)
        }.background(ToyStyle.panel, in: RoundedRectangle(cornerRadius: 20))
            .accessibilityIdentifier("periodic-grid")
    }
    private func detachedRow(_ range: ClosedRange<Int>) -> some View {
        HStack(spacing: 4) {
            Color.clear.frame(width: 100, height: 62)
            ForEach(range, id: \.self) { number in elementTile(ElementCatalog.element(number), width: 48) }
        }
    }
    private var compactGrid: some View {
        Group {
            if matches.isEmpty {
                ContentUnavailableView.search(text: query)
                    .accessibilityIdentifier("table-empty-state")
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))], spacing: 8) {
                    ForEach(matches) { element in elementTile(element, width: nil) }
                }
            }
        }
    }
    private func elementTile(_ element: Element, width: CGFloat?) -> some View {
        let color = property.color(element)
        return Button {
            session.select(element)
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(element.atomicNumber)").font(.system(size: 9, design: .monospaced))
                Text(element.symbol).font(.system(.headline, design: .rounded, weight: .bold))
                Text(property.label(element)).font(.system(size: 8, design: .monospaced)).lineLimit(1)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(6)
                .frame(width: width, height: 62)
                .foregroundStyle(color)
                .background(color.opacity(selected.atomicNumber == element.atomicNumber ? 0.25 : 0.08), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(color.opacity(selected.atomicNumber == element.atomicNumber ? 1 : 0.25), lineWidth: selected.atomicNumber == element.atomicNumber ? 2 : 1))
                .opacity(matchesFilter(element) ? 1 : 0.20)
        }.buttonStyle(.plain)
            .accessibilityLabel("\(element.name), \(element.symbol), atomic number \(element.atomicNumber)")
            .accessibilityValue("\(property.rawValue): \(property.label(element))")
            .accessibilityAddTraits(selected.atomicNumber == element.atomicNumber ? .isSelected : [])
            .accessibilityIdentifier("element-\(element.atomicNumber)")
    }
    private var inspector: some View {
        ToyPanel(title: "\(selected.atomicNumber) / \(selected.name)", subtitle: selected.category) {
            HStack(alignment: .top, spacing: 16) {
                Text(selected.symbol).font(.system(size: 65, weight: .light, design: .rounded)).foregroundStyle(property.color(selected)).accessibilityIdentifier("table-selected-symbol")
                VStack(alignment: .leading, spacing: 6) {
                    Text("Period \(selected.period) · \(selected.block) block").font(.caption)
                    Text(selected.standardState).font(.caption).foregroundStyle(ToyStyle.amber)
                    Text(selected.electronConfiguration).font(.system(.caption, design: .monospaced)).foregroundStyle(ToyStyle.cyan)
                    Text(selected.valenceNote).font(.caption).foregroundStyle(.secondary)
                }
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 16) {
                MetricTile(label: "Atomic weight / mass", value: formatted(selected.atomicMass, unit: "u"))
                MetricTile(label: "Electronegativity", value: formatted(selected.electronegativity, unit: "χ"), color: ToyStyle.amber)
                MetricTile(label: "vdW radius", value: formatted(selected.atomicRadius, unit: "pm"))
                MetricTile(label: "1st ionisation", value: formatted(selected.ionizationEnergy, unit: "eV"), color: ToyStyle.violet)
                MetricTile(label: "Melting point", value: formatted(selected.meltingPoint, unit: "K"))
                MetricTile(label: "Boiling point", value: formatted(selected.boilingPoint, unit: "K"), color: ToyStyle.amber)
            }
            Text("— means unavailable in the source. Values are offline PubChem reference data; predictions and uncertain values for heavy elements retain the source's limitations.")
                .font(.caption2).foregroundStyle(.secondary)
            HStack {
                Button("Build this atom", systemImage: "atom") { session.tab = .atom }
                    .buttonStyle(.glassProminent).accessibilityIdentifier("table-build-atom")
                Button(compareNumber == selected.atomicNumber ? "Pinned" : "Pin to compare", systemImage: "pin") { compareNumber = selected.atomicNumber }
                    .buttonStyle(.glass).accessibilityIdentifier("table-pin")
            }.font(.caption)
            Link("PubChem element source", destination: URL(string: "https://pubchem.ncbi.nlm.nih.gov/element/\(selected.atomicNumber)")!)
                .font(.caption)
        }
    }
    private func mainElement(_ period: Int, _ group: Int) -> Element? {
        ElementCatalog.elements.first { $0.period == period && $0.group == group && !(57...71).contains($0.atomicNumber) && !(89...103).contains($0.atomicNumber) }
    }
    private func matchesFilter(_ element: Element) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let match = q.isEmpty || element.name.localizedCaseInsensitiveContains(q) || element.symbol.localizedCaseInsensitiveContains(q) || "\(element.atomicNumber)" == q
        return match && (family == "All families" || element.category == family)
    }
    private func formatted(_ value: Double?, unit: String) -> String {
        guard let value else { return "—" }
        return value.formatted(.number.precision(.fractionLength(0...2))) + " " + unit
    }
}

struct ElementComparison: View {
    let left: Element
    let right: Element
    var body: some View {
        ToyPanel(title: "Compare / \(left.symbol) ↔ \(right.symbol)", subtitle: "The pinned element stays while you choose another.") {
            ForEach([ElementProperty.valence, .electronegativity, .radius, .mass], id: \.self) { property in
                VStack(alignment: .leading, spacing: 8) {
                    Text(property.rawValue).font(.caption).foregroundStyle(.secondary)
                    comparisonBar(left, property, color: ToyStyle.cyan)
                    comparisonBar(right, property, color: ToyStyle.amber)
                }
            }
        }
        .accessibilityIdentifier("table-comparison")
    }
    private func comparisonBar(_ element: Element, _ property: ElementProperty, color: Color) -> some View {
        let largest = max(property.value(left) ?? 0, property.value(right) ?? 0, 1)
        let fraction = (property.value(element) ?? 0) / largest
        return HStack {
            Text(element.symbol).font(.caption.weight(.semibold)).frame(width: 30, alignment: .leading)
            GeometryReader { geometry in Capsule().fill(color.opacity(0.7)).frame(width: max(2, geometry.size.width * fraction)) }.frame(height: 6)
            Text(property.label(element)).font(.system(.caption, design: .monospaced)).frame(width: 55, alignment: .trailing)
        }.foregroundStyle(color).accessibilityElement(children: .ignore)
            .accessibilityLabel("\(element.name), \(property.rawValue), \(property.label(element)) \(property.unit)")
    }
}
