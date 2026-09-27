import SwiftUI

// Placeholder: a static preview of the screen's layout with a sample value. Nothing is generated or
// copied. Replaced by PasswordScreen in the app task.
struct PlaceholderScreen: View {
    private let sample = "khduvn-xeRvpr-mzt7ai"

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Menu("Password") {
                    Section("Passwords") {
                        Text("Password")
                        Text("Custom Password")
                        Text("Memorable")
                        Text("PIN")
                    }
                    Section("Secrets") {
                        Text("Secret 128")
                        Text("Secret 256")
                    }
                }

                Text(highlighted)
                    .font(.system(.title2, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Text("90.1 bits of entropy")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button("Copy", systemImage: "doc.on.doc") {}
                        .buttonStyle(.borderedProminent)
                    Button("Regenerate", systemImage: "arrow.clockwise") {}
                        .buttonStyle(.bordered)
                }

                Text("Placeholder — sample value, nothing is generated")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .frame(maxWidth: 420)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Pyrgus")
        .toolbar {
            Button("About", systemImage: "info.circle") {}
        }
    }

    private var highlighted: AttributedString {
        var result = AttributedString()
        for character in sample {
            var piece = AttributedString(String(character))
            if character.isNumber { piece.foregroundColor = .indigo }
            result += piece
        }
        return result
    }
}
