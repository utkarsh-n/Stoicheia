import XCTest
@testable import ChemistryCore

final class ChemistryCoreTests: XCTestCase {
    func testAllElementsAndTablePlacements() {
        XCTAssertEqual(ElementCatalog.elements.map(\.atomicNumber), Array(1...118))
        XCTAssertEqual(Set(ElementCatalog.elements.map(\.symbol)).count, 118)
        let lengths = [2, 8, 8, 18, 18, 32, 32]
        for (index, count) in lengths.enumerated() {
            XCTAssertEqual(ElementCatalog.elements.filter { $0.period == index + 1 }.count, count)
        }
        for element in ElementCatalog.elements {
            XCTAssertTrue((1...7).contains(element.period))
            XCTAssertTrue((0...18).contains(element.group))
            XCTAssertEqual(element.group == 0, (57...71).contains(element.id) || (89...103).contains(element.id))
        }
        XCTAssertEqual(ElementCatalog.element(2).group, 18)
        XCTAssertEqual(ElementCatalog.element(26).group, 8)
        XCTAssertEqual(ElementCatalog.element(72).group, 4)
        XCTAssertEqual(ElementCatalog.element(104).group, 4)
        XCTAssertEqual(ElementCatalog.element(118).group, 18)
    }

    func testNeutralConfigurationsConserveElectronsAndCapacities() {
        for element in ElementCatalog.elements {
            XCTAssertEqual(element.shells.reduce(0, +), element.atomicNumber, element.name)
            XCTAssertEqual(element.orbitals.reduce(0) { $0 + $1.electrons }, element.atomicNumber)
            for orbital in element.orbitals {
                XCTAssertTrue((1...orbital.capacity).contains(orbital.electrons), element.name)
                XCTAssertEqual(orbital.boxes.reduce(0, +), orbital.electrons)
            }
        }
    }

    func testAllIonCombinationsConserveElectrons() {
        for protons in 1...118 {
            for electrons in 0...118 {
                let atom = AtomState(protons: protons, neutrons: 0, electrons: electrons)
                let orbitals = atom.orbitals
                XCTAssertEqual(orbitals.reduce(0) { $0 + $1.electrons }, electrons, "Z=\(protons), e=\(electrons)")
                XCTAssertEqual(atom.shells.reduce(0, +), electrons)
                XCTAssertEqual(Set(orbitals.map(\.label)).count, orbitals.count)
                for orbital in orbitals { XCTAssertTrue((1...orbital.capacity).contains(orbital.electrons)) }
            }
        }
    }

    func testChromiumCopperPalladiumAndLawrenciumExceptions() {
        func count(_ z: Int, _ n: Int, _ l: Int) -> Int {
            ElementCatalog.element(z).orbitals.first { $0.n == n && $0.l == l }?.electrons ?? 0
        }
        XCTAssertEqual(count(24, 3, 2), 5)
        XCTAssertEqual(count(24, 4, 0), 1)
        XCTAssertEqual(count(29, 3, 2), 10)
        XCTAssertEqual(count(29, 4, 0), 1)
        XCTAssertEqual(count(46, 4, 2), 10)
        XCTAssertEqual(count(46, 5, 0), 0)
        XCTAssertEqual(count(103, 7, 1), 1)
        XCTAssertEqual(count(103, 6, 2), 0)
    }

    func testIronIonsRemove4sBefore3d() {
        let plusTwo = AtomState(protons: 26, neutrons: 30, electrons: 24)
        let plusThree = AtomState(protons: 26, neutrons: 30, electrons: 23)
        XCTAssertEqual(plusTwo.charge, 2)
        XCTAssertEqual(plusTwo.orbitals.first { $0.label == "3d" }?.electrons, 6)
        XCTAssertNil(plusTwo.orbitals.first { $0.label == "4s" })
        XCTAssertEqual(plusThree.orbitals.first { $0.label == "3d" }?.electrons, 5)
        XCTAssertTrue(plusTwo.configurationNote.contains("Illustrative"))
    }

