import SwiftUI
import ComposableArchitecture

@main
struct LabeloApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TagListView(
                    store: Store(
                        initialState: TagListFeature.State()
                    ) {
                        TagListFeature()
                    }
                )
            }
        }
    }
}




