import SwiftUI

@MainActor
public final class FeaturePortal {
    // MARK: - Properties
    static var apiKey = ""

    /// Shared prompt trigger instance, created during `configure()`.
    public private(set) static var promptTrigger: FeaturePromptTrigger?

    // MARK: - Configuration

    /// Configure the SDK with your API key and optional prompt configuration.
    ///
    /// - Parameters:
    ///   - apiKey: Your FeaturePortal API key.
    ///   - promptConfiguration: Custom engagement thresholds for the feature prompt.
    ///     Pass `nil` to disable the engagement prompt entirely.
    public static func configure(
        apiKey: String,
        promptConfiguration: FeaturePromptConfiguration? = FeaturePromptConfiguration()
    ) {
        self.apiKey = apiKey
        if let config = promptConfiguration {
            self.promptTrigger = FeaturePromptTrigger(configuration: config)
        } else {
            self.promptTrigger = nil
        }
    }

    /// Convenience: log an app launch event for engagement tracking.
    public static func logAppLaunch() {
        promptTrigger?.logAppLaunch()
    }

    /// Convenience: log a significant event for engagement tracking.
    public static func logSignificantEvent() {
        promptTrigger?.logSignificantEvent()
    }
    
    // MARK: - View Factory
    public struct FeatureListView: View {
        @State private var model = FeaturePortalModel()
        #if os(macOS)
        @State private var tab = Tab.requests
        private enum Tab { case requests, roadmap }
        #endif

        public init() {}

        /// With a given model, e.g. mock data in previews.
        init(model: FeaturePortalModel) {
            _model = State(initialValue: model)
        }

        public var body: some View {
            #if os(macOS)
            // A Mac TabView draws its content in an inset, bordered box: a segmented control over the content instead.
            VStack(spacing: 0) {
                Picker("Show", selection: $tab) {
                    Text("Requests").tag(Tab.requests)
                    Text("Roadmap").tag(Tab.roadmap)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
                .padding(.vertical, .grid(2))
                .frame(maxWidth: .infinity)
                .background(Color.featurePortalBackground)

                switch tab {
                case .requests:
                    FeatureRequestList(model: model)
                case .roadmap:
                    NavigationStack { RoadmapView(model: model) }
                }
            }
            // A window or sheet on the Mac sizes itself to its content: give the list room.
            .frame(minWidth: 460, idealWidth: 540, minHeight: 560, idealHeight: 720)
            #else
            TabView {
                FeatureRequestList(model: model)
                    .tabItem {
                        Label("Requests", systemImage: "lightbulb.fill")
                    }

                RoadmapView(model: model)
                    .tabItem {
                        Label("Roadmap", systemImage: "map.fill")
                    }
            }
            #endif
        }
    }

    // MARK: - Private Init
    private init() {}
}

#Preview("Mock data") {
    FeaturePortal.FeatureListView(model: FeaturePortalModel(useMockData: true))
}
