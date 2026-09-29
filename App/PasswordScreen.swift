import PasswordKit
import SwiftUI

/// Compact on iPhone and narrow iPad windows; large on a full-width iPad and on the Mac.
private enum LayoutScale {
    case compact, large

    var columnWidth: CGFloat { self == .large ? 560 : 420 }
    var secretFont: Font.TextStyle { self == .large ? .largeTitle : .title2 }
    var bodyFont: Font { self == .large ? .title3 : .body }
    var captionFont: Font { self == .large ? .callout : .footnote }
    var controlSize: ControlSize { self == .large ? .large : .regular }
}

struct PasswordScreen: View {
    @State private var model = PasswordModel()

    #if os(iOS)
    @State private var showingAbout = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif

    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif

    private var scale: LayoutScale {
        #if os(macOS)
        .large
        #else
        horizontalSizeClass == .regular && verticalSizeClass == .regular ? .large : .compact
        #endif
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                LabeledContent("Format") {
                    // A menu Picker is the native pop-up button on each platform: one ⌃⌄, no submenu.
                    Picker("Format", selection: $model.format) {
                        Section("Passwords") {
                            ForEach(PasswordFormat.allCases.filter { !$0.isSecret }) { Text($0.displayName).tag($0) }
                        }
                        Section("Secrets") {
                            ForEach(PasswordFormat.allCases.filter(\.isSecret)) { Text($0.displayName).tag($0) }
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .buttonStyle(.bordered)
                }

                FormatOptionsView(format: model.format, options: $model.options)

                SecretView(secret: model.password, scale: scale, onCopy: model.copy)

                Text(model.entropyCaption)
                    .font(scale.captionFont)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button(model.justCopied ? "Copied" : "Copy", systemImage: "doc.on.doc", action: model.copy)
                        .buttonStyle(.borderedProminent)
                    Button("Regenerate", systemImage: "arrow.clockwise", action: model.regenerate)
                        .buttonStyle(.bordered)
                }
            }
            .padding()
            .font(scale.bodyFont)
            .controlSize(scale.controlSize)
            .frame(maxWidth: scale.columnWidth)
            .frame(maxWidth: .infinity)
        }
        .defaultScrollAnchor(.center, for: .alignment)
        .navigationTitle("Pyrgus")
        .toolbar {
            Button("About", systemImage: "info.circle") {
                #if os(macOS)
                openWindow(id: AboutWindow.id)
                #else
                showingAbout = true
                #endif
            }
        }
        #if os(iOS)
        .sheet(isPresented: $showingAbout) { AboutSheet() }
        .sensoryFeedback(.impact(weight: .light), trigger: model.generations)
        .sensoryFeedback(.success, trigger: model.copies)
        #endif
    }
}

/// The secret: monospaced, digits in indigo, wrapping and never truncated, spelled out for VoiceOver.
private struct SecretView: View {
    let secret: String
    let scale: LayoutScale
    let onCopy: () -> Void

    var body: some View {
        Text(highlighted)
            .font(.system(scale.secretFont, design: .monospaced))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(perform: onCopy)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(SpokenSecret.spell(secret))
            .accessibilityHint("Copies the password")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(named: "Copy", onCopy)
    }

    /// Display only — never copied or read by VoiceOver, both of which use `secret` directly. A
    /// zero-width space (U+200B) after every character gives the line breaker a break opportunity
    /// at any position, so long tokens wrap without automatic hyphenation inserting a visible "-"
    /// that isn't part of the secret.
    private var highlighted: AttributedString {
        var result = AttributedString()
        for character in secret {
            var piece = AttributedString(String(character))
            if character.isASCII, character.isNumber { piece.foregroundColor = .indigo }
            result += piece
            result += AttributedString("\u{200B}")
        }
        return result
    }
}
