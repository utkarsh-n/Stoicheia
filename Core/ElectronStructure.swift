import Foundation

public struct OrbitalOccupancy: Identifiable, Codable, Hashable, Sendable {
    public let n: Int
    /// Orbital angular-momentum quantum number: 0=s, 1=p, 2=d, 3=f.
    public let l: Int
    public var electrons: Int
    public var label: String { "\(n)\(["s", "p", "d", "f"][l])" }
    public var id: String { label }
    public var capacity: Int { 2 * (2 * l + 1) }
    public var orbitalCount: Int { 2 * l + 1 }

    public init(n: Int, l: Int, electrons: Int) {
        self.n = n
        self.l = l
        self.electrons = electrons
    }

    /// Hund-rule boxes for a free-atom teaching diagram: singly occupy, then pair.
    public var boxes: [Int] {
        (0..<orbitalCount).map { index in
            (electrons > index ? 1 : 0) + (electrons > orbitalCount + index ? 1 : 0)
        }
    }
}

enum ElectronStructure {
    // Madelung order is used only when illustrating added electrons. Neutral atoms use
    // reference configurations, so Cr, Cu, Pd and the other exceptions are preserved.
    static let fillingOrder: [(n: Int, l: Int)] = [
        (1,0), (2,0), (2,1), (3,0), (3,1), (4,0), (3,2), (4,1),
        (5,0), (4,2), (5,1), (6,0), (4,3), (5,2), (6,1), (7,0),
        (5,3), (6,2), (7,1)
    ]

    static let neutralConfigurations: [[OrbitalOccupancy]] = ElementCatalog.elements.map {
        let parsed = parse($0.electronConfiguration)
        precondition(parsed.reduce(0) { $0 + $1.electrons } == $0.atomicNumber, "Configuration electron count does not match atomic number")
        return parsed
    }

    static func neutral(_ atomicNumber: Int) -> [OrbitalOccupancy] {
        neutralConfigurations[min(118, max(1, atomicNumber)) - 1]
    }

    static func parse(_ configuration: String) -> [OrbitalOccupancy] {
        var values: [OrbitalOccupancy] = []
        if let start = configuration.firstIndex(of: "["), let end = configuration.firstIndex(of: "]") {
            let symbol = String(configuration[configuration.index(after: start)..<end])
            if let core = ElementCatalog.elements.first(where: { $0.symbol == symbol }) {
                values = parse(core.electronConfiguration)
            }
        }
        let pattern = try! NSRegularExpression(pattern: "([1-7])([spdf])([0-9]+)")
        let source = configuration as NSString
        for match in pattern.matches(in: configuration, range: NSRange(location: 0, length: source.length)) {
            let n = Int(source.substring(with: match.range(at: 1)))!
            let letter = source.substring(with: match.range(at: 2))
            let l = ["s", "p", "d", "f"].firstIndex(of: letter)!
            let electrons = Int(source.substring(with: match.range(at: 3)))!
            values.append(OrbitalOccupancy(n: n, l: l, electrons: electrons))
        }
        return values.sorted { $0.n == $1.n ? $0.l < $1.l : $0.n < $1.n }
    }

    static func occupancy(protons: Int, electrons: Int) -> [OrbitalOccupancy] {
        var values = neutral(protons)
        var difference = electrons - protons
        if difference < 0 {
            // Highest n is removed first. In transition metals this removes ns before
            // (n-1)d, unlike taking the tail of the Aufbau filling order.
            for index in values.indices.reversed() where difference < 0 {
                let removed = min(-difference, values[index].electrons)
                values[index].electrons -= removed
                difference += removed
            }
        } else if difference > 0 {
            for orbital in fillingOrder where difference > 0 {
                if let index = values.firstIndex(where: { $0.n == orbital.n && $0.l == orbital.l }) {
                    let added = min(difference, values[index].capacity - values[index].electrons)
                    values[index].electrons += added
                    difference -= added
                } else {
                    let added = min(difference, 2 * (2 * orbital.l + 1))
                    values.append(OrbitalOccupancy(n: orbital.n, l: orbital.l, electrons: added))
                    difference -= added
                }
            }
        }
        return values.filter { $0.electrons > 0 }.sorted { $0.n == $1.n ? $0.l < $1.l : $0.n < $1.n }
    }

    static func shells(_ orbitals: [OrbitalOccupancy]) -> [Int] {
        guard let highest = orbitals.map(\.n).max() else { return [] }
        return (1...highest).map { shell in orbitals.filter { $0.n == shell }.reduce(0) { $0 + $1.electrons } }
    }

    static func configuration(_ orbitals: [OrbitalOccupancy]) -> String {
        guard !orbitals.isEmpty else { return "No electrons" }
        let superscripts: [Character: Character] = ["0":"⁰", "1":"¹", "2":"²", "3":"³", "4":"⁴", "5":"⁵", "6":"⁶", "7":"⁷", "8":"⁸", "9":"⁹"]
        return orbitals.map { value in
            value.label + String(String(value.electrons).map { superscripts[$0]! })
        }.joined(separator: " ")
    }
}
