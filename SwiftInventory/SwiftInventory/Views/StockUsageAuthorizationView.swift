import SwiftUI

// PIN authorization presented as a sheet before a stock usage is
// recorded. Handles both first-time PIN setup and verification.
struct StockUsageAuthorizationView: View {

    // Called only after the PIN is set up or verified successfully.
    let onAuthorized: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var isSettingUp = !StockUsagePIN.isConfigured
    @State private var pinText = ""
    @State private var confirmPinText = ""
    @State private var errorMessage: String?

    private let pinLength = 4

    private var isPinComplete: Bool {
        pinText.count == pinLength
    }

    private var canSubmit: Bool {
        if isSettingUp {
            return isPinComplete && confirmPinText.count == pinLength
        }

        return isPinComplete
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                header

                VStack(spacing: 14) {
                    PINField(
                        title: isSettingUp ? "Create a 4-digit PIN" : "Enter your PIN",
                        text: $pinText,
                        pinLength: pinLength
                    )

                    if isSettingUp {
                        PINField(
                            title: "Confirm PIN",
                            text: $confirmPinText,
                            pinLength: pinLength
                        )
                    }

                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .siCard()
                .padding(.horizontal)

                submitButton
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .background(SITheme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40))
                .foregroundStyle(SITheme.navy)
                .frame(width: 76, height: 76)
                .background(SITheme.navy.opacity(0.1))
                .clipShape(Circle())

            Text(isSettingUp ? "Set Up Authorization PIN" : "Authorization Required")
                .font(.title3)
                .fontWeight(.bold)

            Text(
                isSettingUp
                ? "Create a PIN to authorize stock usage deductions."
                : "Enter your PIN to record this stock usage."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        }
    }

    private var submitButton: some View {
        Button {
            submit()
        } label: {
            Label(
                isSettingUp ? "Save PIN & Authorize" : "Authorize",
                systemImage: "checkmark.shield.fill"
            )
            .font(.headline)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSubmit ? SITheme.green : Color(.systemGray4))
            .foregroundStyle(canSubmit ? .white : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .disabled(!canSubmit)
    }

    private func submit() {
        if isSettingUp {
            guard pinText == confirmPinText else {
                errorMessage = "The PINs do not match. Try again."
                confirmPinText = ""
                return
            }

            StockUsagePIN.save(pinText)
            authorize()
        } else {
            guard StockUsagePIN.verify(pinText) else {
                errorMessage = "Incorrect PIN. Try again."
                pinText = ""
                return
            }

            authorize()
        }
    }

    private func authorize() {
        errorMessage = nil
        dismiss()
        onAuthorized()
    }
}

struct PINField: View {

    let title: String
    @Binding var text: String
    let pinLength: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            SecureField("••••", text: $text)
                .keyboardType(.numberPad)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .background(SITheme.softFill)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onChange(of: text) { _, newValue in
                    // Keep the PIN numeric and limited in length.
                    let digits = newValue.filter { $0.isNumber }
                    text = String(digits.prefix(pinLength))
                }
        }
    }
}

#Preview {
    StockUsageAuthorizationView {
    }
}
