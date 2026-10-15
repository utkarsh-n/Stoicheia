import Foundation
import LabKitCore

enum GreekLetter: String, CaseIterable, Identifiable, Hashable {
    case alpha, beta, gamma, delta, epsilon, zeta, eta, theta
    case iota, kappa, lambda, mu, nu, xi, omicron, pi
    case rho, sigma, tau, upsilon, phi, chi, psi, omega

    var id: String { rawValue }
    var entry: GreekEntry { GreekCatalog.entries.first { $0.letter == self }! }
    var position: Int { Self.allCases.firstIndex(of: self)! + 1 }
}

struct GreekEntry: Identifiable {
    let letter: GreekLetter
    let upper: String
    let lower: String
    let origin: String
    let subject: String
    let title: String
    let explanation: String
    let otherUses: String
    var id: GreekLetter { letter }
    var name: String { letter.rawValue.capitalized }
    var glyphs: String { upper + " " + lower }

    func matches(_ query: String) -> Bool {
        query.isEmpty || [name, glyphs, subject, title, explanation, otherUses].contains {
            $0.localizedCaseInsensitiveContains(query)
        }
    }
}

enum GreekCatalog {
    static let entries: [GreekEntry] = [
        .init(letter: .alpha, upper: "Α", lower: "α", origin: "Phoenician aleph → Α. Aleph meant ox; the consonant became a Greek vowel.", subject: "Geometry", title: "An opening angle", explanation: "An angle measures a turn between two rays. Turn α and watch the wedge open. The letter is a label we choose for the angle.", otherUses: "Angular acceleration · alpha particles · significance level"),
        .init(letter: .beta, upper: "Β", lower: "β", origin: "Phoenician beth → Β. The Semitic name meant house.", subject: "Nuclear physics", title: "A neutron transforms", explanation: "In beta-minus decay, a neutron becomes a proton, an electron and an electron antineutrino. Scrub one illustrative event; this is not a decay-rate simulation.", otherUses: "Angles · regression coefficients · beta sheets in proteins"),
        .init(letter: .gamma, upper: "Γ", lower: "γ", origin: "Phoenician gimel → Γ. The name's earliest picture meaning is uncertain; camel is a traditional interpretation.", subject: "Radiation", title: "A gamma photon", explanation: "Gamma radiation is electromagnetic radiation from nuclear transitions. Here a schematic wave changes wavelength; the display scale does not represent actual gamma-ray wavelengths.", otherUses: "Lorentz factor · surface tension · Γ gamma function"),
        .init(letter: .delta, upper: "Δ", lower: "δ", origin: "Phoenician daleth → Δ. The inherited name is associated with door.", subject: "Change", title: "Before becomes after", explanation: "Capital Δ often means a finite change: final minus initial. Lowercase δ can mean a small variation or uncertainty. Move the final position and compare.", otherUses: "Discriminant · Dirac delta · epsilon-delta limits"),
        .init(letter: .epsilon, upper: "Ε", lower: "ε", origin: "Phoenician he → Ε, repurposed as a vowel. Epsilon later meant plain e.", subject: "Calculus", title: "Choose the tolerance", explanation: "ε is a positive error tolerance. For f(x) = 2x near x = 1, choosing δ = ε/2 keeps output error below ε whenever input error is below δ.", otherUses: "Permittivity · strain · a small positive quantity"),
        .init(letter: .zeta, upper: "Ζ", lower: "ζ", origin: "Phoenician zayin → Ζ. The ancient letter name is inherited; its original picture meaning is debated.", subject: "Number theory", title: "Tiny terms add up", explanation: "For real s > 1, ζ(s) sums 1/nˢ over all positive integers. This toy shows the first 40 terms only. Increase s and later terms shrink faster.", otherUses: "Damping ratio · vorticity · other zeta functions"),
        .init(letter: .eta, upper: "Η", lower: "η", origin: "Phoenician heth → Η. Some Greek dialects used it for h; Ionic Greek used it for a long e vowel.", subject: "Energy", title: "Useful output", explanation: "η often names efficiency: useful output energy divided by input energy. Split 100 joules between useful work and other energy transfers.", otherUses: "Viscosity · Dirichlet eta function · pseudorapidity"),
        .init(letter: .theta, upper: "Θ", lower: "θ", origin: "Phoenician teth → Θ. Its early pictorial interpretation is uncertain.", subject: "Geometry", title: "A turn on a circle", explanation: "θ commonly labels an angle. Radians compare arc length with radius: θ = s/r. One complete revolution is 2π radians.", otherUses: "Temperature parameters · polar coordinates · Θ growth bounds"),
        .init(letter: .iota, upper: "Ι", lower: "ι", origin: "Phoenician yodh → Ι. Its inherited name meant hand; Greek repurposed it as a vowel.", subject: "Language + notation", title: "A tiny quantity", explanation: "The English expression an iota means a very small amount. Here ι is our label for a shrinking quantity, rather than a universal scientific constant.", otherUses: "Indices · inclusion maps in some texts · iota subscript in Greek"),
        .init(letter: .kappa, upper: "Κ", lower: "κ", origin: "Phoenician kaph → Κ. The inherited name is associated with palm of a hand.", subject: "Geometry", title: "How sharply it bends", explanation: "κ can measure curvature. A circle has curvature 1/r: a smaller radius bends more sharply. Change the radius of this circle.", otherUses: "Thermal conductivity · dielectric constant · condition number"),
        .init(letter: .lambda, upper: "Λ", lower: "λ", origin: "Phoenician lamed → Λ. The inherited name is traditionally associated with a goad.", subject: "Waves", title: "Distance per cycle", explanation: "λ is commonly wavelength: the distance between repeating wave peaks. At a fixed wave speed, a longer wavelength gives a lower frequency.", otherUses: "Eigenvalues · decay constant · anonymous functions"),
        .init(letter: .mu, upper: "Μ", lower: "μ", origin: "Phoenician mem → Μ. The inherited name is associated with water.", subject: "Mechanics", title: "A surface resists sliding", explanation: "μₖ is a coefficient of kinetic friction. In this idealized model, friction magnitude is μₖN. Hold normal force at 10 newtons and change μₖ.", otherUses: "Population mean · micro prefix · chemical potential"),
        .init(letter: .nu, upper: "Ν", lower: "ν", origin: "Phoenician nun → Ν. Fish is a traditional interpretation of its Semitic name.", subject: "Waves", title: "Cycles each second", explanation: "ν can label frequency. Increase the number of cycles per second and the wave repeats faster. This toy keeps wave speed fixed.", otherUses: "Neutrinos · kinematic viscosity · degrees of freedom"),
        .init(letter: .xi, upper: "Ξ", lower: "ξ", origin: "Phoenician samekh → Ξ in the Ionic alphabet. Local Greek alphabets varied in their use of this sign.", subject: "Coordinates", title: "A coordinate is a choice", explanation: "ξ often serves as a coordinate or variable. Here it labels a point's horizontal position on a chosen axis; it has no fixed universal meaning.", otherUses: "Random variables · Riemann xi function · reaction extent"),
        .init(letter: .omicron, upper: "Ο", lower: "ο", origin: "Phoenician ayin → Ο, repurposed as a vowel. Omicron means small o, distinguishing it from omega.", subject: "Algorithms", title: "Compare rates of growth", explanation: "Order notation uses O and o, often associated with omicron but visually shared with Latin letters. n grows more slowly than n²: n/n² tends to zero.", otherUses: "Primarily a Greek letter · O upper bound · o strict asymptotic comparison"),
        .init(letter: .pi, upper: "Π", lower: "π", origin: "Phoenician pe → Π. The inherited name meant mouth.", subject: "Geometry", title: "The circle ratio", explanation: "π is the circumference of a circle divided by its diameter. Resize the circle: both lengths change while their ratio remains π.", otherUses: "Π products · π bonds · pions · probability in some texts"),
        .init(letter: .rho, upper: "Ρ", lower: "ρ", origin: "Phoenician resh → Ρ. The inherited name meant head.", subject: "Matter", title: "Mass packed into space", explanation: "ρ often denotes density: mass divided by volume. Keep one unit of volume and change the mass represented by the dots.", otherUses: "Electrical resistivity · correlation coefficient · charge density"),
        .init(letter: .sigma, upper: "Σ", lower: "σ / ς", origin: "Sigma is linked to Phoenician shin. Its letter name and shape history are more complex than a simple one-to-one copy.", subject: "Mathematics", title: "Collect the terms", explanation: "Capital Σ commonly means sum. Add the integers from 1 through n. Lowercase σ has many uses; ς is the lowercase form at the end of a Greek word.", otherUses: "Standard deviation · stress · cross section · σ bonds"),
        .init(letter: .tau, upper: "Τ", lower: "τ", origin: "Phoenician taw → Τ. The inherited name is associated with a mark.", subject: "Mechanics", title: "The twisting effect", explanation: "τ often denotes torque. With force perpendicular to a lever, torque equals radius times force. Keep the lever at one metre and change the force.", otherUses: "Time constant · lifetime · 2π circle constant in some texts"),
        .init(letter: .upsilon, upper: "Υ", lower: "υ", origin: "Upsilon was added in Greek and is usually connected to Phoenician waw; its development differs from the basic borrowed series.", subject: "Particle physics", title: "A named bound state", explanation: "Capital Υ names upsilon mesons: bound states of a bottom quark and its antiquark. The separation control is a schematic illustration, not a computed quark orbit.", otherUses: "A Greek vowel · particle labels · variables chosen by authors"),
        .init(letter: .phi, upper: "Φ", lower: "φ / ϕ", origin: "Phi was a Greek addition, with no securely established direct Phoenician counterpart. Early regional alphabets used supplemental signs differently.", subject: "Proportion", title: "Find the golden split", explanation: "The golden ratio φ = (1 + √5)/2 is about 1.618. Split a segment until whole/long equals long/short. The two forms φ and ϕ vary by font and convention.", otherUses: "Phase angle · Φ magnetic flux · work function · Euler's totient"),
        .init(letter: .chi, upper: "Χ", lower: "χ", origin: "Chi was a Greek addition. Its sound value varied among early local alphabets; no direct Phoenician counterpart is secure.", subject: "Statistics", title: "Observed versus expected", explanation: "χ² can measure squared differences between observed and expected counts. Shift observations between two categories; larger mismatch produces a larger statistic.", otherUses: "Magnetic susceptibility · electronegativity in some scales · characteristic functions"),
        .init(letter: .psi, upper: "Ψ", lower: "ψ", origin: "Psi was a Greek addition. Regional scripts assigned different sounds to Ψ before the Ionic alphabet became standard.", subject: "Quantum physics", title: "Amplitude to probability", explanation: "ψ denotes a wavefunction. Its magnitude squared gives probability density. This normalized one-dimensional box model shows the amplitude and its nonnegative square.", otherUses: "Stream function · digamma function · quantum states"),
        .init(letter: .omega, upper: "Ω", lower: "ω", origin: "Omega developed in Ionic Greek for long o. Its name means big o; it has no separate Phoenician predecessor.", subject: "Motion", title: "How fast it turns", explanation: "ω commonly means angular velocity: angle changed per unit time. Increase radians per second and the rotor turns faster.", otherUses: "Ω ohm · solid angle · sample space · asymptotic lower bound")
    ]
}

