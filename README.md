# Stoicheia

A native iPhone laboratory for atoms, periodic patterns, molecules, biological chemistry and Greek notation. Built for iOS 27 with SwiftUI and the workspace's LabKit toy design system.

- **Atom:** spinning, draggable orbital clouds, shell occupancy and a nucleus view. Proton, neutron and electron knobs independently change identity, isotope and charge. Subshell boxes show filling and pairing. Reference-isotope and neutralisation actions, transformation experiments and saved atom state.
- **Table:** all 118 elements in a conventional 18-column table with detached f-block rows, a phone-friendly tile mode, search and family filters. Map outer electrons, electronegativity, van der Waals radius, atomic mass or state; pin and compare two elements; send any element to the atom toy.
- **Bonds & Life:** follow electron structures through covalent/ionic bonding, VSEPR geometry, polarity, qualitative binding, balanced reactions and biological roles.
- **Greek:** all 24 uppercase/lowercase letters, their origins, context-dependent uses and individually controlled visual experiments.

Chrome uses native Liquid Glass. Instrument panels stay opaque. LabKit supplies accessible rotary controls, precise sliders and bounded haptic feedback. The atom model supports Reduce Motion and spoken readouts. Content and reference data work offline.

## Build

The Documents checkout is iCloud-synced. Stage the app and LabKit side by side before building:

```sh
./Tools/stage.sh
xcodebuild -project /private/tmp/stoicheia-build/Stoicheia/Stoicheia.xcodeproj -scheme Stoicheia -destination 'generic/platform=iOS Simulator' build
```

Generate the editable source project with `xcodegen generate` from this folder. The app is iPhone-only, portrait, with automatic signing under the existing development team. Bundle ID: `com.utkarsh.stoicheia`.

## Scientific boundaries

Clouds show qualitative angular shapes, not numerical wavefunctions or electron trajectories; nucleus beads are illustrative. Ion filling uses a teaching model, and extreme knob combinations do not establish existence or stability. Heavy-element ground-state configurations and properties may be predicted. Outer-shell count is not a universal bonding-valence rule, especially for d/f elements. Binding and reaction controls show causal concepts, not computed chemistry or rates. Sources and snapshot provenance are in `Core/Sources.md`, `App/Bonds/Sources.md` and `App/Greek/Sources.md`.

See `Documentation/VERIFICATION.md` for the checks actually performed and remaining device checks.


## Public snapshot

See [PUBLICATION.md](PUBLICATION.md) for publication exclusions and setup requirements.
