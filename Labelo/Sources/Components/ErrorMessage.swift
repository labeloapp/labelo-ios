import SwiftUI

struct TextFieldError: ViewModifier {
    let errorMessage: String?

    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

extension View {
    func errorMessage(_ errorMessage: String?) -> some View {
        modifier(TextFieldError(errorMessage: errorMessage))
    }
}
