import SwiftUI

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Passwords and keys are generated on this device and never leave it. No account, no network.")
                }
                Section("Credits") {
                    Text("Memorable passwords use the EFF long wordlist, licensed CC BY 3.0 US.")
                    Link("EFF wordlists", destination: URL(string: "https://www.eff.org/dice")!)
                }
                Section {
                    LabeledContent("Version", value: Bundle.main.appVersion)
                }
            }
            .navigationTitle("About Pyrgus")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        #if os(macOS)
        .frame(minWidth: 380, minHeight: 320)
        #endif
    }
}

private extension Bundle {
    var appVersion: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(version) (\(build))"
    }
}
