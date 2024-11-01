import SwiftUI
import ComposableArchitecture

struct TagCreateView: View {
    @Bindable var store: StoreOf<TagCreateFeature>
    @FocusState var focus: TagCreateFeature.State.Field?

    var body: some View {
        Form {
            TextField("Name", text: $store.tag.name.sending(\.setName))
                .focused($focus, equals: .name)
                .errorMessage(store.isNameError ? "Name cannot be empty." : nil)
            Picker("Payload Type", selection: $store.type.sending(\.setPayload)) {
                ForEach(TagCreateFeature.PayloadType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            switch store.tag.payload {
            case .text(let text):
                TextField("Text", text: .init(get: {
                    text
                }, set: { newValue in
                    store.send(.setPayloadText(newValue))
                }))
                .focused($focus, equals: .text)
                .errorMessage(store.isPayloadError ? "Text cannot be empty." : nil)
            case .url(_):
                TextField("URL", text: .init(get: {
                    store.urlString
                }, set: { newValue in
                    store.send(.setPayloadURL(newValue))
                }))
                .keyboardType(.URL)
                .textContentType(.URL)
                .focused($focus, equals: .url)
                .errorMessage(store.isPayloadError ? "Not a valid URL." : nil)
            case .data(_):
                Text("Not Implemented")
            }

            Section {
                Button {
                    store.send(.writeButtonTapped)
                } label: {
                    HStack {
                        Spacer()
                        Label("WRITE TAG", systemImage: "radiowaves.right")
                            .font(.body)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}
