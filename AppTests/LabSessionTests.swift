import XCTest
import ChemistryCore
import LabKitFeedback
@testable import Stoicheia

@MainActor final class LabSessionTests: XCTestCase {
    private func makeSession(saved: [Int]? = nil) -> LabSession {
        let name = "Stoicheia.SessionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        if let saved { defaults.set(saved, forKey: "atom") }
        let haptics = HapticEngine()
        haptics.enabled = false // No persistence key: tests never change the user's haptic settings.
        let session = LabSession(defaults: defaults, testing: saved == nil, haptics: haptics)
        defaults.removePersistentDomain(forName: name)
        return session
    }

    func testNeutronChangesPreserveInspectedSubshellAndElectronConfiguration() {
        let session = makeSession()
        session.select(ElementCatalog.element(29))
        session.selectOrbital("3d")
        let configuration = session.atom.configuration
        let electrons = session.atom.electrons
        XCTAssertTrue(session.change(.neutron, to: session.atom.neutrons + 1))
        XCTAssertEqual(session.selectedOrbital, "3d")
        XCTAssertEqual(session.atom.electrons, electrons)
        XCTAssertEqual(session.atom.configuration, configuration)
        session.resetIsotope()
        XCTAssertEqual(session.selectedOrbital, "3d")
    }

    func testBoundaryNoOpsPreserveStateSelectionAndObservation() {
        let cases: [(ParticleKind, Int, Int)] = [
            (.proton, 1, -1), (.proton, 118, 119),
            (.neutron, 0, -1), (.neutron, 200, 201),
            (.electron, 0, -1), (.electron, 118, 119)
        ]
        for (kind, boundary, outside) in cases {
            let session = makeSession()
            session.change(kind, to: boundary)
            if let orbital = session.atom.orbitals.first { session.selectOrbital(orbital.label) }
            let atom = session.atom, orbital = session.selectedOrbital, observation = session.lastChange
            XCTAssertFalse(session.change(kind, to: outside), "\(kind), \(boundary)")
            XCTAssertEqual(session.atom, atom)
            XCTAssertEqual(session.selectedOrbital, orbital)
            XCTAssertEqual(session.lastChange, observation)
        }
    }

    func testRepeatedSameValueDoesNotReplaceObservationOrSelection() {
        let session = makeSession()
        session.selectOrbital("1s")
        let observation = session.lastChange
        XCTAssertFalse(session.change(.electron, to: 6))
        XCTAssertFalse(session.change(.neutron, to: 6))
        XCTAssertEqual(session.lastChange, observation)
        XCTAssertEqual(session.selectedOrbital, "1s")
    }

    func testEmptyIonHasNoSelectedOrbitalAndRefillingFollowsOccupiedShells() {
        let session = makeSession()
        session.selectOrbital("2p")
        session.change(.electron, to: 0)
        XCTAssertEqual(session.atom.orbitals, [])
        XCTAssertEqual(session.selectedOrbital, "")
        session.selectOrbital("1s") // An absent subshell cannot be selected.
        XCTAssertEqual(session.selectedOrbital, "")
        session.change(.electron, to: 1)
        XCTAssertEqual(session.selectedOrbital, "1s")
        session.change(.electron, to: 3)
        XCTAssertEqual(session.selectedOrbital, "2s")
    }

    func testManualSelectionSurvivesElectronChangesWhileOccupied() {
        let session = makeSession()
        session.selectOrbital("1s")
        session.change(.electron, to: 10)
        XCTAssertEqual(session.selectedOrbital, "1s")
        session.change(.electron, to: 1)
        XCTAssertEqual(session.selectedOrbital, "1s")
        XCTAssertEqual(session.atom.orbitals.first?.electrons, 1)
    }

    func testSelectingElementResumesOuterSubshellFollowing() {
        let session = makeSession()
        session.selectOrbital("1s")
        session.select(ElementCatalog.element(3))
        XCTAssertEqual(session.selectedOrbital, "2s")
        session.change(.electron, to: 2)
        XCTAssertEqual(session.selectedOrbital, "1s")
        session.change(.electron, to: 3)
        XCTAssertEqual(session.selectedOrbital, "2s")
    }

    func testCopperExceptionAndIronIonTransitionsUseActualOccupancy() {
        let session = makeSession()
        session.experiment(29)
        XCTAssertEqual(session.selectedOrbital, "4s")
        XCTAssertEqual(session.atom.orbitals.first { $0.label == "3d" }?.electrons, 10)
        XCTAssertEqual(session.atom.orbitals.first { $0.label == "4s" }?.electrons, 1)
        session.experiment(26, charge: 2)
        XCTAssertEqual(session.atom.charge, 2)
        XCTAssertEqual(session.selectedOrbital, "3d")
        XCTAssertNil(session.atom.orbitals.first { $0.label == "4s" })
        XCTAssertEqual(session.atom.orbitals.first { $0.label == "3d" }?.electrons, 6)
    }

    func testRestoringBareIonHasAccurateSelectionAndObservation() {
        let session = makeSession(saved: [29, 34, 0])
        XCTAssertEqual(session.atom.element.symbol, "Cu")
        XCTAssertEqual(session.selectedOrbital, "")
        XCTAssertTrue(session.lastChange.contains("Copper-63"))
        XCTAssertTrue(session.lastChange.contains("0 electrons"))
        XCTAssertFalse(session.lastChange.contains("Carbon"))
    }
}
