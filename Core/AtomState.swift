import Foundation

public struct AtomState: Hashable, Sendable {
    private var protonCount: Int
    private var neutronCount: Int
    private var electronCount: Int

    public init(protons: Int = 6, neutrons: Int = 6, electrons: Int = 6) {
        protonCount = min(118, max(1, protons))
        neutronCount = min(200, max(0, neutrons))
        electronCount = min(118, max(0, electrons))
    }

    public var protons: Int {
        get { protonCount }
        set { protonCount = min(118, max(1, newValue)) }
    }
    public var neutrons: Int {
        get { neutronCount }
        set { neutronCount = min(200, max(0, newValue)) }
    }
    public var electrons: Int {
        get { electronCount }
        set { electronCount = min(118, max(0, newValue)) }
    }
    public var element: Element { ElementCatalog.element(protons) }
    public var massNumber: Int { protons + neutrons }
    public var charge: Int { protons - electrons }
    public var orbitals: [OrbitalOccupancy] { ElectronStructure.occupancy(protons: protons, electrons: electrons) }
    public var shells: [Int] { ElectronStructure.shells(orbitals) }
    public var configuration: String { ElectronStructure.configuration(orbitals) }
    public var outerShellElectrons: Int { shells.last ?? 0 }
    public var valenceElectrons: Int { outerShellElectrons }
    public var valenceNote: String {
        charge == 0 ? element.valenceNote : "Outer-shell count for this ion. Bonding valence depends on its chemical environment."
    }
    public var configurationNote: String {
        if charge != 0 {
            return "Illustrative ion filling. Electrons leave the highest shell first; arbitrary charge states may not exist as bound atoms."
        }
        return element.configurationIsPredicted ? "Predicted free-atom configuration; superheavy-element properties are uncertain." : "Reference free-atom ground-state configuration. Orbital clouds show probability, not electron paths."
    }
    public var isotopeLabel: String { "\(element.symbol)-\(massNumber)" }
    public var chargeLabel: String {
        charge == 0 ? "Neutral" : "\(abs(charge))\(charge > 0 ? "+" : "−") ion"
    }

    public mutating func select(_ element: Element) {
        protons = element.atomicNumber
        neutrons = element.defaultNeutrons
        electrons = element.atomicNumber
    }

    public var stabilityDescription: String {
        // Only these introductory examples carry an explicit evaluated stability label.
        // Natural abundance and proximity to the average atomic mass do not imply stability.
        if (protons == 1 && (massNumber == 1 || massNumber == 2)) ||
           (protons == 6 && (massNumber == 12 || massNumber == 13)) {
            return "\(isotopeLabel) is a stable isotope. Electron charge does not change the identity of its nucleus."
        }
        if protons == 1 && massNumber == 3 {
            return "H-3 (tritium) is radioactive: beta decay, about 12.3 years half-life."
        }
        if protons == 6 && massNumber == 14 {
            return "C-14 is radioactive: beta decay, about 5,730 years half-life."
        }
        if IsotopeCatalog.isDocumented(atomicNumber: protons, massNumber: massNumber) {
            return "\(isotopeLabel) is listed in the isotope reference. Nuclear stability is not evaluated here."
        }
        return "\(isotopeLabel) is not listed in this reference snapshot. Existence and nuclear stability are not established by these knobs."
    }
}

public enum IsotopeCatalog {
    private static let masses: [String: [Int]] = CoreResource.decode("isotopes")
    public static func isDocumented(atomicNumber: Int, massNumber: Int) -> Bool {
        masses[String(atomicNumber)]?.contains(massNumber) ?? false
    }
}
