import SwiftUI

public struct FeatureRequestList: View {
    // MARK: - Properties
    @Bindable var model: FeaturePortalModel
    @State private var showingAddSheet = false
    @State private var showAlert = false
    @State private var showingFilterSheet = false
    
    // MARK: - Initialization
    public init(model: FeaturePortalModel) {
        self.model = model
    }
    
    // MARK: - Body
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Controls
                VStack(spacing: .grid(3)) {
                    // Search Bar
                    HStack(spacing: .grid(2)) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search feature requests...", text: $model.searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, .grid(3))
                    .padding(.vertical, .grid(3))
                    .background(Color.featurePortalCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    // Sort and Filter Row
                    HStack(spacing: .grid(3)) {
                        // Sort Menu
                        Menu {
                            Picker("Sort By", selection: $model.sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Label(option.rawValue, systemImage: option == .newest ? "clock" : "arrow.up")
                                        .tag(option)
                                }
                            }
                        } label: {
                            HStack(spacing: .grid(2)) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.subheadline)
                                Text(model.sortOption.rawValue)
                                    .font(.subheadline.weight(.medium))
                            }
                            .foregroundStyle(Color.featurePortalPrimary)
                            .padding(.horizontal, .grid(3))
                            .padding(.vertical, .grid(2))
                            .background(Color.featurePortalPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .featurePortalPlainMenu()

                        // Filter Button
                        Button(action: { showingFilterSheet = true }) {
                            HStack(spacing: .grid(2)) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.subheadline)
                                Text("Filter")
                                    .font(.subheadline.weight(.medium))

                                if !model.selectedTags.isEmpty {
                                    Text("\(model.selectedTags.count)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.featurePortalOrange)
                                        .clipShape(Capsule())
                                }
                            }
                            .foregroundStyle(Color.featurePortalPrimary)
                            .padding(.horizontal, .grid(3))
                            .padding(.vertical, .grid(2))
                            .background(Color.featurePortalPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .featurePortalPlainButton()

                        Spacer()
                    }
                }
                .padding(.horizontal, .grid(4))
                .padding(.vertical, .grid(3))
                .background(Color.featurePortalBackground)

                Divider()

                // Feature Requests List
                ScrollView {
                    LazyVStack(spacing: .grid(3)) {
                        ForEach(model.featureRequests) { request in
                        NavigationLink {
                            FeatureRequestDetailView(model: model, request: request)
                        } label: {
                            FeatureRequestCell(
                                model: model,
                                request: request
                            ) {
                                guard !model.isLoading else { return }

                                if request.upvotedByCurrentUser && !model.canUndoVote(for: request) {
                                    showAlert = true
                                } else {
                                    Task { @MainActor in
                                        do {
                                            try await model.toggleVote(for: request)
                                        } catch {
                                            print("Error toggling vote: \(error)")
                                        }
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, .grid(4))
                    .padding(.vertical, .grid(3))
                }
                .background(Color.featurePortalBackground)
                .overlay {
                if model.isLoading && model.featureRequests.isEmpty {
                    VStack(spacing: .grid(4)) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Loading feature requests...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if model.featureRequests.isEmpty {
                    VStack(spacing: .grid(4)) {
                        Image(systemName: "lightbulb.max")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.featurePortalPrimary.opacity(0.6))
                            .symbolEffect(.pulse)

                        VStack(spacing: .grid(2)) {
                            Text("No Feature Requests")
                                .font(.title2.weight(.semibold))

                            Text("Be the first to suggest a feature!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Button(action: { showingAddSheet = true }) {
                            Label("Submit Request", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, .grid(6))
                                .padding(.vertical, .grid(3))
                                .background(
                                    LinearGradient(
                                        colors: [.featurePortalPrimary, .featurePortalSecondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .featurePortalButtonShadow()
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.grid(8))
                }
            }
            .refreshable {
                try? await model.loadFeatureRequests()
            }
        }
            .navigationTitle("Feature Requests")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(macOS)
                // No pull to refresh on the Mac.
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task { try? await model.loadFeatureRequests() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .keyboardShortcut("r")
                    .help("Refresh")
                }
                #endif
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.featurePortalPrimary)
                    }
                    #if os(macOS)
                    .keyboardShortcut("n")
                    .help("New Feature Request")
                    #endif
                }
            }
            .alert("Vote is permanent", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You can only undo your vote within 5 minutes of voting. This vote is now permanent.")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            SubmitFeatureRequestView(model: model)
                #if os(macOS)
                .frame(minWidth: 440, idealWidth: 480, minHeight: 560, idealHeight: 640)
                #endif
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(model: model)
                .presentationDetents([.medium])
                #if os(macOS)
                .frame(minWidth: 360, minHeight: 280)
                #endif
        }
    }
}

// MARK: - Filter Sheet
private struct FilterSheet: View {
    @Bindable var model: FeaturePortalModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: .grid(4)) {
                if model.availableTags.isEmpty {
                    VStack(spacing: .grid(3)) {
                        Image(systemName: "tag")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary.opacity(0.5))

                        Text("No tags available")
                            .font(.subheadline.weight(.medium))

                        Text("Tags will appear here once feature requests are tagged")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: .grid(3)) {
                        Text("Filter by Tags")
                            .font(.headline)

                        Text("Select one or more tags to filter")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        FlowLayout(spacing: .grid(2)) {
                            ForEach(model.availableTags) { tag in
                                FilterTagButton(
                                    tag: tag,
                                    isSelected: model.selectedTags.contains(tag.id)
                                ) {
                                    if model.selectedTags.contains(tag.id) {
                                        model.selectedTags.remove(tag.id)
                                    } else {
                                        model.selectedTags.insert(tag.id)
                                    }
                                }
                            }
                        }

                        if !model.selectedTags.isEmpty {
                            Button(action: {
                                model.selectedTags.removeAll()
                            }) {
                                Label("Clear All Filters", systemImage: "xmark.circle.fill")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.featurePortalRed)
                                    .padding(.vertical, .grid(2))
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()
                    }
                    .padding(.grid(4))
                }
            }
            .navigationTitle("Filter")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Filter Tag Button
private struct FilterTagButton: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: .grid(1)) {
                Circle()
                    .fill(tag.color.color)
                    .frame(width: 6, height: 6)

                Text(tag.name)
                    .font(.subheadline.weight(.medium))

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                }
            }
            .foregroundStyle(isSelected ? .white : tag.color.color)
            .padding(.horizontal, .grid(3))
            .padding(.vertical, .grid(2))
            .background(isSelected ? tag.color.color : tag.color.lightColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(tag.color.color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size = CGSize.zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)

                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, subviewSize.height)
                currentX += subviewSize.width + spacing
                size.width = max(size.width, currentX - spacing)
            }

            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}

#Preview("Real data") {
    let model = FeaturePortalModel(useMockData: false)

    Task { @MainActor in
        try? await model.loadFeatureRequests()
    }

    return FeatureRequestList(model: model)
}

#Preview("Mock data") {
    let model = FeaturePortalModel(useMockData: true)
    
    Task { @MainActor in
        try? await model.loadFeatureRequests()
    }
    
    return FeatureRequestList(model: model)
}

#Preview("Empty State") {
    FeatureRequestList(model: FeaturePortalModel())
} 
