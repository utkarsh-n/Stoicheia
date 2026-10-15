import Foundation

/// Element identity is set by proton count. Physical data is an offline PubChem snapshot.
public struct Element: Identifiable, Codable, Hashable, Sendable {
    public var id: Int { atomicNumber }
    public let atomicNumber: Int
    public let symbol: String
    public let name: String
    /// Relative atomic mass, not the number of nucleons in any individual atom.
    public let atomicMass: Double?
    public let category: String
    public let period: Int
    /// Zero denotes the detached lanthanoid/actinoid row in this 18-column layout.
    public let group: Int
    public let electronConfiguration: String
    public let electronegativity: Double?
    /// Picometres; the PubChem field must not be mixed with a different radius definition.
    public let atomicRadius: Double?
    /// First ionization energy, eV.
    public let ionizationEnergy: Double?
    /// Kelvin.
    public let meltingPoint: Double?
    /// Kelvin.
    public let boilingPoint: Double?
    /// g/cm³, at the source's stated conditions.
    public let density: Double?
    public let standardState: String
    public let representativeIsotopeMassNumber: Int
    public let configurationIsPredicted: Bool

    public var defaultNeutrons: Int { representativeIsotopeMassNumber - atomicNumber }
    public var orbitals: [OrbitalOccupancy] { ElectronStructure.neutral(atomicNumber) }
    public var shells: [Int] { ElectronStructure.shells(orbitals) }
    public var outerShellElectrons: Int { shells.last ?? 0 }

    /// A beginner outer-shell count, not a universal definition of bonding valence.
    public var valenceElectrons: Int { outerShellElectrons }
    public var valenceNote: String {
        if block == "d" || block == "f" {
            return "Outer-shell count. Inner d or f electrons can also take part in bonding; valence depends on oxidation state."
        }
        return "For main-group neutral atoms, outer-shell electrons are the usual valence-electron count."
    }

    /// The detached rows use f-block coloring as a table-layout convention.
    public var block: String {
        if group == 0 { return "f" }
        if atomicNumber == 2 || group <= 2 { return "s" }
        return group >= 13 ? "p" : "d"
    }
}

public enum ElementCatalog {
    public static let elements: [Element] = {
        let values: [Element] = CoreResource.decode("elements")
        precondition(values.count == 118 && values.enumerated().allSatisfy { $0.offset + 1 == $0.element.atomicNumber }, "Element catalog must contain all 118 elements in order")
        return values
    }()

    /// Knob values outside the element range are bounded to the closest valid element.
    public static func element(_ atomicNumber: Int) -> Element {
        elements[min(118, max(1, atomicNumber)) - 1]
    }
}

enum CoreResource {
    static func decode<T: Decodable>(_ name: String) -> T {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(T.self, from: data) else {
            preconditionFailure("Missing or malformed bundled science resource: \(name).json")
        }
        return value
    }
}
