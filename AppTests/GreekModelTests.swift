import XCTest
import LabKitCore
@testable import Stoicheia

final class GreekModelTests: XCTestCase {
    func testCatalogAndControlsCoverTheAlphabetExactlyOnce() {
        let letters = GreekLetter.allCases
        let entries = GreekCatalog.entries
        XCTAssertEqual(letters.count, 24)
        XCTAssertEqual(Set(letters).count, 24)
        XCTAssertEqual(entries.map(\.letter), letters)
        XCTAssertEqual(Set(entries.map(\.id)).count, 24)
        XCTAssertEqual(Set(entries.map(\.upper)).count, 24)
        XCTAssertEqual(Set(entries.map(\.lower)).count, 24)
        XCTAssertEqual(Set(entries.map(\.name)).count, 24)
        XCTAssertEqual(letters.map(\.position), Array(1...24))
        XCTAssertEqual(GreekLetter.sigma.entry.lower, "σ / ς")
        XCTAssertEqual(GreekLetter.phi.entry.lower, "φ / ϕ")

        let specs = letters.map { GreekToyModel.control(for: $0) }
        XCTAssertEqual(Set(specs.map(\.id)).count, 24)
        for (letter, spec) in zip(letters, specs) {
            XCTAssertEqual(spec.id.rawValue, "greek-\(letter.rawValue)")
            XCTAssertEqual(spec.glyphSpoken, letter.rawValue)
            XCTAssertEqual(spec.glyph, letter.entry.lower)
            XCTAssertFalse(letter.entry.origin.isEmpty)
            XCTAssertFalse(letter.entry.explanation.isEmpty)
            XCTAssertTrue(letter.entry.matches(letter.rawValue.uppercased()))
        }
    }

    func testEveryControlReachesFiniteExtremaAndKeepsItsDefaultInRange() {
        for letter in GreekLetter.allCases {
            let spec = GreekToyModel.control(for: letter)
            let context = letter.rawValue
            XCTAssertTrue(spec.range.lowerBound.isFinite, context)
            XCTAssertTrue(spec.range.upperBound.isFinite, context)
            XCTAssertLessThan(spec.range.lowerBound, spec.range.upperBound, context)
            XCTAssertTrue(spec.range.contains(spec.defaultValue), context)
            XCTAssertTrue(spec.defaultValue.isFinite, context)
            XCTAssertEqual(spec.value(at: 0), spec.range.lowerBound, accuracy: 1e-12, context)
            XCTAssertEqual(spec.value(at: 1), spec.range.upperBound, accuracy: 1e-12, context)
            XCTAssertEqual(spec.clamp(-.infinity), spec.defaultValue, context)
            XCTAssertEqual(spec.clamp(.nan), spec.defaultValue, context)

            for value in [spec.value(at: 0), spec.defaultValue, spec.value(at: 1)] {
                let rate = GreekToyModel.animationRate(letter, value: value)
                XCTAssertTrue(rate.isFinite, "\(context), value \(value)")
                XCTAssertGreaterThanOrEqual(rate, 0, context)
                let reading = GreekToyModel.reading(letter, value: value).lowercased()
                XCTAssertFalse(reading.isEmpty, context)
                XCTAssertFalse(reading.contains("nan"), context)
                XCTAssertFalse(reading.contains("inf"), context)
                if !GreekToyModel.hasMotion(letter) {
                    XCTAssertEqual(rate, 0, context)
                }
            }
        }
        XCTAssertEqual(Set(GreekLetter.allCases.filter { GreekToyModel.hasMotion($0) }), Set<GreekLetter>([.gamma, .lambda, .nu, .omega]))
    }

    func testChiSquaredHasSymmetricExtremaAndZeroAtBalancedCounts() throws {
        let spec = GreekToyModel.control(for: .chi)
        let minimum = GreekToyModel.reading(.chi, value: spec.value(at: 0))
        let maximum = GreekToyModel.reading(.chi, value: spec.value(at: 1))
        let midpoint = GreekToyModel.reading(.chi, value: spec.value(at: 0.5))
        XCTAssertEqual(minimum, maximum)
        XCTAssertEqual(try number(after: "Σ(O − E)²/E = ", in: minimum), 40)
        XCTAssertEqual(try number(after: "Σ(O − E)²/E = ", in: midpoint), 0)
        XCTAssertEqual(spec.defaultValue, spec.value(at: 0.5))
        // Swapping the two categories preserves the statistic.
        XCTAssertEqual(GreekToyModel.reading(.chi, value: 10), GreekToyModel.reading(.chi, value: 30))
        XCTAssertEqual(try number(after: "Σ(O − E)²/E = ", in: GreekToyModel.reading(.chi, value: 10)), 10)
    }

