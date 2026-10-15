import SwiftUI

struct BondVector {
    var x: Double
    var y: Double
    var z: Double = 0

    func rotated(yaw: Double, pitch: Double) -> BondVector {
        let xx = x * cos(yaw) + z * sin(yaw)
        let zz = -x * sin(yaw) + z * cos(yaw)
        return BondVector(x: xx, y: y * cos(pitch) - zz * sin(pitch), z: y * sin(pitch) + zz * cos(pitch))
    }
}

struct BondAtom: Identifiable {
    let id: Int
    let symbol: String
    let valence: Int
    let lonePairs: Int
    let electronegativity: Double
    let position: BondVector
    let lewis: BondVector

    var color: Color {
        switch symbol {
        case "O": return Color(red: 1, green: 0.40, blue: 0.47)
        case "N": return ToyStyle.cyan
        case "C": return ToyStyle.violet
        case "Na": return ToyStyle.amber
        case "Cl": return Color(red: 0.40, green: 0.93, blue: 0.60)
        default: return Color(red: 0.88, green: 0.94, blue: 1)
        }
    }
}

struct BondConnection {
    let first: Int
    let second: Int
    let order: Int
}

enum BondMolecule: String, CaseIterable, Identifiable {
    case water, methane, ammonia, carbonDioxide, hydrogen, oxygen, salt
    var id: String { rawValue }
    var formula: String {
        switch self {
        case .water: "H₂O"
        case .methane: "CH₄"
        case .ammonia: "NH₃"
        case .carbonDioxide: "CO₂"
        case .hydrogen: "H₂"
        case .oxygen: "O₂"
        case .salt: "NaCl"
        }
    }
    var name: String {
        switch self {
        case .water: "Water"
        case .methane: "Methane"
        case .ammonia: "Ammonia"
        case .carbonDioxide: "Carbon dioxide"
        case .hydrogen: "Hydrogen"
        case .oxygen: "Oxygen"
        case .salt: "Sodium chloride"
        }
    }
    var shape: String {
        switch self {
        case .water: "Bent"
        case .methane: "Tetrahedral"
        case .ammonia: "Trigonal pyramidal"
        case .carbonDioxide: "Linear"
        case .hydrogen, .oxygen: "Diatomic"
        case .salt: "Cubic ionic lattice"
        }
    }
    var angle: String {
        switch self {
        case .water: "104.5°"
        case .methane: "109.5°"
        case .ammonia: "≈107°"
        case .carbonDioxide: "180°"
        case .salt: "6 nearest neighbors"
        default: "No three-atom angle"
        }
    }
    var isPolar: Bool { self == .water || self == .ammonia }
    var totalValence: Int { atoms.reduce(0) { $0 + $1.valence } }
    var sharedPairs: Int { self == .salt ? 0 : connections.reduce(0) { $0 + $1.order } }
    var nonbondingPairs: Int { self == .salt ? 4 : atoms.reduce(0) { $0 + $1.lonePairs } }

