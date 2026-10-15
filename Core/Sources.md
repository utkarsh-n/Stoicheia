# Chemistry data and model boundaries

Retrieved on 2026-10-11. The app bundles all data and works offline.

- **PubChem**, [periodic-table JSON](https://pubchem.ncbi.nlm.nih.gov/rest/pug/periodictable/JSON): all 118 names, symbols, atomic numbers, atomic masses, category labels, electronegativities, atomic radii, first ionization energies, melting/boiling points, densities, states and neutral electron configurations. Raw response is saved in `SourceData/pubchem-periodic-table.json`. Empty numerical cells become null, never zero. Superheavy predicted/calculated configurations retain their flag.
- **NIST**, [Atomic Weights and Isotopic Compositions](https://www.nist.gov/pml/atomic-weights-and-isotopic-compositions-relative-atomic-masses), [downloaded table](https://physics.nist.gov/cgi-bin/Compositions/stand_alone.pl?ele=&all=all&ascii=ascii2&isotype=all): documented isotope mass numbers and most abundant representative isotopes. Raw response is in `SourceData/nist-isotopes-source.txt`. The compilation is based on older 2009/2013 isotope/weight publications and AME2012; absence from this snapshot does not prove an isotope cannot exist. Some listed mass records are estimated, so “listed in the reference” does not assert direct experimental observation.
- **IUPAC**, [Periodic Table of the Elements](https://iupac.org/what-we-do/periodic-table-of-elements/) and the [4 May 2022 chart](https://iupac.org/wp-content/uploads/2022/07/IUPAC_Periodic_Table-04May22_CRA.pdf): groups numbered 1–18 and bracketed representative mass numbers for elements without characteristic natural abundances. Saved chart is in `SourceData/iupac-periodic-table-2022.pdf`. The representative isotope is explicitly selected, not obtained by rounding a weighted atomic mass. Detached La–Lu and Ac–Lr rows have group=0 and f-block colors as a **layout convention**, not an assertion resolving the group-3 debate.
- **NIST**, [Lawrencium Elemental Data Index](https://physics.nist.gov/cgi-bin/Elements/elInfo.pl?context=noframes&element=103): corrects PubChem's older 6d¹ configuration to [Rn]5f¹⁴7s²7p¹.
- **NIST**, [electronic configurations](https://www.nist.gov/pml/atomic-reference-data-electronic-structure-calculations/atomic-reference-data-electronic-8) and [Fe II levels](https://physics.nist.gov/PhysRefData/Handbook/Tables/irontable6_a.htm): support removal of the outer 4s electron before 3d for Fe. Neutral configurations preserve source exceptions such as Cr, Cu and Pd.
- **CIAAW**, [Hydrogen](https://www.ciaaw.org/hydrogen.htm) and [Carbon](https://www.ciaaw.org/carbon.htm): only the introductory H-1/H-2/C-12/C-13 examples carry a stable label. H-3 and C-14 carry a radioactive label and approximate half-life. Other nuclear combinations are labeled “not evaluated” or “not listed.” Natural abundance is not treated as proof of stability.

## Property units

Atomic mass is a relative atomic mass or source representative isotope mass value, **not** an atom's nucleon count. Radius is the PubChem periodic-table field in pm; source radius definitions and phases must be respected. Ionization energy is eV. Melting and boiling temperatures are K. Density is g/cm³ and depends on source conditions. Electronegativity uses the source's Pauling field; missing values remain unknown. Predicted state descriptions for superheavy elements remain explicit.

## Electron model

Neutral atom subshell counts expand each source noble-gas shorthand. Shell diagrams conserve every electron and show probability structure schematically, not planetary trajectories. Orbital shapes need a UI caveat that they are qualitative probability clouds, not a solved many-electron wavefunction.

Positive ions remove electrons in descending principal shell n, then angular momentum l; this gives Fe²⁺=3d⁶ and Fe³⁺=3d⁵ after the Ar core. Added electrons use a simplified Madelung filling sequence starting from the neutral source configuration. Reorganization, excited states, relativistic detail and many ion-specific exceptions are outside this model. Arbitrary ion charges can be mathematically displayed without representing physically bound species.

`valenceElectrons` is a beginner outer-shell count. `outerShellElectrons` uses the same count, and `valenceNote` explicitly explains that d/f electrons may participate in bonding. Transition-metal valence cannot be reduced to one count. This convention is deliberately exposed to the UI so it can label the readout **outer shell**, particularly for d/f elements and ions.

## Reproduce

`python3 Core/normalize.py` regenerates normalized JSON from the saved snapshots without network calls. `swift test` validates complete catalog placement, source configurations, isotope identity and all 14,042 combinations of 1–118 protons with 0–118 electrons. No chemical reaction changes proton count; moving that knob depicts a different nucleus rather than an ordinary chemical reaction.
