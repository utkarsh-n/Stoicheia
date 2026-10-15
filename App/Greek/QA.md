# Greek lab QA reference

All 24 diagrams have been audited against the control specification and numerical readout. This table is the expected runtime behavior, not a claim that simulator UI scenarios have been executed. Root owns simulator testing and full builds.

| Letter | Control minimum → maximum | Expected reading at minimum → maximum | Reset value |
| --- | --- | --- | --- |
| Alpha | 0° → 360° | 0.00 → 6.28 radians; closed ray → full-turn wedge | 60° |
| Beta | 0% → 100% | before → after n → p⁺ + e⁻ + ν̄ₑ event | 0% |
| Gamma | λ 0.30 → 3.00 model m | ν 6.67 → 0.67; short → long schematic wave | λ 1.50 |
| Delta | final −5.0 → +5.0 m | Δx −5.0 → +5.0 m; x₁ = 0 | +3.0 m |
| Epsilon | ε 0.05 → 1.00 | δ 0.025 → 0.500; tolerance band widens | ε 0.40 |
| Zeta | s 1.10 → 4.00 | 40-term partial sum 3.6780 → 1.0823 | s 2.00, sum 1.6202 |
| Eta | 0% → 100% | 0 J → 100 J useful out of 100 J | 65% |
| Theta | 0° → 360° | θ 0.00 → 6.28 rad | 60° |
| Iota | 0.001 → 1.000 | area fraction 0.001 → one whole | 0.100 |
| Kappa | r 0.50 → 4.00 m | κ 2.000 → 0.250 m⁻¹; circle radius grows by eight | r 2.00 m |
| Lambda | λ 0.30 → 3.00 model m | ν 6.67 → 0.67; visible wavelength grows by ten | λ 1.50 |
| Mu | μₖ 0.00 → 1.00 | friction 0.0 → 10.0 N; no arrow at zero | μₖ 0.30 |
| Nu | ν 0.50 → 4.00 Hz | λ 4.00 → 0.50 model m; frequency increases eightfold | ν 1.00 Hz |
| Xi | −1.00 → +1.00 | dot at left → right; signed coordinate matches | +0.30 |
| Omicron | n 1 → 50 | n² 1 → 2500; n/n² 1.000 → 0.020 | n 8 |
| Pi | d 0.50 → 4.00 m | C 1.571 → 12.566 m; ratio stays 3.14159… | d 2.00 m |
| Rho | mass 1 → 40 kg | ρ 1 → 40 kg/m³; one → forty dots | 15 kg |
| Sigma | n 1 → 12 | sum 1 → 78; one → twelve lit bars | n 6, sum 21 |
| Tau | force 0.0 → 10.0 N | torque 0.0 → 10.0 N·m; no force arrow at zero | force 5.0 N |
| Upsilon | separation 0.10 → 1.00 model units | numeric separation updates; labeled quarks remain distinguishable | 0.50 |
| Phi | long fraction 0.500 → 0.850 | whole/long 2.000 → 1.176; long/short 1.000 → 5.667 | 0.618…, both ratios 1.618 |
| Chi | A count 0 → 40 | χ² 40.00 at both extremes; minimum 0.00 at A=20 | A 20 |
| Psi | state n 1 → 5 | one → five probability lobes; ∫|ψ|²dx=1 at every state | n 1 |
| Omega | 0.0 → 8.0 rad/s | 0.00 → 1.27 rev/s; still → rotating; no zero-speed trail | 2.0 rad/s |

## Runtime controls and readouts

- Letter tiles: `greek-letter-alpha` through `greek-letter-omega`.
- Detail roots: `greek-detail-alpha` etc.
- Diagram summaries: `greek-stage-alpha` etc.
- Live equation: `greek-selected-symbol`; its accessibility label identifies the letter, and its accessibility **value** contains the current equation. Visible text is the same equation.
- Knob: `knob-greek-alpha` etc. Native exact slider: `knob-greek-alpha-slider` etc. The slider's accessible value is formatted scientific data, rather than only its normalized thumb position.
- Reset: `greek-reset`. Resets the parameter to the table default and leaves the chosen playback state intact.
- Motion: `greek-motion-button`, present for gamma, lambda, nu and omega. Accessible value is Playing or Paused. The status text is `greek-motion-status`.

## State and motion scenarios

1. Move a control; confirm both knob and equation change. Set both ends using the exact slider; check the table. Tap Reset; confirm the table default.
2. Change alpha, leave detail, open beta, then reopen alpha. Alpha retains its previous control value for this Greek lab session. Switching tabs also retains controls. Search text, per-letter playback choices and frozen phases survive navigation. State is intentionally in memory; it is not advertised as saved across app termination.
3. For one animated scene, pause. The numerical controls remain usable and the motion frame stays frozen; resume advances from that phase. Change playback speed while running: phase stays continuous at the origin of the wave or at the rotor marker.
4. Set omega to zero; phase remains at the current orientation and no timeline frames are requested. Raising the speed resumes from that orientation.
5. Enable Reduce Motion: the current phase freezes without resetting. Parameter changes still change static geometry/readouts; the motion button is hidden and the status explains the behavior. Disable Reduce Motion: resume only if that letter's stored playback state was Playing.
6. Leave the tab or background the app: the clock freezes. Return: no elapsed background time is applied to the phase.
7. At accessibility Dynamic Type sizes, the knob/hint and action buttons stack vertically. Long glyph-variant/title rows can fall back to a vertical layout. Content/equations wrap. Source links and reset/motion labels have at least 44-point interactive height.
8. Scrub beta just below and at 50%. At the transition, both e⁻ and ν̄ₑ appear as distinct dots and labeled paths, then spread toward their final positions at 100%.

## Harness interpretation

- A `-ui-testing` launch starts each animated letter paused for stable endpoint captures. The ordinary app starts them playing. Runtime motion checks must explicitly resume an animated scene and inspect frame advancement, not only the button's Playing value.
- Assert the exact slider value as well as the scientific equation at each endpoint. Readout substrings such as `0 J useful`, `0.0 N` and `= 1` can match larger values. Beta's before/after reading and chi's symmetric extrema cannot establish both endpoint positions by themselves.
- A screenshot taken after revealing a slider may show only part of its diagram. Reveal the stage for geometry captures, and inspect both extreme geometries even when the equation is symmetric.
- Playback state assertions cover the toggle's state, but do not establish phase continuity, no motion while paused, or excluding time spent in the background. The clock unit regressions cover deterministic arithmetic; direct frame observations cover the view wiring.
- Reset must restore the declared default, not just a cached opening reading. Also check double-tap knob reset, per-letter independence, search empty results/clear/back navigation, Reduce Motion, and accessibility text sizes.

## Corrections from the audit

- Replaced absolute-clock-times-rate animation with a phase anchor so rate changes, pause/resume, Reduce Motion and backgrounding preserve the frame.
- Stored per-letter control values, playback choice and phase in the Greek feature's state.
- Suppressed zero-length arrowheads, removed the residual tau arrow at zero and stopped omega's timeline/trail at zero.
- Kept upsilon quark labels apart at minimum schematic separation.
- Made kappa/pi displayed circle sizes proportional to their parameters.
- Added meaningful live readout accessibility values and stable scene/motion identifiers.
- Kept beta's two emitted particles distinct immediately at the transition.