enum GreekToyModel {
    static func hasMotion(_ letter: GreekLetter) -> Bool {
        [.gamma, .lambda, .nu, .omega].contains(letter)
    }

    static func animationRate(_ letter: GreekLetter, value: Double) -> Double {
        switch letter {
        case .gamma, .lambda: return 2 / value
        case .nu: return value
        case .omega: return value / (2 * .pi)
        default: return 0
        }
    }

    static func control(for letter: GreekLetter) -> ParamSpec {
        let info: (String, ClosedRange<Double>, Double, Double, ParamFormat)
        switch letter {
        case .alpha, .theta: info = ("Angle", 0...360, 60, 1, .number(precision: 0, unit: "°"))
        case .beta: info = ("Event progress", 0...1, 0, 0, .percent)
        case .gamma, .lambda: info = ("Wavelength", 0.3...3, 1.5, 0, .number(precision: 2, unit: "model m"))
        case .delta: info = ("Final position", -5...5, 3, 0, .number(precision: 1, unit: "m"))
        case .epsilon: info = ("Tolerance", 0.05...1, 0.4, 0, .number(precision: 2, unit: ""))
        case .zeta: info = ("Exponent s", 1.1...4, 2, 0, .number(precision: 2, unit: ""))
        case .eta: info = ("Efficiency", 0...1, 0.65, 0, .percent)
        case .iota: info = ("Quantity", 0.001...1, 0.1, 0, .number(precision: 3, unit: ""))
        case .kappa: info = ("Radius", 0.5...4, 2, 0, .number(precision: 2, unit: "m"))
        case .mu: info = ("Friction coefficient", 0...1, 0.3, 0, .number(precision: 2, unit: ""))
        case .nu: info = ("Frequency", 0.5...4, 1, 0, .number(precision: 2, unit: "Hz"))
        case .xi: info = ("Coordinate", -1...1, 0.3, 0, .number(precision: 2, unit: ""))
        case .omicron: info = ("Input size n", 1...50, 8, 1, .number(precision: 0, unit: ""))
        case .pi: info = ("Diameter", 0.5...4, 2, 0, .number(precision: 2, unit: "m"))
        case .rho: info = ("Mass", 1...40, 15, 1, .number(precision: 0, unit: "kg"))
        case .sigma: info = ("Last term n", 1...12, 6, 1, .number(precision: 0, unit: ""))
        case .tau: info = ("Force", 0...10, 5, 0, .number(precision: 1, unit: "N"))
        case .upsilon: info = ("Separation", 0.1...1, 0.5, 0, .number(precision: 2, unit: "model units"))
        case .phi: info = ("Long fraction", 0.5...0.85, 0.61803398875, 0, .number(precision: 3, unit: ""))
        case .chi: info = ("Observed in A", 0...40, 20, 1, .number(precision: 0, unit: ""))
        case .psi: info = ("State n", 1...5, 1, 1, .number(precision: 0, unit: ""))
        case .omega: info = ("Angular velocity", 0...8, 2, 0, .number(precision: 1, unit: "rad/s"))
        }
        return ParamSpec(ParamID("greek-\(letter.rawValue)"), title: info.0, icon: "dial.medium", tint: LabColor(0.35, 0.86, 1), range: info.1, defaultValue: info.2, detents: letter == .phi ? [Detent(0.61803398875, "Golden split")] : [], step: info.3, hint: "Turn to explore \(letter.entry.title.lowercased()).", glyph: letter.entry.lower, glyphSpoken: letter.rawValue, format: info.4)
    }

