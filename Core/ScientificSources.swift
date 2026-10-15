import Foundation

public struct ScientificSource: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let url: URL
    public let detail: String
}

public enum ScientificSources {
    public static let retrievalDate = "2026-10-11"
    public static let elements = [
        ScientificSource(id: "pubchem", title: "PubChem periodic table", url: URL(string: "https://pubchem.ncbi.nlm.nih.gov/periodic-table/")!, detail: "All 118 element identities, properties and neutral electron configurations; missing fields remain unknown."),
        ScientificSource(id: "nist-isotopes", title: "NIST isotope masses and compositions", url: URL(string: "https://www.nist.gov/pml/atomic-weights-and-isotopic-compositions-relative-atomic-masses")!, detail: "Representative naturally occurring isotopes and a documented isotope list. This is an older compiled reference, not a live nuclear-stability database."),
        ScientificSource(id: "iupac", title: "IUPAC periodic table", url: URL(string: "https://iupac.org/what-we-do/periodic-table-of-elements/")!, detail: "Group numbering and representative mass numbers for elements without characteristic natural isotope abundances."),
        ScientificSource(id: "nist-lr", title: "NIST: lawrencium ground state", url: URL(string: "https://physics.nist.gov/cgi-bin/Elements/elInfo.pl?context=noframes&element=103")!, detail: "Lawrencium's current 7p ground-state configuration corrects the older 6d entry in PubChem."),
        ScientificSource(id: "ciaaw-h", title: "CIAAW: hydrogen isotopes", url: URL(string: "https://www.ciaaw.org/hydrogen.htm")!, detail: "Hydrogen-1/2 stability and tritium radioactive decay."),
        ScientificSource(id: "ciaaw-c", title: "CIAAW: carbon isotopes", url: URL(string: "https://www.ciaaw.org/carbon.htm")!, detail: "Carbon-12/13 and carbon-14 radioactive decay.")
    ]
}
