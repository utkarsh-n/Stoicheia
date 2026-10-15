import XCTest

@MainActor final class PlaygroundTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        XCTAssertTrue(app.staticTexts["atom-element"].waitForExistence(timeout: 30))
    }

    func testParticleKnobDragsFineControlsAndBoundaries() {
        let proton = app.descendants(matching: .any)["knob-proton"].firstMatch
        reveal(proton)
        proton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo: proton.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0.5)))
        XCTAssertNotEqual(app.staticTexts["atom-element"].label, "Carbon")
        proton.doubleTap()
        XCTAssertEqual(app.staticTexts["atom-element"].label, "Carbon")
        exactParticle("proton", position: 0, expected: "1")
        reveal(app.buttons["atom-proton-minus"]); app.buttons["atom-proton-minus"].tap()
        XCTAssertEqual(app.staticTexts["atom-element"].label, "Hydrogen")
        exactParticle("proton", position: 1, expected: "118")
        reveal(app.buttons["atom-proton-plus"]); app.buttons["atom-proton-plus"].tap()
        XCTAssertEqual(app.staticTexts["atom-element"].label, "Oganesson")
        exactParticle("electron", position: 0, expected: "0")
        reveal(app.staticTexts["atom-configuration"])
        XCTAssertTrue(app.staticTexts["atom-configuration"].label.lowercased().contains("no electrons"))
        capture("Particle-boundaries-bare-ion")
    }

    func testParticlesDistinguishElementIsotopeAndIon() {
        reveal(app.buttons["atom-neutron-plus"]); app.buttons["atom-neutron-plus"].tap()
        XCTAssertEqual(app.staticTexts["atom-element"].label, "Carbon")
        reveal(app.staticTexts["atom-observation"])
        XCTAssertTrue(app.staticTexts["atom-observation"].label.contains("Carbon-13"))
        reveal(app.buttons["atom-electron-plus"]); app.buttons["atom-electron-plus"].tap()
        reveal(app.staticTexts["atom-observation"])
        XCTAssertTrue(app.staticTexts["atom-observation"].label.contains("−1"))
        reveal(app.buttons["atom-proton-plus"]); app.buttons["atom-proton-plus"].tap()
        XCTAssertEqual(app.staticTexts["atom-element"].label, "Nitrogen")
        capture("Atom-particles")
    }

    func testOrbitalSelectionSurvivesIsotopeChangeAndVisualModes() {
        reveal(app.buttons["orbital-1s"]); app.buttons["orbital-1s"].tap()
        reveal(app.descendants(matching: .any)["atom-orb"].firstMatch)
        let orb = app.descendants(matching: .any)["atom-orb"].firstMatch
        XCTAssertTrue(reading(orb).contains("1s"))
        capture("Orbital-1s-cloud")
        reveal(app.buttons["atom-neutron-plus"]); app.buttons["atom-neutron-plus"].tap()
        XCTAssertTrue(reading(orb).contains("1s"))
        reveal(app.buttons["orbital-2p"]); app.buttons["orbital-2p"].tap()
        reveal(orb)
        XCTAssertTrue(reading(orb).contains("2p"))
        capture("Orbital-2p-cloud")
        app.buttons["Shells"].tap(); capture("Carbon-shells")
        app.buttons["Nucleus"].tap(); capture("Carbon-nucleus")
        app.buttons["Clouds"].tap()
    }

    func testPeriodicSearchSelectionAndIons() {
        tab("Table")
        let search = app.textFields["table-search"]
        search.tap(); search.typeText("8\n")
        XCTAssertTrue(app.buttons["element-8"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["element-18"].exists)
        app.buttons["element-8"].tap()
        tab("Atom")
        XCTAssertEqual(app.staticTexts["atom-element"].label, "Oxygen")
        reveal(app.buttons["atom-electron-plus"]); app.buttons["atom-electron-plus"].tap(); app.buttons["atom-electron-plus"].tap()
        reveal(app.staticTexts["atom-configuration"])
        XCTAssertTrue(app.staticTexts["atom-configuration"].label.contains("2p6"))
        capture("Oxygen-ion")
        tab("Table")
        app.buttons["table-clear-search"].tap()
        search.tap(); search.typeText("xxyyzz\n")
        XCTAssertTrue(app.descendants(matching: .any)["table-empty-state"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["table-result-count"].label.contains("0 / 118"))
        capture("Table-empty-search")
    }

    func testPeriodicLensesFamilyFilterAndDetachedElements() {
        tab("Table")
        app.buttons["table-layout"].tap()
        let lenses: [(String, String, String)] = [
            ("Family", "Nonmetal", "Nonmetal"),
            ("Outer electrons", "1", "4"),
            ("Electronegativity", "2.2", "2.55"),
            ("Radius", "120", "170"),
            ("Atomic mass", "1.01", "12.01"),
            ("State", "Gas", "Solid")
        ]
        for (lens, hydrogen, carbon) in lenses {
            chooseTableLens(lens)
            XCTAssertEqual(app.buttons["element-1"].value as? String, "\(lens): \(hydrogen)")
            XCTAssertEqual(app.buttons["element-6"].value as? String, "\(lens): \(carbon)")
            if lens == "Family" {
                XCTAssertEqual(app.buttons["element-2"].value as? String, "Family: Noble gas")
            }
            if lens == "Electronegativity" {
                XCTAssertEqual(app.buttons["element-2"].value as? String, "Electronegativity: —")
            }
            capture("Table-lens-\(lens)")
        }
        app.buttons["table-family"].tap(); app.buttons["Noble gas"].tap()
        XCTAssertTrue(app.staticTexts["table-result-count"].label.contains("7 / 118"))
        XCTAssertTrue(app.buttons["element-2"].exists)
        XCTAssertFalse(app.buttons["element-3"].exists)
        app.buttons["table-family"].tap(); app.buttons["All families"].tap()
        let search = app.textFields["table-search"]
        search.tap(); search.typeText("92\n")
        app.buttons["element-92"].tap(); tab("Atom")
        XCTAssertEqual(app.staticTexts["atom-element"].label, "Uranium")
        capture("Uranium-from-table")
    }

    func testGreekAlphaThroughMuEndpointsAndReset() {
        executionTimeAllowance = 600
        greekSweep(["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu"])
    }

    func testGreekNuThroughOmegaEndpointsAndReset() {
        executionTimeAllowance = 600
        greekSweep(["nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega"])
    }

    func testGreekKnobDragValueRetentionAndPlayback() async throws {
        executionTimeAllowance = 180
        tab("Greek"); openGreek("omega")
        let equation = app.staticTexts["greek-selected-symbol"]
        let initial = reading(equation)
        let knob = app.descendants(matching: .any)["knob-greek-omega"].firstMatch
        reveal(knob)
        knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo: knob.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0.5)))
        XCTAssertNotEqual(reading(equation), initial)
        let changed = reading(equation)
        let heldPhase = try await verifyGreekPlayback("omega")
        let motion = app.buttons["greek-motion-button"]
        tab("Atom"); tab("Greek")
        XCTAssertEqual(reading(equation), changed)
        XCTAssertEqual(motion.value as? String, "Paused")
        XCTAssertEqual(try greekPhase("omega"), heldPhase, "Paused frame survives a tab change")
        leaveGreekLetter(); openGreek("omega")
        XCTAssertEqual(reading(equation), changed)
        XCTAssertEqual(motion.value as? String, "Paused")
        XCTAssertEqual(try greekPhase("omega"), heldPhase, "Paused frame survives leaving the letter")
        captureGreekScene("omega", endpoint: "persisted-pause")
    }

    func testGreekWavesAdvanceAndPauseAtTheirVisiblePhase() async throws {
        executionTimeAllowance = 300
        tab("Greek")
        for letter in ["gamma", "lambda", "nu"] {
            openGreek(letter)
            _ = try await verifyGreekPlayback(letter)
            captureGreekScene(letter, endpoint: "paused-wave")
            leaveGreekLetter()
        }
    }

    func testGreekZeroAngularVelocityKeepsPlayingRotorStill() async throws {
        tab("Greek"); openGreek("omega")
        try requireGreekMotionControls()
        let slider = app.sliders["knob-greek-omega-slider"]
        reveal(slider); setSlider(slider, position: 0)
        XCTAssertEqual(app.staticTexts["greek-selected-symbol"].value as? String, greekReadouts["omega"]!.0)
        let motion = app.buttons["greek-motion-button"]
        reveal(motion); motion.tap()
        XCTAssertEqual(motion.value as? String, "Playing")
        let initialPhase = try greekPhase("omega")
        try await Task.sleep(for: .milliseconds(400))
        XCTAssertEqual(try greekPhase("omega"), initialPhase, "Zero angular velocity freezes the drawn phase")
        XCTAssertTrue(greekStageValue("omega").hasSuffix("Zero speed: still"))
        motion.tap()
        XCTAssertEqual(motion.value as? String, "Paused")
    }

    func testGreekReduceMotionKeepsWaveAndRotorFramesStill() async throws {
        tab("Greek")
        for letter in ["lambda", "omega"] {
            openGreek(letter)
            guard app.staticTexts["greek-motion-status"].label.hasPrefix("Reduce Motion") else {
                throw XCTSkip("This scenario requires the simulator's Reduce Motion setting to be enabled.")
            }
            XCTAssertFalse(app.buttons["greek-motion-button"].exists)
            let slider = app.sliders["knob-greek-\(letter)-slider"]
            reveal(slider); setSlider(slider, position: 1)
            XCTAssertEqual(slider.value as? String, greekControlValues[letter]!.1, "Reduce Motion keeps controls usable")
            let initialPhase = try greekPhase(letter)
            try await Task.sleep(for: .milliseconds(400))
            XCTAssertEqual(try greekPhase(letter), initialPhase, "Reduce Motion freezes \(letter)'s drawn phase")
            XCTAssertTrue(greekStageValue(letter).hasSuffix("Reduce Motion: still"))
            captureGreekScene(letter, endpoint: "reduce-motion")
            leaveGreekLetter()
        }
    }

    func testAllBondPresetsAndShapes() {
        executionTimeAllowance = 300
        tab("Bonds & Life")
        let examples: [(String, String)] = [("water", "104.5"), ("methane", "109.5"), ("ammonia", "107"), ("carbonDioxide", "180"), ("hydrogen", "No three-atom angle"), ("oxygen", "No three-atom angle"), ("salt", "6 nearest")]
        for (name, shape) in examples {
            chooseMolecule(name)
            stage("shape")
            XCTAssertTrue(app.descendants(matching: .any)["bond-shape-readout"].firstMatch.waitForExistence(timeout: 5))
            XCTAssertTrue(app.descendants(matching: .any)["bond-shape-readout"].firstMatch.label.contains(shape), name)
            reveal(app.sliders["bond-rotation-slider"])
            let originalViewpoint = app.staticTexts["bond-rotation-value"].label
            setSlider(app.sliders["bond-rotation-slider"], position: 1)
            XCTAssertNotEqual(app.staticTexts["bond-rotation-value"].label, originalViewpoint)
            XCTAssertEqual(app.sliders["bond-rotation-slider"].value as? String, "180 degrees")
            reveal(app.buttons["bond-rotation-reset"]); app.buttons["bond-rotation-reset"].tap()
            XCTAssertTrue(app.staticTexts["bond-rotation-value"].label.contains("0° yaw"))
            capture("Bond-shape-\(name)")
        }
    }

    func testBondAssemblyAndBindingSettingsPersistAcrossStages() {
        tab("Bonds & Life"); chooseMolecule("water"); stage("electrons")
        reveal(app.sliders["bond-sharing-slider"]); setSlider(app.sliders["bond-sharing-slider"], position: 0)
        let assembly = app.staticTexts["bond-sharing-progress-value"].label
        XCTAssertEqual(assembly, "Bond map: 0% assembled")
        stage("shape"); stage("electrons")
        XCTAssertEqual(app.staticTexts["bond-sharing-progress-value"].label, assembly)
        stage("binding")
        reveal(app.sliders["bond-distance-slider"]); setSlider(app.sliders["bond-distance-slider"], position: 0)
        XCTAssertTrue(app.staticTexts["bond-binding-state"].label.contains("Repulsion"))
        setSlider(app.sliders["bond-distance-slider"], position: 1)
        XCTAssertTrue(app.staticTexts["bond-binding-state"].label.contains("Attraction"))
        XCTAssertEqual(app.sliders["bond-distance-slider"].value as? String, "3.00")
        let distance = app.descendants(matching: .any)["bond-binding-readout"].firstMatch.label
        stage("shape"); stage("binding")
        XCTAssertEqual(app.descendants(matching: .any)["bond-binding-readout"].firstMatch.label, distance)
        reveal(app.buttons["bond-equilibrium-button"]); app.buttons["bond-equilibrium-button"].tap()
        XCTAssertTrue(app.staticTexts["bond-binding-state"].label.contains("minimum"))
        capture("Bond-equilibrium")
    }

    func testBondCanvasDragTiltAndOverlays() {
        tab("Bonds & Life"); chooseMolecule("water"); stage("shape")
        let canvas = app.descendants(matching: .any)["bond-molecule-canvas"].firstMatch
        reveal(canvas)
        let before = canvas.value as? String
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo: canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.6)))
        XCTAssertNotEqual(canvas.value as? String, before)
        reveal(app.buttons["bond-rotation-tilt"]); app.buttons["bond-rotation-tilt"].tap()
        XCTAssertEqual(app.staticTexts["bond-rotation-value"].label, "Viewpoint: 34° yaw · -37° tilt")
        reveal(app.switches["bond-domains-toggle"]); app.switches["bond-domains-toggle"].tap()
        reveal(app.switches["bond-polarity-toggle"]); app.switches["bond-polarity-toggle"].tap()
        XCTAssertTrue(reading(canvas).contains("2 bonding regions and 2 lone-pair regions"))
        XCTAssertTrue(reading(canvas).contains("2 bond polarity arrows shown"))
        stage("electrons"); stage("shape"); tab("Atom"); tab("Bonds & Life")
        XCTAssertTrue(reading(canvas).contains("2 bond polarity arrows shown"))
        chooseMolecule("salt"); stage("shape")
        XCTAssertFalse(app.switches["bond-domains-toggle"].exists)
        XCTAssertFalse(app.switches["bond-polarity-toggle"].exists)
        XCTAssertTrue(reading(canvas).contains("Ionic lattice fragment"))
        capture("Bond-crystal-without-molecular-overlays")
    }

    func testAtomSelectionUpdatesBondContext() {
        tab("Bonds & Life"); stage("shape")
        XCTAssertTrue(app.buttons["bond-molecule-methane"].isSelected)
        tab("Atom")
        reveal(app.buttons["atom-proton-plus"]); app.buttons["atom-proton-plus"].tap(); app.buttons["atom-proton-plus"].tap()
        XCTAssertEqual(app.staticTexts["atom-element"].label, "Oxygen")
        tab("Bonds & Life")
        reveal(app.buttons["bond-molecule-water"])
        XCTAssertTrue(app.buttons["bond-molecule-water"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["bond-shape-readout"].firstMatch.label.contains("104.5"))
        capture("Atom-oxygen-updates-bond-context")
    }

    func testReactionsConserveAtomsAndPersistCatalystTemperature() {
        tab("Bonds & Life"); stage("reactions")
        for example in ["Make water", "Photosynthesis", "ATP hydrolysis"] {
            reveal(app.buttons["bond-reaction-picker"]); app.buttons["bond-reaction-picker"].tap(); app.buttons[example].tap()
            let expectedEquation = ["Make water": "2H₂ + O₂ → 2H₂O", "Photosynthesis": "6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂", "ATP hydrolysis": "ATP⁴⁻ + H₂O → ADP³⁻ + HPO₄²⁻ + H⁺"][example]!
            XCTAssertEqual(app.staticTexts["bond-reaction-equation"].label, expectedEquation)
            reveal(app.descendants(matching: .any)["bond-conservation-ledger"].firstMatch)
            let ledger = reading(app.descendants(matching: .any)["bond-conservation-ledger"].firstMatch)
            XCTAssertTrue(ledger.contains("conserved"))
            reveal(app.sliders["bond-reaction-progress"]); setSlider(app.sliders["bond-reaction-progress"], position: 1)
            XCTAssertEqual(app.staticTexts["bond-reaction-progress-value"].label, "100%")
            XCTAssertEqual(app.descendants(matching: .any)["bond-reaction-canvas"].firstMatch.value as? String, "100 percent through rearrangement")
            XCTAssertEqual(reading(app.descendants(matching: .any)["bond-conservation-ledger"].firstMatch), ledger)
            capture("Reaction-\(example)")
        }
        reveal(app.switches["bond-catalyst-toggle"]); app.switches["bond-catalyst-toggle"].tap()
        reveal(app.sliders["bond-temperature-slider"]); setSlider(app.sliders["bond-temperature-slider"], position: 1)
        let temperature = app.staticTexts["bond-temperature-value"].label
        XCTAssertEqual(temperature, "Thermal dial: 100%")
        stage("shape"); stage("reactions"); tab("Atom"); tab("Bonds & Life")
        XCTAssertTrue(app.staticTexts["bond-reaction-equation"].label.contains("ATP"))
        XCTAssertTrue(app.staticTexts["bond-catalyst-readout"].label.contains("Lower barrier"))
        XCTAssertEqual(app.staticTexts["bond-temperature-value"].label, temperature)
    }

    func testLifeScenesEndpointsAndRetention() {
        executionTimeAllowance = 300
        tab("Bonds & Life"); stage("life")
        for (scene, option, endpoint) in [("Water", "water", "Aligned"), ("Carbon", "carbon", "6 C"), ("Nitrogen", "nitrogen", "Glycine"), ("O₂ + iron", "oxygen", "at one Fe"), ("Na⁺ / K⁺", "gradient", "3 Na⁺ out"), ("Phosphate", "phosphate", "ADP"), ("Calcium", "calcium", "6 Ca²⁺")] {
            reveal(app.buttons["bond-life-picker"]); app.buttons["bond-life-picker"].tap()
            let sceneOption = app.buttons["bond-life-option-\(option)"]
            XCTAssertTrue(sceneOption.waitForExistence(timeout: 5))
            sceneOption.tap()
            reveal(app.sliders["bond-life-slider"]); setSlider(app.sliders["bond-life-slider"], position: 0)
            XCTAssertEqual(app.staticTexts["bond-life-progress-value"].label, "Scene control: 0%")
            capture("Life-\(scene)-start")
            setSlider(app.sliders["bond-life-slider"], position: 1)
            XCTAssertEqual(app.staticTexts["bond-life-progress-value"].label, "Scene control: 100%")
            XCTAssertTrue(app.staticTexts["bond-life-readout"].label.contains(endpoint), scene)
            if scene == "Na⁺ / K⁺" { XCTAssertEqual(app.staticTexts["bond-life-readout"].label, "3 Na⁺ out · 2 K⁺ in · 1 ATP") }
            capture("Life-\(scene)-end")
        }
        stage("shape"); stage("life"); tab("Atom"); tab("Bonds & Life")
        XCTAssertTrue(app.staticTexts["bond-life-title"].label.contains("cellular message"))
        XCTAssertTrue(app.staticTexts["bond-life-readout"].label.contains("6 Ca²⁺"))
    }

    private func greekSweep(_ letters: [String]) {
        tab("Greek")
        for letter in letters {
            openGreek(letter)
            let equation = app.staticTexts["greek-selected-symbol"]
            let initial = equation.value as? String
            XCTAssertNotNil(initial, "\(letter) exposes its live equation")
            let slider = app.sliders["knob-greek-\(letter)-slider"]
            let controlValues = greekControlValues[letter]!
            let knob = app.descendants(matching: .any)["knob-greek-\(letter)"].firstMatch
            reveal(knob)
            XCTAssertEqual(knob.value as? String, controlValues.2, "\(letter) initial knob")
            knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                .press(forDuration: 0.05, thenDragTo: knob.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0.5)))
            XCTAssertNotEqual(knob.value as? String, controlValues.2, "\(letter) rotary drag changes the parameter")
            knob.doubleTap()
            XCTAssertEqual(knob.value as? String, controlValues.2, "\(letter) double-tap resets the knob")
            XCTAssertEqual(equation.value as? String, initial, "\(letter) double-tap resets the equation")
            reveal(slider); setSlider(slider, position: 0)
            XCTAssertEqual(slider.value as? String, controlValues.0, "\(letter) minimum control")
            let minimum = equation.value as? String
            let endpoints = greekReadouts[letter]!
            XCTAssertEqual(minimum, endpoints.0, "\(letter) minimum equation")
            captureGreekScene(letter, endpoint: "minimum")
            reveal(slider)
            setSlider(slider, position: 1)
            XCTAssertEqual(slider.value as? String, controlValues.1, "\(letter) maximum control")
            let maximum = equation.value as? String
            // Chi-squared has symmetric extreme values; both differ from its zero default.
            if letter == "chi" { XCTAssertNotEqual(minimum, initial); XCTAssertEqual(minimum, maximum) }
            else { XCTAssertNotEqual(minimum, maximum, letter) }
            XCTAssertEqual(maximum, endpoints.1, "\(letter) maximum equation")
            captureGreekScene(letter, endpoint: "maximum")
            reveal(app.buttons["greek-reset"]); app.buttons["greek-reset"].tap()
            XCTAssertEqual(equation.value as? String, initial, letter)
            XCTAssertEqual(slider.value as? String, controlValues.2, "\(letter) reset control")
            leaveGreekLetter()
        }
    }
    private var greekControlValues: [String: (String, String, String)] {
        ["alpha": ("0 degrees", "360 degrees", "60 degrees"),
         "beta": ("0 percent", "100 percent", "0 percent"),
         "gamma": ("0.30 model metres", "3.00 model metres", "1.50 model metres"),
         "delta": ("minus 5.0 metres", "5.0 metres", "3.0 metres"),
         "epsilon": ("0.05", "1.00", "0.40"), "zeta": ("1.10", "4.00", "2.00"),
         "eta": ("0 percent", "100 percent", "65 percent"),
         "theta": ("0 degrees", "360 degrees", "60 degrees"),
         "iota": ("0.001", "1.000", "0.100"), "kappa": ("0.50 metres", "4.00 metres", "2.00 metres"),
         "lambda": ("0.30 model metres", "3.00 model metres", "1.50 model metres"),
         "mu": ("0.00", "1.00", "0.30"), "nu": ("0.50 hertz", "4.00 hertz", "1.00 hertz"),
         "xi": ("minus 1.00", "1.00", "0.30"), "omicron": ("1", "50", "8"),
         "pi": ("0.50 metres", "4.00 metres", "2.00 metres"), "rho": ("1 kilograms", "40 kilograms", "15 kilograms"),
         "sigma": ("1", "12", "6"), "tau": ("0.0 newtons", "10.0 newtons", "5.0 newtons"),
         "upsilon": ("0.10 model units", "1.00 model units", "0.50 model units"),
         "phi": ("0.500", "0.850", "0.618, Golden split"), "chi": ("0", "40", "20"),
         "psi": ("1", "5", "1"), "omega": ("0.0 rad per second", "8.0 rad per second", "2.0 rad per second")]
    }
    private var greekReadouts: [String: (String, String)] {
        ["alpha": ("α = 0° · 0.00 radians", "α = 360° · 6.28 radians"),
         "beta": ("n → p⁺ + e⁻ + ν̄ₑ · before transition", "n → p⁺ + e⁻ + ν̄ₑ · after transition"),
         "gamma": ("λ = 0.30 · ν = 6.67 · speed = 2 model units/s", "λ = 3.00 · ν = 0.67 · speed = 2 model units/s"),
         "delta": ("Δx = x₂ − x₁ = -5.0 − 0 = -5.0 m", "Δx = x₂ − x₁ = 5.0 − 0 = 5.0 m"),
         "epsilon": ("ε = 0.05 · δ = ε/2 = 0.025", "ε = 1.00 · δ = ε/2 = 0.500"),
         "zeta": ("Σₙ₌₁⁴⁰ 1/nˢ = 3.6780 · partial sum", "Σₙ₌₁⁴⁰ 1/nˢ = 1.0823 · partial sum"),
         "eta": ("η = Euseful / Ein = 0% · 0 J useful", "η = Euseful / Ein = 100% · 100 J useful"),
         "theta": ("θ = s/r = 0.00 rad", "θ = s/r = 6.28 rad"),
         "iota": ("ι = 0.001 · this toy's label for a small amount", "ι = 1.000 · this toy's label for a small amount"),
         "kappa": ("κ = 1/r = 2.000 m⁻¹", "κ = 1/r = 0.250 m⁻¹"),
         "lambda": ("λ = 0.30 · ν = 6.67 · speed = 2 model units/s", "λ = 3.00 · ν = 0.67 · speed = 2 model units/s"),
         "mu": ("Ffriction = μₖN = 0.00 × 10 = 0.0 N", "Ffriction = μₖN = 1.00 × 10 = 10.0 N"),
         "nu": ("ν = 0.50 Hz · λ = 4.00 model m", "ν = 4.00 Hz · λ = 0.50 model m"),
         "xi": ("ξ = -1.00 · position on a chosen axis", "ξ = 1.00 · position on a chosen axis"),
         "omicron": ("n = 1 · n² = 1 · n/n² = 1.000", "n = 50 · n² = 2500 · n/n² = 0.020"),
         "pi": ("C = πd = 1.571 m · C/d = 3.14159…", "C = πd = 12.566 m · C/d = 3.14159…"),
         "rho": ("ρ = m/V = 1 kg / 1 m³ = 1 kg/m³", "ρ = m/V = 40 kg / 1 m³ = 40 kg/m³"),
         "sigma": ("Σₖ₌₁ⁿ k = n(n + 1)/2 = 1", "Σₖ₌₁ⁿ k = n(n + 1)/2 = 78"),
         "tau": ("τ = rF = 1 m × 0.0 N = 0.0 N·m", "τ = rF = 1 m × 10.0 N = 10.0 N·m"),
         "upsilon": ("Υ = b b̄ · separation = 0.10 model units · schematic", "Υ = b b̄ · separation = 1.00 model units · schematic"),
         "phi": ("whole/long = 2.000 · long/short = 1.000", "whole/long = 1.176 · long/short = 5.667"),
         "chi": ("χ² = Σ(O − E)²/E = 40.00 · E = 20 per group", "χ² = Σ(O − E)²/E = 40.00 · E = 20 per group"),
         "psi": ("ψ = √2 sin(nπx), L = 1 · n = 1 · ∫|ψ|² dx = 1", "ψ = √2 sin(nπx), L = 1 · n = 5 · ∫|ψ|² dx = 1"),
         "omega": ("ω = Δθ/Δt = 0.0 rad/s · 0.00 rev/s", "ω = Δθ/Δt = 8.0 rad/s · 1.27 rev/s")]
    }
    private func exactParticle(_ particle: String, position: Double, expected: String) {
        let fine = app.buttons["atom-\(particle)-fine"]
        reveal(fine); fine.tap()
        let slider = app.sliders["knob-\(particle)-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5)); setSlider(slider, position: position)
        XCTAssertTrue(app.staticTexts["atom-\(particle)-exact-value"].label.hasPrefix(expected + " "))
        app.buttons["atom-fine-done"].tap()
    }
    private func tab(_ name: String) {
        let button = app.tabBars.buttons[name]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "\(name) tab exists")
        button.tap()
        let selected = XCTNSPredicateExpectation(predicate: NSPredicate(format: "selected == true"), object: button)
        XCTAssertEqual(XCTWaiter.wait(for: [selected], timeout: 10), .completed, "\(name) tab becomes selected")
        let destination: XCUIElement
        switch name {
        case "Atom": destination = app.staticTexts["atom-element"]
        case "Table": destination = app.staticTexts["table-result-count"]
        case "Bonds & Life": destination = app.descendants(matching: .any)["bonds-lab"].firstMatch
        case "Greek":
            // The Greek stack can retain an open letter when returning from another tab.
            destination = app.descendants(matching: .any).matching(NSPredicate(format: "identifier == %@ OR identifier == %@", "greek-grid", "greek-selected-symbol")).firstMatch
        default: XCTFail("Unknown tab \(name)"); return
        }
        XCTAssertTrue(destination.waitForExistence(timeout: 10), "\(name) destination appears")
    }
    private func chooseTableLens(_ name: String) {
        let picker = app.buttons["table-property"]
        reveal(picker); picker.tap()
        let option = app.buttons.matching(NSPredicate(format: "label == %@ AND identifier != %@", name, "table-property")).firstMatch
        XCTAssertTrue(option.waitForExistence(timeout: 5), "\(name) lens option appears")
        option.tap()
    }
    private func openGreek(_ letter: String) {
        let tile = app.buttons["greek-letter-\(letter)"]
        reveal(tile); tile.tap()
        XCTAssertTrue(app.descendants(matching: .any)["greek-detail-\(letter)"].firstMatch.waitForExistence(timeout: 5), "\(letter) detail appears")
        XCTAssertTrue(app.staticTexts["greek-selected-symbol"].waitForExistence(timeout: 5))
    }
    private func leaveGreekLetter() {
        let back = app.navigationBars.firstMatch.buttons.matching(NSPredicate(format: "identifier != %@", "guide"))
        XCTAssertEqual(back.count, 1, "Greek detail has one back button distinct from the Guide toolbar action")
        back.element(boundBy: 0).tap()
        XCTAssertTrue(app.descendants(matching: .any)["greek-grid"].firstMatch.waitForExistence(timeout: 5), "Back returns to the Greek alphabet")
    }
    private func captureGreekScene(_ letter: String, endpoint: String) {
        let scene = app.descendants(matching: .any)["greek-stage-\(letter)"].firstMatch
        XCTAssertTrue(scene.waitForExistence(timeout: 5))
        // The diagram deliberately ignores touch, so isHittable cannot establish visibility.
        // Check its full frame between the navigation and tab bars before attaching evidence.
        let window = app.frame
        let content = CGRect(x: window.minX, y: window.minY + 110, width: window.width, height: max(0, window.height - 220))
        func visible() -> Bool { !scene.frame.isEmpty && content.contains(scene.frame) }
        for _ in 0..<6 { if visible() { break }; verticalScroll(up: false) }
        for _ in 0..<6 { if visible() { break }; verticalScroll(up: true) }
        XCTAssertTrue(visible(), "\(letter) diagram fully visible in screenshot")
        capture("Greek-\(letter)-\(endpoint)")
    }
    private func greekStageValue(_ letter: String) -> String {
        app.descendants(matching: .any)["greek-stage-\(letter)"].firstMatch.value as? String ?? ""
    }
    private func greekPhase(_ letter: String) throws -> Double {
        let value = greekStageValue(letter)
        let marker = try XCTUnwrap(value.range(of: " · visual phase "), "\(letter) stage exposes its drawn phase")
        let suffix = String(value[marker.upperBound...])
        let number = try XCTUnwrap(suffix.components(separatedBy: " turns").first)
        let phase = try XCTUnwrap(Double(number), "\(letter) phase is numeric: \(value)")
        XCTAssertTrue(phase.isFinite)
        XCTAssertGreaterThanOrEqual(phase, 0)
        XCTAssertLessThanOrEqual(phase, 1) // Three-place rounding can display 1.000 immediately before wrapping.
        return phase
    }
    private func requireGreekMotionControls() throws {
        let status = app.staticTexts["greek-motion-status"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        if status.label.hasPrefix("Reduce Motion") {
            throw XCTSkip("Playback requires Reduce Motion to be disabled; the separate Reduce Motion scenario checks still frames.")
        }
        XCTAssertTrue(app.buttons["greek-motion-button"].waitForExistence(timeout: 5))
    }
    private func verifyGreekPlayback(_ letter: String) async throws -> Double {
        try requireGreekMotionControls()
        let motion = app.buttons["greek-motion-button"]
        reveal(motion)
        XCTAssertEqual(motion.value as? String, "Paused")
        let initialPhase = try greekPhase(letter)
        try await Task.sleep(for: .milliseconds(250))
        XCTAssertEqual(try greekPhase(letter), initialPhase, "\(letter) holds its frame before Resume")
        motion.tap()
        XCTAssertEqual(motion.value as? String, "Playing")
        let startedPhase = try greekPhase(letter)
        var advanced = false
        // Several samples avoid treating one complete revolution between two observations as stillness.
        for _ in 0..<6 {
            try await Task.sleep(for: .milliseconds(170))
            if abs(try greekPhase(letter) - startedPhase) > 0.002 {
                advanced = true
                break
            }
        }
        motion.tap()
        XCTAssertEqual(motion.value as? String, "Paused")
        let heldPhase = try greekPhase(letter)
        XCTAssertTrue(greekStageValue(letter).hasSuffix("Paused"))
        XCTAssertTrue(advanced, "\(letter) playback advances the phase used by its Canvas")
        try await Task.sleep(for: .milliseconds(400))
        XCTAssertEqual(try greekPhase(letter), heldPhase, "\(letter) holds the drawn phase after Pause")
        return heldPhase
    }
    private func chooseMolecule(_ name: String) {
        let picker = app.scrollViews["bond-molecule-picker"]
        reveal(picker)
        scrollPicker(picker, target: app.buttons["bond-molecule-\(name)"])
        app.buttons["bond-molecule-\(name)"].tap()
    }
    private func stage(_ name: String) {
        let picker = app.scrollViews["bond-stage-picker"]
        reveal(picker); scrollPicker(picker, target: app.buttons["bond-stage-\(name)"])
        app.buttons["bond-stage-\(name)"].tap()
    }
    private func scrollPicker(_ picker: XCUIElement, target: XCUIElement) {
        for _ in 0..<4 { if target.isHittable { return }; picker.swipeLeft() }
        for _ in 0..<4 { if target.isHittable { return }; picker.swipeRight() }
        XCTAssertTrue(target.isHittable)
    }
    private func reading(_ element: XCUIElement) -> String {
        [element.label, element.value as? String ?? ""].joined(separator: " · ")
    }
    private func setSlider(_ slider: XCUIElement, position: Double) {
        XCTAssertTrue(slider.isHittable)
        slider.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo: slider.coordinate(withNormalizedOffset: CGVector(dx: position, dy: 0.5)))
    }
    private func reveal(_ target: XCUIElement) {
        if target.exists && target.isHittable { return }
        for _ in 0..<8 {
            verticalScroll(up: true)
            if target.exists && target.isHittable { return }
        }
        for _ in 0..<8 {
            verticalScroll(up: false)
            if target.exists && target.isHittable { return }
        }
        XCTAssertTrue(target.exists && target.isHittable, "Cannot reveal \(target.identifier)")
    }
    private func verticalScroll(up: Bool) {
        let from = app.coordinate(withNormalizedOffset: CGVector(dx: 0.96, dy: up ? 0.82 : 0.3))
        let to = app.coordinate(withNormalizedOffset: CGVector(dx: 0.96, dy: up ? 0.3 : 0.82))
        from.press(forDuration: 0.01, thenDragTo: to)
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways
        add(attachment)
    }
}
