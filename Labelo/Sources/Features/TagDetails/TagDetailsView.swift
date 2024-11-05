import SwiftUI
import ComposableArchitecture

struct TagDetailsView: View {
    @Bindable var store: StoreOf<TagDetailsFeature>

    var body: some View {
        Form {
            LabeledContent("Name", value: store.tag.name)
            LabeledContent("Payload Type", value: store.tag.payloadType)
            switch store.tag.payload {
            case .text(let text):
                LabeledContent("Text", value: text)
            case .url(let url):
                LabeledContent("URL", value: url.absoluteString)
            case .data(let data):
                LabeledContent("Data", value: "raw data")
            }
        }
    }
}

