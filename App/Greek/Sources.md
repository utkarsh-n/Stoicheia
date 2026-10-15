# Greek symbol lab sources

Reviewed 11 October 2026. Copy in the app is original concise explanatory text. A letter's scientific meaning is contextual, not inherent; other-use lists are examples of common conventions. This is the modern 24-letter alphabet, not an exhaustive historical inventory. Final sigma ς and alternate phi ϕ are included.

## Alphabet and history

- [University of Cambridge, Beginning NT Greek, alphabet](https://www.greek.divinity.cam.ac.uk/content/unit1/u1_overview.html): modern names, order and uppercase/lowercase glyphs.
- [Scuola Normale Superiore, Mnamon: Greek alphabets](https://mnamon.sns.it/index.php?id=12&lang=en&page=Scrittura): Phoenician adaptation, vowel innovation, regional variation, supplemental phi/chi/psi signs, Ionic eta and omega, and uncertainty about where/when transmission occurred.
- [University of Chicago ISAC, I. J. Gelb, A Study of Writing](https://isac.uchicago.edu/publications/study-writing): Semitic predecessors and inherited letter names; aleph/ox, yodh/hand, pe/mouth, resh/head.
- [Oxford Faculty of Classics, The Early Greek Alphabets](https://classics.web.ox.ac.uk/node/2286521): borrowing and adaptation of the Phoenician consonantal alphabet.

Inherited names are summarized with cautious traditional glosses. The original pictorial interpretations of gimel, zayin and teth are uncertain. Sigma's shape/name development, upsilon's association with waw and the supplemental letters should not be read as a simple universal one-to-one copying process. The app labels these qualifications explicitly.

## Equations and teaching models

- [OpenStax College Physics, glossary of symbols](https://openstax.org/books/college-physics/pages/d-glossary-of-key-symbols-and-notation): selected conventions for alpha/beta/gamma, delta, theta, lambda, mu, rho, tau, upsilon, phi and omega.
- [OpenStax, rotation angle and angular velocity](https://openstax.org/books/college-physics/pages/6-1-rotation-angle-and-angular-velocity): radians, θ = s/r, ω = Δθ/Δt. Alpha and theta angle toys both use Euclidean geometry.
- [OpenStax, nuclear forces and radioactivity](https://openstax.org/books/physics/pages/22-2-nuclear-forces-and-radioactivity): beta and gamma decay. The beta toy correctly includes an electron antineutrino in neutron beta-minus decay. Event scrubbing is illustrative, not a statistical lifetime calculation. The gamma toy is a schematic electromagnetic wave, not a scale representation of a gamma photon.
- [OpenStax, the precise definition of a limit](https://openstax.org/books/calculus-volume-1/pages/2-5-the-precise-definition-of-a-limit): epsilon-delta relation. The toy's f(x)=2x, a=1, L=2 uses δ=ε/2.
- [Wolfram Research, Riemann zeta function](https://mathworld.wolfram.com/RiemannZetaFunction.html): convergent series for real s > 1. The toy restricts s to 1.1–4 and reports only its finite 40-term partial sum.
- [OpenStax, introduction to heat engines](https://openstax.org/books/university-physics-volume-2/pages/4-2-heat-engines): useful work and input-energy efficiency. The η toy is a generic energy accounting example with fixed input 100 J.
- [Wolfram Research, curvature](https://mathworld.wolfram.com/Curvature.html): κ convention and circle curvature 1/r. The diagram is a circular curve, not a general curvature solver.
- [OpenStax, electromagnetic energy](https://openstax.org/books/chemistry-atoms-first/pages/3-1-electromagnetic-energy): λ for wavelength and ν for frequency, speed = λν. Wave toys use a stated fixed model speed of 2 units/s.
- [OpenStax, friction](https://openstax.org/books/university-physics-volume-1/pages/6-2-friction): idealized kinetic friction F=μₖN, fixed N=10 N in the toy.
- [Cornell University, reasoning about resources](https://www.cs.cornell.edu/courses/cs212/1999sp/handouts/order.html): asymptotic O and o definitions. Omicron is a lettering association; O/o notation is visually shared with Latin letters. The diagram labels its independently scaled n and n² curves, while the numeric ratio 1/n supplies the exact comparison.
- [OpenStax, density](https://openstax.org/books/college-physics/pages/11-2-density): ρ=m/V. Dot count stands for mass at fixed volume, not a molecular packing simulation.
- [OpenStax, series and their notations](https://openstax.org/books/algebra-and-trigonometry-2e/pages/13-4-series-and-their-notations): Σ as summation. Toy sum 1+…+n uses n(n+1)/2.
- [CERN, Bottomonium particles don't go with the flow](https://alumni.cern/news/204997): Υ as bottom/antibottom bound state. The spring-like connection is schematic; no quark trajectory, force law or binding energy is calculated.
- [Wolfram Research, golden ratio](https://mathworld.wolfram.com/GoldenRatio.html): φ=(1+√5)/2 and whole/long=long/short. The adjustable split compares the two ratios and has a golden-ratio detent.
- [OpenStax, introductory statistics, chi-square](https://openstax.org/books/introductory-statistics-2e/pages/11-2-goodness-of-fit-test): χ²=Σ(O−E)²/E. Toy expected counts are 20 in each of two groups, total count 40; no p-value or statistical conclusion is inferred.
- [OpenStax, wave functions](https://openstax.org/books/university-physics-volume-3/pages/7-1-wave-functions): ψ and |ψ|². The toy is a normalized particle-in-a-box spatial wavefunction ψ=√2 sin(nπx), 0≤x≤1, n=1…5; probability density is 2 sin²(nπx). It is not an atom's orbital.

The xi axis is an explicitly chosen coordinate convention, and the iota toy is an explicitly chosen small-quantity illustration. Neither assigns an intrinsic universal scientific definition to its letter. The pi circle toy uses C/d=π. Tau uses torque rF for a perpendicular force, with a fixed one-metre lever.

## Interface

- [Apple Developer, applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views): interactive glass controls grouped in GlassEffectContainer; educational content remains on opaque panels. Shared LabKit GlassKnob and PrecisionSlider provide adjustable VoiceOver actions, keyboard control, reset, exact slider input and meaningful haptic detents.

Continuous diagram motion stops for Reduce Motion. All interactive controls have descriptive accessibility labels; the toy stage has a text equivalent containing the current numerical reading.