    static func reading(_ letter: GreekLetter, value v: Double) -> String {
        switch letter {
        case .alpha: return "α = \(fixed(v))° · \(fixed(v * .pi / 180, 2)) radians"
        case .theta: return "θ = s/r = \(fixed(v * .pi / 180, 2)) rad"
        case .beta: return v < 0.5 ? "n → p⁺ + e⁻ + ν̄ₑ · before transition" : "n → p⁺ + e⁻ + ν̄ₑ · after transition"
        case .gamma, .lambda: return "λ = \(fixed(v, 2)) · ν = \(fixed(2 / v, 2)) · speed = 2 model units/s"
        case .delta: return "Δx = x₂ − x₁ = \(fixed(v, 1)) − 0 = \(fixed(v, 1)) m"
        case .epsilon: return "ε = \(fixed(v, 2)) · δ = ε/2 = \(fixed(v / 2, 3))"
        case .zeta: return "Σₙ₌₁⁴⁰ 1/nˢ = \(fixed((1...40).reduce(0.0) { $0 + pow(Double($1), -v) }, 4)) · partial sum"
        case .eta: return "η = Euseful / Ein = \(fixed(v * 100))% · \(fixed(v * 100)) J useful"
        case .iota: return "ι = \(fixed(v, 3)) · this toy's label for a small amount"
        case .kappa: return "κ = 1/r = \(fixed(1 / v, 3)) m⁻¹"
        case .mu: return "Ffriction = μₖN = \(fixed(v, 2)) × 10 = \(fixed(v * 10, 1)) N"
        case .nu: return "ν = \(fixed(v, 2)) Hz · λ = \(fixed(2 / v, 2)) model m"
        case .xi: return "ξ = \(fixed(v, 2)) · position on a chosen axis"
        case .omicron: return "n = \(fixed(v)) · n² = \(fixed(v * v)) · n/n² = \(fixed(1 / v, 3))"
        case .pi: return "C = πd = \(fixed(.pi * v, 3)) m · C/d = 3.14159…"
        case .rho: return "ρ = m/V = \(fixed(v)) kg / 1 m³ = \(fixed(v)) kg/m³"
        case .sigma: return "Σₖ₌₁ⁿ k = n(n + 1)/2 = \(fixed(v * (v + 1) / 2))"
        case .tau: return "τ = rF = 1 m × \(fixed(v, 1)) N = \(fixed(v, 1)) N·m"
        case .upsilon: return "Υ = b b̄ · separation = \(fixed(v, 2)) model units · schematic"
        case .phi: return "whole/long = \(fixed(1 / v, 3)) · long/short = \(fixed(v / (1 - v), 3))"
        case .chi: return "χ² = Σ(O − E)²/E = \(fixed(pow(v - 20, 2) / 10, 2)) · E = 20 per group"
        case .psi: return "ψ = √2 sin(nπx), L = 1 · n = \(fixed(v)) · ∫|ψ|² dx = 1"
        case .omega: return "ω = Δθ/Δt = \(fixed(v, 1)) rad/s · \(fixed(v / (2 * .pi), 2)) rev/s"
        }
    }

    private static func fixed(_ v: Double, _ precision: Int = 0) -> String {
        String(format: "%.*f", precision, v)
    }
}