    func testWaveMotionAndReadoutsPreserveTheFixedModelSpeed() throws {
        for letter in [GreekLetter.gamma, .lambda] {
            let spec = GreekToyModel.control(for: letter)
            for wavelength in [spec.range.lowerBound, spec.defaultValue, spec.range.upperBound] {
                let frequency = GreekToyModel.animationRate(letter, value: wavelength)
                XCTAssertEqual(frequency * wavelength, 2, accuracy: 1e-12, letter.rawValue)
                let reading = GreekToyModel.reading(letter, value: wavelength)
                XCTAssertEqual(try number(after: "λ = ", in: reading), wavelength, accuracy: 0.0051)
                XCTAssertEqual(try number(after: "ν = ", in: reading), frequency, accuracy: 0.0051)
            }
        }
        // These exact pairs independently check the frequency-controlled presentation.
        for (frequency, wavelength) in [(0.5, 4.0), (1.0, 2.0), (4.0, 0.5)] {
            let reading = GreekToyModel.reading(.nu, value: frequency)
            let displayedWavelength = try number(after: "λ = ", in: reading)
            XCTAssertEqual(displayedWavelength, wavelength, accuracy: 1e-12)
            XCTAssertEqual(GreekToyModel.animationRate(.nu, value: frequency), frequency)
            XCTAssertEqual(frequency * displayedWavelength, 2, accuracy: 1e-12)
        }
    }

    func testRateChangePreservesTheExactCurrentFrame() {
        var clock = GreekMotionClock()
        clock.rebase(at: 100, rate: 2, running: true)
        XCTAssertEqual(clock.phase(at: 100.125), 0.25, accuracy: 1e-12)
        clock.rebase(at: 100.125, rate: 1, running: true)
        XCTAssertEqual(clock.phase(at: 100.125), 0.25, accuracy: 1e-12)
        XCTAssertEqual(clock.phase(at: 100.25), 0.375, accuracy: 1e-12)
        XCTAssertEqual(clock.rate, 1)
    }

    func testPauseRestartAndBackgroundExcludeInactiveTime() {
        var clock = GreekMotionClock()
        clock.rebase(at: 10, rate: 1, running: true)
        clock.rebase(at: 10.25, rate: 1, running: false) // User pauses.
        XCTAssertEqual(clock.phase(at: 500), 0.25, accuracy: 1e-12)
        clock.rebase(at: 500, rate: 2, running: true)
        XCTAssertEqual(clock.phase(at: 500), 0.25, accuracy: 1e-12)
        XCTAssertEqual(clock.phase(at: 500.125), 0.5, accuracy: 1e-12)
        clock.rebase(at: 500.125, rate: 2, running: false) // Scene becomes inactive.
        XCTAssertEqual(clock.phase(at: 1_000), 0.5, accuracy: 1e-12)
        clock.rebase(at: 1_000, rate: 2, running: true)
        XCTAssertEqual(clock.phase(at: 1_000), 0.5, accuracy: 1e-12)
        XCTAssertEqual(clock.phase(at: 1_000.125), 0.75, accuracy: 1e-12)
    }

    func testZeroRateFreezesAndRestartDoesNotReplayElapsedTime() {
        var clock = GreekMotionClock()
        clock.rebase(at: 1, rate: 1, running: true)
        clock.rebase(at: 1.25, rate: 0, running: true)
        XCTAssertEqual(clock.rate, 0)
        XCTAssertEqual(clock.phase(at: 100), 0.25, accuracy: 1e-12)
        clock.rebase(at: 100, rate: 1, running: true)
        XCTAssertEqual(clock.phase(at: 100), 0.25, accuracy: 1e-12)
        XCTAssertEqual(clock.phase(at: 100.125), 0.375, accuracy: 1e-12)
    }

    func testPhaseWrapsWithoutRewindingForEarlierTimestamps() {
        var clock = GreekMotionClock()
        XCTAssertEqual(clock.phase(at: 50), 0)
        clock.rebase(at: 100, rate: 4, running: true)
        XCTAssertEqual(clock.phase(at: 99), 0)
        XCTAssertEqual(clock.phase(at: 100.3125), 0.25, accuracy: 1e-12)
        XCTAssertEqual(clock.phase(at: 101), 0, accuracy: 1e-12)
        for time in [100.0, 100.125, 100.999, 1_000.0] {
            XCTAssertTrue((0.0..<1.0).contains(clock.phase(at: time)))
        }
    }

    private func number(after marker: String, in reading: String, file: StaticString = #filePath, line: UInt = #line) throws -> Double {
        let range = try XCTUnwrap(reading.range(of: marker), "Missing \(marker) in \(reading)", file: file, line: line)
        let token = reading[range.upperBound...].prefix { "0123456789.-+".contains($0) }
        return try XCTUnwrap(Double(String(token)), "Missing number in \(reading)", file: file, line: line)
    }
}