    var atoms: [BondAtom] {
        func atom(_ id: Int, _ symbol: String, _ valence: Int, _ lonePairs: Int, _ en: Double, _ position: BondVector, _ lewis: BondVector? = nil) -> BondAtom {
            BondAtom(id: id, symbol: symbol, valence: valence, lonePairs: lonePairs, electronegativity: en, position: position, lewis: lewis ?? position)
        }
        switch self {
        case .water:
            let theta = 52.25 * Double.pi / 180
            return [atom(0, "O", 6, 2, 3.44, .init(x: 0, y: -0.25), .init(x: 0, y: -0.2)),
                    atom(1, "H", 1, 0, 2.20, .init(x: -sin(theta), y: cos(theta) - 0.25), .init(x: -1, y: 0.65)),
                    atom(2, "H", 1, 0, 2.20, .init(x: sin(theta), y: cos(theta) - 0.25), .init(x: 1, y: 0.65))]
        case .methane:
            return [atom(0, "C", 4, 0, 2.55, .init(x: 0, y: 0)),
                    atom(1, "H", 1, 0, 2.20, .init(x: 0.72, y: 0.72, z: 0.72), .init(x: 0, y: -1)),
                    atom(2, "H", 1, 0, 2.20, .init(x: -0.72, y: -0.72, z: 0.72), .init(x: 1, y: 0)),
                    atom(3, "H", 1, 0, 2.20, .init(x: -0.72, y: 0.72, z: -0.72), .init(x: 0, y: 1)),
                    atom(4, "H", 1, 0, 2.20, .init(x: 0.72, y: -0.72, z: -0.72), .init(x: -1, y: 0))]
        case .ammonia:
            return [atom(0, "N", 5, 1, 3.04, .init(x: 0, y: -0.18)),
                    atom(1, "H", 1, 0, 2.20, .init(x: 0, y: 0.22, z: 1), .init(x: 0, y: 1)),
                    atom(2, "H", 1, 0, 2.20, .init(x: -0.866, y: 0.22, z: -0.5), .init(x: -1, y: 0)),
                    atom(3, "H", 1, 0, 2.20, .init(x: 0.866, y: 0.22, z: -0.5), .init(x: 1, y: 0))]
        case .carbonDioxide:
            return [atom(0, "C", 4, 0, 2.55, .init(x: 0, y: 0)), atom(1, "O", 6, 2, 3.44, .init(x: -1.15, y: 0)), atom(2, "O", 6, 2, 3.44, .init(x: 1.15, y: 0))]
        case .hydrogen:
            return [atom(0, "H", 1, 0, 2.20, .init(x: -0.65, y: 0)), atom(1, "H", 1, 0, 2.20, .init(x: 0.65, y: 0))]
        case .oxygen:
            return [atom(0, "O", 6, 2, 3.44, .init(x: -0.65, y: 0)), atom(1, "O", 6, 2, 3.44, .init(x: 0.65, y: 0))]
        case .salt:
            return [atom(0, "Na", 1, 0, 0.93, .init(x: -0.72, y: 0)), atom(1, "Cl", 7, 4, 3.16, .init(x: 0.72, y: 0))]
        }
    }
    var connections: [BondConnection] {
        switch self {
        case .water: return [.init(first: 0, second: 1, order: 1), .init(first: 0, second: 2, order: 1)]
        case .methane: return (1...4).map { .init(first: 0, second: $0, order: 1) }
        case .ammonia: return (1...3).map { .init(first: 0, second: $0, order: 1) }
        case .carbonDioxide: return [.init(first: 0, second: 1, order: 2), .init(first: 0, second: 2, order: 2)]
        case .hydrogen: return [.init(first: 0, second: 1, order: 1)]
        case .oxygen: return [.init(first: 0, second: 1, order: 2)]
        case .salt: return []
        }
    }
    var electronExplanation: String {
        switch self {
        case .water: "Oxygen brings 6 valence electrons and each hydrogen brings 1. Two shared pairs make O–H bonds; two pairs remain on oxygen."
        case .methane: "Carbon brings 4 valence electrons. Four hydrogens each bring 1, making four shared pairs and no lone pairs on carbon."
        case .ammonia: "Nitrogen brings 5 valence electrons. Three shared pairs make N–H bonds; one lone pair remains on nitrogen."
        case .carbonDioxide: "Carbon brings 4 and each oxygen brings 6: 16 valence electrons. Two double bonds use 8; four oxygen lone pairs use the other 8."
        case .hydrogen: "Each hydrogen brings one electron. The shared pair gives each hydrogen a filled first shell in this Lewis model."
        case .oxygen: "The Lewis picture has a double bond and two lone pairs on each oxygen. It misses O₂’s two unpaired electrons; molecular orbital theory explains its magnetism."
        case .salt: "Sodium loses one valence electron and chlorine gains it. Na⁺ and Cl⁻ attract in a repeating ionic crystal; NaCl expresses the 1:1 ratio."
        }
    }
    var shapeExplanation: String {
        switch self {
        case .water: "Four electron regions surround oxygen, but only two are bonds. The lone pairs lead to a bent arrangement of the three nuclei."
        case .methane: "Four bonding regions point toward the corners of a tetrahedron. A flat cross cannot show these angles; rotate the model."
        case .ammonia: "Three bonds and one lone pair surround nitrogen. The nuclei form a pyramid; the lone pair occupies the fourth electron region."
        case .carbonDioxide: "Each double bond counts as one electron region around carbon. Two regions spread to opposite sides, giving a straight molecule."
        case .hydrogen, .oxygen: "Two nuclei define one axis. Bond angle requires at least three nuclei, so there is no internal angle to report."
        case .salt: "This fragment shows alternating positive and negative ions. An interior ion has six oppositely charged nearest neighbors in the rock-salt structure."
        }
    }
    var polarityExplanation: String {
        switch self {
        case .water: "Oxygen attracts shared electrons more strongly than hydrogen. The bent O–H directions do not cancel, so water has a molecular dipole."
        case .ammonia: "Nitrogen attracts shared electrons more strongly than hydrogen. The pyramidal bond directions do not cancel, so ammonia is polar."
        case .carbonDioxide: "Both C=O bonds are polar, but their equal, opposite directions cancel. A polar bond does not guarantee a polar molecule."
        case .methane: "The four C–H bond directions cancel by tetrahedral symmetry. Methane has no permanent molecular dipole."
        case .hydrogen, .oxygen: "Identical atoms have the same electronegativity. Neither end preferentially attracts the shared electrons."
        case .salt: "These are charged ions in a crystal, not partial charges in a discrete molecule. Molecular dipole classification is not useful for the whole crystal."
        }
    }
}

enum BondStage: String, CaseIterable, Identifiable {
    case electrons = "Electrons", shape = "Shape", binding = "Binding", reactions = "Reactions", life = "Life"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .electrons: "circle.dotted.circle"
        case .shape: "cube.transparent"
        case .binding: "point.topleft.down.to.point.bottomright.curvepath"
        case .reactions: "arrow.triangle.2.circlepath"
        case .life: "leaf"
        }
    }
}

enum BondPhysics {
    /// Dimensionless Morse-style illustration. No molecule-specific fit is implied.
    static func potential(_ r: Double) -> Double { pow(1 - exp(-2.2 * (r - 1)), 2) - 1 }
    static func force(_ r: Double) -> Double {
        let e = exp(-2.2 * (r - 1))
        return -4.4 * e * (1 - e)
    }

    static func normalizedYaw(_ value: Double) -> Double { atan2(sin(value), cos(value)) }
}

/// Feature-owned interaction state survives moving between the five learning stages.
struct BondExploration {
    var electronProgress = 1.0
    var yaw = 0.4
    var pitch = -0.25
    var showPolarity = false
    var showDomains = false
    var distance = 1.0
    var reaction: BondReaction
    var reactionProgress = 0.0
    var thermal = 0.25
    var catalyst = false
    var lifeLink: BondLifeLink
    var lifeProgress: Double

    init(molecule: BondMolecule) {
        reaction = BondReaction.suggested(for: molecule)
        lifeLink = BondLifeLink.suggested(for: molecule)
        lifeProgress = lifeLink == .carbon ? 0.4 : 0.5
    }

    mutating func follow(_ molecule: BondMolecule) {
        reaction = BondReaction.suggested(for: molecule)
        reactionProgress = 0
        lifeLink = BondLifeLink.suggested(for: molecule)
        lifeProgress = lifeLink == .carbon ? 0.4 : 0.5
    }
}
