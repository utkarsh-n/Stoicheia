# Bonds & Life: model notes and sources

Reviewed 2026-10-11. Explanatory copy is original, with the following teaching references. Graphics are schematics; no measured orbitals, kinetic constants, binding affinities, or cellular concentrations are inferred.

## Electron accounting, shape, and polarity

- [OpenStax Chemistry 2e, 7.2 Covalent Bonding](https://openstax.org/books/chemistry-2e/pages/7-2-covalent-bonding): covalent sharing, electronegativity, and qualitative pair potential energy. Pauling values used in the presets: H 2.20, C 2.55, N 3.04, O 3.44, Na 0.93, Cl 3.16.
- [OpenStax Chemistry 2e, 7.3 Lewis Symbols and Structures](https://openstax.org/books/chemistry-2e/pages/7-3-lewis-symbols-and-structures): valence electron accounting, lone pairs, single/double bonds, and ionic transfer. All presets preserve their total valence electron count during the dot morph.
- [OpenStax Chemistry 2e, 7.6 Molecular Structure and Polarity](https://openstax.org/books/chemistry-2e/pages/7-6-molecular-structure-and-polarity): VSEPR, water's 104.5° angle, methane's 109.5° tetrahedron, ammonia's approximately 107° pyramid, and the cancellation of bond polarity in CO₂ and CH₄. Multiple bonds count as one VSEPR electron region.
- [OpenStax Chemistry: Atoms First 2e, 5.4 Molecular Orbital Theory](https://openstax.org/books/chemistry-atoms-first-2e/pages/5-4-molecular-orbital-theory): the two unpaired electrons and paramagnetism of O₂, which its simple Lewis diagram cannot represent.
- [OpenStax Chemistry: Atoms First 2e, 4.1 Ionic Bonding](https://openstax.org/books/chemistry-atoms-first-2e/pages/4-1-ionic-bonding) and [Chemistry 2e, 10.6 Lattice Structures](https://openstax.org/books/chemistry-2e/pages/10-6-lattice-structures-in-crystalline-solids): NaCl as a repeating crystal, its 1:1 stoichiometry, and six oppositely charged nearest neighbors for an interior ion. The rendered 3×3×3 fragment is cropped; boundary ions have neighbors outside the fragment.

## Binding and reaction controls

The potential well is an authored, dimensionless Morse-style curve, E(r) = (1 − exp(−2.2(r − 1)))² − 1, with r₀ = 1. It is not fitted to any preset. The derivative is used only to distinguish inward attraction, outward repulsion, and the neighborhood of the minimum. A native selection haptic occurs on region changes.

- [OpenStax Chemistry 2e, 12.5 Collision Theory](https://openstax.org/books/chemistry-2e/pages/12-5-collision-theory): energy and orientation requirements, activation barriers, thermal energy, and catalysts. The schematic barrier has arbitrary energy units. Thermal controls do not predict rate. Catalyzed and uncatalyzed paths keep identical endpoints.
- [OpenStax Biology 2e, 8.1 Overview of Photosynthesis](https://openstax.org/books/biology-2e/pages/8-1-overview-of-photosynthesis): the balanced net equation 6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂, powered by light, as a summary of many steps.
- [OpenStax Biology 2e, 8.2 Light-Dependent Reactions](https://openstax.org/books/biology-2e/pages/8-2-the-light-dependent-reactions-of-photosynthesis): oxygenic photosynthesis releases O₂ originating from water. The toy map tracks counts rather than isotope origin.
- [IUBMB/IUPAC Recommendations for biochemical thermodynamics, Tables 1–3](https://iubmb.qmul.ac.uk/thermod/noGreek/th1t3.html): one explicitly balanced chemical equation, ATP⁴⁻ + H₂O → ADP³⁻ + HPO₄²⁻ + H⁺. ATP⁴⁻ = C₁₀H₁₂N₅O₁₃P₃; ADP³⁻ = C₁₀H₁₂N₅O₁₀P₂. Protonation and magnesium binding depend on conditions.
- [Rhea reaction 16580](https://www.rhea-db.org/rhea/16580): ATP and ADP ion formulas and charges used in the conservation ledger.

Reaction inventories are computed from each species' atom dictionary, coefficient, and charge. Water formation conserves H₄O₂. Photosynthesis conserves C₆H₁₂O₁₈. The selected ATP chemical equation conserves C₁₀H₁₄N₅O₁₄P₃ and net charge −4. The dot trajectories are illustrative group rearrangements, not mechanisms or simulations of time.

## Biological links

- [OpenStax Biology 2e, 2.2 Water](https://openstax.org/books/biology-2e/pages/2-2-water): polarity, intermolecular hydrogen bonds, and solvent behavior. The graphic distinguishes O–H covalent bonds from an O···H intermolecular contact.
- [OpenStax Biology 2e, 2.3 Carbon](https://openstax.org/books/biology-2e/pages/2-3-carbon): carbon's four-bond capacity and biological backbones. The controlled carbon chain is an alkane, CₙH₂ₙ₊₂, with implicit hydrogens; it does not represent every carbon-containing molecule.
- [OpenStax Biology 2e, 3.4 Proteins](https://openstax.org/books/biology-2e/pages/3-4-proteins) and [15.1 The Genetic Code](https://openstax.org/books/biology-2e/pages/15-1-the-genetic-code): amino groups, carboxyl groups, and amino acids as protein building blocks. The nitrogen diagram shows glycine's NH₃⁺–CH₂–COO⁻ form, with pH-dependent protonation explicitly noted.
- [OpenStax Biology 2e, 31.3 Nutritional Adaptations of Plants](https://openstax.org/books/biology-2e/pages/31-3-nutritional-adaptations-of-plants): microbial conversion of atmospheric nitrogen into ammonia and its incorporation into amino acids.
- [NCBI Bookshelf, Oxygen Transport](https://www.ncbi.nlm.nih.gov/books/NBK54103/): reversible O₂ binding at each heme iron and four hemes per hemoglobin molecule, with cooperative binding.
- [Shaanan, Structure of human oxyhaemoglobin at 2.1 Å resolution](https://pubmed.ncbi.nlm.nih.gov/6644819/) and [Collman et al., Structure of an Iron(II) Dioxygen Complex](https://pmc.ncbi.nlm.nih.gov/articles/PMC388220/): bent, end-on Fe–O₂ geometry in oxygen-carrying heme proteins and a model complex. The toy connects Fe to one oxygen with the distal oxygen angled away; protein and axial ligand are omitted.
- [OpenStax Biology 2e, 5.3 Active Transport](https://openstax.org/books/biology-2e/pages/5-3-active-transport): one ATP-powered Na⁺/K⁺ ATPase cycle moves three Na⁺ out and two K⁺ in, maintaining electrochemical gradients.
- [NCBI Bookshelf, Second Messengers](https://www.ncbi.nlm.nih.gov/books/NBK10794/): Ca²⁺ as an intracellular messenger and organelle calcium storage.
- [OpenStax Biology 2e, 6.4 ATP](https://openstax.org/books/biology-2e/pages/6-4-atp-adenosine-triphosphate): hydrolysis, favorable product free energy, and coupling to cellular work. Bond breaking alone requires energy; the whole reaction's free-energy change matters.

## UI and accessibility

[Apple glass button style](https://developer.apple.com/documentation/SwiftUI/PrimitiveButtonStyle/glass%28_%3A%29) and [glassEffect](https://developer.apple.com/documentation/swiftui/view/glasseffect%28_%3Ain%3A%29) guide native controls. Content panels remain opaque. Rotation is available through drag, a labeled native slider, and reset/tilt buttons. Reduce Motion removes animated viewpoint transitions. Canvas summaries and numerical readouts accompany all graphics. Selection feedback is tied to preset/stage changes or discrete modeled transitions.
