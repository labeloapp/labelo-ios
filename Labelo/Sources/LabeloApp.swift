import SwiftUI
import ComposableArchitecture

@main
struct LabeloApp: App {
    var body: some Scene {
        WindowGroup {
                TagListView(
                    store: Store(
                        initialState: TagListFeature.State()
                    ) {
                        TagListFeature()
#if DEBUG
                            ._printChanges()
#endif
                    }
                )
        }
    }
}




