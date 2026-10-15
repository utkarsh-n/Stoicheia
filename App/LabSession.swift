import SwiftUI
import ChemistryCore
import LabKitFeedback
import Observation

enum PlaygroundTab: Hashable { case atom, table, bonds, greek }

@MainActor @Observable final class LabSession {
    var atom: AtomState
    var tab = PlaygroundTab.atom
    var running = true
    private(set) var selectedOrbital = ""
    var lastChange = "Carbon: four outer-shell electrons, a starting point for life's chemistry."
    let haptics: HapticEngine
    @ObservationIgnored private let defaults: UserDefaults
    private let testing: Bool
    private var followsOuterOrbital = true

    init(defaults: UserDefaults = .standard, testing: Bool? = nil, haptics: HapticEngine? = nil) {
        self.defaults = defaults
        self.testing = testing ?? ProcessInfo.processInfo.arguments.contains("-ui-testing")
        self.haptics = haptics ?? HapticEngine(persistenceKey: "Stoicheia")
        let saved = defaults.array(forKey: "atom") as? [Int]
        if !self.testing, let saved, saved.count == 3 {
            atom = AtomState(protons: saved[0], neutrons: saved[1], electrons: saved[2])
        } else { atom = AtomState() }
        running = !self.testing
        followOrbital()
        lastChange = "\(atom.element.name)-\(atom.massNumber), \(atom.electrons) electrons, charge \(chargeText). Change one part and follow what happens."
    }

    func select(_ element: Element) {
        atom = AtomState(protons: element.atomicNumber, neutrons: element.defaultNeutrons, electrons: element.atomicNumber)
        lastChange = "\(element.name) loaded as a neutral atom. Turn one control and follow what changes."
        followOrbital(force: true); save(); haptics.play(.select)
    }

    /// Returns false at an end stop, preserving the observation and selected cloud.
    @discardableResult func change(_ component: ParticleKind, to value: Int) -> Bool {
        let previous = atom
        switch component {
        case .proton:
            atom.protons = min(118, max(1, value))
        case .neutron:
            atom.neutrons = min(200, max(0, value))
        case .electron:
            atom.electrons = min(118, max(0, value))
        }
        guard atom != previous else { return false }
        switch component {
        case .proton:
            lastChange = "\(atom.protons) protons define \(atom.element.name). Neutrons and electrons stayed where you set them."
        case .neutron:
            lastChange = "Same element, new isotope: \(atom.element.name)-\(atom.massNumber). \(atom.stabilityDescription)"
        case .electron:
            lastChange = "\(atom.electrons) electrons and \(atom.protons) protons give charge \(chargeText). The element is still \(atom.element.name)."
        }
        // Isotopes have the same electron occupancy; do not discard a user's inspected subshell.
        if component != .neutron { followOrbital() }
        save()
        return true
    }

    func selectOrbital(_ label: String) {
        guard atom.orbitals.contains(where: { $0.label == label }) else { return }
        selectedOrbital = label
        followsOuterOrbital = false
        haptics.play(.select)
    }

    var chargeText: String { atom.charge == 0 ? "0 (neutral)" : String(format: "%+d", atom.charge) }
    func neutralise() {
        haptics.play(change(.electron, to: atom.protons) ? .detent : .boundary)
    }
    func resetIsotope() {
        haptics.play(change(.neutron, to: atom.element.defaultNeutrons) ? .reset : .boundary)
    }
    func experiment(_ number: Int, neutrons: Int? = nil, charge: Int = 0) {
        select(ElementCatalog.element(number))
        if let neutrons { change(.neutron, to: neutrons) }
        if charge != 0 { change(.electron, to: atom.protons - charge) }
    }
    private func followOrbital(force: Bool = false) {
        let orbitals = atom.orbitals
        let selectionExists = orbitals.contains { $0.label == selectedOrbital }
        guard force || followsOuterOrbital || !selectionExists else { return }
        followsOuterOrbital = true
        selectedOrbital = orbitals.max(by: { ($0.n, $0.l) < ($1.n, $1.l) })?.label ?? ""
    }
    private func save() {
        if !testing { defaults.set([atom.protons, atom.neutrons, atom.electrons], forKey: "atom") }
    }
}

enum ParticleKind: String, CaseIterable, Identifiable {
    case proton, neutron, electron
    var id: String { rawValue }
    var title: String { rawValue.capitalized + "s" }
    var color: Color { switch self { case .proton: ToyStyle.amber; case .neutron: ToyStyle.violet; case .electron: ToyStyle.cyan } }
}
