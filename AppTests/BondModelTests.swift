import XCTest
import Foundation
@testable import Stoicheia

@MainActor final class BondModelTests: XCTestCase {
    func testReactionSpeciesConserveTheirActualAtomsAndCharge() {
        let examples: [(BondReaction, [String: Int], Int)] = [
            (.water, ["H": 4, "O": 2], 0),
            (.photosynthesis, ["C": 6, "H": 12, "O": 18], 0),
            (.atp, ["C": 10, "H": 14, "N": 5, "O": 14, "P": 3], -4)
        ]
        for (reaction, expectedAtoms, expectedCharge) in examples {
            XCTAssertFalse(reaction.reactants.isEmpty, reaction.rawValue)
            XCTAssertFalse(reaction.products.isEmpty, reaction.rawValue)
            for species in reaction.reactants + reaction.products {
                XCTAssertGreaterThan(species.coefficient, 0, species.formula)
                XCTAssertFalse(species.atoms.isEmpty, species.formula)
                XCTAssertTrue(species.atoms.values.allSatisfy { $0 > 0 }, species.formula)
            }
            let before = BondReaction.inventory(reaction.reactants)
            let after = BondReaction.inventory(reaction.products)
            XCTAssertEqual(before, expectedAtoms, reaction.rawValue)
            XCTAssertEqual(after, expectedAtoms, reaction.rawValue)
            XCTAssertEqual(BondReaction.totalCharge(reaction.reactants), expectedCharge, reaction.rawValue)
            XCTAssertEqual(BondReaction.totalCharge(reaction.products), expectedCharge, reaction.rawValue)
            XCTAssertTrue(reaction.isBalanced, reaction.rawValue)
        }
    }

    func testLewisInventoriesAccountForEveryValenceElectron() {
        let examples: [(BondMolecule, Int, Int, Int)] = [
            (.water, 8, 2, 2), (.methane, 8, 4, 0), (.ammonia, 8, 3, 1),
            (.carbonDioxide, 16, 4, 4), (.hydrogen, 2, 1, 0),
            (.oxygen, 12, 2, 4), (.salt, 8, 0, 4)
        ]
        for (molecule, valence, shared, lone) in examples {
            XCTAssertEqual(molecule.atoms.reduce(0) { $0 + $1.valence }, valence, molecule.name)
            XCTAssertEqual(molecule.totalValence, valence, molecule.name)
            XCTAssertEqual(molecule.sharedPairs, shared, molecule.name)
            XCTAssertEqual(molecule.nonbondingPairs, lone, molecule.name)
            XCTAssertEqual(molecule.totalValence, 2 * (molecule.sharedPairs + molecule.nonbondingPairs), molecule.name)
            XCTAssertEqual(molecule.atoms.reduce(0) { $0 + $1.lonePairs }, lone, molecule.name)
        }
    }

    func testCovalentLewisAccountingAtEachAtomAndValidConnectivity() {
        for molecule in BondMolecule.allCases where molecule != .salt {
            var contributedToBonds = Array(repeating: 0, count: molecule.atoms.count)
            for connection in molecule.connections {
                XCTAssertTrue(molecule.atoms.indices.contains(connection.first), molecule.name)
                XCTAssertTrue(molecule.atoms.indices.contains(connection.second), molecule.name)
                guard molecule.atoms.indices.contains(connection.first), molecule.atoms.indices.contains(connection.second) else { continue }
                XCTAssertNotEqual(connection.first, connection.second, molecule.name)
                XCTAssertGreaterThan(connection.order, 0, molecule.name)
                contributedToBonds[connection.first] += connection.order
                contributedToBonds[connection.second] += connection.order
            }
            for index in molecule.atoms.indices {
                let atom = molecule.atoms[index]
                XCTAssertEqual(atom.valence, contributedToBonds[index] + 2 * atom.lonePairs, "\(molecule.formula), atom \(index) \(atom.symbol)")
            }
        }
        // Ionic transfer changes local atom inventories, while preserving their sum.
        let salt = BondMolecule.salt
        XCTAssertTrue(salt.connections.isEmpty)
        XCTAssertEqual(salt.atoms[0].symbol, "Na")
        XCTAssertEqual(salt.atoms[0].valence, 1)
        XCTAssertEqual(salt.atoms[1].symbol, "Cl")
        XCTAssertEqual(salt.atoms[1].valence, 7)
        XCTAssertEqual(salt.atoms[1].lonePairs * 2, 8)
    }

    func testStoredMolecularCoordinatesHaveTheirReportedBondAngles() {
        let water = BondMolecule.water.atoms
        XCTAssertEqual(angle(vector(from: water[0].position, to: water[1].position), vector(from: water[0].position, to: water[2].position)), 104.5, accuracy: 0.001)

        let ammonia = BondMolecule.ammonia.atoms
        for first in 1...3 {
            for second in 1...3 where second > first {
                XCTAssertEqual(angle(vector(from: ammonia[0].position, to: ammonia[first].position), vector(from: ammonia[0].position, to: ammonia[second].position)), 107, accuracy: 0.1)
            }
        }

        let methane = BondMolecule.methane.atoms
        for first in 1...4 {
            for second in 1...4 where second > first {
                XCTAssertEqual(angle(vector(from: methane[0].position, to: methane[first].position), vector(from: methane[0].position, to: methane[second].position)), 109.5, accuracy: 0.05)
            }
        }

        let carbonDioxide = BondMolecule.carbonDioxide.atoms
        XCTAssertEqual(angle(vector(from: carbonDioxide[0].position, to: carbonDioxide[1].position), vector(from: carbonDioxide[0].position, to: carbonDioxide[2].position)), 180, accuracy: 0.001)
        XCTAssertEqual(BondMolecule.hydrogen.angle, "No three-atom angle")
        XCTAssertEqual(BondMolecule.oxygen.angle, "No three-atom angle")
    }

