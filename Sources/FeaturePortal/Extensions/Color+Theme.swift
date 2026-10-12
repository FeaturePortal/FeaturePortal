import SwiftUI

public extension Color {
    // MARK: - Primary Colors
    static let featurePortalPrimary = Color(red: 0.231, green: 0.510, blue: 0.965) // #3B82F6
    static let featurePortalSecondary = Color(red: 0.549, green: 0.318, blue: 0.969) // #8C51F7

    // MARK: - Accent Colors
    static let featurePortalOrange = Color(red: 0.976, green: 0.549, blue: 0.184) // #F98B2F
    static let featurePortalBlue = Color(red: 0.055, green: 0.647, blue: 0.914) // #0EA5E9
    static let featurePortalGreen = Color(red: 0.133, green: 0.698, blue: 0.298) // #22C55E
    static let featurePortalRed = Color(red: 0.937, green: 0.267, blue: 0.267) // #EF4444
    static let featurePortalPurple = Color(red: 0.651, green: 0.318, blue: 0.925) // #A651EC

    // MARK: - Surface Colors
    #if os(iOS)
    static let featurePortalCardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let featurePortalBackground = Color(uiColor: .systemGroupedBackground)
    static let featurePortalBorder = Color(uiColor: .separator)
    #elseif os(macOS)
    static let featurePortalCardBackground = Color(nsColor: .controlBackgroundColor)
    static let featurePortalBackground = Color(nsColor: .windowBackgroundColor)
    static let featurePortalBorder = Color(nsColor: .separatorColor)
    #else
    static let featurePortalCardBackground = Color.gray.opacity(0.1)
    static let featurePortalBackground = Color.gray.opacity(0.05)
    static let featurePortalBorder = Color.gray.opacity(0.2)
    #endif

    // MARK: - Tag Colors
    enum TagColor: String, CaseIterable {
        case blue = "BLUE"
        case red = "RED"
        case green = "GREEN"
        case purple = "PURPLE"
        case orange = "ORANGE"

        var color: Color {
            switch self {
            case .blue: return .featurePortalBlue
            case .red: return .featurePortalRed
            case .green: return .featurePortalGreen
            case .purple: return .featurePortalPurple
            case .orange: return .featurePortalOrange
            }
        }

        var lightColor: Color {
            color.opacity(0.15)
        }
    }
}

// MARK: - Shadow Styles
public extension View {
    func featurePortalCardShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 2
        )
    }

    func featurePortalButtonShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}
