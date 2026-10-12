import SwiftUI

struct SubmitFeatureRequestView: View {
    // MARK: - Properties
    let model: FeaturePortalModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    @State private var title = ""
    @State private var description = ""
    @State private var email = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""

    enum Field {
        case title, description, email
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .grid(5)) {
                    // Header
                    VStack(spacing: .grid(2)) {
                        Image(systemName: "lightbulb.max.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.featurePortalPrimary, .featurePortalSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolEffect(.pulse)

                        Text("Share Your Idea")
                            .font(.title2.weight(.bold))

                        Text("Help us improve by sharing your feature request")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, .grid(4))

                    // Form Fields
                    VStack(spacing: .grid(4)) {
                        // Title Field
                        VStack(alignment: .leading, spacing: .grid(2)) {
                            Label("Title", systemImage: "text.alignleft")
                                .font(.subheadline.weight(.semibold))

                            TextField("Enter a clear, concise title", text: $title)
                                .textFieldStyle(.plain)
                                #if os(iOS)
                                .textInputAutocapitalization(.sentences)
                                #endif
                                .focused($focusedField, equals: .title)
                                .padding(.grid(3))
                                .background(Color.featurePortalCardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(
                                            focusedField == .title ? Color.featurePortalPrimary : Color.featurePortalBorder,
                                            lineWidth: focusedField == .title ? 2 : 0.5
                                        )
                                )

                            HStack {
                                Text("Keep it short and descriptive")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                CharacterCounter(count: title.count, minimum: 3)
                            }
                        }

                        // Description Field
                        VStack(alignment: .leading, spacing: .grid(2)) {
                            Label("Description", systemImage: "text.alignleft")
                                .font(.subheadline.weight(.semibold))

                            TextField("Describe your feature request in detail", text: $description, axis: .vertical)
                                .textFieldStyle(.plain)
                                .lineLimit(5...10)
                                #if os(iOS)
                                .textInputAutocapitalization(.sentences)
                                #endif
                                .focused($focusedField, equals: .description)
                                .padding(.grid(3))
                                .background(Color.featurePortalCardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(
                                            focusedField == .description ? Color.featurePortalPrimary : Color.featurePortalBorder,
                                            lineWidth: focusedField == .description ? 2 : 0.5
                                        )
                                )

                            HStack {
                                Text("Explain why this would be valuable")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                CharacterCounter(count: description.count, minimum: 10)
                            }
                        }

                        // Email Field
                        VStack(alignment: .leading, spacing: .grid(2)) {
                            Label("Contact Email", systemImage: "envelope")
                                .font(.subheadline.weight(.semibold))

                            TextField("your@email.com (optional)", text: $email)
                                .textFieldStyle(.plain)
                                #if os(iOS)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                #endif
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .padding(.grid(3))
                                .background(Color.featurePortalCardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(
                                            focusedField == .email ? Color.featurePortalPrimary : Color.featurePortalBorder,
                                            lineWidth: focusedField == .email ? 2 : 0.5
                                        )
                                )

                            Text("We'll notify you when there are updates")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Submit Button
                    Button(action: submitRequest) {
                        HStack(spacing: .grid(2)) {
                            if isSubmitting {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(isSubmitting ? "Submitting..." : "Submit Request")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, .grid(4))
                        .background(
                            LinearGradient(
                                colors: [.featurePortalPrimary, .featurePortalSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .featurePortalButtonShadow()
                    }
                    .featurePortalPlainButton()
                    .disabled(!isValid || isSubmitting)
                    .opacity(!isValid || isSubmitting ? 0.5 : 1.0)
                    .padding(.top, .grid(2))
                }
                .padding(.grid(4))
            }
            .background(Color.featurePortalBackground)
            .navigationTitle("New Feature Request")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Private Methods
    private var isValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmedTitle.count >= 3 &&
               trimmedDescription.count >= 10 &&
               (email.isEmpty || email.contains("@"))
    }

    private func submitRequest() {
        let request = FeatureWishRequest(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            authorEmail: email.isEmpty ? nil : email.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        isSubmitting = true

        Task {
            do {
                try await model.submitFeatureRequest(request)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                isSubmitting = false
            }
        }
    }
}

// MARK: - Character Counter
private struct CharacterCounter: View {
    let count: Int
    let minimum: Int

    var body: some View {
        HStack(spacing: .grid(1)) {
            if count >= minimum {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Color.featurePortalGreen)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Color.featurePortalOrange)
            }

            Text("\(count)/\(minimum)")
                .font(.caption.weight(.medium))
                .foregroundStyle(count >= minimum ? Color.featurePortalGreen : Color.featurePortalOrange)
        }
        .padding(.horizontal, .grid(2))
        .padding(.vertical, .grid(1))
        .background((count >= minimum ? Color.featurePortalGreen : Color.featurePortalOrange).opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    SubmitFeatureRequestView(model: FeaturePortalModel())
}
