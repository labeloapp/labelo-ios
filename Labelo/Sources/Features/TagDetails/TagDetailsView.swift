import SwiftUI
import ComposableArchitecture

struct TagDetailsView: View {
    @Bindable var store: StoreOf<TagDetailsFeature>

    var body: some View {
        List {
            Section("Tag") {
                LabeledContent("Name", value: store.tag.name)
                LabeledContent("Payload Type", value: store.tag.payloadType)
                switch store.tag.payload {
                case .text(let text):
                    LabeledContent("Text", value: text)
                case .url(let url):
                    LabeledContent("URL", value: url.absoluteString)
                case .data(let data):
                    LabeledContent("Data", value: "\(data.count) bytes")
                }
            }

            if !store.entries.isEmpty {
                Section("History") {
                    ForEach(store.entries) { entry in
                        Text("Read at \(entry.readAt.formatted(.dateTime))")
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            writeButton
        }
        .onAppear {
            store.send(.getHistory)
        }
    }

    private var writeButton: some View {
        Button {
            store.send(.didTapWriteButton)
        } label: {
            Label("WRITE TAG", systemImage: "radiowaves.right")
                .font(.body)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 60)
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 16)
    }
}

