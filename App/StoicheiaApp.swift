import SwiftUI
import LabKitUI

@main struct StoicheiaApp: App {
    @State private var session = LabSession()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            RootView(session: session)
                .labPalette(ToyStyle.palette).labHaptics(session.haptics)
                .onChange(of: scenePhase, initial: true) { _, phase in
                    if phase == .active { session.haptics.start() }
                    else { session.haptics.stop() }
                }
        }
    }
}

struct RootView: View {
    @Bindable var session: LabSession
    @State private var showGuide = false
    var body: some View {
        TabView(selection: $session.tab) {
            Tab("Atom", systemImage: "atom", value: .atom) {
                NavigationStack { AtomLabView(session: session).navigationTitle("Stoicheia").navigationBarTitleDisplayMode(.inline).toolbar { guideButton } }
            }
            Tab("Table", systemImage: "square.grid.3x3", value: .table) {
                NavigationStack { PeriodicLabView(session: session).navigationTitle("Periodic table").navigationBarTitleDisplayMode(.inline).toolbar { guideButton } }
            }
            Tab("Bonds & Life", systemImage: "point.3.connected.trianglepath.dotted", value: .bonds) {
                NavigationStack { BondsLabView(initialAtomicNumber: session.atom.protons).navigationTitle("Bonds & Life").navigationBarTitleDisplayMode(.inline).toolbar { guideButton } }
            }
            Tab("Greek", systemImage: "character.book.closed", value: .greek) {
                NavigationStack { GreekLabView().navigationTitle("Greek playground").navigationBarTitleDisplayMode(.inline).toolbar { guideButton } }
            }
        }
        .tint(ToyStyle.cyan).background(ToyStyle.background)
        .sheet(isPresented: $showGuide) { GuideView() }
    }
    private var guideButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("How it works", systemImage: "info.circle") { showGuide = true }
                .labelStyle(.iconOnly).accessibilityIdentifier("guide")
        }
    }
}