    func testBondDirectionSymmetryDistinguishesPolarAndNonpolarPresets() {
        for molecule in [BondMolecule.methane, .carbonDioxide, .hydrogen, .oxygen] {
            XCTAssertEqual(magnitude(bondPolaritySum(molecule)), 0, accuracy: 0.000_001, molecule.name)
            XCTAssertFalse(molecule.isPolar, molecule.name)
        }
        for molecule in [BondMolecule.water, .ammonia] {
            XCTAssertGreaterThan(magnitude(bondPolaritySum(molecule)), 0.1, molecule.name)
            XCTAssertTrue(molecule.isPolar, molecule.name)
        }
    }

    func testPairPotentialHasStableMinimumAndForcePointsTowardIt() {
        XCTAssertEqual(BondPhysics.potential(1), -1, accuracy: 0.000_001)
        XCTAssertEqual(BondPhysics.force(1), 0, accuracy: 0.000_001)
        for step in 0...245 {
            let distance = 0.55 + Double(step) / 100
            XCTAssertGreaterThanOrEqual(BondPhysics.potential(distance), BondPhysics.potential(1) - 1e-12)
        }
        for distance in [0.55, 0.75, 0.95] { XCTAssertGreaterThan(BondPhysics.force(distance), 0) }
        for distance in [1.05, 1.5, 3.0] { XCTAssertLessThan(BondPhysics.force(distance), 0) }
        XCTAssertLessThan(abs(BondPhysics.potential(10)), 0.001)

        // The displayed force must agree with the independently sampled energy slope.
        let increment = 0.000_01
        for distance in [0.6, 0.9, 1.0, 1.3, 2.5] {
            let negativeSlope = -(BondPhysics.potential(distance + increment) - BondPhysics.potential(distance - increment)) / (2 * increment)
            XCTAssertEqual(BondPhysics.force(distance), negativeSlope, accuracy: 0.000_01)
        }
    }

    func testYawNormalizationStaysWithinSliderRangeAndPreservesOrientation() {
        for turns in [-1000.0, -20, -1, 0, 1, 20, 1000] {
            for offset in [-Double.pi, -0.4, 0, 0.6, Double.pi] {
                let original = turns * 2 * .pi + offset
                let wrapped = BondPhysics.normalizedYaw(original)
                XCTAssertGreaterThanOrEqual(wrapped, -.pi)
                XCTAssertLessThanOrEqual(wrapped, .pi)
                XCTAssertEqual(cos(wrapped), cos(original), accuracy: 1e-10)
                XCTAssertEqual(sin(wrapped), sin(original), accuracy: 1e-10)
            }
        }
    }

    func testFollowingMoleculeResetsContextWhileRetainingGenericExperimentControls() {
        var state = BondExploration(molecule: .methane)
        XCTAssertEqual(state.reaction, .photosynthesis)
        XCTAssertEqual(state.lifeLink, .carbon)
        XCTAssertEqual(state.lifeProgress, 0.4)

        state.electronProgress = 0.37
        state.yaw = 2.6
        state.pitch = -0.4
        state.showPolarity = true
        state.showDomains = true
        state.distance = 2.2
        state.thermal = 0.8
        state.catalyst = true
        state.reaction = .atp
        state.reactionProgress = 0.87
        state.lifeLink = .calcium
        state.lifeProgress = 1
        state.follow(.ammonia)

        XCTAssertEqual(state.reaction, .water)
        XCTAssertEqual(state.reactionProgress, 0)
        XCTAssertEqual(state.lifeLink, .nitrogen)
        XCTAssertEqual(state.lifeProgress, 0.5)
        XCTAssertEqual(state.electronProgress, 0.37)
        XCTAssertEqual(state.yaw, 2.6)
        XCTAssertEqual(state.pitch, -0.4)
        XCTAssertTrue(state.showPolarity)
        XCTAssertTrue(state.showDomains)
        XCTAssertEqual(state.distance, 2.2)
        XCTAssertEqual(state.thermal, 0.8)
        XCTAssertTrue(state.catalyst)

        state.follow(.carbonDioxide)
        XCTAssertEqual(state.reaction, .photosynthesis)
        XCTAssertEqual(state.reactionProgress, 0)
        XCTAssertEqual(state.lifeLink, .carbon)
        XCTAssertEqual(state.lifeProgress, 0.4)
        XCTAssertEqual(state.distance, 2.2)
        XCTAssertTrue(state.catalyst)
    }

    private func vector(from a: BondVector, to b: BondVector) -> BondVector {
        BondVector(x: b.x - a.x, y: b.y - a.y, z: b.z - a.z)
    }

    private func magnitude(_ vector: BondVector) -> Double {
        sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    }

    private func angle(_ a: BondVector, _ b: BondVector) -> Double {
        let cosine = (a.x * b.x + a.y * b.y + a.z * b.z) / (magnitude(a) * magnitude(b))
        return acos(min(1, max(-1, cosine))) * 180 / .pi
    }

    /// Qualitative EN-weighted direction sum; this is not a calculated physical dipole.
    private func bondPolaritySum(_ molecule: BondMolecule) -> BondVector {
        var sum = BondVector(x: 0, y: 0)
        let atoms = molecule.atoms
        for bond in molecule.connections {
            let first = atoms[bond.first], second = atoms[bond.second]
            let direction = vector(from: first.position, to: second.position)
            let scale = (second.electronegativity - first.electronegativity) / magnitude(direction)
            sum.x += direction.x * scale
            sum.y += direction.y * scale
            sum.z += direction.z * scale
        }
        return sum
    }
}
