//
//  AddButton.swift
//  featureloop-ios-dev
//
//  Created by Tihomir Videnov on 10.11.24.
//

import SwiftUI

public struct AddButton: View {
    // MARK: - Properties
    @Environment(\.colorScheme) private var colorScheme
    let action: () -> Void
    
    // MARK: - Initialization
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .padding(.horizontal, .grid(5))
                .padding(.vertical, .grid(4))
                .background(Color.accentColor)
                .cornerRadius(.grid(4))
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.1),
                       radius: 3, x: 1, y: 3)
        }
        .featurePortalPlainButton()
        .accessibilityLabel("Add Feature Request")
        .accessibilityHint("Double tap to create a new feature request")
    }
}

#Preview {
    AddButton(action: {})
}
