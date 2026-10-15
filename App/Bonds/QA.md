# Bonds & Life runtime QA contract

Static audit and scientific checks: 2026-10-11. Root owns simulator execution, screenshots, and full builds. This file lists expected runtime observations; it does not claim they have all been observed.

## Presets

`bond-molecule-picker` is a horizontally scrolling picker. Button identifiers are `bond-molecule-` plus the case below.

| Case suffix | Formula | Valence e⁻ | Shared pairs | Lone pairs | Shape | Angle / coordination | Molecular polarity | Suggested Life |
|---|---|---:|---:|---:|---|---|---|---|
| water | H₂O | 8 | 2 | 2 | Bent | 104.5° | Polar | Water |
| methane | CH₄ | 8 | 4 | 0 | Tetrahedral | 109.5° | Nonpolar | Carbon |
| ammonia | NH₃ | 8 | 3 | 1 | Trigonal pyramidal | ≈107° | Polar | Nitrogen |
| carbonDioxide | CO₂ | 16 | 4 | 4 | Linear | 180° | Nonpolar | Carbon |
| hydrogen | H₂ | 2 | 1 | 0 | Diatomic | No three-atom angle | Nonpolar | Water |
| oxygen | O₂ | 12 | 2 | 4 | Diatomic | No three-atom angle | Nonpolar | O₂ + iron |
| salt | NaCl | 8 | 0; 1 e⁻ transferred | 4 | Cubic ionic lattice | 6 nearest neighbors | Ionic crystal | Na⁺ / K⁺ |

`bond-stage-picker` scrolls horizontally. Stage button identifiers: `bond-stage-electrons`, `bond-stage-shape`, `bond-stage-binding`, `bond-stage-reactions`, `bond-stage-life`.

## Slider and toggle expectations

| Control identifier | Set / action | Expected observation |
|---|---|---|
| bond-sharing-slider | 0%, 50%, 100% | `bond-sharing-progress-value`: Bond map: 0% / 50% / 100% assembled. Electron inventory remains fixed for that preset. |
| bond-rotation-slider | 0%, 50%, 100% normalized slider | yaw −180°, 0°, +180° respectively in `bond-rotation-value`; projected model changes. |
| bond-rotation-reset | tap | Viewpoint: 0° yaw · 0° tilt. |
| bond-rotation-tilt | tap | Viewpoint: 34° yaw · −37° tilt. |
| bond-domains-toggle | on/off | Shared regions plus every atom's lone-pair regions appear/disappear. Hidden for NaCl. |
| bond-polarity-toggle | on/off | Bond arrows appear/disappear when atom electronegativities differ. H₂/O₂ have no arrows; NaCl omits this control. |
| bond-distance-slider | 0%, 100% normalized slider | r/r₀ 0.55 and 3.00; Relative E 1.86 and −0.02; `bond-binding-state` is Repulsion dominates / Attraction pulls inward. |
| bond-equilibrium-button | tap | r/r₀ 1.00; Relative E −1.00; Near the energy minimum. |
| bond-reaction-progress | 0%, 50%, 100% | `bond-reaction-progress-value`: 0% / 50% / 100%; canvas groups change, `bond-conservation-ledger` stays identical. |
| bond-catalyst-toggle | on | `bond-catalyst-readout`: Lower barrier · same endpoints; `bond-barrier-canvas` shows a lower violet path. |
| bond-catalyst-toggle | off | Uncatalyzed route. |
| bond-temperature-slider | 0%, 100% | `bond-temperature-value`: Thermal dial: 0% / 100%; amber band changes height, conservation and endpoints stay unchanged. |
| bond-life-slider | 0%, 100% | `bond-life-progress-value`: Scene control: 0% / 100%; scene-specific readouts below. |

Rotation values are rounded degrees. Long drags now wrap yaw into −π…π, keeping the native slider valid without changing the physical orientation. Numeric slider targets may land within a small tolerance in XCUI automation.

## Reactions

Use menu `bond-reaction-picker`, choosing Make water, Photosynthesis, or ATP hydrolysis. Changing this menu returns reaction progress to 0. `bond-reaction-equation` shows the exact selected equation.

- Make water: 2H₂ + O₂ → 2H₂O. Ledger H 4 = 4, O 2 = 2; net charge 0 = 0.
- Photosynthesis: 6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂. Ledger C 6 = 6, H 12 = 12, O 18 = 18; net charge 0 = 0.
- ATP hydrolysis: ATP⁴⁻ + H₂O → ADP³⁻ + HPO₄²⁻ + H⁺. Ledger C 10 = 10, H 14 = 14, N 5 = 5, O 14 = 14, P 3 = 3; net charge −4 = −4.

The ledger's first label is Atoms and charge conserved. Neither scrubbing, temperature, nor catalyst changes the inventories. Molecular atom maps are qualitative and do not map photosynthetic oxygen isotope origin.

## Life scene endpoints

Use `bond-life-picker`; `bond-life-title`, `bond-life-readout`, `bond-life-progress-value`, and `bond-life-canvas` expose the result. Carbon uses six discrete steps, 0%, 20%, 40%, 60%, 80%, 100%, defaulting to 40% on first selection. Other scenes default to 50%.

| Menu choice | At 0% | At 100% |
|---|---|---|
| Water | Turn the positive H toward negative O | Aligned: an O···H contact |
| Carbon | 1 C · 4 H · alkane | 6 C · 14 H · alkane |
| Nitrogen | Glycine · one N in the amino group; dimmer amino group | Same molecule and readout; stronger group highlight |
| O₂ + iron | O₂ approaching the Fe site | O₂ at one Fe binding site; Fe connects to one O, with the second O angled away |
| Na⁺ / K⁺ | 3 Na⁺ outward / 2 K⁺ inward; ions begin on opposite sides | 3 Na⁺ out · 2 K⁺ in · 1 ATP |
| Calcium | 1 Ca²⁺ shown in the signaling region | 6 Ca²⁺ shown in the signaling region |
| Phosphate | ATP + water | ADP + inorganic phosphate |

## State regression scenarios

1. Choose water, assemble its Lewis map to 50%; move to Shape and back. Map stays at 50%.
2. Turn on domains and polarity, adjust rotation, leave Shape and return. Toggles and viewpoint remain set.
3. Adjust binding distance; leave Binding and return. Distance remains set.
4. Choose ATP hydrolysis, scrub 50%, enable catalyst, set temperature 100%; move to another stage, then another app tab, and return. All four values remain set; no appearance handler replaces the menu choice.
5. Choose Calcium in Life and set 100%; move to another stage or app tab and return. Calcium and 100% remain set.
6. Select a different actual molecule preset. Reaction and Life follow the new context; reaction progress becomes 0 and Life control becomes its initial value. Rotation, electron-map assembly, generic binding distance, thermal dial, and catalyst remain user-controlled.
7. Change the atom's proton count elsewhere. 6 → methane, 8 → water, 7 → ammonia, 11/17 → salt, 1 → hydrogen; other numbers use the water example. Merely revisiting the tab with the same proton count preserves a manually selected preset.

QA-only audit edits: moved experiment values into feature-owned state, removed onAppear overwrites, normalized drag yaw, initialized the discrete carbon control on its valid 40% step, added numerical readouts and canvas/picker identifiers. No simulator, Xcode configuration, or build controls were changed by this feature audit.
