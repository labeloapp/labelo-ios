import SwiftUI
import ComposableArchitecture

struct ReadResultView: View {
    @Bindable var store: StoreOf<ReadResultFeature>

    var body: some View {
        Form {
            switch store.result {
            case .text(let text):
                Section("Text") {
                    Text(text)
                }
            case .url(let url):
                Section("URL") {
                    Button {
                        store.send(.open(url))
                    } label: {
                        Text(url.absoluteString)
                    }
                }
            case .tag(let tag):
                tagView(tag)
            case .empty:
                ContentUnavailableView("Tag is empty", systemImage: "radiowaves.right")
            default:
                ContentUnavailableView("Couldn't decode tag data", systemImage: "radiowaves.right")
            }
        }
    }

    @ViewBuilder
    private func tagView(_ tag: Tag) -> some View {
        Section("Tag") {
            LabeledContent("Name", value: tag.name)
            LabeledContent("Payload Type", value: tag.payloadType)
            switch tag.payload {
            case .text(let text):
                LabeledContent("Text", value: text)
            case .url(let url):
                LabeledContent("URL") {
                    Button {
                        store.send(.open(url))
                    } label: {
                        Text(url.absoluteString)
                    }
                }
            case .data(let data):
                LabeledContent("Data", value: "\(data.count) bytes")
            }
        }
    }
}
