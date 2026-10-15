import SwiftUI
import LabKitUI
import LabKitFeedback

struct GuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.labHaptics) private var haptics
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ToyPanel(title: "01 / What you're looking at") {
                        Text("Stoicheia is a pocket laboratory for the building blocks of matter and the symbols used to describe them. Change one thing, observe the result, then connect it to the next scale.")
                    }
                    ToyPanel(title: "02 / Touch") {
                        Text("Drag a knob up or right to increase it. Double-tap to reset. ± changes exactly one particle. Drag the atom to rotate; tap a subshell to choose a cloud. Swipe the full periodic table sideways, or switch to tiles.")
                    }
                    ToyPanel(title: "03 / Follow the scales") {
                        Text("Atom → periodic patterns → shared or transferred electrons → molecular shape and polarity → attraction and reaction barriers → biological function. Each playground exposes a different part of the same story.")
                    }
                    ToyPanel(title: "04 / What's real and illustrative") {
                        Text("Element identity and electron counts follow the core model. Reference properties come from PubChem. Ground-state configurations include known filling exceptions. Unlisted isotopes are unevaluated, and extreme ions may not exist as bound atoms.")
                        Text("Changing proton count changes the nucleus. Ordinary chemical reactions rearrange electrons and bonds; they do not turn one element into another.")
                        Text("Cloud shapes, coloured lobes, nucleus beads, bond rods, binding curves, and reaction progress are qualitative teaching pictures. Cloud dots represent probability samples, not orbiting particles. This app is not a quantum, nuclear, molecular-dynamics, or reaction-rate solver.")
                        Text("Transition-metal valence is not one fixed number. Outer-shell counts are labelled separately from variable bonding valence. Greek symbols have context-dependent meanings.")
                    }
                    ToyPanel(title: "05 / Experiments") {
                        Text("Keep carbon's proton count fixed and add a neutron. Neutralise sodium after removing an electron. Compare oxygen and neon. Follow water from its Lewis structure to a bent shape, a dipole, and hydrogen bonding.")
                    }
                    ToyPanel(title: "06 / Access") {
                        Text("Knobs support VoiceOver adjustable actions. Models include spoken readouts. Reduce Motion stops automatic atom rotation; every control still works. The app uses no device sensors or network requests for its learning content.")
                    }
                    ToyPanel(title: "07 / Sound & feel") {
                        if let haptics { Toggle("Tactile feedback", isOn: Binding(get: { haptics.enabled }, set: { haptics.enabled = $0 })) }
                        Text("Feedback marks control changes and selections. There is no continuous vibration or audio bed.").font(.caption).foregroundStyle(.secondary)
                    }
                    ToyPanel(title: "08 / Sources") {
                        Link("PubChem periodic table & element records", destination: URL(string: "https://pubchem.ncbi.nlm.nih.gov/ptable/")!)
                        Link("NIST atomic ground states", destination: URL(string: "https://physics.nist.gov/PhysRefData/ASD/ionEnergy.html")!)
                        Link("OpenStax Chemistry 2e", destination: URL(string: "https://openstax.org/details/books/chemistry-2e")!)
                        Link("OpenStax Biology 2e", destination: URL(string: "https://openstax.org/details/books/biology-2e")!)
                        Link("University of Cambridge: the Greek alphabet", destination: URL(string: "https://www.greek.divinity.cam.ac.uk/content/unit1/u1_overview.html")!)
                        Link("Apple: Materials and Liquid Glass", destination: URL(string: "https://developer.apple.com/design/human-interface-guidelines/materials")!)
                        Text("Full data provenance and feature source notes are included with the project.").font(.caption).foregroundStyle(.secondary)
                    }
                }.font(.subheadline).padding(16)
            }.background(ToyStyle.background).navigationTitle("How Stoicheia works").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}
