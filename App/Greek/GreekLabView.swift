import LabKitCore
import LabKitUI
import SwiftUI

struct GreekLabView: View {
    @State private var query = ""
    @State private var values: [GreekLetter: Double] = [:]
    @State private var playback: [GreekLetter: Bool] = [:]
    @State private var clocks: [GreekLetter: GreekMotionClock] = [:]
    @ScaledMetric(relativeTo: .caption) private var minimumTileWidth: CGFloat = 76
    private var columns: [GridItem] { [GridItem(.adaptive(minimum: minimumTileWidth), spacing: 10)] }
    private var matches: [GreekEntry] { GreekCatalog.entries.filter { $0.matches(query) } }
    private var initialPlayback: Bool { !ProcessInfo.processInfo.arguments.contains("-ui-testing") }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                introduction
                HStack {
                    Text("THE ALPHABET").font(.caption.weight(.semibold)).tracking(2)
                    Spacer()
                    Text("\(matches.count) / 24").font(.caption.monospacedDigit())
                }
                .foregroundStyle(.white.opacity(0.65))
                if matches.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(matches) { entry in
                            NavigationLink(value: entry.letter) {
                                GreekLetterTile(entry: entry)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(entry.name), \(entry.title)")
                            .accessibilityHint("Open interactive symbol lab")
                            .accessibilityIdentifier("greek-letter-\(entry.letter.rawValue)")
                        }
                    }
                    .accessibilityIdentifier("greek-grid")
                }
                Text("Letters are shared tools. Their meaning depends on the equation, the field and the author; uppercase and lowercase often do different jobs.")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                GreekSourceLinks()
            }
            .padding(18)
        }
        .background(ToyStyle.background)
        .navigationTitle("Greek symbols")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $query, prompt: "Angle, wave, density or letter…")
        .navigationDestination(for: GreekLetter.self) { letter in
            GreekDetailView(letter: letter, value: valueBinding(letter), isPlaying: playbackBinding(letter), motion: motionBinding(letter))
        }
    }

    private func valueBinding(_ letter: GreekLetter) -> Binding<Double> {
        Binding(
            get: { values[letter] ?? GreekToyModel.control(for: letter).defaultValue },
            set: { values[letter] = GreekToyModel.control(for: letter).clamp($0) }
        )
    }

    private func playbackBinding(_ letter: GreekLetter) -> Binding<Bool> {
        Binding(get: { playback[letter] ?? initialPlayback }, set: { playback[letter] = $0 })
    }

    private func motionBinding(_ letter: GreekLetter) -> Binding<GreekMotionClock> {
        Binding(get: { clocks[letter] ?? GreekMotionClock() }, set: { clocks[letter] = $0 })
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("24 LETTERS · MANY WORLDS")
                .font(.caption.weight(.semibold)).tracking(1.8)
                .foregroundStyle(ToyStyle.cyan)
            Text("Αα   Λλ   Ψψ")
                .font(.system(size: 49, weight: .light, design: .serif))
                .foregroundStyle(.white)
            Text("Turn a symbol into something you can feel.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            Text("Pick a letter. Turn its knob. Discover the idea behind one of its many meanings, and follow the letter back to its origins.")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ToyStyle.panel, in: .rect(cornerRadius: 24))
        .overlay(alignment: .topTrailing) {
            Image(systemName: "sparkle")
                .font(.system(size: 25, weight: .light))
                .foregroundStyle(ToyStyle.amber)
                .padding(20)
                .accessibilityHidden(true)
        }
    }
}

private struct GreekLetterTile: View {
    let entry: GreekEntry

    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(entry.upper).foregroundStyle(.white.opacity(0.6))
                Text(entry.letter == .sigma ? "σ" : entry.letter == .phi ? "φ" : entry.lower)
                    .foregroundStyle(ToyStyle.cyan)
            }
            .font(.system(size: 28, weight: .medium, design: .serif))
            .accessibilityHidden(true)
            Text(entry.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, minHeight: 86)
        .background(ToyStyle.panel, in: .rect(cornerRadius: 17))
        .overlay {
            RoundedRectangle(cornerRadius: 17)
                .strokeBorder(ToyStyle.cyan.opacity(0.16), lineWidth: 1)
        }
    }
}

struct GreekDetailView: View {
    let letter: GreekLetter
    @Binding var value: Double
    @Binding var isPlaying: Bool
    @Binding var motion: GreekMotionClock
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var entry: GreekEntry { letter.entry }
    private var spec: ParamSpec { GreekToyModel.control(for: letter) }