    func testIdentityIsotopeAndIonAreIndependent() {
        var atom = AtomState()
        XCTAssertEqual(atom.element.symbol, "C")
        XCTAssertEqual(atom.massNumber, 12)
        atom.neutrons = 8
        XCTAssertEqual(atom.element.symbol, "C")
        XCTAssertEqual(atom.massNumber, 14)
        XCTAssertTrue(atom.stabilityDescription.contains("radioactive"))
        atom.electrons = 4
        XCTAssertEqual(atom.element.symbol, "C")
        XCTAssertEqual(atom.massNumber, 14)
        XCTAssertEqual(atom.charge, 2)
        atom.protons = 7
        XCTAssertEqual(atom.element.symbol, "N")
        XCTAssertEqual(atom.massNumber, 15)
    }

    func testRepresentativeIsotopesAreDocumentedNotRoundedWeights() {
        for element in ElementCatalog.elements {
            XCTAssertTrue(IsotopeCatalog.isDocumented(atomicNumber: element.atomicNumber, massNumber: element.representativeIsotopeMassNumber), element.name)
            XCTAssertGreaterThanOrEqual(element.defaultNeutrons, 0)
        }
        // Ni's weighted atomic mass rounds to 59; its most abundant isotope is 58.
        XCTAssertEqual(ElementCatalog.element(28).representativeIsotopeMassNumber, 58)
        XCTAssertEqual(ElementCatalog.element(28).defaultNeutrons, 30)
        XCTAssertEqual(ElementCatalog.element(43).representativeIsotopeMassNumber, 97)
        XCTAssertEqual(ElementCatalog.element(118).representativeIsotopeMassNumber, 294)
    }

    func testStabilityIsNeverInferredFromKnobs() {
        XCTAssertTrue(AtomState().stabilityDescription.contains("stable isotope"))
        let unknown = AtomState(protons: 6, neutrons: 200, electrons: 6)
        XCTAssertTrue(unknown.stabilityDescription.contains("not listed"))
        XCTAssertFalse(unknown.stabilityDescription.contains("is a stable"))
        let iron = AtomState(protons: 26, neutrons: 30, electrons: 26)
        XCTAssertTrue(iron.stabilityDescription.contains("not evaluated"))
        let tritium = AtomState(protons: 1, neutrons: 2, electrons: 1)
        XCTAssertTrue(tritium.stabilityDescription.contains("radioactive"))
    }

    func testEmptyShellAndKnobBounds() {
        var atom = AtomState(protons: 0, neutrons: -4, electrons: -20)
        XCTAssertEqual(atom.protons, 1)
        XCTAssertEqual(atom.neutrons, 0)
        XCTAssertEqual(atom.electrons, 0)
        XCTAssertEqual(atom.shells, [])
        XCTAssertEqual(atom.configuration, "No electrons")
        atom.protons = 999
        atom.neutrons = 999
        atom.electrons = 999
        XCTAssertEqual(atom.protons, 118)
        XCTAssertEqual(atom.neutrons, 200)
        XCTAssertEqual(atom.electrons, 118)
        XCTAssertEqual(ElementCatalog.element(-10).atomicNumber, 1)
        XCTAssertEqual(ElementCatalog.element(999).atomicNumber, 118)
    }

    func testSelectingElementResetsToRepresentativeNeutralAtom() {
        var atom = AtomState(protons: 6, neutrons: 8, electrons: 4)
        atom.select(ElementCatalog.element(8))
        XCTAssertEqual(atom.protons, 8)
        XCTAssertEqual(atom.neutrons, 8)
        XCTAssertEqual(atom.electrons, 8)
        XCTAssertEqual(atom.valenceElectrons, 6)
        XCTAssertEqual(atom.shells, [2, 6])
    }

    func testUnknownPropertiesAndPredictionFlagsArePreserved() {
        XCTAssertNil(ElementCatalog.element(118).electronegativity)
        XCTAssertNil(ElementCatalog.element(118).atomicRadius)
        XCTAssertTrue(ElementCatalog.element(118).configurationIsPredicted)
        XCTAssertFalse(ElementCatalog.element(6).configurationIsPredicted)
        XCTAssertEqual(ElementCatalog.element(8).electronegativity, 3.44)
        XCTAssertEqual(ElementCatalog.element(1).meltingPoint, 13.81)
    }
}
