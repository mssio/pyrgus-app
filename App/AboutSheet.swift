#if os(iOS)
import SwiftUI

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(AppInfo.privacyNote)
                }
                Section("Credits") {
                    Text(AppInfo.creditNote)
                    Link("EFF wordlists", destination: AppInfo.effWordlistsURL)
                }
                Section {
                    Link("Support", destination: AppInfo.supportURL)
                    Link("Privacy Policy", destination: AppInfo.privacyURL)
                }
                Section {
                    LabeledContent("Version", value: Bundle.main.versionLabel)
                    if let built = Bundle.main.buildDateLabel {
                        LabeledContent("Built", value: built)
                    }
                }
            }
            .navigationTitle("About Pyrgus")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}
#endif
