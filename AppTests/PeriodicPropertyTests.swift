import XCTest
import ChemistryCore
@testable import Stoicheia

final class PeriodicPropertyTests: XCTestCase {
    func testFamilyLensReportsActualFamiliesIncludingHydrogenAndMetalloids() {
        XCTAssertEqual(ElementProperty.family.label(ElementCatalog.element(1)), "Nonmetal")
        XCTAssertEqual(ElementProperty.family.label(ElementCatalog.element(11)), "Alkali metal")
        XCTAssertEqual(ElementProperty.family.label(ElementCatalog.element(5)), "Metalloid")
        XCTAssertEqual(ElementProperty.family.label(ElementCatalog.element(13)), "Post-transition metal")
        XCTAssertEqual(ElementProperty.family.label(ElementCatalog.element(57)), "Lanthanide")
        XCTAssertEqual(ElementProperty.family.label(ElementCatalog.element(89)), "Actinide")
    }

    func testPropertyLensesKeepMissingValuesAndUnitsExplicit() {
        let oxygen = ElementCatalog.element(8)
        XCTAssertEqual(ElementProperty.valence.value(oxygen), 6)
        XCTAssertEqual(ElementProperty.phase.label(oxygen), "Gas")
        XCTAssertEqual(ElementProperty.radius.unit, "pm (van der Waals)")
        XCTAssertNil(ElementProperty.electronegativity.value(ElementCatalog.element(2)))
        XCTAssertEqual(ElementProperty.electronegativity.label(ElementCatalog.element(2)), "—")
    }
}
