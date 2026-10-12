import SwiftUI

struct FeatureRequestDetailView: View {
    // MARK: - Properties
    let model: FeaturePortalModel
    let request: FeatureWishResponse
    
    @State private var newComment = ""
    @State private var isSubmittingComment = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var comments: [FeatureWishComment] = []
    @State private var isLoadingComments = false
    @State private var showVoteAlert = false
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: .grid(4)) {
                // Header Section
                VStack(alignment: .leading, spacing: .grid(4)) {
                    HStack {
                        Text(request.title)
                            .font(.title.bold())
                            .foregroundStyle(.primary)

                        Spacer()

                        StatusBadge(status: request.status)
                    }

                    // Tags
                    if !request.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: .grid(2)) {
                                ForEach(request.tags) { tag in
                                    TagView(tag: tag, size: .medium)
                                }
                            }
                        }
                    }

                    Text(request.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)

                    HStack(spacing: .grid(4)) {
                        HStack(spacing: .grid(1)) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                            Text(Date(timeIntervalSince1970: request.createdAt), style: .relative)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)

                        Divider()
                            .frame(height: 12)

                        HStack(spacing: .grid(1)) {
                            Image(systemName: "bubble.left.fill")
                                .font(.caption)
                            Text("\(request.commentCount)")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(Color.featurePortalBlue)

                        Spacer()

                        VStack(spacing: .grid(1)) {
                            VoteButton(
                                votes: request.upvoteCount,
                                isVoted: request.upvotedByCurrentUser
                            ) {
                                if request.upvotedByCurrentUser && !model.canUndoVote(for: request) {
                                    showVoteAlert = true
                                } else {
                                    Task { @MainActor in
                                        try? await model.toggleVote(for: request)
                                    }
                                }
                            }

                            if request.upvotedByCurrentUser, let remaining = model.remainingUndoTime(for: request) {
                                Text("Undo: \(formatTime(remaining))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.grid(4))
                .background(Color.featurePortalCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.featurePortalBorder.opacity(0.5), lineWidth: 0.5)
                )

                // Comments Section
                VStack(alignment: .leading, spacing: .grid(4)) {
                    HStack {
                        Label("Comments", systemImage: "bubble.left.and.bubble.right.fill")
                            .font(.title3.weight(.semibold))
                        Spacer()
                        Text("\(comments.count)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, .grid(2))
                            .padding(.vertical, .grid(1))
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    if isLoadingComments {
                        HStack {
                            Spacer()
                            VStack(spacing: .grid(2)) {
                                ProgressView()
                                Text("Loading comments...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.grid(8))
                    } else if comments.isEmpty {
                        VStack(spacing: .grid(3)) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary.opacity(0.5))

                            Text("No comments yet")
                                .font(.subheadline.weight(.medium))

                            Text("Be the first to share your thoughts!")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.grid(8))
                    } else {
                        LazyVStack(spacing: .grid(3)) {
                            ForEach(comments) { comment in
                                CommentView(comment: comment)
                            }
                        }
                    }

                    // New Comment Section
                    VStack(alignment: .leading, spacing: .grid(3)) {
                        Text("Add a comment")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        TextField("Share your thoughts...", text: $newComment, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(3...6)
                            #if os(iOS)
                            .textInputAutocapitalization(.sentences)
                            #endif
                            .padding(.grid(3))
                            .background(Color.featurePortalCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.featurePortalBorder, lineWidth: 0.5)
                            )

                        Button(action: submitComment) {
                            HStack(spacing: .grid(2)) {
                                if isSubmittingComment {
                                    ProgressView()
                                        .controlSize(.small)
                                }
                                Text(isSubmittingComment ? "Posting..." : "Post Comment")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .grid(3))
                            .background(
                                LinearGradient(
                                    colors: [.featurePortalPrimary, .featurePortalSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .featurePortalButtonShadow()
                        }
                        .featurePortalPlainButton()
                        .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmittingComment)
                        .opacity(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmittingComment ? 0.5 : 1.0)
                    }
                    .padding(.grid(4))
                    .background(Color.featurePortalCardBackground.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.grid(4))
        }
        .background(Color.featurePortalBackground)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Vote is permanent", isPresented: $showVoteAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can only undo your vote within 5 minutes of voting. This vote is now permanent.")
        }
        .task {
            // Track view for analytics
            model.trackView(for: request)
            // Load comments
            await loadComments()
        }
    }
    
    // MARK: - Private Methods
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    private func loadComments() async {
        guard request.commentCount > 0 else { return }
        
        isLoadingComments = true
        defer { isLoadingComments = false }
        
        do {
            comments = try await model.fetchComments(for: request)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func submitComment() {
        let trimmedComment = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedComment.isEmpty else { return }
        
        isSubmittingComment = true
        
        Task { @MainActor in
            do {
                let newComment = try await model.addComment(trimmedComment, to: request)
                self.newComment = "" // Clear the input
                comments.append(newComment) // Add the new comment to the list
            } catch {
                print("Comment submission error: \(error)")
                errorMessage = "Failed to submit comment"
                showError = true
            }
            isSubmittingComment = false
        }
    }
}

// MARK: - Comment View
private struct CommentView: View {
    let comment: FeatureWishComment

    var body: some View {
        VStack(alignment: .leading, spacing: .grid(3)) {
            HStack(spacing: .grid(2)) {
                HStack(spacing: .grid(1)) {
                    Image(systemName: comment.isByAdmin ? "checkmark.seal.fill" : "person.circle.fill")
                        .font(.caption)
                    Text(comment.isByAdmin ? "Team" : "User")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(comment.isByAdmin ? Color.featurePortalBlue : .secondary)
                .padding(.horizontal, .grid(2))
                .padding(.vertical, .grid(1))
                .background(
                    comment.isByAdmin ?
                        Color.featurePortalBlue.opacity(0.12) :
                        Color.secondary.opacity(0.08)
                )
                .clipShape(Capsule())

                Spacer()

                HStack(spacing: .grid(1)) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(Date(timeIntervalSince1970: comment.createdAt), style: .relative)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Text(comment.body)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(2)
        }
        .padding(.grid(4))
        .background(Color.featurePortalCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    comment.isByAdmin ?
                        Color.featurePortalBlue.opacity(0.3) :
                        Color.featurePortalBorder.opacity(0.5),
                    lineWidth: comment.isByAdmin ? 1.5 : 0.5
                )
        )
    }
}

#Preview {
    NavigationStack {
        FeatureRequestDetailView(
            model: FeaturePortalModel(),
            request: FeatureWishResponse(
                title: "Dark Mode Support",
                description: "Add support for dark mode throughout the application.",
                upvoteCount: 42,
                commentCount: 3,
                upvotedByCurrentUser: true
            )
        )
    }
}

#Preview("Comment Types") {
    VStack(spacing: 20) {
        CommentView(
            comment: FeatureWishComment(
                body: "This is an admin comment",
                isByAdmin: true,
                createdAt: Date().timeIntervalSince1970
            )
        )
        
        CommentView(
            comment: FeatureWishComment(
                body: "This is a regular user comment",
                isByAdmin: false,
                createdAt: Date().timeIntervalSince1970
            )
        )
    }
    .padding()
} 