    init(letter: GreekLetter, value: Binding<Double>, isPlaying: Binding<Bool>, motion: Binding<GreekMotionClock>) {
        self.letter = letter
        _value = value
        _isPlaying = isPlaying
        _motion = motion
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                title
                GreekToyStage(letter: letter, value: value, isPlaying: isPlaying, motion: $motion)
                    .frame(height: 240)
                    .background(ToyStyle.panel, in: .rect(cornerRadius: 24))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24).strokeBorder(ToyStyle.cyan.opacity(0.22))
                    }
                Text(GreekToyModel.reading(letter, value: value))
                    .font(.system(.callout, design: .monospaced).weight(.medium))
                    .foregroundStyle(ToyStyle.cyan)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("\(entry.name) live equation")
                    .accessibilityValue(GreekToyModel.reading(letter, value: value))
                    .accessibilityIdentifier("greek-selected-symbol")
                control
                GreekInfoBlock(title: "What you’re playing with", text: entry.explanation)
                GreekInfoBlock(title: "A letter with a history", text: entry.origin)
                GreekInfoBlock(title: "Other places it appears", text: entry.otherUses)
                Text("These are selected conventions, not fixed meanings for a glyph. The diagram uses a teaching model; read the equation and its units to know what the symbol means here.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
                GreekSourceLinks()
            }
            .padding(18)
        }
        .background(ToyStyle.background)
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("greek-detail-\(letter.rawValue)")
    }

    private var title: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 18) {
                titleGlyphs
                titleCopy
            }
            VStack(alignment: .leading, spacing: 12) {
                titleGlyphs
                titleCopy
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var titleGlyphs: some View {
        Text(entry.glyphs)
            .font(.system(size: 43, weight: .light, design: .serif))
            .foregroundStyle(ToyStyle.amber)
            .fixedSize()
            .accessibilityLabel("Uppercase and lowercase \(entry.name)")
    }

    private var titleCopy: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(entry.subject.uppercased())
                .font(.caption2.weight(.semibold)).tracking(1.5)
                .foregroundStyle(ToyStyle.cyan)
            Text(entry.title).font(.title3.weight(.semibold)).foregroundStyle(.white)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var control: some View {
        VStack(spacing: 10) {
            GlassEffectContainer(spacing: 16) {
                VStack(spacing: 14) {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(spacing: 12) {
                            dial
                            controlHint
                        }
                    } else {
                        HStack(spacing: 22) {
                            dial
                            controlHint
                        }
                    }
                    actionButtons
                }
            }
            PrecisionSlider(spec: spec, value: $value)
            if GreekToyModel.hasMotion(letter) {
                Text(motionStatus)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("greek-motion-status")
            }
        }
        .padding(16)
        .background(ToyStyle.panel, in: .rect(cornerRadius: 24))
    }

    private var motionStatus: String {
        if reduceMotion { return "Reduce Motion keeps the diagram still. You can keep exploring with the control." }
        if !isPlaying { return "Motion is paused. Resume from this frame." }
        if letter == .omega && value == 0 { return "Angular velocity is zero, so the rotor is still." }
        return "Motion is playing. Pause to inspect a frame."
    }

    private var dial: some View {
        GlassKnob(spec: spec, value: $value).frame(width: 120)
    }

    private var controlHint: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TURN TO EXPLORE").font(.caption2.weight(.semibold)).tracking(1.2)
                .foregroundStyle(ToyStyle.cyan)
            Text(spec.hint).font(.callout).foregroundStyle(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtons: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    resetButton
                    motionButton
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: 12) {
                    resetButton
                    motionButton
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var resetButton: some View {
        Button { value = spec.defaultValue } label: {
            Label("Reset", systemImage: "arrow.counterclockwise")
                .frame(minHeight: 44)
                .padding(.horizontal, 10)
        }
        .buttonStyle(.glass)
        .accessibilityLabel("Reset \(entry.name) control")
        .accessibilityIdentifier("greek-reset")
    }

    @ViewBuilder private var motionButton: some View {
        if GreekToyModel.hasMotion(letter) && !reduceMotion {
            Button { isPlaying.toggle() } label: {
                Label(isPlaying ? "Pause" : "Resume", systemImage: isPlaying ? "pause.fill" : "play.fill")
                    .frame(minHeight: 44)
                    .padding(.horizontal, 10)
            }
            .buttonStyle(.glass)
            .accessibilityLabel(isPlaying ? "Pause \(entry.name) motion" : "Resume \(entry.name) motion")
            .accessibilityValue(isPlaying ? "Playing" : "Paused")
            .accessibilityIdentifier("greek-motion-button")
        }
    }
}

private struct GreekInfoBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundStyle(.white)
            Text(text).font(.callout).foregroundStyle(.white.opacity(0.73))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GreekSourceLinks: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FOLLOW THE SOURCES").font(.caption2.weight(.semibold)).tracking(1.5)
                .foregroundStyle(.white.opacity(0.6))
            sourceLink("Alphabet · University of Cambridge", url: "https://www.greek.divinity.cam.ac.uk/content/unit1/u1_overview.html")
            sourceLink("Origins · Scuola Normale Superiore", url: "https://mnamon.sns.it/index.php?id=12&lang=en&page=Scrittura")
            sourceLink("Physics notation · OpenStax", url: "https://openstax.org/books/college-physics/pages/d-glossary-of-key-symbols-and-notation")
        }
        .font(.footnote)
        .tint(ToyStyle.cyan)
        .padding(.vertical, 8)
    }

    private func sourceLink(_ title: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            Text(title)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
}
