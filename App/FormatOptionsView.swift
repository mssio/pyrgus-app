import PasswordKit
import SwiftUI

/// The chosen format's options, shown only for PIN, Custom Password and Memorable.
struct FormatOptionsView: View {
    let format: PasswordFormat
    @Binding var options: PasswordOptions

    var body: some View {
        switch format {
        case .pin:
            Picker("PIN length", selection: $options.pinLength) {
                ForEach(PinLength.allCases, id: \.self) { Text("\($0.rawValue)").tag($0) }
            }
            .pickerStyle(.segmented)
        case .strong:
            VStack(alignment: .leading, spacing: 12) {
                StepSlider(
                    label: "Length", unit: "characters", value: $options.customLength,
                    range: PasswordOptions.customLengthRange)
                Toggle("Include symbols", isOn: $options.includeSymbols)
            }
        case .memorable:
            VStack(alignment: .leading, spacing: 12) {
                StepSlider(
                    label: "Words", unit: "words", value: $options.memorableWordCount,
                    range: PasswordOptions.memorableWordCountRange)
                Text("Separator")
                Picker("Separator", selection: $options.memorableSeparator) {
                    ForEach(MemorableSeparator.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        case .standard, .secret128, .secret256:
            EmptyView()
        }
    }
}

/// "Length: 24" over a whole-number slider with its end values as captions.
private struct StepSlider: View {
    let label: String
    let unit: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(label): \(value)")
            Slider(
                value: Binding(get: { Double(value) }, set: { value = Int($0.rounded()) }),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 1
            ) {
                Text(label)
            } minimumValueLabel: {
                Text("\(range.lowerBound)")
            } maximumValueLabel: {
                Text("\(range.upperBound)")
            }
            .accessibilityValue("\(value) \(unit)")
        }
    }
}

extension MemorableSeparator {
    var label: String {
        switch self {
        case .space: "Space"
        case .hyphen: "Hyphen (-)"
        case .underscore: "Underscore (_)"
        }
    }
}
