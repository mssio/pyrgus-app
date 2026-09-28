import PasswordKit
import SwiftUI

struct PasswordScreen: View {
    @State private var model = PasswordModel()
    @State private var showingAbout = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                LabeledContent("Format") {
                    Menu {
                        Picker("Format", selection: $model.format) {
                            Section("Passwords") {
                                ForEach(PasswordFormat.allCases.filter { !$0.isSecret }) { Text($0.displayName).tag($0) }
                            }
                            Section("Secrets") {
                                ForEach(PasswordFormat.allCases.filter(\.isSecret)) { Text($0.displayName).tag($0) }
                            }
                        }
                    } label: {
                        Label(model.format.displayName, systemImage: "chevron.up.chevron.down")
                            .labelStyle(.trailingIcon)
                    }
                    .menuStyle(.button)
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Format")
                    .accessibilityValue(model.format.displayName)
                }

                FormatOptionsView(format: model.format, options: $model.options)

                SecretView(secret: model.password, onCopy: model.copy)

                Text(model.entropyCaption)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button(model.justCopied ? "Copied" : "Copy", systemImage: "doc.on.doc", action: model.copy)
                        .buttonStyle(.borderedProminent)
                    Button("Regenerate", systemImage: "arrow.clockwise", action: model.regenerate)
                        .buttonStyle(.bordered)
                }
            }
            .padding()
            .frame(maxWidth: 420)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Pyrgus")
        .toolbar {
            Button("About", systemImage: "info.circle") { showingAbout = true }
        }
        .sheet(isPresented: $showingAbout) { AboutSheet() }
        #if os(iOS)
        .sensoryFeedback(.impact(weight: .light), trigger: model.generations)
        .sensoryFeedback(.success, trigger: model.copies)
        #endif
    }
}

/// The secret: monospaced, digits in indigo, wrapping and never truncated, spelled out for VoiceOver.
private struct SecretView: View {
    let secret: String
    let onCopy: () -> Void

    var body: some View {
        Text(highlighted)
            .font(.system(.title2, design: .monospaced))
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
