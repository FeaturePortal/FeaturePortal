import SwiftUI

extension View {
    /// A button that draws its own label: on the Mac it would otherwise sit inside a system bezel (iOS draws none).
    @ViewBuilder
    func featurePortalPlainButton() -> some View {
        #if os(macOS)
        buttonStyle(.plain)
        #else
        self
        #endif
    }

    /// A menu that draws its own label: on the Mac it would otherwise stretch into a full-width pop-up button.
    @ViewBuilder
    func featurePortalPlainMenu() -> some View {
        #if os(macOS)
        menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
            .fixedSize()
        #else
        self
        #endif
    }
}
