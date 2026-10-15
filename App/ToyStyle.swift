import SwiftUI
import LabKitCore
import LabKitUI

enum ToyStyle {
    static let background = Color(red: 0.025, green: 0.037, blue: 0.055)
    static let panel = Color(red: 0.055, green: 0.075, blue: 0.10)
    static let cyan = Color(red: 0.40, green: 0.91, blue: 0.95)
    static let amber = Color(red: 1.0, green: 0.73, blue: 0.35)
    static let violet = Color(red: 0.73, green: 0.64, blue: 1.0)
    static let palette = LabPalette(app: "Stoicheia", ground: .abyss,
        signature: LabColor(0.40, 0.91, 0.95),
        dataHues: [DataHue("proton", "Protons", LabColor(1, 0.73, 0.35)),
                   DataHue("neutron", "Neutrons", LabColor(0.73, 0.64, 1)),
                   DataHue("electron", "Electrons", LabColor(0.40, 0.91, 0.95))])
}

struct ToyEyebrow: View {
    let text: String
    var body: some View {
        Text(text.uppercased()).font(.system(.caption2, design: .monospaced))
            .tracking(1.7).foregroundStyle(ToyStyle.cyan)
    }
}

struct ToyPanel<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder let content: () -> Content
    init(title: String, subtitle: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title; self.subtitle = subtitle; self.content = content
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ToyEyebrow(text: title)
            if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }
            content()
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(ToyStyle.panel, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(.white.opacity(0.10)))
    }
}

struct MetricTile: View {
    let label: String
    let value: String
    var color: Color = ToyStyle.cyan
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(color).monospacedDigit().minimumScaleFactor(0.6)
        }.frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
    }
}
