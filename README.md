# FeaturePortal iOS SDK

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+%20%7C%20macOS%2014+-blue.svg)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The official iOS SDK for [FeaturePortal](https://featureportal.com) - a powerful feature request and roadmap management platform. Integrate beautiful, native feature request and roadmap views directly into your iOS or Mac app.

## Features

- **Native SwiftUI Interface**: Beautiful, pre-built UI components that match iOS design guidelines
- **Feature Requests**: Allow users to submit and vote on feature requests directly from your app
- **Public Roadmap**: Keep your users informed with an integrated roadmap view
- **Real-time Updates**: Automatically sync feature requests and roadmap items
- **Engagement Prompt**: Animated mascot that appears to active users at the right moment, with configurable thresholds, cooldowns, and opt-out support
- **Easy Integration**: Simple configuration with just a few lines of code

## Requirements

- iOS 17.0+ or macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add FeaturePortal to your project using Swift Package Manager:

1. In Xcode, select **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/FeaturePortal/featureportal-ios.git
   ```
3. Select the version rule (recommended: **Up to Next Major Version** with `1.0.0`)
4. Click **Add Package**

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/FeaturePortal/featureportal-ios.git", from: "1.0.0")
]
```

## Getting Started

### 1. Get Your API Key

Before integrating the SDK, you'll need to get your API key from FeaturePortal:

1. Sign up or log in at [featureportal.com](https://featureportal.com)
2. Create a new project or select an existing one
3. Navigate to **Settings → API Keys**
4. Copy your API key

For detailed instructions, visit the [FeaturePortal Documentation](https://featureportal.com/docs).

### 2. Configure the SDK

Import FeaturePortal in your app's main file and configure it with your API key:

```swift
import SwiftUI
import FeaturePortal

@main
struct YourApp: App {

    init() {
        // Configure FeaturePortal with your API key
        FeaturePortal.configure(apiKey: "your-api-key-here")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 3. Display the Feature Portal

Add the FeaturePortal view anywhere in your app:

```swift
import SwiftUI
import FeaturePortal

struct ContentView: View {
    var body: some View {
        FeaturePortal.FeatureListView()
    }
}
```

The `FeatureListView` includes a tabbed interface with:
- **Requests Tab**: View and submit feature requests
- **Roadmap Tab**: See what's planned, in progress, and completed

## Usage Examples

### Presenting as a Sheet

```swift
struct SettingsView: View {
    @State private var showFeaturePortal = false

    var body: some View {
        Button("Feature Requests & Roadmap") {
            showFeaturePortal = true
        }
        .sheet(isPresented: $showFeaturePortal) {
            FeaturePortal.FeatureListView()
        }
    }
}
```

### Presenting as a Navigation Destination

```swift
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Feature Requests") {
                    FeaturePortal.FeatureListView()
                }
            }
            .navigationTitle("Settings")
        }
    }
}
```

### In a Mac Window

On macOS, `FeatureListView` switches between Requests and Roadmap with a segmented control, and its toolbar (Refresh ⌘R, New ⌘N) goes in the window's toolbar:

```swift
@main
struct MyMacApp: App {
    var body: some Scene {
        // ...
        Window("Feature Requests", id: "feature-requests") {
            FeaturePortal.FeatureListView()
        }
    }
}
```

In an AppKit app (a menu bar app, for instance), host it in an `NSHostingController` and let its toolbar and title reach the window:

```swift
let host = NSHostingController(rootView: FeaturePortal.FeatureListView())
host.sceneBridgingOptions = [.toolbars, .title]
let window = NSWindow(contentViewController: host)
window.makeKeyAndOrderFront(nil)
```

### Standalone Tab

```swift
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            FeaturePortal.FeatureListView()
                .tabItem {
                    Label("Feature Requests", systemImage: "lightbulb")
                }
        }
    }
}
```

## Engagement Prompt

FeaturePortal includes an animated mascot that automatically appears to engaged users and invites them to submit feature requests. The prompt respects cooldown periods, annual caps, and user opt-out — it only shows when users are genuinely active.

### How It Works

The SDK tracks engagement signals across app sessions:

| Signal | What it tracks |
|--------|---------------|
| App launches | Total number of times the app has been opened |
| First launch date | How long the user has had the app |
| Significant events | Key actions you define (purchases, feature usage, etc.) |
| Recent sessions | Number of sessions within a rolling window |

The mascot appears only when **all** thresholds are met, the cooldown has passed, and the user has not opted out.

### Step 1 — Log App Launches

Call `FeaturePortal.logAppLaunch()` once per app launch, right after `configure()`:

```swift
@main
struct YourApp: App {
    init() {
        FeaturePortal.configure(apiKey: "your-api-key-here")
        FeaturePortal.logAppLaunch() // ← increment launch count & session timestamp
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

This call does two things:
- Increments the total app launch counter
- Records the current timestamp as a session, used to evaluate "recent activity"

On the very first call it also records the first-launch date, which gates the `minDaysSinceFirstLaunch` threshold.

### Step 2 — Log Significant Events

Call `FeaturePortal.logSignificantEvent()` when the user completes a meaningful action — you define what "significant" means for your app:

```swift
// After a purchase
FeaturePortal.logSignificantEvent()

// After finishing onboarding
FeaturePortal.logSignificantEvent()

// After using a core feature
FeaturePortal.logSignificantEvent()
```

### Step 3 — Add the Prompt Modifier

Apply `.featurePrompt()` to your root view. The modifier checks eligibility automatically on appear and whenever the app returns to the foreground:

```swift
struct ContentView: View {
    var body: some View {
        TabView {
            // ...
        }
        .featurePrompt()
    }
}
```

Customize the message and CTA text:

```swift
.featurePrompt(
    message: "Loving the app? Help us improve it!",
    ctaText: "Request a Feature"
)
```

Manually trigger the prompt (e.g. from a Settings screen), bypassing eligibility checks:

```swift
struct SettingsView: View {
    @State private var showPrompt = false

    var body: some View {
        Button("Give Feedback") {
            showPrompt = true
        }
        .featurePrompt(forceShow: $showPrompt)
    }
}
```

### Customizing Thresholds

Pass a `FeaturePromptConfiguration` to `configure()` to override the defaults:

```swift
FeaturePortal.configure(
    apiKey: "your-api-key-here",
    promptConfiguration: FeaturePromptConfiguration(
        minAppLaunchCount: 3,           // default: 5
        minDaysSinceFirstLaunch: 3,     // default: 7
        minSignificantEventCount: 1,    // default: 3
        minRecentSessionCount: 2,       // default: 3
        recentSessionWindowDays: 7,     // default: 14
        cooldownDays: 60,               // default: 30
        maxPromptsPerYear: 6            // default: 12
    )
)
```

Pass `nil` to disable the engagement prompt entirely:

```swift
FeaturePortal.configure(apiKey: "your-api-key-here", promptConfiguration: nil)
```

### Development & Testing

Reset all engagement data during development (e.g. on logout or in debug menus):

```swift
FeaturePortal.promptTrigger?.resetAllData()
```

Use the `forceShow` binding (see Step 3) to preview the mascot without waiting for thresholds to be met.

## Demo Project

This repository includes a demo project that showcases the SDK integration. To run the demo:

1. Clone this repository
2. Open `Demo/Demo.xcodeproj` in Xcode
3. Update the API key in `DemoApp.swift` with your own key
4. Build and run the project

The demo app demonstrates the basic integration and shows both the feature request and roadmap views in action.

## Read Feedback from AI Agents (MCP)

FeaturePortal runs a remote [MCP](https://modelcontextprotocol.io) server, so coding agents like Claude Code, Codex and Cursor can read your projects, feature requests, comments and roadmap while they work on your app.

1. Create a read-only API token in **Dashboard → [API Tokens](https://featureportal.com/dashboard/api-tokens)**. It starts with `fp_pat_` and is different from the project API key you pass to `FeaturePortal.configure(apiKey:)`.
2. Connect your agent, for example Claude Code:

```bash
claude mcp add --transport http featureportal https://featureportal.com/api/mcp \
  --header "Authorization: Bearer fp_pat_YOUR_TOKEN"
```

3. Ask things like *"What are the top requests for my app?"* or *"Summarize this month's feedback about sync and plan the implementation."*

Available tools: `list_projects`, `list_feedback`, `get_feedback`, `get_roadmap` and `get_project_stats`. See the [MCP documentation](https://featureportal.com/docs/mcp) for Codex, Cursor and other clients.

## Documentation

For more information about FeaturePortal and its features, visit:

- [Official Documentation](https://featureportal.com/docs)
- [API Reference](https://featureportal.com/docs/api)
- [Feature Portal Website](https://featureportal.com)

## Platform Support

| Platform | Status | Minimum Version |
|----------|--------|----------------|
| iOS | ✅ Fully Supported | iOS 17.0+ |
| macOS | ✅ Supported | macOS 14.0+ |
| visionOS | 🚧 Planned | TBD |

## Support

If you encounter any issues or have questions:

- Check the [Documentation](https://featureportal.com/docs)
- Open an issue on [GitHub](https://github.com/FeaturePortal/featureportal-ios/issues)
- Contact support at [featureportal.com](https://featureportal.com)

## License

This SDK is available under the MIT License. See the LICENSE file for more info.

---

Made with ❤️ by the FeaturePortal team
